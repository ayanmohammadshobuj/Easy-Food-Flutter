// lib/component/favourites_screen.dart
import 'package:flutter/material.dart';
import 'package:easy_fooods_delivery/model/favorite.dart';
import 'package:easy_fooods_delivery/services/favorite_service.dart';
import 'package:easy_fooods_delivery/ui/restaurant_favorite_card.dart';

class FavouritesScreen extends StatefulWidget {
  @override
  _FavouritesScreenState createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  late Future<List<Favorite>> futureFavoriteRestaurants;

  @override
  void initState() {
    super.initState();
    futureFavoriteRestaurants = fetchFavoriteRestaurants();
  }

  Future<List<Favorite>> fetchFavoriteRestaurants() async {
    final favoriteService = FavoriteService();
    return await favoriteService.getFavoriteRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Restaurants'),
        backgroundColor: Colors.redAccent,
      ),
      body: FutureBuilder<List<Favorite>>(
        future: futureFavoriteRestaurants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorite restaurants available'));
          }

          final favoriteRestaurants = snapshot.data!;

          return ListView.builder(
            itemCount: favoriteRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = favoriteRestaurants[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: RestaurantFavoriteCard(
                  restaurant: restaurant,
                  onFavoritePressed: () {
                    // Handle favorite logic here
                    print('${restaurant.title} removed from favorites');
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