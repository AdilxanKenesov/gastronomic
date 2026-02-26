import '../../data/models/search_model.dart';
import '../repositories/search_repository.dart';

class SearchUseCase {
  final SearchRepository repository;
  SearchUseCase({required this.repository});

  Future<SearchResponse> call({
    required String query,
    int page = 1,
    int perPage = 10,
    String language = 'uz',
  }) => repository.search(query: query, page: page, perPage: perPage, language: language);
}