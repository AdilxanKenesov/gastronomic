import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../data/models/search_model.dart';

class SearchRemoteDatasource {
  Future<SearchResponse> search({
    required String query,
    int page = 1,
    int perPage = 10,
    String language = 'uz',
  }) async {
    try {
      if (query.length < 2) throw Exception('Search query must be at least 2 characters');
      final queryParams = {
        'q': query, 'page': page.toString(), 'per_page': perPage.toString(),
      };
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.search}')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: ApiConstants.headers(language: language));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SearchResponse.fromJson(jsonData);
      } else if (response.statusCode == 422) {
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['message'] ?? 'Validation error');
      } else {
        throw Exception('Failed to perform search');
      }
    } catch (e) {
      throw Exception('Error searching: $e');
    }
  }
}