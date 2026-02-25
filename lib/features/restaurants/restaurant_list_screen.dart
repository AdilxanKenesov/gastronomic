import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/restaurant_card.dart';
import '../../core/widgets/map_restaurant_card.dart';
import '../../core/widgets/state_widgets.dart';
import '../../core/mixins/restaurant_navigation_mixin.dart';
import '../../data/models/restaurant_model.dart';
import '../settings/bloc/settings_bloc.dart';
import 'bloc/restaurant_bloc.dart';

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

  // Map uchun alohida restoranlar ro'yxati (koordinatalar bilan)
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

  // Xarita uchun restoranlarni yuklash (koordinatalar bilan)
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

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _filterOption(l10n.translate('all_restaurants'), Icons.reorder, "all"),
              _filterOption(l10n.translate('rating'), Icons.star_border, "top"),
              _filterOption(l10n.translate('open_restaurants'), Icons.door_front_door_outlined, "open"),
            ],
          ),
        );
      },
    );
  }

  Widget _filterOption(String title, IconData icon, String filterKey) {
    bool isSelected = _selectedFilter == filterKey;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.iconSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      onTap: () {
        setState(() => _selectedFilter = filterKey);
        Navigator.pop(context);
      },
    );
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: BlocBuilder<RestaurantBloc, RestaurantState>(
          builder: (context, state) {
            int count = 0;
            if (state is RestaurantLoaded) {
              count = _getFilteredList(state.restaurants).length;
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.brandName ?? widget.categoryName ?? l10n.translate('restaurants'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count ${l10n.translate('natija')}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textPrimary),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Toggle bar ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleItem(
                      l10n.translate('list_view'),
                      isListView,
                          () => setState(() {
                        isListView = true;
                        _selectedRestaurant = null;
                      }),
                    ),
                  ),
                  Expanded(
                    child: _buildToggleItem(
                      l10n.translate('view_on_map'),
                      !isListView,
                          () {
                        setState(() {
                          isListView = false;
                          _selectedRestaurant = null;
                        });
                        // Xarita uchun restoranlarni yuklash
                        _loadMapRestaurants();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Body: List or Map ────────────────────────────────
          Expanded(
            child: isListView ? _buildRestaurantListSection(l10n) : _buildMapSection(l10n),
          ),
        ],
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
          final displayItems = _getFilteredList(state.restaurants);

          if (displayItems.isEmpty) {
            return const EmptyState();
          }

          return ListView.builder(
            itemCount: displayItems.length,
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              final restaurant = displayItems[index];
              preloadIfNeeded(restaurant);
              final displayRestaurant = getDisplayRestaurant(restaurant);
              return RestaurantCard(
                restaurant: displayRestaurant,
                onTap: () => navigateToRestaurant(displayRestaurant),
                imageHeight: 200,
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildMapSection(AppLocalizations l10n) {
    // Koordinatalari bor restoranlarni filter qilish
    final restaurantsWithCoords = _mapRestaurants.where(
      (r) => r.latitude != null && r.longitude != null,
    ).toList();

    // Nukus markazi (default)
    const nukusCenter = Point(latitude: 42.4619, longitude: 59.6166);

    return Stack(
      children: [
        // ─── Yandex Map ─────────────────────────────────
        YandexMap(
          onMapCreated: (controller) {
            _mapController = controller;
            // Birinchi restoranga yoki Nukus markaziga focus
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
          // Yandex logosini pastki chap burchakka
          logoAlignment: const MapAlignment(
            horizontal: HorizontalAlignment.left,
            vertical: VerticalAlignment.bottom,
          ),
        ),

        // ─── Loading indicator ──────────────────────────
        if (_isLoadingMapData)
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),

        // ─── No restaurants message ─────────────────────
        if (!_isLoadingMapData && restaurantsWithCoords.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
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
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

        // ─── Selected restaurant bottom card ────────────
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

  // ─── Map markers ──────────────────────────────────────────────
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
                image: BitmapDescriptor.fromAssetImage('assets/images/marker.png'),
                scale: isSelected ? 0.7 : 0.5,
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
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 0.5,
      ),
    );

    // To'liq ma'lumotlarni yuklash
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

  // ─── Toggle item ──────────────────────────────────────────────
  Widget _buildToggleItem(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}