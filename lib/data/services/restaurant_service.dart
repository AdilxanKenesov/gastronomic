import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/restaurant_model.dart';
import '../models/api_response.dart';

class RestaurantService {
  // Barcha restoranlarni olish (Paginatsiya bilan yoki Listsiz)
  Future<PaginatedResponse<Restaurant>> getRestaurants({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    int? cityId,
    int? brandId,
    int? menuSectionId,
    double? minRating,
    double? maxRating,
    String? sortBy,
    String language = 'uz',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (cityId != null) 'city_id': cityId.toString(),
        if (brandId != null) 'brand_id': brandId.toString(),
        if (menuSectionId != null) 'menu_section_id': menuSectionId.toString(),
        if (minRating != null) 'min_rating': minRating.toString(),
        if (maxRating != null) 'max_rating': maxRating.toString(),
        if (sortBy != null) 'sort_by': sortBy,
      };

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.restaurants}')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConstants.headers(language: language),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final dynamic apiData = jsonData['data'];

        if (apiData is List) {
          return PaginatedResponse<Restaurant>(
            data: apiData.map((item) => Restaurant.fromJson(item)).toList(),
            currentPage: 1,
            lastPage: 1,
            perPage: apiData.length,
            total: apiData.length,
          );
        }
        // AGAR API STANDART PAGINATSIYA OBYEKTINI QAYTARSA
        else if (apiData is Map<String, dynamic>) {
          return PaginatedResponse.fromJson(
            apiData,
                (json) => Restaurant.fromJson(json),
          );
        } else {
          throw Exception('Noma\'lum ma\'lumot formati');
        }
      } else {
        throw Exception('Server xatosi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Restoranlarni yuklashda xatolik: $e');
    }
  }

  // Restoran batafsil ma'lumotlarini olish
  Future<Restaurant> getRestaurantDetail({
    required int id,
    String language = 'uz',
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.restaurantDetail(id)}');
      final response = await http.get(uri, headers: ApiConstants.headers(language: language));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Restaurant.fromJson(jsonData['data']);
      } else {
        throw Exception('Restoran topilmadi');
      }
    } catch (e) {
      throw Exception('Batafsil ma\'lumotni olishda xatolik: $e');
    }
  }

  // Yaqin atrofdagi restoranlar
  Future<PaginatedResponse<Restaurant>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    int page = 1,
    int perPage = 10,
    String language = 'uz',
  }) async {
    try {
      final queryParams = {
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': radius.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nearbyRestaurants}')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: ApiConstants.headers(language: language));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final dynamic apiData = jsonData['data'];

        if (apiData is List) {
          return PaginatedResponse<Restaurant>(
            data: apiData.map((item) => Restaurant.fromJson(item)).toList(),
            currentPage: 1, lastPage: 1, perPage: apiData.length, total: apiData.length,
          );
        } else {
          return PaginatedResponse.fromJson(apiData, (json) => Restaurant.fromJson(json));
        }
      } else {
        throw Exception('Yaqin atrofdagi restoranlar yuklanmadi');
      }
    } catch (e) {
      throw Exception('Joylashuv bo\'yicha yuklashda xatolik: $e');
    }
  }

  // Eng yaqin restoranlar (List qaytaradi)
  Future<List<Restaurant>> getNearestRestaurants({
    required double latitude,
    required double longitude,
    String language = 'uz',
  }) async {
    try {
      final queryParams = {'lat': latitude.toString(), 'lng': longitude.toString()};
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nearestRestaurants}')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: ApiConstants.headers(language: language));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        return data.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  // Xarita uchun
  Future<List<Restaurant>> getRestaurantsForMap({
    int? categoryId,
    int? cityId,
    double? minRating,
    double? maxRating,
    String language = 'uz',
  }) async {
    try {
      final queryParams = {
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (cityId != null) 'city_id': cityId.toString(),
        if (minRating != null) 'min_rating': minRating.toString(),
        if (maxRating != null) 'max_rating': maxRating.toString(),
      };

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.restaurantsMap}')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: ApiConstants.headers(language: language));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        return data.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  // Kategoriya bo'yicha top restoranlar
  Future<List<Restaurant>> getTopRestaurantsByCategory({
    required int categoryId,
    int limit = 10,
    String language = 'uz',
  }) async {
    try {
      final queryParams = {'limit': limit.toString()};
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.topRestaurantsByCategory(categoryId)}')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: ApiConstants.headers(language: language));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        return data.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }
}