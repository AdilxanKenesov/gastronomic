import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantsForMapUseCase {
  final RestaurantRepository repository;
  GetRestaurantsForMapUseCase({required this.repository});

  Future<List<Restaurant>> call({
    int? categoryId,
    int? cityId,
    double? minRating,
    double? maxRating,
    String language = 'uz',
  }) => repository.getRestaurantsForMap(
    categoryId: categoryId, cityId: cityId,
    minRating: minRating, maxRating: maxRating, language: language,
  );
}