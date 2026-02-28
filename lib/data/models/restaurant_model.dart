import '../../domain/entities/restaurant.dart';

class RestaurantModel {
  static Restaurant fromJson(Map<String, dynamic> json) {
    List<RestaurantImage>? parsedImages;
    if (json['images'] != null && json['images'] is List) {
      parsedImages = (json['images'] as List).map((img) {
        if (img is Map<String, dynamic>) {
          return RestaurantImageModel.fromJson(img);
        } else if (img is String) {
          return const RestaurantImage(id: 0, imagePath: '', isCover: false);
        }
        return RestaurantImage(id: 0, imagePath: img.toString(), isCover: false);
      }).toList();
    }

    List<OperatingHour>? parsedOperatingHours;
    if (json['operating_hours'] != null && json['operating_hours'] is List) {
      parsedOperatingHours = (json['operating_hours'] as List)
          .whereType<Map<String, dynamic>>()
          .map((h) => OperatingHourModel.fromJson(h))
          .toList();
    }

    String? coverUrl = json['image_url']?.toString();
    if ((coverUrl == null || coverUrl.isEmpty) && json['cover_image'] != null) {
      coverUrl = json['cover_image'].toString();
    }
    if ((coverUrl == null || coverUrl.isEmpty) && parsedImages != null && parsedImages.isNotEmpty) {
      final cover = parsedImages.where((img) => img.isCover).firstOrNull;
      coverUrl = cover?.imagePath ?? parsedImages.first.imagePath;
    }

    return Restaurant(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['branch_name']?.toString() ?? json['name']?.toString() ?? 'Nomsiz',
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      latitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      longitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      phone: json['phone']?.toString(),
      workingHours: json['working_hours']?.toString(),
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString())
          : null,
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count']
          : int.tryParse(json['reviews_count']?.toString() ?? '0'),
      imageUrl: coverUrl,
      images: parsedImages,
      brand: json['brand'] != null && json['brand'] is Map<String, dynamic>
          ? BrandModel.fromJson(json['brand'])
          : null,
      category: json['category'] != null && json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'])
          : null,
      city: json['city'] != null && json['city'] is Map<String, dynamic>
          ? CityModel.fromJson(json['city'])
          : null,
      isActive: json.containsKey('is_active')
          ? (json['is_active'] == true || json['is_active'] == 1)
          : true,
      qrCode: json['qr_code']?.toString(),
      distance: json['distance'] != null ? double.tryParse(json['distance'].toString()) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString().replaceAll(' ', 'T'))
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString().replaceAll(' ', 'T'))
          : null,
      operatingHours: parsedOperatingHours,
    );
  }

  static Map<String, dynamic> toJson(Restaurant r) {
    return {
      'id': r.id,
      'branch_name': r.name,
      'description': r.description,
      'address': r.address,
      'latitude': r.latitude,
      'longitude': r.longitude,
      'phone': r.phone,
      'working_hours': r.workingHours,
      'average_rating': r.averageRating,
      'reviews_count': r.reviewsCount,
      'image_url': r.imageUrl,
      'is_active': r.isActive,
      'qr_code': r.qrCode,
      'distance': r.distance,
      'created_at': r.createdAt?.toIso8601String(),
      'updated_at': r.updatedAt?.toIso8601String(),
    };
  }
}

class RestaurantImageModel {
  static RestaurantImage fromJson(Map<String, dynamic> json) {
    return RestaurantImage(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      imagePath: json['image_path']?.toString() ?? '',
      isCover: json['is_cover'] == 1 || json['is_cover'] == true,
    );
  }
}

class BrandModel {
  static Brand fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      logoUrl: json['logo']?.toString() ?? json['logo_url']?.toString(),
      imageUrl: json['image']?.toString(),
    );
  }
}

class CategoryModel {
  static Category fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}

class CityModel {
  static City fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class OperatingHourModel {
  static OperatingHour fromJson(Map<String, dynamic> json) {
    return OperatingHour(
      dayOfWeek: json['day_of_week'] is int
          ? json['day_of_week']
          : int.tryParse(json['day_of_week']?.toString() ?? '0') ?? 0,
      openingTime: json['opening_time']?.toString() ?? '00:00:00',
      closingTime: json['closing_time']?.toString() ?? '00:00:00',
      isClosed: json['is_closed'] == true || json['is_closed'] == 1,
    );
  }
}