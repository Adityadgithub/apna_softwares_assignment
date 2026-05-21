import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/product_detail.dart';
import '../controllers/product_detail_controller.dart';
import '../widgets/detail_info_row.dart';
import '../widgets/empty_state.dart';

class ProductDetailPage extends GetView<ProductDetailController> {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorMessage.value != null) {
          return EmptyState(
            icon: Icons.info_outline_rounded,
            title: 'Product unavailable',
            subtitle: controller.errorMessage.value,
            action: TextButton.icon(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go back'),
            ),
          );
        }

        final item = controller.detail.value!;
        return _DetailBody(
          item: item,
          onFavorite: controller.toggleFavorite,
        );
      }),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.item, required this.onFavorite});

  final ProductDetail item;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows(item);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: Get.back,
          ),
          actions: [
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                item.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: item.isFavorite ? AppColors.accent : Colors.white,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _HeroImage(url: item.productImage),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.categoryName != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.categoryName!,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                _PriceRow(item: item),
                if (item.description != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: AppTheme.cardShadow,
                  child: Column(children: rows),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRows(ProductDetail d) {
    final rows = <Widget>[];

    void add(String label, String? value, {IconData? icon}) {
      if (value == null || value.isEmpty) return;
      if (rows.isNotEmpty) rows.add(const Divider(height: 1));
      rows.add(DetailInfoRow(label: label, value: value, icon: icon));
    }

    add('Product ID', d.id.toString(), icon: Icons.tag_rounded);
    add('Price', _money(d.price), icon: Icons.sell_rounded);
    add('MRP', _money(d.mrp), icon: Icons.payments_rounded);
    add('Purchase price', _money(d.purchasePrice));
    add('GST', d.gstName ?? (d.taxRate != null ? '${d.taxRate}%' : null));
    add('Tax rate', d.taxRate != null ? '${d.taxRate}%' : null);
    add('HSN code', d.hsnCode);
    add('Slug', d.slug);
    add('Status', d.status);
    add('Unit', d.unitName);
    add('Barcode', d.barcode);
    add(
      'Stock',
      d.currentStockCount?.toString(),
      icon: Icons.inventory_2_outlined,
    );
    add(
      'Out of stock',
      d.isOutOfStock == null ? null : (d.isOutOfStock! ? 'Yes' : 'No'),
    );
    add(
      'Manage stock',
      d.wantToManageStock == null ? null : (d.wantToManageStock! ? 'Yes' : 'No'),
    );
    add('Low stock alert', d.lowStockAlertQty?.toString());
    add('Created', d.createdAt);
    add('Updated', d.updatedAt);

    if (rows.isEmpty) {
      rows.add(
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No extra details available'),
        ),
      );
    }

    return rows;
  }

  String? _money(double? v) => v != null ? '₹${v.toStringAsFixed(2)}' : null;
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      child: url != null
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const _Placeholder(),
            )
          : const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: const Icon(
        Icons.inventory_2_rounded,
        size: 80,
        color: Colors.white54,
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.item});

  final ProductDetail item;

  @override
  Widget build(BuildContext context) {
    final price = item.price ?? item.mrp;

    return Row(
      children: [
        if (price != null)
          Text(
            '₹${price.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        if (item.mrp != null && item.price != null && item.mrp != item.price) ...[
          const SizedBox(width: 12),
          Text(
            'MRP ₹${item.mrp!.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
          ),
        ],
      ],
    );
  }
}
