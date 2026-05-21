import 'package:drift/drift.dart';

import '../core/constants/app_constants.dart';
import 'database/app_database.dart';
import 'models/product_detail_model.dart';
import 'models/product_model.dart';
import 'models/sync_action.dart';

/// All local DB reads/writes (products, favorites, page cache, sync queue).
class LocalStore {
  LocalStore(this._db);

  final AppDatabase _db;

  // --- Products ---

  Future<void> saveProducts(List<ProductModel> products, int page) async {
    await _db.batch((batch) {
      for (final p in products) {
        batch.insert(
          _db.productsTable,
          ProductsTableCompanion.insert(
            id: Value(p.id),
            name: p.name,
            price: Value(p.price),
            mrp: Value(p.mrp),
            imageUrl: Value(p.imageUrl),
            categoryName: Value(p.categoryName),
            pageNumber: page,
            isFavoriteRemote: Value(p.isFavorite),
            rawJson: Value(p.rawJson),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<ProductModel>> getByPage(int page) async {
    final rows = await (_db.select(_db.productsTable)
          ..where((t) => t.pageNumber.equals(page))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    final favIds = await _favoriteIds();
    return rows
        .map((r) => _rowToModel(r, favIds.contains(r.id)))
        .toList();
  }

  Future<List<ProductModel>> getAllOrdered() async {
    final rows = await (_db.select(_db.productsTable)
          ..orderBy([
            (t) => OrderingTerm.asc(t.pageNumber),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .get();
    final favIds = await _favoriteIds();
    return rows.map((r) => _rowToModel(r, favIds.contains(r.id))).toList();
  }

  Future<List<ProductModel>> getFavorites() async {
    final favRows = await (_db.select(_db.favoritesTable)
          ..where((t) => t.isFavorite.equals(true)))
        .get();
    if (favRows.isEmpty) return [];

    final ids = favRows.map((e) => e.productId).toList();
    final rows = await (_db.select(_db.productsTable)
          ..where((t) => t.id.isIn(ids))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map((r) => _rowToModel(r, true)).toList();
  }

  Future<ProductDetailModel?> getDetailById(int id) async {
    final row = await (_db.select(_db.productsTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;

    final isFavorite = (await _favoriteIds()).contains(id);
    if (row.rawJson != null && row.rawJson!.isNotEmpty) {
      return ProductDetailModel.fromRawJson(row.rawJson!, isFavorite: isFavorite);
    }

    return ProductDetailModel(
      id: row.id,
      name: row.name,
      productImage: row.imageUrl,
      categoryName: row.categoryName,
      price: row.price,
      mrp: row.mrp,
      isFavorite: isFavorite,
    );
  }

  Future<bool> hasAny() async {
    final count = await _db.select(_db.productsTable).get();
    return count.isNotEmpty;
  }

  ProductModel _rowToModel(ProductsTableData r, bool isFavorite) {
    return ProductModel.fromDb(
      {
        'id': r.id,
        'name': r.name,
        'price': r.price,
        'mrp': r.mrp,
        'image_url': r.imageUrl,
        'category_name': r.categoryName,
        'page_number': r.pageNumber,
      },
      isFavorite: isFavorite,
    );
  }

  // --- Favorites ---

  Future<void> setFavorite(int productId, bool value) async {
    if (value) {
      await _db.into(_db.favoritesTable).insertOnConflictUpdate(
            FavoritesTableCompanion.insert(
              productId: Value(productId),
              isFavorite: const Value(true),
            ),
          );
    } else {
      await (_db.delete(_db.favoritesTable)
            ..where((t) => t.productId.equals(productId)))
          .go();
    }
  }

  Future<bool> isFavorite(int productId) async {
    final row = await (_db.select(_db.favoritesTable)
          ..where((t) => t.productId.equals(productId)))
        .getSingleOrNull();
    return row?.isFavorite ?? false;
  }

  Future<Set<int>> _favoriteIds() async {
    final rows = await (_db.select(_db.favoritesTable)
          ..where((t) => t.isFavorite.equals(true)))
        .get();
    return rows.map((e) => e.productId).toSet();
  }

  // --- Page cache ---

  Future<void> savePage(int page, int itemCount, int totalPages) async {
    await _db.into(_db.pageCachesTable).insertOnConflictUpdate(
          PageCachesTableCompanion.insert(
            page: Value(page),
            fetchedAt: DateTime.now(),
            itemCount: itemCount,
            totalPages: Value(totalPages),
          ),
        );
  }

  Future<int?> getTotalPages() async {
    final rows = await _db.select(_db.pageCachesTable).get();
    if (rows.isEmpty) return null;
    return rows.map((e) => e.totalPages).reduce((a, b) => a > b ? a : b);
  }

  Future<bool> hasPage(int page) async {
    final row = await (_db.select(_db.pageCachesTable)
          ..where((t) => t.page.equals(page)))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> isPageCacheValid(int page) async {
    final row = await (_db.select(_db.pageCachesTable)
          ..where((t) => t.page.equals(page)))
        .getSingleOrNull();
    if (row == null) return false;
    final age = DateTime.now().difference(row.fetchedAt);
    return age.inMinutes < AppConstants.cacheExpiryMinutes;
  }

  // --- Sync queue ---

  Future<void> enqueueSync(int productId, bool add) async {
    final action =
        add ? AppConstants.syncActionAdd : AppConstants.syncActionRemove;

    await (_db.delete(_db.syncQueueTable)
          ..where(
            (t) =>
                t.productId.equals(productId) & t.status.equals('pending'),
          ))
        .go();

    await _db.into(_db.syncQueueTable).insert(
          SyncQueueTableCompanion.insert(
            action: action,
            productId: productId,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<List<SyncAction>> pendingSync() async {
    final rows = await (_db.select(_db.syncQueueTable)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    return rows
        .map(
          (r) => SyncAction(
            id: r.id,
            action: r.action,
            productId: r.productId,
            retryCount: r.retryCount,
            status: r.status,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  Future<int> pendingSyncCount() async {
    final rows = await (_db.select(_db.syncQueueTable)
          ..where((t) => t.status.equals('pending')))
        .get();
    return rows.length;
  }

  Future<void> markSyncDone(int id) async {
    await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id))).write(
      const SyncQueueTableCompanion(status: Value('done')),
    );
  }

  Future<void> markSyncFailed(int id, int retries) async {
    if (retries >= AppConstants.maxSyncRetries) {
      await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id)))
          .write(const SyncQueueTableCompanion(status: Value('failed')));
      return;
    }
    await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id))).write(
      SyncQueueTableCompanion(retryCount: Value(retries + 1)),
    );
  }
}
