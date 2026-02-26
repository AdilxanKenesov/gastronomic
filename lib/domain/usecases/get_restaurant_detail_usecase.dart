import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantDetailUseCase {
  final RestaurantRepository repository;
  GetRestaurantDetailUseCase({required this.repository});

  Future<Restaurant> call({required int id, String language = 'uz'}) =>
      repository.getRestaurantDetail(id: id, language: language);
}