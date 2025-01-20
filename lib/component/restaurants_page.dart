// lib/component/restaurants_page.dart
import 'package:easy_fooods_delivery/model/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_fooods_delivery/ui/restaurant_list_card.dart';
import 'package:easy_fooods_delivery/services/restaurant_service.dart';

class RestaurantsPage extends StatefulWidget {
  @override
  _RestaurantsPageState createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  late Future<List<Restaurant>> futureRestaurants;
  late Future<List<Restaurant>> futureFavoriteRestaurants;

  @override
  void initState() {
    super.initState();
    futureRestaurants = fetchRestaurants();
    futureFavoriteRestaurants = fetchFavoriteRestaurants();
  }

  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await http.get(Uri.parse('http://localhost:8000/open/restaurants'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((restaurant) => Restaurant.fromJson(restaurant)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<List<Restaurant>> fetchFavoriteRestaurants() async {
    final restaurantService = RestaurantService();
    return await restaurantService.getFavoriteRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants'),
      ),
      body: FutureBuilder<List<List<Restaurant>>>(
        future: Future.wait([futureRestaurants, futureFavoriteRestaurants]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data![0].isEmpty) {
            return Center(child: Text('No restaurants available'));
          }

          final restaurants = snapshot.data![0];
          final favoriteRestaurants = snapshot.data![1];

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              final isFavorite = favoriteRestaurants.any((fav) => fav.id == restaurant.id);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: RestaurantListCard(
                  restaurant: restaurant,
                  isFavorite: isFavorite,
                  onFavoritePressed: () {
                    // Handle favorite logic here
                    setState(() {
                      if (isFavorite) {
                        favoriteRestaurants.removeWhere((fav) => fav.id == restaurant.id);
                      } else {
                        favoriteRestaurants.add(restaurant);
                      }
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}