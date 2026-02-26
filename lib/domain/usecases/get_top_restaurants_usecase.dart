import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetTopRestaurantsUseCase {
  final RestaurantRepository repository;
  GetTopRestaurantsUseCase({required this.repository});

  Future<List<Restaurant>> call({
    required int categoryId,
    int limit = 10,
    String language = 'uz',
  }) => repository.getTopRestaurantsByCategory(
    categoryId: categoryId, limit: limit, language: language,
  );
}