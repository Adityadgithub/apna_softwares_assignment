import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/app_page_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/list_loading.dart';
import '../widgets/product_tile.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final FavoritesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<FavoritesController>();
    controller.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AppPageHeader(
            title: 'Favorites',
            subtitle: 'Products you\'ve saved for quick access',
            actions: [
              HeaderIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: Get.back,
              ),
              HeaderIconButton(
                icon: Icons.refresh_rounded,
                tooltip: 'Refresh',
                onPressed: controller.loadFavorites,
              ),
            ],
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.favorites.isEmpty) {
                return const ListLoading(itemCount: 4);
              }

              if (controller.favorites.isEmpty) {
                return EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'No favorites yet',
                  subtitle: 'Tap the heart on any product to save it here',
                  action: OutlinedButton.icon(
                    onPressed: Get.back,
                    icon: const Icon(Icons.storefront_rounded),
                    label: const Text('Browse products'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.card,
                onRefresh: controller.loadFavorites,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: controller.favorites.length,
                  itemBuilder: (context, index) {
                    final product = controller.favorites[index];
                    return ProductTile(
                      product: product,
                      onTap: () =>
                          Get.toNamed('/product/detail', arguments: product.id),
                      onFavorite: () => controller.onFavoriteTap(product),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
