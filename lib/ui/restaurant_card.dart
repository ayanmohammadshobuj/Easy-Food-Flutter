// lib/ui/restaurant_card.dart
import 'package:flutter/material.dart';
import 'package:easy_fooods_delivery/model/restaurant.dart';
import 'package:easy_fooods_delivery/services/restaurant_service.dart';
import 'dart:convert';

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.isFavorite,
    required this.onFavoritePressed,
  }) : super(key: key);

  @override
  _RestaurantCardState createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() async {
    final restaurantService = RestaurantService();
    try {
      await restaurantService.addToFavorites(widget.restaurant.id);
      setState(() {
        _isFavorite = !_isFavorite;
      });
      widget.onFavoritePressed();
    } catch (e) {
      // Handle error
      print('Failed to add to favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/restaurant-view',
          arguments: widget.restaurant,
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          width: size.width * 0.8, // 80% of the display width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.memory(
                      base64Decode(widget.restaurant.restaurantImages.coverImage),
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Favorite Icon
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Icon(
                        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _isFavorite ? Colors.redAccent : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              // Restaurant Details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Cuisine Type
                    Text(
                      widget.restaurant.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.restaurant.cuisineType,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),

                    // Rating, Delivery Time, and Free Delivery
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              widget.restaurant.totalRating.toStringAsFixed(1),
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),

                        // Delivery Time
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 20, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              '10-30 min',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),

                        // Free Delivery
                        Row(
                          children: [
                            Icon(Icons.delivery_dining, size: 20, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              'Free for 1st Order',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}