import '../entities/restaurant.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories({String language});
}