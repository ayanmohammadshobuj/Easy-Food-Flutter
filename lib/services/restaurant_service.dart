// lib/services/restaurant_service.dart
import 'dart:convert';
import 'package:easy_fooods_delivery/model/restaurant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantService {
  static const String _baseUrl = 'http://localhost:8000/open/restaurants';

  Future<List<Restaurant>> getRestaurants() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<void> addToFavorites(int restaurantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/$restaurantId/add-favourites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      print('Failed to add to favorites: ${response.body}');
      throw Exception('Failed to add to favorites');
    }
  }

  Future<List<Restaurant>> getFavoriteRestaurants() async {
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
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load favorite restaurants');
    }
  }
}