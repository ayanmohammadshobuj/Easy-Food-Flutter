// lib/component/home_screen_content.dart
import 'package:easy_fooods_delivery/ui/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_fooods_delivery/model/restaurant.dart';
import 'package:easy_fooods_delivery/ui/offer_card.dart';
import 'package:easy_fooods_delivery/component/restaurants_page.dart';
import 'package:easy_fooods_delivery/services/restaurant_service.dart';

class HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
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
    return ListView(
      children: [
        // Offers Section
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              OfferCard(
                imageUrl: 'https://images.deliveryhero.io/image/fd-bd/campaign-assets/56d7d978-8b76-11ef-89ea-8ef8580cd68b/desktop_landing_Enorpn.png?height=450&quality=95&width=2000&?width=2000',
              ),
              OfferCard(
                imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpK1noS9RwpA351YDfG9dRCvSON-j5nZHU0A&s',
              ),
              OfferCard(
                imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpK1noS9RwpA351YDfG9dRCvSON-j5nZHU0A&s',
              ),
            ],
          ),
        ),

        // Fast Delivery Section
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fast Delivery',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Restaurant Cards Section
        FutureBuilder<List<List<Restaurant>>>(
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

            return SizedBox(
              height: 240, // Slightly increased height for the card
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  final isFavorite = favoriteRestaurants.any((fav) => fav.id == restaurant.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RestaurantCard(
                      restaurant: restaurant,
                      isFavorite: isFavorite,
                      onFavoritePressed: () {
                        // Handle favorite logic here
                        print('${restaurant.name} added to favorites');
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),

        SizedBox(height: 16),

        // Promotional Section
        Stack(
          children: [
            Container(
              height: 280,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpK1noS9RwpA351YDfG9dRCvSON-j5nZHU0A&s'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 200,
              color: Colors.black.withOpacity(0.5),
            ),
            Center(
              child: Text(
                'Order Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}