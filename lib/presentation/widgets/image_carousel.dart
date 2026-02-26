import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final BorderRadius? borderRadius;
  final Duration autoScrollDuration;
  final bool showIndicators;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 180,
    this.borderRadius,
    this.autoScrollDuration = const Duration(seconds: 2),
    this.showIndicators = true,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (widget.imageUrls.length <= 1) return;

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (!mounted || _isUserInteracting) return;

      final nextPage = (_currentPage + 1) % widget.imageUrls.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onUserInteractionStart() {
    _isUserInteracting = true;
    _autoScrollTimer?.cancel();
  }

  void _onUserInteractionEnd() {
    _isUserInteracting = false;
    // 3 sekund kutib, keyin avtomatik aylanishni qayta boshlash
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isUserInteracting) {
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildPlaceholder();
    }

    if (widget.imageUrls.length == 1) {
      return _buildSingleImage(widget.imageUrls.first);
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          child: SizedBox(
            height: widget.height,
            child: GestureDetector(
              onPanDown: (_) => _onUserInteractionStart(),
              onPanEnd: (_) => _onUserInteractionEnd(),
              onPanCancel: () => _onUserInteractionEnd(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.imageUrls[index],
                    height: widget.height,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: widget.height,
                        color: AppColors.background,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),

        // Indicators
        if (widget.showIndicators && widget.imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSingleImage(String url) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      child: Image.network(
        url,
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: widget.height,
            color: AppColors.background,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      child: Container(
        height: widget.height,
        width: double.infinity,
        color: AppColors.background,
        child: const Icon(
          Icons.restaurant,
          size: 60,
          color: AppColors.iconSecondary,
        ),
      ),
    );
  }
}