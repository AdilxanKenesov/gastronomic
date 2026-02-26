import '../entities/restaurant.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase({required this.repository});

  Future<List<Category>> call({String language = 'uz'}) {
    return repository.getCategories(language: language);
  }
}