import 'package:get/get.dart';

import '../../services/connectivity_service.dart';
import '../../services/sync_manager.dart';

class ConnectivityController extends GetxController {
  final ConnectivityService _connectivity = Get.find();
  final SyncManager _syncManager = Get.find();

  final isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    isOnline.value = await _connectivity.isOnline();
    _connectivity.startListening();
    _connectivity.onStatusChange.listen((online) {
      isOnline.value = online;
      if (online) _syncManager.processQueue();
    });
    await _syncManager.refreshPendingCount();
    if (isOnline.value) await _syncManager.processQueue();
  }
}
