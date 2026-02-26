import '../entities/restaurant.dart';
import '../../data/models/api_response.dart';

abstract class RestaurantRepository {
  Future<PaginatedResponse<Restaurant>> getRestaurants({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    int? cityId,
    int? brandId,
    double? minRating,
    String? sortBy,
    String language = 'uz',
  });

  Future<Restaurant> getRestaurantDetail({required int id, String language = 'uz'});

  Future<PaginatedResponse<Restaurant>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    String language = 'uz',
  });

  Future<List<Restaurant>> getNearestRestaurants({
    required double latitude,
    required double longitude,
    String language = 'uz',
  });

  Future<List<Restaurant>> getRestaurantsForMap({
    int? categoryId,
    int? cityId,
    double? minRating,
    double? maxRating,
    String language = 'uz',
  });

  Future<List<Restaurant>> getTopRestaurantsByCategory({
    required int categoryId,
    int limit = 10,
    String language = 'uz',
  });
}