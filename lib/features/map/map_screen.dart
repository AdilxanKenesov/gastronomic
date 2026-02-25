import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/map_restaurant_card.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/services/restaurant_service.dart';
import '../settings/bloc/settings_bloc.dart';
import '../restaurant_detail/restaurant_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  YandexMapController? _controller;
  final RestaurantService _restaurantService = RestaurantService();

  Restaurant? _selectedRestaurant;
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  // Nukus markazi (default)
  final Point _nukusCenter = const Point(latitude: 42.4619, longitude: 59.6166);

  @override
  void initState() {
    super.initState();
    _loadMapRestaurants();
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  Future<void> _loadMapRestaurants() async {
    try {
      final settingsState = context.read<SettingsBloc>().state;
      final restaurants = await _restaurantService.getRestaurantsForMap(
        language: settingsState.apiLanguage,
      );

      if (mounted) {
        setState(() {
          _restaurants = restaurants;
          _isLoading = false;
        });

        _moveCameraToInitialPosition();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        _moveCameraToInitialPosition();
      }
    }
  }

  void _moveCameraToInitialPosition() {
    if (_controller == null) return;

    // Koordinatalari bor restoranlarni topish
    final restaurantsWithCoords = _restaurants.where(
      (r) => r.latitude != null && r.longitude != null,
    ).toList();

    Point targetPoint;

    if (restaurantsWithCoords.isNotEmpty) {
      // Birinchi restoranга yo'naltirish
      targetPoint = Point(
        latitude: restaurantsWithCoords.first.latitude!,
        longitude: restaurantsWithCoords.first.longitude!,
      );
    } else {
      // Nukus markaziga yo'naltirish
      targetPoint = _nukusCenter;
    }

    _controller!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: targetPoint, zoom: 14),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
    );
  }

  List<MapObject> _getMapObjects() {
    final List<MapObject> objects = [];

    for (final restaurant in _restaurants) {
      if (restaurant.latitude != null && restaurant.longitude != null) {
        final isSelected = _selectedRestaurant?.id == restaurant.id;
        objects.add(
          PlacemarkMapObject(
            mapId: MapObjectId('restaurant_${restaurant.id}'),
            point: Point(
              latitude: restaurant.latitude!,
              longitude: restaurant.longitude!,
            ),
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

    _controller?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: restaurant.latitude!,
            longitude: restaurant.longitude!,
          ),
          zoom: 16,
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
      final fullRestaurant = await _restaurantService.getRestaurantDetail(
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

  void _navigateToRestaurant() {
    if (_selectedRestaurant != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailScreen(restaurant: _selectedRestaurant!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      bottomSheet: _selectedRestaurant != null
          ? Container(
              margin: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: MapRestaurantCard(
                restaurant: _selectedRestaurant!,
                onTap: _navigateToRestaurant,
                onClose: () => setState(() => _selectedRestaurant = null),
              ),
            )
          : null,
      body: Stack(
        children: [
          // Yandex Map
          YandexMap(
            onMapCreated: (controller) {
              _controller = controller;
              if (!_isLoading) {
                _moveCameraToInitialPosition();
              }
            },
            mapObjects: _getMapObjects(),
            onMapTap: (_) => setState(() => _selectedRestaurant = null),
            // Yandex logosini pastki chap burchakka ko'chirish
            logoAlignment: const MapAlignment(
              horizontal: HorizontalAlignment.left,
              vertical: VerticalAlignment.bottom,
            ),
          ),

          // Top bar with title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 16,
                left: 60,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 6, left: 16),
                child: Text(
                  l10n.translate('restaurants'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ),

          // Loading
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}