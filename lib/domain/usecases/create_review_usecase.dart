import '../entities/review.dart';
import '../repositories/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository repository;
  CreateReviewUseCase({required this.repository});

  Future<Review> call({
    required int restaurantId,
    required String deviceId,
    required int rating,
    String? comment,
    String? phone,
    List<int>? selectedOptionIds,
  }) => repository.createReview(
    restaurantId: restaurantId, deviceId: deviceId, rating: rating,
    comment: comment, phone: phone, selectedOptionIds: selectedOptionIds,
  );
}