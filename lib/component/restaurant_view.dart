// lib/component/restaurant_view.dart
import 'package:flutter/material.dart';
import 'package:easy_fooods_delivery/model/restaurant.dart';
import 'package:easy_fooods_delivery/services/restaurant_service.dart';
import '../ui/food_card.dart';

class RestaurantView extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantView({super.key, required this.restaurant});

  @override
  State<RestaurantView> createState() => _RestaurantViewState();
}

class _RestaurantViewState extends State<RestaurantView> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = false; // Initialize with the actual favorite status
    _fetchFavoriteStatus();
  }

  Future<void> _fetchFavoriteStatus() async {
    final restaurantService = RestaurantService();
    final favoriteRestaurants = await restaurantService.getFavoriteRestaurants();
    setState(() {
      _isFavorite = favoriteRestaurants.any((fav) => fav.id == widget.restaurant.id);
    });
  }

  void _toggleFavorite() async {
    final restaurantService = RestaurantService();
    try {
      await restaurantService.addToFavorites(widget.restaurant.id);
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      // Handle error
      print('Failed to add to favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Image.asset(
            'images/discount1.jpeg', // Replace with the path to your logo image
            height: 40, // Adjust the height as needed
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.redAccent : Colors.black,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTitleSection(),
          const SizedBox(height: 16),
          _buildHeaderSection(),
          const SizedBox(height: 16),
          _buildOffersSection(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildCategoriesSection(),
          const SizedBox(height: 16),
          _buildPopularSection(),
          const SizedBox(height: 16),
          _buildFoodItemsSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/cart'); // Navigate to the cart screen
        },
        label: Text('View Your Cart'),
        icon: Icon(Icons.shopping_cart),
        backgroundColor: Colors.redAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.restaurant.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.deepOrange, size: 14),
            const Icon(Icons.star, color: Colors.deepOrange, size: 14),
            const Icon(Icons.star, color: Colors.deepOrange, size: 14),
            const Icon(Icons.star, color: Colors.deepOrange, size: 14),
            const Icon(Icons.star_border, color: Colors.deepOrange, size: 14),
            const SizedBox(width: 4),
            Text(
              "${widget.restaurant.totalRating} (15000+ ratings)",
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.directions_bike, color: Colors.black),
              Container(
                child: Text(
                  "Delivery 15–30 min",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Text("Change",
                  style: TextStyle(fontSize: 15, color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Free delivery for first order",
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
            const SizedBox(width: 8),
            const Text(
              "tk 39",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const Text(
              " Min. order Tk 50",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOffersSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOfferCard(
          "40% off (CRAZY)",
          "Min. order Tk 399. Valid for all items. Use in cart.",
        ),
        _buildOfferCard(
          "25% off (YUMPANDA)",
          "Min. order Tk 199. Valid for all items.",
        ),
      ],
    );
  }

  Widget _buildOfferCard(String title, String description) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(8),
            right: Radius.circular(8),
          ),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: "Search in menu",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: widget.restaurant.categories.map((category) {
            return Chip(
              label: Text(category.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularSection() {
    final popularFoods = widget.restaurant.foods.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🔥 Popular",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
          ),
          itemCount: popularFoods.length,
          itemBuilder: (context, index) {
            return FoodCard(food: popularFoods[index], restaurantId: widget.restaurant.id);
          },
        ),
      ],
    );
  }

  Widget _buildFoodItem(String imagePath, String name) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 150,
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.restaurant.categories.map((category) {
        final categoryFoods = widget.restaurant.foods
            .where((food) => food.foodCategory.id == category.id)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemCount: categoryFoods.length,
              itemBuilder: (context, index) {
                return FoodCard(food: categoryFoods[index], restaurantId: widget.restaurant.id);
              },
            ),
          ],
        );
      }).toList(),
    );
  }
}