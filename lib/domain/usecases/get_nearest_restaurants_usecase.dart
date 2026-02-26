import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetNearestRestaurantsUseCase {
  final RestaurantRepository repository;
  GetNearestRestaurantsUseCase({required this.repository});

  Future<List<Restaurant>> call({
    required double latitude,
    required double longitude,
    String language = 'uz',
  }) => repository.getNearestRestaurants(
    latitude: latitude, longitude: longitude, language: language,
  );
}