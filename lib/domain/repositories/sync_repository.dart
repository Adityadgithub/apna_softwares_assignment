import '../entities/sync_action.dart';

abstract class SyncRepository {
  Future<List<SyncAction>> getPendingActions();

  Future<void> enqueueFavorite(int productId, bool add);

  Future<int> pendingCount();
}
