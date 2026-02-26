import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../data/models/menu_model.dart';
import '../../../domain/entities/menu.dart';

class MenuRemoteDatasource {
  Future<RestaurantMenu> getRestaurantMenu({required int restaurantId, String language = 'uz'}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.restaurantMenu(restaurantId)}');
      final response = await http.get(uri, headers: ApiConstants.headers(language: language));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final dynamic apiData = jsonData['data'];

        if (apiData is List) {
          final sections = apiData
              .map((section) => MenuSectionModel.fromJson(section as Map<String, dynamic>))
              .toList();
          return RestaurantMenu(restaurantId: restaurantId, restaurantName: '', sections: sections);
        }
        return RestaurantMenuModel.fromJson(apiData);
      } else {
        throw Exception('Failed to load restaurant menu');
      }
    } catch (e) {
      throw Exception('Error fetching restaurant menu: $e');
    }
  }

  Future<MenuItem> getMenuItemDetail({required int menuItemId, String language = 'uz'}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.menuItemDetail(menuItemId)}');
      final response = await http.get(uri, headers: ApiConstants.headers(language: language));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MenuItemModel.fromJson(jsonData['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Menu item not found');
      } else {
        throw Exception('Failed to load menu item details');
      }
    } catch (e) {
      throw Exception('Error fetching menu item details: $e');
    }
  }
}