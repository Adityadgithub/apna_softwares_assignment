import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/data_load_source.dart';
import '../../data/models/product.dart';
import '../../data/product_repository.dart';
import '../../services/pagination_manager.dart';
import '../../services/sync_manager.dart';
import 'connectivity_controller.dart';
import 'favorites_controller.dart';

class ProductController extends GetxController {
  final ProductRepository _repo = Get.find();
  final SyncManager _syncManager = Get.find();
  final ConnectivityController _connectivity = Get.find();

  final products = <Product>[].obs;
  final dataLoadSource = Rxn<DataLoadSource>();
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final scrollController = ScrollController();

  final _pagination = PaginationManager();
  bool _usedApiThisSession = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadInitial();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadInitial() async {
    _pagination.reset();
    _usedApiThisSession = false;
    products.clear();
    await _loadPage(1, initial: true);
  }

  @override
  Future<void> refresh() async {
    _pagination.reset();
    _usedApiThisSession = false;
    products.clear();
    await _loadPage(1, initial: true, forceRefresh: true);
  }

  Future<void> _loadPage(
    int page, {
    bool initial = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _pagination.loadedPages.contains(page)) return;
    if (_pagination.isLoading) return;

    if (initial) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    _pagination.startLoading();
    errorMessage.value = null;

    try {
      final items = await _repo.getProducts(
        page: page,
        forceRefresh: forceRefresh,
      );
      final totalPages = await _repo.getTotalPages();

      if (page == 1 && items.length > 10) {
        products.assignAll(items);
      } else {
        final ids = products.map((e) => e.id).toSet();
        for (final item in items) {
          if (!ids.contains(item.id)) products.add(item);
        }
      }

      _pagination.onPageLoaded(page, totalPages);
      _updateDataLoadBanner();
    } on AppException catch (e) {
      errorMessage.value = e.message;
      _pagination.stopLoading();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> loadMore() async {
    if (!_pagination.canLoadMore()) return;
    await _loadPage(_pagination.nextPage());
  }

  Future<void> onFavoriteTap(Product product) async {
    final next = !product.isFavorite;
    final i = products.indexWhere((e) => e.id == product.id);
    if (i >= 0) products[i] = product.copyWith(isFavorite: next);
    if (Get.isRegistered<FavoritesController>()) {
      final fav = Get.find<FavoritesController>();
      if (next) {
        if (!fav.favorites.any((e) => e.id == product.id)) {
          fav.favorites.add(product.copyWith(isFavorite: true));
        }
      } else {
        fav.favorites.removeWhere((e) => e.id == product.id);
      }
    }
    await _repo.toggleFavorite(product.id, next);
    await _syncManager.refreshPendingCount();
    if (_connectivity.isOnline.value) {
      await _syncManager.processQueue();
    }
  }

  bool get hasMore => _pagination.hasMore;

  void _updateDataLoadBanner() {
    if (_repo.lastLoadSource == DataLoadSource.api) {
      _usedApiThisSession = true;
    }
    dataLoadSource.value = _usedApiThisSession
        ? DataLoadSource.api
        : DataLoadSource.localCache;
  }
}
