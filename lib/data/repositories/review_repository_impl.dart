import '../../domain/repositories/review_repository.dart';
import '../../domain/entities/review.dart';
import '../datasources/remote/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDatasource datasource;

  ReviewRepositoryImpl({required this.datasource});

  @override
  Future<ReviewsResponse> getRestaurantReviews({
    required int restaurantId, int page = 1, int perPage = 10,
  }) => datasource.getRestaurantReviews(
    restaurantId: restaurantId, page: page, perPage: perPage,
  );

  @override
  Future<Review> createReview({
    required int restaurantId, required String deviceId, required int rating,
    String? comment, String? phone, List<int>? selectedOptionIds,
  }) => datasource.createReview(
    restaurantId: restaurantId, deviceId: deviceId, rating: rating,
    comment: comment, phone: phone, selectedOptionIds: selectedOptionIds,
  );
}