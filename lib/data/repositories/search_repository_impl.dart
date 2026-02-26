import '../../domain/repositories/search_repository.dart';
import '../../data/models/search_model.dart';
import '../datasources/remote/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDatasource datasource;

  SearchRepositoryImpl({required this.datasource});

  @override
  Future<SearchResponse> search({
    required String query, int page = 1, int perPage = 10, String language = 'uz',
  }) => datasource.search(query: query, page: page, perPage: perPage, language: language);
}