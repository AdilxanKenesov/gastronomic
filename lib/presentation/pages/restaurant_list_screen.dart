import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/l10n/app_localizations.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/map_restaurant_card.dart';
import '../widgets/state_widgets.dart';
import '../widgets/shimmer_widgets.dart';
import '../../core/mixins/restaurant_navigation_mixin.dart';
import '../../domain/entities/restaurant.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/restaurant_bloc.dart';

class RestaurantListScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;

  const RestaurantListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
  });

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen>
    with RestaurantNavigationMixin {
  bool isListView = true;
  String _selectedFilter = "all";

  // --- Map state ---
  YandexMapController? _mapController;
  Restaurant? _selectedRestaurant;

  List<Restaurant> _mapRestaurants = [];
  bool _isLoadingMapData = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  void _loadRestaurants() {
    final settingsState = context.read<SettingsBloc>().state;
    context.read<RestaurantBloc>().add(
      LoadRestaurants(
        categoryId: widget.categoryId,
        brandId: widget.brandId,
        language: settingsState.apiLanguage,
      ),
    );
  }

  Future<void> _loadMapRestaurants() async {
    if (_mapRestaurants.isNotEmpty) return;

    setState(() => _isLoadingMapData = true);
    try {
      final settingsState = context.read<SettingsBloc>().state;
      final restaurants = await restaurantService.getRestaurantsForMap(
        categoryId: widget.categoryId,
        language: settingsState.apiLanguage,
      );

      if (mounted) {
        setState(() {
          _mapRestaurants = restaurants;
          _isLoadingMapData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMapData = false);
      }
    }
  }

  // ─── Filtered list helper ─────────────────────────────────────
  List<Restaurant> _getFilteredList(List<Restaurant> restaurants) {
    List<Restaurant> displayItems = List.from(restaurants);

    if (_selectedFilter == "top") {
      displayItems.sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));
    } else if (_selectedFilter == "open") {
      displayItems = displayItems.where((res) => res.isCurrentlyOpen).toList();
    }

    return displayItems;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(l10n),
          if (isListView) _buildFilterChips(l10n),
          Expanded(
            child: isListView ? _buildRestaurantListSection(l10n) : _buildMapSection(l10n),
          ),
        ],
      ),
    );
  }

  // ─── Header (photo app bar) ───────────────────────────────────
  Widget _buildHeader(AppLocalizations l10n) {
    final topPadding = MediaQuery.of(context).padding.top;
    final hasName = widget.brandName != null || widget.categoryName != null;
    final mainTitle = widget.brandName ?? widget.categoryName ?? l10n.translate('restaurants');

    return Container(
      height: 168 + topPadding,
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
            Image.asset('assets/img.png', fit: BoxFit.cover),
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
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _glassCircle(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        _viewToggle(),
                      ],
                    ),
                    const Spacer(),
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: hasName ? mainTitle : '${l10n.translate('restaurants')} ',
                            style: AppText.serif(fontSize: 30, color: Colors.white, height: 1.05),
                          ),
                          if (!hasName)
                            TextSpan(
                              text: l10n.translate('directory'),
                              style: AppText.serif(
                                fontSize: 30,
                                color: AppColors.accent,
                                fontStyle: FontStyle.italic,
                                height: 1.05,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    BlocBuilder<RestaurantBloc, RestaurantState>(
                      builder: (context, state) {
                        int count = 0;
                        if (state is RestaurantLoaded) {
                          count = _getFilteredList(state.restaurants).length;
                        }
                        return Text(
                          '$count ${l10n.translate('natija')}',
                          style: AppText.sans(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassCircle({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.8),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  /// List ⇄ Map segmented toggle (funksionallik saqlanadi).
  Widget _viewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleSeg(
            icon: Icons.view_agenda_outlined,
            active: isListView,
            onTap: () => setState(() {
              isListView = true;
              _selectedRestaurant = null;
            }),
          ),
          _toggleSeg(
            icon: Icons.map_outlined,
            active: !isListView,
            onTap: () {
              setState(() {
                isListView = false;
                _selectedRestaurant = null;
              });
              _loadMapRestaurants();
            },
          ),
        ],
      ),
    );
  }

  Widget _toggleSeg({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 40,
        height: 32,
        decoration: BoxDecoration(
          color: active ? AppColors.cream : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? AppColors.primary : Colors.white,
        ),
      ),
    );
  }

  // ─── Filter chips ─────────────────────────────────────────────
  Widget _buildFilterChips(AppLocalizations l10n) {
    final filters = <MapEntry<String, String>>[
      MapEntry('all', l10n.translate('filter_all')),
      MapEntry('open', l10n.translate('filter_open_now')),
      MapEntry('top', l10n.translate('filter_top_rated')),
    ];

    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final entry = filters[index];
          final selected = _selectedFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: AppText.sans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantListSection(AppLocalizations l10n) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoading) {
          return const SingleChildScrollView(
            child: RestaurantListShimmer(
              count: 4,
              imageHeight: 200,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }
        if (state is RestaurantError) {
          return ErrorState(onRetry: _loadRestaurants);
        }
        if (state is RestaurantLoaded) {
          final displayItems = _getFilteredList(state.restaurants);

          if (displayItems.isEmpty) {
            return const EmptyState();
          }

          return ListView.builder(
            itemCount: displayItems.length,
            padding: const EdgeInsets.only(top: 4, bottom: 20),
            itemBuilder: (context, index) {
              final restaurant = displayItems[index];
              preloadIfNeeded(restaurant);
              final displayRestaurant = getDisplayRestaurant(restaurant);
              return RestaurantCard(
                restaurant: displayRestaurant,
                onTap: () => navigateToRestaurant(displayRestaurant),
                imageHeight: 200,
                featuredLabel: index == 0 ? l10n.translate('editors_pick') : null,
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildMapSection(AppLocalizations l10n) {
    final restaurantsWithCoords = _mapRestaurants.where(
      (r) => r.latitude != null && r.longitude != null,
    ).toList();

    const nukusCenter = Point(latitude: 42.4619, longitude: 59.6166);

    return Stack(
      children: [
        YandexMap(
          onMapCreated: (controller) {
            _mapController = controller;
            if (restaurantsWithCoords.isNotEmpty) {
              _mapController?.moveCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: Point(
                      latitude: restaurantsWithCoords.first.latitude!,
                      longitude: restaurantsWithCoords.first.longitude!,
                    ),
                    zoom: 13,
                  ),
                ),
              );
            } else {
              _mapController?.moveCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: nukusCenter, zoom: 13),
                ),
              );
            }
          },
          mapObjects: _getMapObjects(restaurantsWithCoords),
          onMapTap: (_) {
            setState(() => _selectedRestaurant = null);
          },
          logoAlignment: const MapAlignment(
            horizontal: HorizontalAlignment.left,
            vertical: VerticalAlignment.bottom,
          ),
        ),
        if (_isLoadingMapData)
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        if (!_isLoadingMapData && restaurantsWithCoords.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off, size: 48, color: AppColors.iconSecondary),
                  const SizedBox(height: 12),
                  Text(
                    l10n.translate('no_restaurants_on_map'),
                    textAlign: TextAlign.center,
                    style: AppText.sans(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        if (_selectedRestaurant != null)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: _buildMapRestaurantCard(_selectedRestaurant!, l10n),
          ),
      ],
    );
  }

  List<MapObject> _getMapObjects(List<Restaurant> restaurants) {
    final List<MapObject> objects = [];

    for (final restaurant in restaurants) {
      if (restaurant.latitude != null && restaurant.longitude != null) {
        final isSelected = _selectedRestaurant?.id == restaurant.id;
        objects.add(
          PlacemarkMapObject(
            mapId: MapObjectId('res_${restaurant.id}'),
            point: Point(latitude: restaurant.latitude!, longitude: restaurant.longitude!),
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage('assets/images/restaurant.png'),
                scale: isSelected ? 0.5 : 0.3,
              ),
            ),
            opacity: 1.0,
            consumeTapEvents: true,
            onTap: (PlacemarkMapObject self, Point point) {
              _onMarkerTap(restaurant);
            },
          ),
        );
      }
    }
    return objects;
  }

  void _onMarkerTap(Restaurant restaurant) async {
    setState(() => _selectedRestaurant = restaurant);

    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: restaurant.latitude!, longitude: restaurant.longitude!),
          zoom: 15,
        ),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 0.5),
    );

    try {
      final settingsState = context.read<SettingsBloc>().state;
      final fullRestaurant = await restaurantService.getRestaurantDetail(
        id: restaurant.id,
        language: settingsState.apiLanguage,
      );

      if (mounted && _selectedRestaurant?.id == restaurant.id) {
        setState(() => _selectedRestaurant = fullRestaurant);
      }
    } catch (_) {
      // Xatolik bo'lsa oddiy ma'lumot bilan davom etamiz
    }
  }

  Widget _buildMapRestaurantCard(Restaurant restaurant, AppLocalizations l10n) {
    return MapRestaurantCard(
      restaurant: restaurant,
      onTap: () => navigateToRestaurant(restaurant),
      onClose: () => setState(() => _selectedRestaurant = null),
    );
  }
}
