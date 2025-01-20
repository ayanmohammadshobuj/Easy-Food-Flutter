// lib/ui/restaurant_list_card.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_fooods_delivery/model/restaurant.dart';
import 'package:easy_fooods_delivery/services/restaurant_service.dart';

class RestaurantListCard extends StatefulWidget {
  final Restaurant restaurant;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const RestaurantListCard({
    Key? key,
    required this.restaurant,
    required this.isFavorite,
    required this.onFavoritePressed,
  }) : super(key: key);

  @override
  _RestaurantListCardState createState() => _RestaurantListCardState();
}

class _RestaurantListCardState extends State<RestaurantListCard> {
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
    final imageBytes = base64Decode(widget.restaurant.restaurantImages.dpImage);

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
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image with Delivery Time
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      imageBytes,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 20, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '10-30 min',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
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
              SizedBox(height: 8),
              // Restaurant Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.restaurant.cuisineType,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.pedal_bike, size: 20, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'Free for 1st Order',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                widget.restaurant.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}