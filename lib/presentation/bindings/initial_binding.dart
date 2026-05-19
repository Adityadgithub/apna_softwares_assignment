import 'package:get/get.dart';

import '../../core/network/dio_client.dart';
import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/local/favorite_local_ds.dart';
import '../../data/datasources/local/page_cache_local_ds.dart';
import '../../data/datasources/local/product_local_ds.dart';
import '../../data/datasources/local/sync_queue_local_ds.dart';
import '../../data/datasources/remote/product_remote_ds.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/get_product_detail.dart';
import '../../domain/usecases/get_products_page.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../services/connectivity_service.dart';
import '../../services/sync_manager.dart';
import '../controllers/connectivity_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final dioClient = DioClient();
    final db = AppDatabase();

    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<AppDatabase>(db, permanent: true);

    Get.lazyPut(() => ProductRemoteDataSource(dioClient.dio), fenix: true);
    Get.lazyPut(() => ProductLocalDataSource(db), fenix: true);
    Get.lazyPut(() => FavoriteLocalDataSource(db), fenix: true);
    Get.lazyPut(() => PageCacheLocalDataSource(db), fenix: true);
    Get.lazyPut(() => SyncQueueLocalDataSource(db), fenix: true);

    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(
        remote: Get.find(),
        local: Get.find(),
        favorites: Get.find(),
        pageCache: Get.find(),
        syncQueue: Get.find(),
        connectivity: Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut<SyncRepository>(
      () => SyncRepositoryImpl(Get.find<SyncQueueLocalDataSource>()),
      fenix: true,
    );

    Get.lazyPut(() => GetProductsPage(Get.find()), fenix: true);
    Get.lazyPut(() => GetFavorites(Get.find()), fenix: true);
    Get.lazyPut(() => GetProductDetail(Get.find()), fenix: true);
    Get.lazyPut(() => ToggleFavorite(Get.find()), fenix: true);
    Get.put<SyncManager>(
      SyncManager(
        queue: Get.find<SyncQueueLocalDataSource>(),
        connectivity: Get.find<ConnectivityService>(),
      ),
      permanent: true,
    );
    Get.put(ConnectivityController(), permanent: true);
  }
}
