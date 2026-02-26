import '../../domain/entities/review.dart';

class QuestionConditionModel {
  static QuestionCondition fromJson(Map<String, dynamic> json) {
    return QuestionCondition(
      field: json['field']?.toString() ?? 'rating',
      operator: json['operator']?.toString() ?? '<=',
      value: json['value'] is int ? json['value'] : int.tryParse(json['value']?.toString() ?? '0') ?? 0,
    );
  }
}

class QuestionOptionModel {
  static QuestionOption fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      text: json['text']?.toString() ?? '',
    );
  }
}

class SubQuestionModel {
  static SubQuestion fromJson(Map<String, dynamic> json) {
    return SubQuestion(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      isRequired: json['is_required'] == true,
      allowMultiple: json['allow_multiple'] == true,
      condition: json['condition'] != null
          ? QuestionConditionModel.fromJson(json['condition'] as Map<String, dynamic>)
          : null,
      options: (json['options'] as List?)
              ?.map((o) => QuestionOptionModel.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ReviewQuestionModel {
  static ReviewQuestion fromJson(Map<String, dynamic> json) {
    return ReviewQuestion(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      isRequired: json['is_required'] == true,
      allowMultiple: json['allow_multiple'] == true,
      sortOrder: json['sort_order'] is int ? json['sort_order'] : int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      options: (json['options'] as List?)
              ?.map((o) => QuestionOptionModel.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      subQuestions: (json['sub_questions'] as List?)
              ?.map((s) => SubQuestionModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ReviewModel {
  static Review fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      restaurantId: json['restaurant_id'] is int
          ? json['restaurant_id']
          : int.tryParse(json['restaurant_id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : null,
      deviceId: json['device_id']?.toString(),
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString(),
      userName: json['user_name']?.toString() ?? json['client']?['name']?.toString(),
      userAvatar: json['user_avatar']?.toString() ?? json['client']?['avatar']?.toString(),
      isGuest: json['is_guest'] == true,
      client: json['client'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

class ReviewsResponseModel {
  static ReviewsResponse fromJson(Map<String, dynamic> json) {
    // API javobi: { "success": true, "data": [...], "statistics": {...}, "meta": {...} }
    final rawList = (json['data'] ?? json['reviews']) as List? ?? [];
    return ReviewsResponse(
      reviews: rawList.map((r) => ReviewModel.fromJson(r as Map<String, dynamic>)).toList(),
      stats: json['statistics'] != null
          ? ReviewStatsModel.fromJson(json['statistics'] as Map<String, dynamic>)
          : json['stats'] != null
              ? ReviewStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
              : null,
      meta: json['meta'] != null
          ? PaginationMetaModel.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReviewStatsModel {
  static ReviewStats fromJson(Map<String, dynamic> json) {
    Map<int, int> distribution = {};
    final rawDist = json['rating_distribution'];
    if (rawDist is Map) {
      rawDist.forEach((key, value) {
        final k = int.tryParse(key.toString());
        final v = int.tryParse(value.toString()) ?? 0;
        if (k != null) distribution[k] = v;
      });
    }
    return ReviewStats(
      averageRating: double.tryParse(
              (json['average_rating'] ?? json['avg_rating'] ?? 0).toString()) ??
          0.0,
      totalReviews:
          int.tryParse((json['total_reviews'] ?? json['count'] ?? 0).toString()) ?? 0,
      ratingDistribution: distribution,
    );
  }
}

class PaginationMetaModel {
  static PaginationMeta fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
    );
  }
}

class CreateReviewRequest {
  final String deviceId;
  final int rating;
  final String? comment;
  final String? phone;
  final List<int>? selectedOptionIds;

  CreateReviewRequest({
    required this.deviceId,
    required this.rating,
    this.comment,
    this.phone,
    this.selectedOptionIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'rating': rating,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (selectedOptionIds != null && selectedOptionIds!.isNotEmpty)
        'selected_option_ids': selectedOptionIds,
    };
  }
}