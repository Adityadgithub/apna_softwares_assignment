import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/product_detail_model.dart';
import '../../models/product_model.dart';
import 'app_database.dart';

class ProductLocalDataSource {
  ProductLocalDataSource(this._db);

  final AppDatabase _db;

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
        .map(
          (r) => ProductModel.fromDb(
            {
              'id': r.id,
              'name': r.name,
              'price': r.price,
              'mrp': r.mrp,
              'image_url': r.imageUrl,
              'category_name': r.categoryName,
              'page_number': r.pageNumber,
            },
            isFavorite: favIds.contains(r.id),
          ),
        )
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

    return rows
        .map(
          (r) => ProductModel.fromDb(
            {
              'id': r.id,
              'name': r.name,
              'price': r.price,
              'mrp': r.mrp,
              'image_url': r.imageUrl,
              'category_name': r.categoryName,
              'page_number': r.pageNumber,
            },
            isFavorite: favIds.contains(r.id),
          ),
        )
        .toList();
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

    return rows
        .map(
          (r) => ProductModel.fromDb(
            {
              'id': r.id,
              'name': r.name,
              'price': r.price,
              'mrp': r.mrp,
              'image_url': r.imageUrl,
              'category_name': r.categoryName,
              'page_number': r.pageNumber,
            },
            isFavorite: true,
          ),
        )
        .toList();
  }

  Future<ProductDetailModel?> getDetailById(int id) async {
    final row = await (_db.select(_db.productsTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;

    final isFavorite = (await _favoriteIds()).contains(id);
    if (row.rawJson != null && row.rawJson!.isNotEmpty) {
      return ProductDetailModel.fromRawJson(
        row.rawJson!,
        isFavorite: isFavorite,
      );
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

  Future<Set<int>> _favoriteIds() async {
    final rows = await (_db.select(_db.favoritesTable)
          ..where((t) => t.isFavorite.equals(true)))
        .get();
    return rows.map((e) => e.productId).toSet();
  }

  Future<bool> isPageCacheValid(int page) async {
    final row = await (_db.select(_db.pageCachesTable)
          ..where((t) => t.page.equals(page)))
        .getSingleOrNull();
    if (row == null) return false;
    final age = DateTime.now().difference(row.fetchedAt);
    return age.inMinutes < AppConstants.cacheExpiryMinutes;
  }
}
