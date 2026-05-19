import 'package:drift/drift.dart';

import 'app_database.dart';

class FavoriteLocalDataSource {
  FavoriteLocalDataSource(this._db);

  final AppDatabase _db;

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
}
