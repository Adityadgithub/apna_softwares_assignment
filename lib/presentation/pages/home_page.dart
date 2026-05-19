import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../services/sync_manager.dart';
import '../controllers/connectivity_controller.dart';
import '../controllers/product_controller.dart';
import '../widgets/app_page_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/list_loading.dart';
import '../widgets/product_tile.dart';
import '../widgets/status_banner.dart';

class HomePage extends GetView<ProductController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityController>();
    final syncManager = Get.find<SyncManager>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AppPageHeader(
            title: 'Products',
            subtitle: 'Browse your catalog offline or online',
            actions: [
              HeaderIconButton(
                icon: Icons.favorite_rounded,
                tooltip: 'Favorites',
                onPressed: () => Get.toNamed('/favorites'),
              ),
              HeaderIconButton(
                icon: Icons.refresh_rounded,
                tooltip: 'Refresh',
                onPressed: controller.refresh,
              ),
            ],
          ),
          Obx(() {
            if (controller.isLoading.value && controller.products.isEmpty) {
              return const SizedBox.shrink();
            }
            return StatusBanner(
              isOnline: connectivity.isOnline.value,
              syncState: syncManager.syncState.value,
              pendingCount: syncManager.pendingCount.value,
              dataLoadSource: controller.dataLoadSource.value,
            );
          }),
          Expanded(child: Obx(() => _buildBody(syncManager))),
        ],
      ),
    );
  }

  Widget _buildBody(SyncManager syncManager) {
    if (controller.isLoading.value && controller.products.isEmpty) {
      return const ListLoading();
    }

    if (controller.errorMessage.value != null && controller.products.isEmpty) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Couldn\'t load products',
        // subtitle: controller.errorMessage.value,
        action: FilledButton.icon(
          onPressed: controller.refresh,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    if (controller.products.isEmpty) {
      return const EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'No products yet',
        subtitle: 'Pull down to refresh or check your connection',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      onRefresh: controller.refresh,
      child: ListView.builder(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        itemCount: controller.products.length + (controller.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.products.length) {
            if (!controller.isLoadingMore.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.loadMore();
              });
            }
            return const PageLoader();
          }
          final product = controller.products[index];
          return ProductTile(
            product: product,
            onTap: () => Get.toNamed('/product/detail', arguments: product.id),
            onFavorite: () => controller.onFavoriteTap(product),
          );
        },
      ),
    );
  }
}
