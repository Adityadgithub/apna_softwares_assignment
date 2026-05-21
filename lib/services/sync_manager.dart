import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../core/constants/app_constants.dart';
import '../data/local_store.dart';
import '../data/models/sync_action.dart';
import 'connectivity_service.dart';

enum SyncState { idle, syncing, failed }

class SyncManager extends GetxService {
  SyncManager({
    required LocalStore store,
    required ConnectivityService connectivity,
    Logger? logger,
  })  : _store = store,
        _connectivity = connectivity,
        _log = logger ?? Logger();

  final LocalStore _store;
  final ConnectivityService _connectivity;
  final Logger _log;

  final syncState = SyncState.idle.obs;
  final pendingCount = 0.obs;

  Future<void> refreshPendingCount() async {
    pendingCount.value = await _store.pendingSyncCount();
  }

  Future<void> processQueue() async {
    if (!await _connectivity.isOnline()) return;
    if (syncState.value == SyncState.syncing) return;

    syncState.value = SyncState.syncing;
    try {
      final actions = await _store.pendingSync();
      for (final action in actions) {
        await _processAction(action);
      }
      await refreshPendingCount();
      syncState.value = SyncState.idle;
    } catch (e) {
      _log.e('Sync failed: $e');
      syncState.value = SyncState.failed;
    }
  }

  Future<void> _processAction(SyncAction action) async {
    try {
      await _simulateRemoteSync(action);
      await _store.markSyncDone(action.id);
    } catch (e) {
      await _store.markSyncFailed(action.id, action.retryCount);
      _log.w('Action ${action.id} failed, retry ${action.retryCount + 1}');
    }
  }

  Future<void> _simulateRemoteSync(SyncAction action) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (action.action != AppConstants.syncActionAdd &&
        action.action != AppConstants.syncActionRemove) {
      throw Exception('Unknown action');
    }
  }
}
