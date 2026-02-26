import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';
import '../../data/models/api_response.dart';

class GetRestaurantsUseCase {
  final RestaurantRepository repository;
  GetRestaurantsUseCase({required this.repository});

  Future<PaginatedResponse<Restaurant>> call({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    int? cityId,
    int? brandId,
    double? minRating,
    String? sortBy,
    String language = 'uz',
  }) => repository.getRestaurants(
    page: page, perPage: perPage, categoryId: categoryId, cityId: cityId,
    brandId: brandId, minRating: minRating, sortBy: sortBy, language: language,
  );
}