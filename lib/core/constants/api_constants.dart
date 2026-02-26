import 'env.dart';

class ApiConstants {
  // Base URL — defined in env.dart (gitignored)
  static const String baseUrl = Env.baseUrl;

  // Restaurants Endpoints
  static const String restaurants = '/api/restaurants';
  static String restaurantDetail(int id) => '/api/restaurants/$id';
  static String restaurantMenu(int id) => '/api/restaurants/$id/menu';
  static String restaurantReviews(int id) => '/api/restaurants/$id/reviews';
  static const String restaurantsMap = '/api/restaurants/map';
  static const String nearbyRestaurants = '/api/restaurants/nearby';
  static const String nearestRestaurants = '/api/restaurants/nearest';
  static String topRestaurantsByCategory(int categoryId) =>
      '/api/categories/$categoryId/top-restaurants';

  // Menu Endpoints
  static String menuItemDetail(int id) => '/api/menu-items/$id';

  // Search Endpoints
  static const String search = '/api/search';

  // Category Endpoints
  static const String categories = '/api/categories';

  // Review Questions Endpoint
  static const String questions = '/api/questions';

  // Headers
  static Map<String, String> headers({String language = 'uz'}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': language,
    };
  }
}