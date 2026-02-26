import '../entities/review.dart';

abstract class ReviewRepository {
  Future<ReviewsResponse> getRestaurantReviews({
    required int restaurantId,
    int page = 1,
    int perPage = 10,
  });

  Future<Review> createReview({
    required int restaurantId,
    required String deviceId,
    required int rating,
    String? comment,
    String? phone,
    List<int>? selectedOptionIds,
  });
}