import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/usecases/get_restaurants_usecase.dart';
import '../../domain/usecases/get_nearby_restaurants_usecase.dart';
import '../../domain/usecases/get_nearest_restaurants_usecase.dart';
import '../../domain/usecases/get_top_restaurants_usecase.dart';
import '../../domain/usecases/search_usecase.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../data/repositories/restaurant_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../data/datasources/remote/restaurant_remote_datasource.dart';
import '../../data/datasources/remote/search_remote_datasource.dart';

// Events
abstract class RestaurantEvent {}

class LoadRestaurants extends RestaurantEvent {
  final int? categoryId;
  final int? cityId;
  final int? brandId;
  final double? minRating;
  final String? sortBy;
  final int page;
  final int perPage;
  final String language;

  LoadRestaurants({
    this.categoryId, this.cityId, this.brandId, this.minRating, this.sortBy,
    this.page = 1, this.perPage = 20, this.language = 'uz',
  });
}

class LoadNearbyRestaurants extends RestaurantEvent {
  final double latitude;
  final double longitude;
  final double radius;
  final String language;

  LoadNearbyRestaurants({
    required this.latitude, required this.longitude,
    this.radius = 5.0, this.language = 'uz',
  });
}

class LoadTopRestaurants extends RestaurantEvent {
  final int categoryId;
  final int limit;
  final String language;

  LoadTopRestaurants({required this.categoryId, this.limit = 10, this.language = 'uz'});
}

class LoadNearestRestaurants extends RestaurantEvent {
  final double latitude;
  final double longitude;
  final String language;

  LoadNearestRestaurants({
    required this.latitude, required this.longitude, this.language = 'uz',
  });
}

class SearchRestaurants extends RestaurantEvent {
  final String query;
  final String language;

  SearchRestaurants(this.query, {this.language = 'uz'});
}

// States
abstract class RestaurantState {}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantLoaded extends RestaurantState {
  final List<Restaurant> restaurants;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasMore;

  RestaurantLoaded({
    required this.restaurants, required this.currentPage,
    required this.totalPages, required this.total, required this.hasMore,
  });
}

class RestaurantError extends RestaurantState {
  final String message;
  RestaurantError(this.message);
}

// BLoC
class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  late final GetRestaurantsUseCase _getRestaurants;
  late final GetNearbyRestaurantsUseCase _getNearbyRestaurants;
  late final GetTopRestaurantsUseCase _getTopRestaurants;
  late final GetNearestRestaurantsUseCase _getNearestRestaurants;
  late final SearchUseCase _search;

  RestaurantBloc() : super(RestaurantInitial()) {
    final RestaurantRepository restaurantRepository = RestaurantRepositoryImpl(
      datasource: RestaurantRemoteDatasource(),
    );
    final SearchRepository searchRepository = SearchRepositoryImpl(
      datasource: SearchRemoteDatasource(),
    );

    _getRestaurants = GetRestaurantsUseCase(repository: restaurantRepository);
    _getNearbyRestaurants = GetNearbyRestaurantsUseCase(repository: restaurantRepository);
    _getTopRestaurants = GetTopRestaurantsUseCase(repository: restaurantRepository);
    _getNearestRestaurants = GetNearestRestaurantsUseCase(repository: restaurantRepository);
    _search = SearchUseCase(repository: searchRepository);

    on<LoadRestaurants>(_onLoadRestaurants, transformer: droppable());
    on<LoadNearbyRestaurants>(_onLoadNearbyRestaurants, transformer: droppable());
    on<LoadTopRestaurants>(_onLoadTopRestaurants, transformer: droppable());
    on<LoadNearestRestaurants>(_onLoadNearestRestaurants, transformer: droppable());
    on<SearchRestaurants>(_onSearchRestaurants, transformer: restartable());
  }

  Future<void> _onLoadRestaurants(LoadRestaurants event, Emitter<RestaurantState> emit) async {
    emit(RestaurantLoading());
    try {
      final response = await _getRestaurants(
        page: event.page, perPage: event.perPage, categoryId: event.categoryId,
        cityId: event.cityId, brandId: event.brandId, minRating: event.minRating,
        sortBy: event.sortBy ?? 'rating', language: event.language,
      );
      emit(RestaurantLoaded(
        restaurants: response.data, currentPage: response.currentPage,
        totalPages: response.lastPage, total: response.total, hasMore: response.hasNextPage,
      ));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  Future<void> _onLoadNearbyRestaurants(LoadNearbyRestaurants event, Emitter<RestaurantState> emit) async {
    emit(RestaurantLoading());
    try {
      final response = await _getNearbyRestaurants(
        latitude: event.latitude, longitude: event.longitude,
        radius: event.radius, language: event.language,
      );
      emit(RestaurantLoaded(
        restaurants: response.data, currentPage: response.currentPage,
        totalPages: response.lastPage, total: response.total, hasMore: response.hasNextPage,
      ));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  Future<void> _onLoadTopRestaurants(LoadTopRestaurants event, Emitter<RestaurantState> emit) async {
    emit(RestaurantLoading());
    try {
      final restaurants = await _getTopRestaurants(
        categoryId: event.categoryId, limit: event.limit, language: event.language,
      );
      emit(RestaurantLoaded(
        restaurants: restaurants, currentPage: 1, totalPages: 1,
        total: restaurants.length, hasMore: false,
      ));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  Future<void> _onLoadNearestRestaurants(LoadNearestRestaurants event, Emitter<RestaurantState> emit) async {
    emit(RestaurantLoading());
    try {
      final restaurants = await _getNearestRestaurants(
        latitude: event.latitude, longitude: event.longitude, language: event.language,
      );
      emit(RestaurantLoaded(
        restaurants: restaurants, currentPage: 1, totalPages: 1,
        total: restaurants.length, hasMore: false,
      ));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }

  Future<void> _onSearchRestaurants(SearchRestaurants event, Emitter<RestaurantState> emit) async {
    if (event.query.isEmpty) {
      add(LoadRestaurants(language: event.language));
      return;
    }
    emit(RestaurantLoading());
    try {
      final response = await _search(query: event.query, page: 1, perPage: 20, language: event.language);
      final List<Restaurant> restaurants = response.restaurants.data.cast<Restaurant>();
      emit(RestaurantLoaded(
        restaurants: restaurants, currentPage: 1, totalPages: 1,
        total: restaurants.length, hasMore: false,
      ));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }
}