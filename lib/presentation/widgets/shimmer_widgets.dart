import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

/// Reusable shimmer base — wraps any widget with shimmer animation
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
    );
  }
}

Widget _shimmerWrap(Widget child) {
  return Shimmer.fromColors(
    baseColor: const Color(0xFFE0E6EF),
    highlightColor: const Color(0xFFF5F8FF),
    child: child,
  );
}

// ─── Category shimmer (horizontal list) ────────────────────────────────────
class CategoryListShimmer extends StatelessWidget {
  const CategoryListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: 3,
          itemBuilder: (context, index) => Container(
            width: 260,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: 120, height: 14, borderRadius: BorderRadius.circular(6)),
                    const SizedBox(height: 6),
                    _ShimmerBox(width: 80, height: 11, borderRadius: BorderRadius.circular(6)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Restaurant card shimmer ────────────────────────────────────────────────
class RestaurantCardShimmer extends StatelessWidget {
  final EdgeInsets margin;
  final double imageHeight;

  const RestaurantCardShimmer({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.imageHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      Container(
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _ShimmerBox(
                width: double.infinity,
                height: imageHeight,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            // Text area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 180, height: 18, borderRadius: BorderRadius.circular(6)),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 80, height: 14, borderRadius: BorderRadius.circular(6)),
                  const SizedBox(height: 10),
                  _ShimmerBox(width: double.infinity, height: 13, borderRadius: BorderRadius.circular(6)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders N restaurant card shimmers in a column
class RestaurantListShimmer extends StatelessWidget {
  final int count;
  final double imageHeight;
  final EdgeInsets margin;

  const RestaurantListShimmer({
    super.key,
    this.count = 3,
    this.imageHeight = 180,
    this.margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => RestaurantCardShimmer(margin: margin, imageHeight: imageHeight),
      ),
    );
  }
}

// ─── Menu grid shimmer (2-column) ───────────────────────────────────────────
class MenuGridShimmer extends StatelessWidget {
  final int count;

  const MenuGridShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: count,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(width: 70, height: 13, borderRadius: BorderRadius.circular(5)),
                      const SizedBox(height: 6),
                      _ShimmerBox(width: double.infinity, height: 13, borderRadius: BorderRadius.circular(5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Review card shimmer ─────────────────────────────────────────────────────
class ReviewCardShimmer extends StatelessWidget {
  const ReviewCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ShimmerBox(width: 42, height: 42, borderRadius: BorderRadius.all(Radius.circular(21))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 120, height: 14, borderRadius: BorderRadius.circular(5)),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 80, height: 11, borderRadius: BorderRadius.circular(5)),
                  const SizedBox(height: 10),
                  _ShimmerBox(width: double.infinity, height: 12, borderRadius: BorderRadius.circular(5)),
                  const SizedBox(height: 5),
                  _ShimmerBox(width: double.infinity * 0.7, height: 12, borderRadius: BorderRadius.circular(5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Review stats shimmer ────────────────────────────────────────────────────
class ReviewStatsShimmer extends StatelessWidget {
  const ReviewStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Big rating number block
            Column(
              children: [
                _ShimmerBox(width: 60, height: 48, borderRadius: BorderRadius.circular(8)),
                const SizedBox(height: 8),
                _ShimmerBox(width: 80, height: 16, borderRadius: BorderRadius.circular(5)),
                const SizedBox(height: 6),
                _ShimmerBox(width: 60, height: 12, borderRadius: BorderRadius.circular(5)),
              ],
            ),
            const SizedBox(width: 24),
            // Bars
            Expanded(
              child: Column(
                children: List.generate(5, (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      _ShimmerBox(width: 14, height: 12, borderRadius: BorderRadius.circular(3)),
                      const SizedBox(width: 6),
                      Expanded(child: _ShimmerBox(width: double.infinity, height: 8, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}