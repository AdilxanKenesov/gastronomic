import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';
import '../../data/models/api_response.dart';

class GetNearbyRestaurantsUseCase {
  final RestaurantRepository repository;
  GetNearbyRestaurantsUseCase({required this.repository});

  Future<PaginatedResponse<Restaurant>> call({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    String language = 'uz',
  }) => repository.getNearbyRestaurants(
    latitude: latitude, longitude: longitude, radius: radius, language: language,
  );
}