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

  Restaurant({
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

  // Cover rasmni olish (is_cover = 1)
  String? get coverImageUrl {
    // Avval imageUrl ni tekshiramiz (bo'sh emas bo'lsa)
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl;

    if (images != null && images!.isNotEmpty) {
      // Avval cover rasmni qidiramiz
      final cover = images!.where((img) => img.isCover && img.imagePath.isNotEmpty).firstOrNull;
      if (cover != null) return cover.imagePath;
      // Cover topilmasa birinchi rasmni qaytaramiz (bo'sh emas bo'lsa)
      final firstValid = images!.where((img) => img.imagePath.isNotEmpty).firstOrNull;
      if (firstValid != null) return firstValid.imagePath;
    }
    return null;
  }

  // Hozir ochiq yoki yopiqligini hisoblash (operating_hours asosida)
  bool get isCurrentlyOpen {
    // Agar restoran faol emas bo'lsa - yopiq
    if (!isActive) return false;

    // Agar operating_hours yo'q yoki bo'sh bo'lsa - isActive ga qaraymiz
    if (operatingHours == null || operatingHours!.isEmpty) return isActive;

    final now = DateTime.now();
    // DateTime.weekday: 1=Monday, 7=Sunday
    // API: 0=Sunday, 1=Monday, ..., 6=Saturday
    final currentDayOfWeek = now.weekday == 7 ? 0 : now.weekday;

    // Bugungi kunning ish vaqtini topish
    final todayHours = operatingHours!.where(
      (h) => h.dayOfWeek == currentDayOfWeek,
    ).firstOrNull;

    // Bugun uchun ma'lumot yo'q yoki yopiq bo'lsa
    if (todayHours == null || todayHours.isClosed) return false;

    // Hozirgi vaqtni soat va daqiqa sifatida olish
    final currentMinutes = now.hour * 60 + now.minute;

    // Ochilish va yopilish vaqtlarini parse qilish
    final openingParts = todayHours.openingTime.split(':');
    final closingParts = todayHours.closingTime.split(':');

    if (openingParts.length < 2 || closingParts.length < 2) return isActive;

    final openingMinutes = int.parse(openingParts[0]) * 60 + int.parse(openingParts[1]);
    int closingMinutes = int.parse(closingParts[0]) * 60 + int.parse(closingParts[1]);

    // Agar yopilish vaqti 00:00:00 bo'lsa, yarim tunni (24:00) anglatadi
    if (closingMinutes == 0) {
      closingMinutes = 24 * 60; // 1440 daqiqa
    }

    // Agar restoran tungi vaqtda ishlasa (yopilish < ochilish)
    if (closingMinutes < openingMinutes) {
      // Hozirgi vaqt ochilishdan keyin YOKI yopilishdan oldin bo'lishi kerak
      return currentMinutes >= openingMinutes || currentMinutes <= closingMinutes;
    }

    // Oddiy holat: hozirgi vaqt ochilish va yopilish orasida
    return currentMinutes >= openingMinutes && currentMinutes <= closingMinutes;
  }

  // Barcha rasmlar ro'yxati (carousel uchun)
  List<String> get allImageUrls {
    final List<String> urls = [];

    // images arraydan rasmlarni olish
    if (images != null && images!.isNotEmpty) {
      for (final img in images!) {
        if (img.imagePath.isNotEmpty) {
          urls.add(img.imagePath);
        }
      }
    }

    // Agar images bo'sh bo'lsa, coverImageUrl dan foydalanamiz
    if (urls.isEmpty && coverImageUrl != null && coverImageUrl!.isNotEmpty) {
      urls.add(coverImageUrl!);
    }

    return urls;
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // images ni parse qilish
    List<RestaurantImage>? parsedImages;
    if (json['images'] != null && json['images'] is List) {
      parsedImages = (json['images'] as List).map((img) {
        if (img is Map<String, dynamic>) {
          return RestaurantImage.fromJson(img);
        } else if (img is String) {
          // Agar oddiy string bo'lsa
          return RestaurantImage(id: 0, imagePath: img, isCover: false);
        }
        return RestaurantImage(id: 0, imagePath: img.toString(), isCover: false);
      }).toList();
    }

    // operating_hours ni parse qilish
    List<OperatingHour>? parsedOperatingHours;
    if (json['operating_hours'] != null && json['operating_hours'] is List) {
      parsedOperatingHours = (json['operating_hours'] as List)
          .whereType<Map<String, dynamic>>()
          .map((h) => OperatingHour.fromJson(h))
          .toList();
    }

    // Cover rasmni topish (image_url yoki cover_image sifatida)
    String? coverUrl = json['image_url']?.toString();

    // Agar image_url yo'q bo'lsa, cover_image ni tekshiramiz (list endpoint uchun)
    if ((coverUrl == null || coverUrl.isEmpty) && json['cover_image'] != null) {
      coverUrl = json['cover_image'].toString();
    }

    // Agar hali ham yo'q bo'lsa, images arraydan olamiz
    if ((coverUrl == null || coverUrl.isEmpty) && parsedImages != null && parsedImages.isNotEmpty) {
      final cover = parsedImages.where((img) => img.isCover).firstOrNull;
      coverUrl = cover?.imagePath ?? parsedImages.first.imagePath;
    }

    return Restaurant(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      // API da branch_name yoki name bo'lishi mumkin
      name: json['branch_name']?.toString() ?? json['name']?.toString() ?? 'Nomsiz',
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      // API'dan koordinatalar almashtirilgan holda keladi (lat<->lng)
      // Shuning uchun longitude ni latitude sifatida, latitude ni longitude sifatida olamiz
      latitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      longitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
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
          ? Brand.fromJson(json['brand'])
          : null,
      category: json['category'] != null && json['category'] is Map<String, dynamic>
          ? Category.fromJson(json['category'])
          : null,
      city: json['city'] != null && json['city'] is Map<String, dynamic>
          ? City.fromJson(json['city'])
          : null,
      // Agar is_active kelsa - uni ishlatamiz, kelmasa defa
      // ult true
      isActive: json.containsKey('is_active')
          ? (json['is_active'] == true || json['is_active'] == 1)
          : true,
      qrCode: json['qr_code']?.toString(),
      distance: json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString().replaceAll(' ', 'T'))
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString().replaceAll(' ', 'T'))
          : null,
      operatingHours: parsedOperatingHours,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'working_hours': workingHours,
      'average_rating': averageRating,
      'reviews_count': reviewsCount,
      'image_url': imageUrl,
      'images': images?.map((img) => img.toJson()).toList(),
      'brand': brand?.toJson(),
      'category': category?.toJson(),
      'city': city?.toJson(),
      'is_active': isActive,
      'qr_code': qrCode,
      'distance': distance,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'operating_hours': operatingHours?.map((h) => h.toJson()).toList(),
    };
  }
}

// Restoran rasmi modeli
class RestaurantImage {
  final int id;
  final String imagePath;
  final bool isCover;

  RestaurantImage({
    required this.id,
    required this.imagePath,
    required this.isCover,
  });

  factory RestaurantImage.fromJson(Map<String, dynamic> json) {
    return RestaurantImage(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      imagePath: json['image_path']?.toString() ?? '',
      isCover: json['is_cover'] == 1 || json['is_cover'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'is_cover': isCover ? 1 : 0,
    };
  }
}

class Brand {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? imageUrl;

  Brand({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.imageUrl,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      // API da 'logo' yoki 'logo_url' bo'lishi mumkin
      logoUrl: json['logo']?.toString() ?? json['logo_url']?.toString(),
      imageUrl: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logoUrl,
      'image': imageUrl,
    };
  }
}

class Category {
  final int id;
  final String name;
  final String? description;
  final String? icon;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
  }
}

class City {
  final int id;
  final String name;

  City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// Ish vaqti modeli
class OperatingHour {
  final int dayOfWeek; // 0=Sunday, 1=Monday, ..., 6=Saturday
  final String openingTime; // "09:00:00"
  final String closingTime; // "23:00:00"
  final bool isClosed;

  OperatingHour({
    required this.dayOfWeek,
    required this.openingTime,
    required this.closingTime,
    required this.isClosed,
  });

  factory OperatingHour.fromJson(Map<String, dynamic> json) {
    return OperatingHour(
      dayOfWeek: json['day_of_week'] is int
          ? json['day_of_week']
          : int.tryParse(json['day_of_week']?.toString() ?? '0') ?? 0,
      openingTime: json['opening_time']?.toString() ?? '00:00:00',
      closingTime: json['closing_time']?.toString() ?? '00:00:00',
      isClosed: json['is_closed'] == true || json['is_closed'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'is_closed': isClosed,
    };
  }
}