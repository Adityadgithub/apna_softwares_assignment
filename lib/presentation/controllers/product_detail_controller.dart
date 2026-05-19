import 'package:get/get.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/usecases/get_product_detail.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../services/sync_manager.dart';
import 'connectivity_controller.dart';
import 'favorites_controller.dart';
import 'product_controller.dart';

class ProductDetailController extends GetxController {
  final GetProductDetail _getDetail = Get.find();
  final ToggleFavorite _toggleFavorite = Get.find();
  final SyncManager _syncManager = Get.find();
  final ConnectivityController _connectivity = Get.find();

  late final int productId;

  final detail = Rxn<ProductDetail>();
  final isLoading = true.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    productId = Get.arguments as int;
    loadDetail();
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _getDetail(productId);
    if (result == null) {
      errorMessage.value = 'Product not found. Open it from the list first.';
    } else {
      detail.value = result;
    }
    isLoading.value = false;
  }

  Future<void> toggleFavorite() async {
    final current = detail.value;
    if (current == null) return;

    final next = !current.isFavorite;
    detail.value = current.copyWith(isFavorite: next);
    await _toggleFavorite(current.id, next);
    _syncLists(current.id, next);
    await _syncManager.refreshPendingCount();
    if (_connectivity.isOnline.value) {
      await _syncManager.processQueue();
    }
  }

  void _syncLists(int id, bool isFavorite) {
    if (Get.isRegistered<ProductController>()) {
      final home = Get.find<ProductController>();
      final i = home.products.indexWhere((e) => e.id == id);
      if (i >= 0) {
        home.products[i] = home.products[i].copyWith(isFavorite: isFavorite);
      }
    }
    if (Get.isRegistered<FavoritesController>()) {
      final fav = Get.find<FavoritesController>();
      if (isFavorite) {
        final d = detail.value;
        if (d != null && !fav.favorites.any((e) => e.id == id)) {
          fav.favorites.add(_toProduct(d));
        }
      } else {
        fav.favorites.removeWhere((e) => e.id == id);
      }
    }
  }

  Product _toProduct(ProductDetail d) {
    return Product(
      id: d.id,
      name: d.name,
      price: d.price,
      mrp: d.mrp,
      imageUrl: d.productImage,
      categoryName: d.categoryName,
      isFavorite: d.isFavorite,
    );
  }
}
