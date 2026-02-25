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

  Review({
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

  factory Review.fromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'user_id': userId,
      'device_id': deviceId,
      'rating': rating,
      'comment': comment,
      'user_name': userName,
      'user_avatar': userAvatar,
      'is_guest': isGuest,
      'client': client,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
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

class ReviewsResponse {
  final List<Review> reviews;
  final ReviewStats? stats;
  final PaginationMeta? meta;

  ReviewsResponse({
    required this.reviews,
    this.stats,
    this.meta,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ReviewsResponse(
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((review) => Review.fromJson(review))
              .toList()
          : (json['data'] as List)
              .map((review) => Review.fromJson(review))
              .toList(),
      stats: json['stats'] != null 
          ? ReviewStats.fromJson(json['stats']) 
          : null,
      meta: json['meta'] != null 
          ? PaginationMeta.fromJson(json['meta']) 
          : null,
    );
  }
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    Map<int, int> distribution = {};
    if (json['rating_distribution'] != null) {
      (json['rating_distribution'] as Map<String, dynamic>).forEach((key, value) {
        distribution[int.parse(key)] = value as int;
      });
    }

    return ReviewStats(
      averageRating: double.parse(json['average_rating'].toString()),
      totalReviews: json['total_reviews'] as int,
      ratingDistribution: distribution,
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
    );
  }
}
