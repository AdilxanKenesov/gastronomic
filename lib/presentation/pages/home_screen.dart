import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/l10n/app_localizations.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/state_widgets.dart';
import '../widgets/shimmer_widgets.dart';
import '../widgets/animated_entrance.dart';
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

  /// Ekran birinchi ochilganda kontent o'ngdan suzib chiqadi (kirish
  /// animatsiyasi). Bu oyna yopilgach (true bo'lgach) keyingi qayta yuklashlar
  /// — masalan, detal ekranidan qaytganda — animatsiyasiz, darhol ko'rsatiladi.
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _loadCategories();

    // Birinchi "kirish" animatsiyasi uchun oyna; tugagach o'chiramiz.
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _revealed = true);
    });

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
      LoadCategories(language: settingsState.categoryApiLanguage),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Kirish oynasi ochiq bo'lsa, [child]ni o'ngdan suzib kiruvchi animatsiyaga
  /// o'raydi; aks holda o'zgarishsiz qaytaradi. [delayMs] — staggered effekt.
  Widget _reveal(Widget child, {int delayMs = 0}) {
    if (_revealed) return child;
    return AnimatedEntrance(
      delay: Duration(milliseconds: delayMs),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShrink = _isSearching || _isScrolledDown;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(shouldShrink, l10n),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                if (!_isSearching) ...[
                  const SizedBox(height: 22),
                  _buildBrandRail(l10n),
                  const SizedBox(height: 16),
                  _buildCategoryChips(l10n),
                  const SizedBox(height: 26),
                  _reveal(_buildPromoCard(l10n), delayMs: 120),
                  const SizedBox(height: 8),
                ],
                _buildRestaurantListSection(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────
  Widget _buildAppBar(bool shrink, AppLocalizations l10n) {
    final topPadding = MediaQuery.of(context).padding.top;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      height: (shrink ? 112.0 : 226.0) + topPadding,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Restoran fotosi (fon)
            Image.asset('assets/img.png', fit: BoxFit.cover),
            // Gradient qoplama
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.appBarOverlay,
                  stops: AppColors.appBarOverlayStops,
                ),
              ),
            ),
            // Kontent
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: shrink ? 0.0 : 1.0,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: shrink
                              ? const SizedBox.shrink()
                              : _reveal(_buildTitle(l10n), delayMs: 80),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _reveal(_buildSearchBar(l10n), delayMs: 160),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    TextStyle base(Color c, {FontStyle style = FontStyle.normal}) => AppText.serif(
          fontSize: 34,
          color: c,
          fontStyle: style,
          height: 1.06,
        );
    return RichText(
      maxLines: 2,
      text: TextSpan(
        children: [
          TextSpan(text: '${l10n.translate('home_title_1')} ', style: base(Colors.white)),
          TextSpan(
            text: l10n.translate('home_title_accent'),
            style: base(AppColors.accent, style: FontStyle.italic),
          ),
          TextSpan(text: l10n.translate('home_title_2'), style: base(Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    final hasText = _searchController.text.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: AppText.sans(fontSize: 14.5, color: AppColors.textPrimary),
              onChanged: (value) {
                setState(() {}); // trailing tugmani yangilash uchun
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
                isCollapsed: true,
                hintText: l10n.translate('search_hint'),
                hintStyle: AppText.sans(color: AppColors.textHint, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (hasText) {
                _searchController.clear();
                _searchFocusNode.unfocus();
                setState(() => _isSearching = false);
                _loadRestaurants();
              } else {
                _searchFocusNode.unfocus();
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasText ? Icons.close_rounded : Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section header (overline + serif title + action) ─────────
  Widget _sectionHeader({
    required String overline,
    required String title,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(overline, style: AppText.overline()),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppText.serif(fontSize: 26, color: AppColors.textPrimary, height: 1.0),
                ),
              ],
            ),
          ),
          if (onAction != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Text(
                actionLabel ?? _seeAllLabel,
                style: AppText.sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // helper to avoid passing l10n into _sectionHeader for default label
  String get _seeAllLabel => AppLocalizations.of(context).translate('see_all');

  // ─── Brand rail (Top kitchens) ────────────────────────────────
  Widget _buildBrandRail(AppLocalizations l10n) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoaded && state.restaurants.isNotEmpty) {
          final unique = _getUniqueByBrand(state.restaurants).take(10).toList();
          return _reveal(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                  overline: l10n.translate('featured'),
                  title: l10n.translate('top_kitchens'),
                  onAction: () => _openAllRestaurants(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 118,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                    itemCount: unique.length,
                    itemBuilder: (context, index) => _buildBrandItem(unique[index]),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBrandItem(Restaurant restaurant) {
    final name = restaurant.brand?.name ?? restaurant.name;
    return GestureDetector(
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
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(child: _buildRestaurantLogo(restaurant)),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppText.sans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Categories (chip: icon + name) ───────────────────────────
  Widget _buildCategoryChips(AppLocalizations l10n) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading || state is CategoryInitial) {
          return const CategoryListShimmer();
        }
        if (state is CategoryLoaded && state.categories.isNotEmpty) {
          final categories = state.categories;
          return _reveal(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                  overline: l10n.translate('explore'),
                  title: l10n.translate('categories'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 46,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) => _buildCategoryChip(categories[index]),
                  ),
                ),
              ],
            ),
            delayMs: 60,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoryChip(Category cat) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 18, height: 18, child: _buildCategoryIcon(cat.icon)),
              const SizedBox(width: 8),
              Text(
                cat.name,
                style: AppText.sans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String? iconUrl) {
    if (iconUrl != null && iconUrl.isNotEmpty) {
      return Image.network(
        iconUrl,
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, st) => const Icon(
          Icons.restaurant_rounded,
          color: AppColors.primary,
          size: 18,
        ),
      );
    }
    return const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 18);
  }

  // ─── Promo card (Restaurants near you → Map) ───────────────────
  Widget _buildPromoCard(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        },
        child: Container(
          height: 152,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.brandGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: MapPatternPainter())),
                Positioned(
                  right: -10,
                  top: 20,
                  child: Icon(
                    Icons.location_on,
                    size: 110,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${l10n.translate('restaurants')} ',
                              style: AppText.serif(fontSize: 25, color: Colors.white, height: 1.1),
                            ),
                            TextSpan(
                              text: l10n.translate('near_you'),
                              style: AppText.serif(
                                fontSize: 25,
                                color: AppColors.accent,
                                fontStyle: FontStyle.italic,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.map_outlined, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              l10n.translate('view_map'),
                              style: AppText.sans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
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
    );
  }

  // ─── Restaurant list ──────────────────────────────────────────
  void _openAllRestaurants() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RestaurantListScreen()),
    ).then((_) => _loadRestaurants());
  }

  /// Brand bo'yicha deduplicate qilingan restoranlar ro'yxatini qaytaradi.
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
                size: 30,
                color: AppColors.iconSecondary,
              ),
            );
          }
          return const Icon(Icons.restaurant, size: 30, color: AppColors.iconSecondary);
        },
      );
    }

    if (coverUrl != null && coverUrl.isNotEmpty) {
      return Image.network(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.restaurant, size: 30, color: AppColors.iconSecondary),
      );
    }

    return const Icon(Icons.restaurant, size: 30, color: AppColors.iconSecondary);
  }

  Widget _buildRestaurantListSection(AppLocalizations l10n) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                child: Container(
                  width: 150,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const RestaurantListShimmer(count: 3),
            ],
          );
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

          final displayItems =
              _showAllRestaurants ? restaurants : restaurants.take(5).toList();

          if (displayItems.isEmpty) {
            return const EmptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isSearching)
                _reveal(
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 6),
                    child: Text(
                      l10n.translate('restaurants'),
                      style: AppText.serif(fontSize: 26, color: AppColors.textPrimary),
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
                  return _reveal(
                    RestaurantCard(
                      restaurant: displayRestaurant,
                      onTap: () => navigateToRestaurant(displayRestaurant),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    delayMs: (index * 70).clamp(0, 500),
                  );
                },
              ),
              if (!_showAllRestaurants && restaurants.length > 5)
                _buildAllRestaurantsButton(l10n),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildAllRestaurantsButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => setState(() => _showAllRestaurants = true),
      child: Container(
        height: 56,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            l10n.translate('all_restaurants'),
            style: AppText.sans(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
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
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
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

    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.4), 8, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.6), 6, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.75), 5, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
