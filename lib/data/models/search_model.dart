import 'restaurant_model.dart';
import 'menu_model.dart';
import 'review_model.dart';

class SearchResponse {
  final SearchResults restaurants;
  final SearchResults menuItems;

  SearchResponse({
    required this.restaurants,
    required this.menuItems,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return SearchResponse(
      restaurants: SearchResults.fromJson(
        data['restaurants'], 
        (item) => Restaurant.fromJson(item),
      ),
      menuItems: SearchResults.fromJson(
        data['menu_items'], 
        (item) => MenuItem.fromJson(item),
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
      meta: json['meta'] != null 
          ? PaginationMeta.fromJson(json['meta']) 
          : null,
    );
  }
}
