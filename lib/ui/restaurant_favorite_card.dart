// lib/ui/restaurant_favorite_card.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_fooods_delivery/model/favorite.dart';

class RestaurantFavoriteCard extends StatelessWidget {
  final Favorite restaurant;
  final VoidCallback onFavoritePressed;

  const RestaurantFavoriteCard({
    Key? key,
    required this.restaurant,
    required this.onFavoritePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageBytes = base64Decode(restaurant.dpImage);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                imageBytes,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            // Restaurant Details
            Text(
              restaurant.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              restaurant.cuisine,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              restaurant.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            // Favorite Button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.favorite, color: Colors.redAccent),
                onPressed: onFavoritePressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}