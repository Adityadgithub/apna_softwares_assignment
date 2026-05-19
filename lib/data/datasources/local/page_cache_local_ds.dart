import 'package:drift/drift.dart';

import 'app_database.dart';

class PageCacheLocalDataSource {
  PageCacheLocalDataSource(this._db);

  final AppDatabase _db;

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

  Future<List<int>> cachedPages() async {
    final rows = await (_db.select(_db.pageCachesTable)
          ..orderBy([(t) => OrderingTerm.asc(t.page)]))
        .get();
    return rows.map((e) => e.page).toList();
  }
}
