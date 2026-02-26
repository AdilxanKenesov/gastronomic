import '../entities/menu.dart';

abstract class MenuRepository {
  Future<RestaurantMenu> getRestaurantMenu({required int restaurantId, String language = 'uz'});
  Future<MenuItem> getMenuItemDetail({required int menuItemId, String language = 'uz'});
}