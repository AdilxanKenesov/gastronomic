import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/remote/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDatasource datasource;

  CategoryRepositoryImpl({required this.datasource});

  @override
  Future<List<Category>> getCategories({String language = 'uz'}) {
    return datasource.getCategories(language: language);
  }
}