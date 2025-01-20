import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_fooods_delivery/model/restaurant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_fooods_delivery/ui/food_card.dart';

class FoodViewDialog extends StatefulWidget {
  final int foodId;
  final int restaurantId;

  const FoodViewDialog({Key? key, required this.foodId, required this.restaurantId}) : super(key: key);

  @override
  _FoodViewDialogState createState() => _FoodViewDialogState();
}

class _FoodViewDialogState extends State<FoodViewDialog> {
  late Future<Food> _foodFuture;
  late Future<List<Food>> _restaurantFoodsFuture;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _foodFuture = _fetchFoodDetails(widget.foodId);
    _restaurantFoodsFuture = _fetchRestaurantFoods(widget.restaurantId);
  }

  Future<Food> _fetchFoodDetails(int foodId) async {
    final response = await http.get(Uri.parse('http://localhost:8000/anyone/food/$foodId'));

    if (response.statusCode == 200) {
      return Food.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load food details');
    }
  }

  Future<List<Food>> _fetchRestaurantFoods(int restaurantId) async {
    final response = await http.get(Uri.parse('http://localhost:8000/anyone/restaurant/$restaurantId/foods'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Food.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurant foods');
    }
  }

  Future<void> _addToCart(int foodId, int quantity) async {
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
      body: json.encode({'foodId': foodId, 'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to cart: ${responseData['food']['name']}')),
      );
      Navigator.pop(context); // Close the dialog
    } else {
      throw Exception('Failed to add to cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Food>(
      future: _foodFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data found'));
        } else {
          final food = snapshot.data!;
          return _buildFoodViewDialog(context, food);
        }
      },
    );
  }

  Widget _buildFoodViewDialog(BuildContext context, Food food) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.85,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.memory(
                    base64Decode(food.image),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  food.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Tk ${food.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, color: Colors.pink),
                ),
                SizedBox(height: 8.0),
                Text(
                  food.description,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Frequently Bought Together',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Add frequently bought together items here
                SizedBox(height: 8.0),
                Text(
                  'Other Customers Also Ordered',
                  style: TextStyle(fontSize: 14),
                ),
                // Add other customer ordered items here
                SizedBox(height: 16.0),
                Text(
                  'Other Foods from this Restaurant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                FutureBuilder<List<Food>>(
                  future: _restaurantFoodsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return Center(child: Text('No data found'));
                    } else {
                      final foods = snapshot.data!;
                      return Column(
                        children: foods.take(4).map((food) => FoodCard(food: food, restaurantId: widget.restaurantId)).toList(),
                      );
                    }
                  },
                ),
                SizedBox(height: 16.0),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Handle view more action
                    },
                    child: Text('View More'),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_quantity > 1) _quantity--;
                            });
                          },
                        ),
                        Text('$_quantity'), // Default quantity
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _addToCart(food.id, _quantity);
                      },
                      icon: Icon(Icons.shopping_cart),
                      label: Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Button color
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}