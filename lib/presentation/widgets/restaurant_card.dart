import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
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

  /// API mosligi uchun saqlangan (vizual jihatdan ishlatilmaydi).
  final bool showDivider;

  /// Ixtiyoriy "EDITOR'S PICK" pill (rasm ustida, chap-yuqorida).
  final String? featuredLabel;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.imageHeight = 180,
    this.showDivider = false,
    this.featuredLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = _buildSubtitle();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Rasm + ustki chiplar ──────────────────────────────
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  ImageCarousel(
                    imageUrls: restaurant.allImageUrls,
                    height: imageHeight,
                    borderRadius: BorderRadius.circular(14),
                    autoScrollDuration: const Duration(seconds: 2),
                  ),
                  if (featuredLabel != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _featuredPill(featuredLabel!),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _statusChip(l10n),
                  ),
                ],
              ),
            ),

            // ── Matn qismi ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _buildName()),
                      const SizedBox(width: 10),
                      _ratingPill(),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppText.sans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  _buildAddressRow(l10n),
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
      style: AppText.serif(fontSize: 23, color: AppColors.textPrimary, height: 1.1),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Krem fonli yulduzcha pill: ⭐ 4.8 (312)
  Widget _ratingPill() {
    final rating = restaurant.averageRating;
    if (rating == null || rating == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.starRating, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppText.sans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Glassmorphism Open/Closed chip (rasm ustida).
  Widget _statusChip(AppLocalizations l10n) {
    final isOpen = restaurant.isCurrentlyOpen;
    final dotColor = isOpen ? AppColors.success : AppColors.error;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                isOpen ? l10n.translate('open') : l10n.translate('closed'),
                style: AppText.sans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// EDITOR'S PICK uslubidagi to'q pill.
  Widget _featuredPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppText.overline(color: AppColors.accent, fontSize: 10),
      ),
    );
  }

  Widget _buildAddressRow(AppLocalizations l10n) {
    final distance = restaurant.distance;
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: AppColors.iconSecondary,
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            restaurant.address ?? l10n.translate('address_not_specified'),
            style: AppText.sans(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (distance != null) ...[
          const SizedBox(width: 8),
          Text(
            '·  ${distance.toStringAsFixed(1)} km',
            style: AppText.sans(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// Brend tavsifi + kategoriya (· bilan birlashtirilgan, 1 qator).
  String? _buildSubtitle() {
    final List<String> parts = [];
    final brand = restaurant.brand;
    final desc = (brand?.description?.isNotEmpty ?? false)
        ? brand!.description!
        : (restaurant.description?.isNotEmpty ?? false)
            ? restaurant.description!
            : null;
    if (desc != null) parts.add(desc);
    final categoryName = restaurant.category?.name;
    if (categoryName != null && categoryName.isNotEmpty) parts.add(categoryName);
    if (parts.isEmpty) return null;
    return parts.join('  ·  ');
  }
}
