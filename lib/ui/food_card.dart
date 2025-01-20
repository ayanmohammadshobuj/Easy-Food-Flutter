import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_fooods_delivery/component/food/food_view_dialog.dart';
import 'package:easy_fooods_delivery/model/restaurant.dart';

class FoodCard extends StatefulWidget {
  final Food food;
  final int restaurantId;

  const FoodCard({Key? key, required this.food, required this.restaurantId}) : super(key: key);

  @override
  _FoodCardState createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  int? _cartQuantity;
  int? _cartId;
  bool _showQuantitySelector = false;

  @override
  void initState() {
    super.initState();
    _fetchCartQuantity();
  }

  Future<void> _fetchCartQuantity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('http://localhost:8000/api/cart-item/food/${widget.food.id}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _cartQuantity = responseData['quantity'];
        _cartId = responseData['id']; // Store the cartId
      });
    } else {
      setState(() {
        _cartQuantity = null;
      });
    }
  }

  Future<void> _addToCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.put(
      Uri.parse('http://localhost:8000/api/cart/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'foodId': widget.food.id, 'quantity': 1}),
    );

    if (response.statusCode == 200) {
      _fetchCartQuantity();
    } else {
      throw Exception('Failed to add to cart');
    }
  }

  Future<void> _updateCartQuantity(int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.put(
      Uri.parse('http://localhost:8000/api/cart-item/food/${widget.food.id}/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      _fetchCartQuantity();
    } else {
      throw Exception('Failed to update cart quantity');
    }
  }

  Future<void> _removeFromCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    print('Removing cart item with ID: $_cartId'); // Log the cartId

    final response = await http.delete(
      Uri.parse('http://localhost:8000/api/cart-item/$_cartId/remove'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      _fetchCartQuantity();
    } else {
      print('Failed to remove from cart: ${response.body}');
      throw Exception('Failed to remove from cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => FoodViewDialog(foodId: widget.food.id, restaurantId: widget.restaurantId),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.memory(
                    base64Decode(widget.food.image),
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 130,
                        width: double.infinity,
                        color: Colors.grey,
                        child: Icon(Icons.error, color: Colors.white),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _cartQuantity == null
                      ? GestureDetector(
                    onTap: _addToCart,
                    child: Icon(Icons.add_circle_outlined, color: Colors.white, size: 28),
                  )
                      : GestureDetector(
                    onTap: () {
                      setState(() {
                        _showQuantitySelector = !_showQuantitySelector;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$_cartQuantity',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                if (_showQuantitySelector)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: _buildQuantitySelector(),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.food.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.food.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tk ${widget.food.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(_cartQuantity == 1 ? Icons.delete : Icons.remove),
            onPressed: () {
              if (_cartQuantity == 1) {
                _removeFromCart();
                setState(() {
                  _showQuantitySelector = false;
                });
              } else {
                _updateCartQuantity(_cartQuantity! - 1);
                setState(() {
                  _cartQuantity = _cartQuantity! - 1;
                });
              }
            },
          ),
          Text('$_cartQuantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _updateCartQuantity(_cartQuantity! + 1);
              setState(() {
                _cartQuantity = _cartQuantity! + 1;
              });
            },
          ),
        ],
      ),
    );
  }
}