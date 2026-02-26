import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../domain/entities/restaurant.dart';

class CategoryRemoteDatasource {
  Future<List<Category>> getCategories({String language = 'uz'}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}');
    final response = await http.get(uri, headers: ApiConstants.headers(language: language));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List;
      return data
          .map((item) => _categoryFromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Categories yuklashda xato: ${response.statusCode}');
  }

  Category _categoryFromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}