import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.onFavorite,
    this.onTap,
  });

  final Product product;
  final VoidCallback onFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final price = product.price ?? product.mrp;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DecoratedBox(
        decoration: AppTheme.cardShadow,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        _ProductImage(url: product.imageUrl),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                              if (product.categoryName != null &&
                                  product.categoryName!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  product.categoryName!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              _PriceChip(price: price),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _FavoriteButton(
                  isFavorite: product.isFavorite,
                  onPressed: onFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCCFBF1), Color(0xFF99F6E4)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _PlaceholderIcon(),
            )
          : const _PlaceholderIcon(),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 32),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({this.price});

  final double? price;

  @override
  Widget build(BuildContext context) {
    final label = price != null ? '₹${price!.toStringAsFixed(0)}' : 'Price N/A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isFavorite
          ? AppColors.accent.withValues(alpha: 0.12)
          : AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? AppColors.accent : AppColors.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
