import 'package:get/get.dart';

import '../../data/api.dart';
import '../../data/database/app_database.dart';
import '../../data/local_store.dart';
import '../../data/product_repository.dart';
import '../../services/connectivity_service.dart';
import '../../services/sync_manager.dart';
import '../controllers/connectivity_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final db = AppDatabase();

    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<AppDatabase>(db, permanent: true);
    Get.lazyPut(() => LocalStore(db), fenix: true);
    Get.lazyPut(() => ProductApi(), fenix: true);

    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(
        api: Get.find(),
        store: Get.find(),
        connectivity: Get.find(),
      ),
      fenix: true,
    );

    Get.put<SyncManager>(
      SyncManager(
        store: Get.find<LocalStore>(),
        connectivity: Get.find<ConnectivityService>(),
      ),
      permanent: true,
    );
    Get.put(ConnectivityController(), permanent: true);
  }
}
