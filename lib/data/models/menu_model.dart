// Base URL for images
const String _baseUrl = 'https://gastronomic.webclub.uz';

// URL ni to'liq qilish funksiyasi
String? _makeAbsoluteUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  // Nisbiy URL bo'lsa, base URL qo'shamiz
  if (url.startsWith('/')) {
    return '$_baseUrl$url';
  }
  return '$_baseUrl/$url';
}

class MenuItem {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final String? imageUrl;
  final int? weight; // gramm
  final int restaurantId;
  final MenuSection? menuSection;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.imageUrl,
    this.weight,
    required this.restaurantId,
    this.menuSection,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Narxni olish - restaurant_price yoki base_price yoki price
    double? price;
    if (json['restaurant_price'] != null) {
      price = double.tryParse(json['restaurant_price'].toString());
    } else if (json['base_price'] != null) {
      price = double.tryParse(json['base_price'].toString());
    } else if (json['price'] != null) {
      price = double.tryParse(json['price'].toString());
    }

    // Rasmni olish - image_path yoki image_url
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
          ? MenuSection.fromJson(json['menu_section'])
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'weight': weight,
      'restaurant_id': restaurantId,
      'menu_section': menuSection?.toJson(),
      'is_available': isAvailable,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class MenuSection {
  final int id;
  final String name;
  final String? description;
  final int? sortOrder;
  final List<MenuItem>? items;

  MenuSection({
    required this.id,
    required this.name,
    this.description,
    this.sortOrder,
    this.items,
  });

  factory MenuSection.fromJson(Map<String, dynamic> json) {
    return MenuSection(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      sortOrder: json['sort_order'] is int
          ? json['sort_order']
          : int.tryParse(json['sort_order']?.toString() ?? ''),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sort_order': sortOrder,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}

class RestaurantMenu {
  final int restaurantId;
  final String restaurantName;
  final List<MenuSection> sections;

  RestaurantMenu({
    required this.restaurantId,
    required this.restaurantName,
    required this.sections,
  });

  factory RestaurantMenu.fromJson(Map<String, dynamic> json) {
    return RestaurantMenu(
      restaurantId: json['restaurant_id'] is int
          ? json['restaurant_id']
          : int.tryParse(json['restaurant_id']?.toString() ?? '0') ?? 0,
      restaurantName: json['restaurant_name']?.toString() ?? '',
      sections: json['sections'] != null
          ? (json['sections'] as List)
              .map((section) => MenuSection.fromJson(section as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }
}
