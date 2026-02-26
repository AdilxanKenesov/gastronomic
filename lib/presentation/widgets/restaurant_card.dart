import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../domain/entities/restaurant.dart';
import 'image_carousel.dart';

/// Reusable restaurant card widget
/// DRY prinsipi - bir widget, ko'p screen
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final EdgeInsets margin;
  final double imageHeight;
  final bool showDivider;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.imageHeight = 180,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ImageCarousel(
                imageUrls: restaurant.allImageUrls,
                height: imageHeight,
                borderRadius: BorderRadius.circular(16),
                autoScrollDuration: const Duration(seconds: 2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildName(),
                  const SizedBox(height: 6),
                  _buildRating(),
                  if (showDivider)
                    const Divider(
                      height: 16,
                      thickness: 0.8,
                      color: AppColors.divider,
                    ),
                  _buildAddressRow(l10n),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildName() {
    return Text(
      restaurant.name,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(Icons.star, color: AppColors.starRating, size: 18),
        const SizedBox(width: 4),
        Text(
          restaurant.averageRating?.toStringAsFixed(1) ?? '0.0',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          "(${restaurant.reviewsCount ?? 0})",
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: AppColors.iconPrimary,
          size: 20,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            restaurant.address ?? l10n.translate('address_not_specified'),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusChip(l10n),
      ],
    );
  }

  Widget _buildStatusChip(AppLocalizations l10n) {
    final isOpen = restaurant.isCurrentlyOpen;
    return Text(
      isOpen ? l10n.translate('open') : l10n.translate('closed'),
      style: TextStyle(
        fontSize: 13,
        color: isOpen ? AppColors.success : AppColors.error,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}