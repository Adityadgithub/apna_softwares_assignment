import '../../domain/entities/sync_action.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/local/sync_queue_local_ds.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl(this._queue);

  final SyncQueueLocalDataSource _queue;

  @override
  Future<List<SyncAction>> getPendingActions() => _queue.pending();

  @override
  Future<void> enqueueFavorite(int productId, bool add) {
    return _queue.enqueue(productId, add);
  }

  @override
  Future<int> pendingCount() => _queue.pendingCount();
}
