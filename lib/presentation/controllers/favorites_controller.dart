import 'package:get/get.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../services/sync_manager.dart';
import 'connectivity_controller.dart';
import 'product_controller.dart';

class FavoritesController extends GetxController {
  final GetFavorites _getFavorites = Get.find();
  final ToggleFavorite _toggleFavorite = Get.find();
  final SyncManager _syncManager = Get.find();
  final ConnectivityController _connectivity = Get.find();

  final favorites = <Product>[].obs;
  final isLoading = false.obs;

  Future<void> loadFavorites() async {
    isLoading.value = true;
    favorites.assignAll(await _getFavorites());
    isLoading.value = false;
  }

  Future<void> onFavoriteTap(Product product) async {
    await _toggleFavorite(product.id, false);
    favorites.removeWhere((e) => e.id == product.id);
    _syncHomeProduct(product.id);
    await _syncManager.refreshPendingCount();
    if (_connectivity.isOnline.value) {
      await _syncManager.processQueue();
    }
  }

  void _syncHomeProduct(int productId) {
    if (!Get.isRegistered<ProductController>()) return;
    final home = Get.find<ProductController>();
    final i = home.products.indexWhere((e) => e.id == productId);
    if (i >= 0) {
      home.products[i] = home.products[i].copyWith(isFavorite: false);
    }
  }
}
