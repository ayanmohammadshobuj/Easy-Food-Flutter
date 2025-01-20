// lib/component/restaurants_screen.dart
import 'package:flutter/material.dart';
import 'package:easy_fooods_delivery/model/restaurant.dart';
import 'package:easy_fooods_delivery/services/restaurant_service.dart';
import 'package:easy_fooods_delivery/ui/restaurant_list_card.dart';

class RestaurantsScreen extends StatefulWidget {
  @override
  _RestaurantsScreenState createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  late Future<List<Restaurant>> futureRestaurants;
  late Future<List<Restaurant>> futureFavoriteRestaurants;

  @override
  void initState() {
    super.initState();
    futureRestaurants = fetchRestaurants();
    futureFavoriteRestaurants = fetchFavoriteRestaurants();
  }

  Future<List<Restaurant>> fetchRestaurants() async {
    final restaurantService = RestaurantService();
    return await restaurantService.getRestaurants();
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
        backgroundColor: Colors.redAccent,
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