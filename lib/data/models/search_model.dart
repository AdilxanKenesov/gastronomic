import '../../domain/entities/restaurant.dart';
import '../../domain/entities/menu.dart';
import 'restaurant_model.dart';
import 'menu_model.dart';

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });
}

class PaginationMetaModel {
  static PaginationMeta fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? '15') ?? 15,
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }
}

class SearchResponse {
  final SearchResults<Restaurant> restaurants;
  final SearchResults<MenuItem> menuItems;

  SearchResponse({
    required this.restaurants,
    required this.menuItems,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return SearchResponse(
      restaurants: SearchResults.fromJson(
        data['restaurants'],
        (item) => RestaurantModel.fromJson(item),
      ),
      menuItems: SearchResults.fromJson(
        data['menu_items'],
        (item) => MenuItemModel.fromJson(item),
      ),
    );
  }
}

class SearchResults<T> {
  final List<T> data;
  final PaginationMeta? meta;

  SearchResults({
    required this.data,
    this.meta,
  });

  factory SearchResults.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return SearchResults(
      data: (json['data'] as List)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] != null ? PaginationMetaModel.fromJson(json['meta']) : null,
    );
  }
}