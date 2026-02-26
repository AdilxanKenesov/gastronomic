class Restaurant {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? workingHours;
  final double? averageRating;
  final int? reviewsCount;
  final String? imageUrl;
  final List<RestaurantImage>? images;
  final Brand? brand;
  final Category? category;
  final City? city;
  final bool isActive;
  final String? qrCode;
  final double? distance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OperatingHour>? operatingHours;

  const Restaurant({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.workingHours,
    this.averageRating,
    this.reviewsCount,
    this.imageUrl,
    this.images,
    this.brand,
    this.category,
    this.city,
    this.isActive = true,
    this.qrCode,
    this.distance,
    this.createdAt,
    this.updatedAt,
    this.operatingHours,
  });

  String? get coverImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl;
    if (images != null && images!.isNotEmpty) {
      final cover = images!.where((img) => img.isCover && img.imagePath.isNotEmpty).firstOrNull;
      if (cover != null) return cover.imagePath;
      final firstValid = images!.where((img) => img.imagePath.isNotEmpty).firstOrNull;
      if (firstValid != null) return firstValid.imagePath;
    }
    return null;
  }

  bool get isCurrentlyOpen {
    if (!isActive) return false;
    if (operatingHours == null || operatingHours!.isEmpty) return isActive;
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday == 7 ? 0 : now.weekday;
    final todayHours = operatingHours!.where((h) => h.dayOfWeek == currentDayOfWeek).firstOrNull;
    if (todayHours == null || todayHours.isClosed) return false;
    final currentMinutes = now.hour * 60 + now.minute;
    final openingParts = todayHours.openingTime.split(':');
    final closingParts = todayHours.closingTime.split(':');
    if (openingParts.length < 2 || closingParts.length < 2) return isActive;
    final openingMinutes = int.parse(openingParts[0]) * 60 + int.parse(openingParts[1]);
    int closingMinutes = int.parse(closingParts[0]) * 60 + int.parse(closingParts[1]);
    if (closingMinutes == 0) closingMinutes = 24 * 60;
    if (closingMinutes < openingMinutes) {
      return currentMinutes >= openingMinutes || currentMinutes <= closingMinutes;
    }
    return currentMinutes >= openingMinutes && currentMinutes <= closingMinutes;
  }

  List<String> get allImageUrls {
    final List<String> urls = [];
    if (images != null && images!.isNotEmpty) {
      for (final img in images!) {
        if (img.imagePath.isNotEmpty) urls.add(img.imagePath);
      }
    }
    if (urls.isEmpty && coverImageUrl != null && coverImageUrl!.isNotEmpty) {
      urls.add(coverImageUrl!);
    }
    return urls;
  }
}

class RestaurantImage {
  final int id;
  final String imagePath;
  final bool isCover;

  const RestaurantImage({
    required this.id,
    required this.imagePath,
    required this.isCover,
  });
}

class Brand {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? imageUrl;

  const Brand({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.imageUrl,
  });
}

class Category {
  final int id;
  final String name;
  final String? description;
  final String? icon;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });
}

class City {
  final int id;
  final String name;

  const City({required this.id, required this.name});
}

class OperatingHour {
  final int dayOfWeek;
  final String openingTime;
  final String closingTime;
  final bool isClosed;

  const OperatingHour({
    required this.dayOfWeek,
    required this.openingTime,
    required this.closingTime,
    required this.isClosed,
  });
}