// lib/services/favorite_service.dart
import 'dart:convert';
import 'package:easy_fooods_delivery/model/favorite.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _baseUrl = 'http://localhost:8000/open/restaurants';

  Future<List<Favorite>> getFavoriteRestaurants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/favorites'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Favorite.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load favorite restaurants');
    }
  }
}