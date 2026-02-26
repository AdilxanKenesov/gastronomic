import '../../domain/repositories/menu_repository.dart';
import '../../domain/entities/menu.dart';
import '../datasources/remote/menu_remote_datasource.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDatasource datasource;

  MenuRepositoryImpl({required this.datasource});

  @override
  Future<RestaurantMenu> getRestaurantMenu({required int restaurantId, String language = 'uz'}) =>
      datasource.getRestaurantMenu(restaurantId: restaurantId, language: language);

  @override
  Future<MenuItem> getMenuItemDetail({required int menuItemId, String language = 'uz'}) =>
      datasource.getMenuItemDetail(menuItemId: menuItemId, language: language);
}