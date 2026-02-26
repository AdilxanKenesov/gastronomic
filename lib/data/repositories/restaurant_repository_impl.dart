import '../../domain/repositories/restaurant_repository.dart';
import '../../domain/entities/restaurant.dart';
import '../../data/models/api_response.dart';
import '../datasources/remote/restaurant_remote_datasource.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDatasource datasource;

  RestaurantRepositoryImpl({required this.datasource});

  @override
  Future<PaginatedResponse<Restaurant>> getRestaurants({
    int page = 1, int perPage = 10, int? categoryId, int? cityId,
    int? brandId, double? minRating, String? sortBy, String language = 'uz',
  }) => datasource.getRestaurants(
    page: page, perPage: perPage, categoryId: categoryId, cityId: cityId,
    brandId: brandId, minRating: minRating, sortBy: sortBy, language: language,
  );

  @override
  Future<Restaurant> getRestaurantDetail({required int id, String language = 'uz'}) =>
      datasource.getRestaurantDetail(id: id, language: language);

  @override
  Future<PaginatedResponse<Restaurant>> getNearbyRestaurants({
    required double latitude, required double longitude,
    double radius = 5.0, String language = 'uz',
  }) => datasource.getNearbyRestaurants(
    latitude: latitude, longitude: longitude, radius: radius, language: language,
  );

  @override
  Future<List<Restaurant>> getNearestRestaurants({
    required double latitude, required double longitude, String language = 'uz',
  }) => datasource.getNearestRestaurants(
    latitude: latitude, longitude: longitude, language: language,
  );

  @override
  Future<List<Restaurant>> getRestaurantsForMap({
    int? categoryId, int? cityId, double? minRating, double? maxRating, String language = 'uz',
  }) => datasource.getRestaurantsForMap(
    categoryId: categoryId, cityId: cityId,
    minRating: minRating, maxRating: maxRating, language: language,
  );

  @override
  Future<List<Restaurant>> getTopRestaurantsByCategory({
    required int categoryId, int limit = 10, String language = 'uz',
  }) => datasource.getTopRestaurantsByCategory(
    categoryId: categoryId, limit: limit, language: language,
  );
}