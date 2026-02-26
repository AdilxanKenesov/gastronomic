import '../entities/menu.dart';
import '../repositories/menu_repository.dart';

class GetRestaurantMenuUseCase {
  final MenuRepository repository;
  GetRestaurantMenuUseCase({required this.repository});

  Future<RestaurantMenu> call({required int restaurantId, String language = 'uz'}) =>
      repository.getRestaurantMenu(restaurantId: restaurantId, language: language);
}