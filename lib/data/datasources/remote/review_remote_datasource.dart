import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../data/models/review_model.dart';
import '../../../domain/entities/review.dart';

class ReviewRemoteDatasource {
  Future<List<ReviewQuestion>> getQuestions({String language = 'ru'}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.questions}');
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Accept-Language': language,
      }).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as List;
        return data.map((q) => ReviewQuestionModel.fromJson(q as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  Future<ReviewsResponse> getRestaurantReviews({
    required int restaurantId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = {'page': page.toString(), 'per_page': perPage.toString()};
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.restaurantReviews(restaurantId)}',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReviewsResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  Future<Review> createReview({
    required int restaurantId,
    required String deviceId,
    required int rating,
    List<Map<String, dynamic>>? comments,
    String? phone,
    String? email,
    List<int>? selectedOptionIds,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.restaurantReviews(restaurantId)}',
      );
      final requestData = CreateReviewRequest(
        deviceId: deviceId, rating: rating, comments: comments,
        phone: phone, email: email, selectedOptionIds: selectedOptionIds,
      );
      final bodyJson = requestData.toJson();
      developer.log('CREATE REVIEW → URL: $uri', name: 'ReviewDS');
      developer.log('CREATE REVIEW → BODY: ${json.encode(bodyJson)}', name: 'ReviewDS');
      final response = await http.post(
        uri, headers: ApiConstants.headers(), body: json.encode(bodyJson),
      ).timeout(const Duration(seconds: 30));
      developer.log('CREATE REVIEW ← STATUS: ${response.statusCode}', name: 'ReviewDS');
      developer.log('CREATE REVIEW ← BODY: ${response.body}', name: 'ReviewDS');
      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReviewModel.fromJson(jsonData['data']);
      } else if (response.statusCode == 422) {
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['message'] ?? 'Validation error');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. You can only post 3 reviews per day per restaurant.');
      } else {
        throw Exception('[${response.statusCode}] ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }
}