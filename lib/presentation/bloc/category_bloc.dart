import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/repositories/category_repository.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/datasources/remote/category_remote_datasource.dart';

// Events
abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {
  final String language;
  LoadCategories({this.language = 'uz'});
}

// States
abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}

// BLoC
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  late final GetCategoriesUseCase _getCategories;

  CategoryBloc() : super(CategoryInitial()) {
    final CategoryRepository repository = CategoryRepositoryImpl(
      datasource: CategoryRemoteDatasource(),
    );
    _getCategories = GetCategoriesUseCase(repository: repository);

    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _getCategories(language: event.language);
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}