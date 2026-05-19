import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/sync_action.dart';
import 'app_database.dart';

class SyncQueueLocalDataSource {
  SyncQueueLocalDataSource(this._db);

  final AppDatabase _db;

  Future<void> enqueue(int productId, bool add) async {
    final action =
        add ? AppConstants.syncActionAdd : AppConstants.syncActionRemove;

    await (_db.delete(_db.syncQueueTable)
          ..where(
            (t) =>
                t.productId.equals(productId) &
                t.status.equals('pending'),
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

  Future<List<SyncAction>> pending() async {
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

  Future<int> pendingCount() async {
    final rows = await (_db.select(_db.syncQueueTable)
          ..where((t) => t.status.equals('pending')))
        .get();
    return rows.length;
  }

  Future<void> markDone(int id) async {
    await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id))).write(
      const SyncQueueTableCompanion(status: Value('done')),
    );
  }

  Future<void> markFailed(int id, int retries) async {
    if (retries >= AppConstants.maxSyncRetries) {
      await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id)))
          .write(const SyncQueueTableCompanion(status: Value('failed')));
      return;
    }
    await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id))).write(
      SyncQueueTableCompanion(
        retryCount: Value(retries + 1),
      ),
    );
  }
}
