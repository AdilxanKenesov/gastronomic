import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetReviewsUseCase {
  final ReviewRepository repository;
  GetReviewsUseCase({required this.repository});

  Future<ReviewsResponse> call({
    required int restaurantId,
    int page = 1,
    int perPage = 10,
  }) => repository.getRestaurantReviews(
    restaurantId: restaurantId, page: page, perPage: perPage,
  );
}