import '../../data/models/search_model.dart';

abstract class SearchRepository {
  Future<SearchResponse> search({
    required String query,
    int page = 1,
    int perPage = 10,
    String language = 'uz',
  });
}