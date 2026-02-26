import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/restaurant.dart';
import '../../data/datasources/remote/restaurant_remote_datasource.dart';
import '../../presentation/bloc/settings_bloc.dart';
import '../../presentation/pages/restaurant_detail_screen.dart';

/// Restoran navigatsiya logikasini qayta ishlatish uchun mixin
/// DRY prinsipi - bir joyda yozib, ko'p joyda ishlatish
mixin RestaurantNavigationMixin<T extends StatefulWidget> on State<T> {
  final RestaurantRemoteDatasource restaurantService = RestaurantRemoteDatasource();
  final Map<int, Restaurant> loadedRestaurants = {};
  bool _isNavigating = false;

  /// Restoran detail ma'lumotlarini yuklash
  Future<void> loadRestaurantDetail(Restaurant restaurant) async {
    if (loadedRestaurants.containsKey(restaurant.id)) return;

    try {
      final settingsState = context.read<SettingsBloc>().state;
      final fullRestaurant = await restaurantService.getRestaurantDetail(
        id: restaurant.id,
        language: settingsState.apiLanguage,
      );

      if (mounted) {
        setState(() {
          loadedRestaurants[restaurant.id] = fullRestaurant;
        });
      }
    } catch (e) {
      // Production da log chiqarmaymiz
      assert(() {
        debugPrint('Error loading restaurant detail: $e');
        return true;
      }());
    }
  }

  /// Restoranga navigate qilish
  Future<void> navigateToRestaurant(Restaurant restaurant) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    try {
      // Agar allaqachon yuklangan bo'lsa
      final cached = loadedRestaurants[restaurant.id];
      if (cached != null) {
        _pushRestaurantScreen(cached);
        return;
      }

      // Yuklab navigate qilish
      final settingsState = context.read<SettingsBloc>().state;
      final loaded = await restaurantService.getRestaurantDetail(
        id: restaurant.id,
        language: settingsState.apiLanguage,
      );

      if (mounted) {
        loadedRestaurants[restaurant.id] = loaded;
        _pushRestaurantScreen(loaded);
      }
    } catch (e) {
      // Xatolik bo'lsa oddiy ma'lumot bilan navigate qilish
      if (mounted) {
        _pushRestaurantScreen(restaurant);
      }
    } finally {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    }
  }

  void _pushRestaurantScreen(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }

  /// Cached yoki original restoranni olish
  Restaurant getDisplayRestaurant(Restaurant restaurant) {
    return loadedRestaurants[restaurant.id] ?? restaurant;
  }

  /// Agar yuklanmagan bo'lsa, yuklashni boshlash
  void preloadIfNeeded(Restaurant restaurant) {
    if (!loadedRestaurants.containsKey(restaurant.id)) {
      loadRestaurantDetail(restaurant);
    }
  }
}