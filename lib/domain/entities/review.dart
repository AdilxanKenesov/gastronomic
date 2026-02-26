class QuestionCondition {
  final String field;
  final String operator;
  final int value;

  const QuestionCondition({
    required this.field,
    required this.operator,
    required this.value,
  });
}

class QuestionOption {
  final int id;
  final String text;

  const QuestionOption({required this.id, required this.text});
}

class SubQuestion {
  final int id;
  final String title;
  final bool isRequired;
  final bool allowMultiple;
  final QuestionCondition? condition;
  final List<QuestionOption> options;

  const SubQuestion({
    required this.id,
    required this.title,
    required this.isRequired,
    required this.allowMultiple,
    this.condition,
    required this.options,
  });
}

class ReviewQuestion {
  final int id;
  final String title;
  final bool isRequired;
  final bool allowMultiple;
  final int sortOrder;
  final List<QuestionOption> options;
  final List<SubQuestion> subQuestions;

  const ReviewQuestion({
    required this.id,
    required this.title,
    required this.isRequired,
    required this.allowMultiple,
    required this.sortOrder,
    required this.options,
    required this.subQuestions,
  });
}

class Review {
  final int id;
  final int restaurantId;
  final int? userId;
  final String? deviceId;
  final int rating;
  final String? comment;
  final String? userName;
  final String? userAvatar;
  final bool isGuest;
  final dynamic client;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.restaurantId,
    this.userId,
    this.deviceId,
    required this.rating,
    this.comment,
    this.userName,
    this.userAvatar,
    this.isGuest = true,
    this.client,
    this.createdAt,
    this.updatedAt,
  });
}

class ReviewsResponse {
  final List<Review> reviews;
  final ReviewStats? stats;
  final PaginationMeta? meta;

  const ReviewsResponse({
    required this.reviews,
    this.stats,
    this.meta,
  });
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });
}