import '../../domain/entities/menu.dart';

const String _baseUrl = 'https://gastronomic.webclub.uz';

String? _makeAbsoluteUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  if (url.startsWith('/')) return '$_baseUrl$url';
  return '$_baseUrl/$url';
}

class MenuItemModel {
  static MenuItem fromJson(Map<String, dynamic> json) {
    double? price;
    if (json['restaurant_price'] != null) {
      price = double.tryParse(json['restaurant_price'].toString());
    } else if (json['base_price'] != null) {
      price = double.tryParse(json['base_price'].toString());
    } else if (json['price'] != null) {
      price = double.tryParse(json['price'].toString());
    }

    String? imageUrl = json['image_path']?.toString() ?? json['image_url']?.toString();

    return MenuItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: price,
      imageUrl: _makeAbsoluteUrl(imageUrl),
      weight: json['weight'] is int
          ? json['weight']
          : int.tryParse(json['weight']?.toString() ?? ''),
      restaurantId: json['restaurant_id'] is int
          ? json['restaurant_id']
          : int.tryParse(json['restaurant_id']?.toString() ?? '0') ?? 0,
      menuSection: json['menu_section'] != null
          ? MenuSectionModel.fromJson(json['menu_section'])
          : null,
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

class MenuSectionModel {
  static MenuSection fromJson(Map<String, dynamic> json) {
    return MenuSection(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      sortOrder: json['sort_order'] is int
          ? json['sort_order']
          : int.tryParse(json['sort_order']?.toString() ?? ''),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => MenuItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class RestaurantMenuModel {
  static RestaurantMenu fromJson(Map<String, dynamic> json) {
    return RestaurantMenu(
      restaurantId: json['restaurant_id'] is int
          ? json['restaurant_id']
          : int.tryParse(json['restaurant_id']?.toString() ?? '0') ?? 0,
      restaurantName: json['restaurant_name']?.toString() ?? '',
      sections: json['sections'] != null
          ? (json['sections'] as List)
              .map((section) => MenuSectionModel.fromJson(section as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}