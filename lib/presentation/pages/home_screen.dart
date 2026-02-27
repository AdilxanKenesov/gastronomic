import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/state_widgets.dart';
import '../../core/mixins/restaurant_navigation_mixin.dart';
import '../bloc/restaurant_bloc.dart';
import '../bloc/category_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../../domain/entities/restaurant.dart';
import 'restaurant_list_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RestaurantNavigationMixin {
  bool _showAllRestaurants = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = false;
  bool _isScrolledDown = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _loadCategories();

    _scrollController.addListener(() {
      if (_scrollController.offset > 40 && !_isScrolledDown) {
        setState(() => _isScrolledDown = true);
      } else if (_scrollController.offset <= 40 && _isScrolledDown) {
        setState(() => _isScrolledDown = false);
      }
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;
      });
    });
  }


  void _loadRestaurants() {
    final settingsState = context.read<SettingsBloc>().state;
    context.read<RestaurantBloc>().add(
      LoadRestaurants(language: settingsState.apiLanguage),
    );
  }

  void _loadCategories() {
    final settingsState = context.read<SettingsBloc>().state;
    context.read<CategoryBloc>().add(
      LoadCategories(language: settingsState.apiLanguage),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShrink = _isSearching || _isScrolledDown;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          _buildCustomAppBar(shouldShrink, l10n),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              children: [
                if (!_isSearching) ...[
                  const SizedBox(height: 20),
                  _buildHorizontalCategories(l10n),
                  _buildNearRestaurantsBanner(l10n),

                ],
                _buildRestaurantListSection(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Har bir kategoriya uchun rang juftligi (bg, title, subtitle)
  static const List<List<Color>> _categoryColors = [
    [AppColors.primaryLight, AppColors.primaryDark, AppColors.primary],
    [AppColors.orange, AppColors.textOnPrimary, AppColors.orangeLight],
    [AppColors.success, AppColors.textOnPrimary, AppColors.successLight],
    [Color(0xFF7C3AED), Colors.white, Color(0xFFDDD6FE)],
    [Color(0xFF0EA5E9), Colors.white, Color(0xFFBAE6FD)],
    [Color(0xFFEC4899), Colors.white, Color(0xFFFCE7F3)],
  ];

  Widget _buildHorizontalCategories(AppLocalizations l10n) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading || state is CategoryInitial) {
          return const SizedBox(
            height: 90,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (state is CategoryError) {
          return const SizedBox(height: 10);
        }

        if (state is CategoryLoaded && state.categories.isNotEmpty) {
          final categories = state.categories;
          return SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final colors = _categoryColors[index % _categoryColors.length];
                final bgColor = colors[0];
                final titleColor = colors[1];
                final subtitleColor = colors[2];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantListScreen(
                          categoryId: cat.id,
                          categoryName: cat.name,
                        ),
                      ),
                    ).then((_) => _loadRestaurants());
                  },
                  child: Container(
                    width: 260,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.card.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: _buildCategoryIcon(cat.icon, bgColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (cat.description != null &&
                                    cat.description!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    cat.description!,
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox(height: 10);
      },
    );
  }

  Widget _buildCategoryIcon(String? iconUrl, Color fallbackColor) {
    if (iconUrl != null && iconUrl.isNotEmpty) {
      return Image.network(
        iconUrl,
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, st) => Icon(
          Icons.restaurant_rounded,
          color: fallbackColor,
          size: 26,
        ),
      );
    }
    return Icon(Icons.restaurant_rounded, color: fallbackColor, size: 26);
  }

  Widget _buildCustomAppBar(bool shouldShrink, AppLocalizations l10n) {
    final topPadding = MediaQuery.of(context).padding.top;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: shouldShrink ? 125.0 + topPadding : 300.0 + topPadding,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildSearchBar(l10n),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: shouldShrink ? 0.0 : 1.0,
                  child: shouldShrink
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildLogosStack(),
                            _buildRestaurantsButton(l10n),
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

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 14.0),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (value) {
            final settingsState = context.read<SettingsBloc>().state;
            if (value.length >= 2) {
              context.read<RestaurantBloc>().add(
                SearchRestaurants(value, language: settingsState.apiLanguage),
              );
            } else if (value.isEmpty) {
              context.read<RestaurantBloc>().add(
                LoadRestaurants(language: settingsState.apiLanguage),
              );
            }
          },
          decoration: InputDecoration(
            hintText: l10n.translate('search_hint'),
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.iconPrimary, size: 24),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.iconSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                      setState(() => _isSearching = false);
                      _loadRestaurants();
                    },
                  )
                : null,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            filled: true,
            fillColor: AppColors.card,
          ),
        ),
      ),
    );
  }


  Widget _buildNearRestaurantsBanner(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 5, right: 15, left: 15),
              width: 373,
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  children: [
                    // Background gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF05C05F),
                            Color(0xFF03A04F),
                            Color(0xFF028040),
                          ],
                        ),
                      ),
                    ),
                    // Map pattern background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: MapPatternPainter(),
                      ),
                    ),
                    // Location markers
                    Positioned(
                      right: 30,
                      top: 40,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 80,
                      ),
                    ),
                    Positioned(
                      right: 80,
                      bottom: 30,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 50,
                      ),
                    ),
                    Positioned(
                      right: 150,
                      top: 80,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white.withValues(alpha: 0.25),
                        size: 40,
                      ),
                    ),
                    // Top gradient overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 110,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF05C05F),
                              const Color(0xCC05C05F),
                              const Color(0x0005C05F),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Text content
                    Positioned(
                      top: 20,
                      left: 20,
                      width: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('banner_text'),
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.33,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.map_outlined,
                                  color: Color(0xFF05C05F),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.translate('view_map'),
                                  style: const TextStyle(
                                    color: Color(0xFF05C05F),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Brand bo'yicha deduplicate qilingan restoranlar ro'yxatini qaytaradi.
  /// Har bir brand uchun faqat bitta restoran saqlanadi.
  /// Brand bo'lmagan restoranlar ham qo'shiladi.
  List<Restaurant> _getUniqueByBrand(List<Restaurant> restaurants) {
    final Map<int, Restaurant> brandMap = {};
    final List<Restaurant> noBrand = [];

    for (final restaurant in restaurants) {
      final brand = restaurant.brand;
      if (brand != null) {
        brandMap.putIfAbsent(brand.id, () => restaurant);
      } else {
        noBrand.add(restaurant);
      }
    }

    return [...brandMap.values, ...noBrand];
  }

  Widget _buildLogosStack() {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoaded && state.restaurants.isNotEmpty) {
          final uniqueRestaurants = _getUniqueByBrand(state.restaurants).take(10).toList();

          return SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 30),
              itemCount: uniqueRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = uniqueRestaurants[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      final brand = restaurant.brand;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantListScreen(
                            brandId: brand?.id,
                            brandName: brand?.name ?? restaurant.name,
                          ),
                        ),
                      ).then((_) => _loadRestaurants());
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(22.5),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19.5),
                        child: _buildRestaurantLogo(restaurant),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox(height: 70);
      },
    );
  }

  Widget _buildRestaurantLogo(Restaurant restaurant) {
    final logoUrl = restaurant.brand?.logoUrl;
    final coverUrl = restaurant.coverImageUrl;

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          if (coverUrl != null && coverUrl.isNotEmpty) {
            return Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => const Icon(
                Icons.restaurant,
                size: 35,
                color: AppColors.iconSecondary,
              ),
            );
          }
          return const Icon(
            Icons.restaurant,
            size: 35,
            color: AppColors.iconSecondary,
          );
        },
      );
    }

    if (coverUrl != null && coverUrl.isNotEmpty) {
      return Image.network(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.restaurant,
          size: 35,
          color: AppColors.iconSecondary,
        ),
      );
    }

    return const Icon(
      Icons.restaurant,
      size: 35,
      color: AppColors.iconSecondary,
    );
  }

  Widget _buildRestaurantsButton(AppLocalizations l10n) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RestaurantListScreen()),
        ).then((_) {
          _loadRestaurants();
        });
      },
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, color: AppColors.iconPrimary, size: 24),
            const SizedBox(width: 12),
            Text(
              l10n.translate('restaurants'),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantListSection(AppLocalizations l10n) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoading) {
          return const LoadingIndicator();
        }

        if (state is RestaurantError) {
          return ErrorState(onRetry: _loadRestaurants);
        }

        if (state is RestaurantLoaded) {
          List<Restaurant> restaurants = state.restaurants;

          restaurants.sort((a, b) {
            final ratingA = a.averageRating ?? 0;
            final ratingB = b.averageRating ?? 0;
            return ratingB.compareTo(ratingA);
          });

          final displayItems = _showAllRestaurants
              ? restaurants
              : restaurants.take(5).toList();

          if (displayItems.isEmpty) {
            return const EmptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isSearching)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 10),
                  child: Text(
                    l10n.translate('restaurants'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final restaurant = displayItems[index];
                  preloadIfNeeded(restaurant);
                  final displayRestaurant = getDisplayRestaurant(restaurant);
                  return RestaurantCard(
                    restaurant: displayRestaurant,
                    onTap: () => navigateToRestaurant(displayRestaurant),
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    showDivider: true,
                  );
                },
              ),
              if (!_showAllRestaurants && restaurants.length > 5)
                _buildAllRestaurantsButton(l10n),
              const SizedBox(height: 30),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildAllRestaurantsButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAllRestaurants = true;
        });
      },
      child: Container(
        height: 60,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            l10n.translate('all_restaurants'),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for map-like pattern background
class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw grid lines for map effect
    const spacing = 30.0;

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw some diagonal roads
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.8, size.height),
      roadPaint,
    );

    // Draw some circles for points of interest
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.4), 8, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.6), 6, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.75), 5, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}