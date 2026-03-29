class MenuItem {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final String? imageUrl;
  final String? weight; // API dan string formatda kelyapti "0.50"
  final String? weightUnit; // "л" yoki "г"
  final bool? isWater;
  final int restaurantId;
  final MenuSection? menuSection;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.imageUrl,
    this.weight,
    this.weightUnit,
    this.isWater,
    required this.restaurantId,
    this.menuSection,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });
}

class MenuSection {
  final int id;
  final String name;
  final String? description;
  final int? sortOrder;
  final List<MenuItem>? items;

  const MenuSection({
    required this.id,
    required this.name,
    this.description,
    this.sortOrder,
    this.items,
  });
}

class RestaurantMenu {
  final int restaurantId;
  final String restaurantName;
  final List<MenuSection> sections;

  const RestaurantMenu({
    required this.restaurantId,
    required this.restaurantName,
    required this.sections,
  });
}
