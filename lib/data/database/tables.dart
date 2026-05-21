import 'package:drift/drift.dart';

class ProductsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  RealColumn get price => real().nullable()();
  RealColumn get mrp => real().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get categoryName => text().nullable()();
  IntColumn get pageNumber => integer()();
  BoolColumn get isFavoriteRemote =>
      boolean().withDefault(const Constant(false))();
  TextColumn get rawJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FavoritesTable extends Table {
  IntColumn get productId => integer()();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {productId};
}

class PageCachesTable extends Table {
  IntColumn get page => integer()();
  DateTimeColumn get fetchedAt => dateTime()();
  IntColumn get itemCount => integer()();
  IntColumn get totalPages => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {page};
}

class SyncQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()();
  IntColumn get productId => integer()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
}
