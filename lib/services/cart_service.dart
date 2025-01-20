// lib/services/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_fooods_delivery/model/cart_item.dart';

class CartService {
  static const String _baseUrl = 'http://localhost:8000/api/cart';

  Future<List<CartItem>> getCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> cartItems = data['cartItems'];
      return cartItems.map((json) => CartItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> updateCartItem(int foodId, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.put(
      Uri.parse('http://localhost:8000/api/cart-item/food/$foodId/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart item');
    }
  }

  Future<void> deleteCartItem(int cartItemId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.delete(
      Uri.parse('http://localhost:8000/api/cart-item/$cartItemId/remove'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete cart item');
    }
  }
}
