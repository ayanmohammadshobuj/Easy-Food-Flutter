// lib/component/restaurant_search_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_fooods_delivery/model/restaurant.dart';
import 'package:easy_fooods_delivery/ui/restaurant_list_card.dart';

class RestaurantSearchScreen extends StatefulWidget {
  @override
  _RestaurantSearchScreenState createState() => _RestaurantSearchScreenState();
}

class _RestaurantSearchScreenState extends State<RestaurantSearchScreen> {
  List<Restaurant> _searchResults = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  Future<void> _searchRestaurants(String keyword) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('http://localhost:8000/open/restaurants/search/anything?keyword=$keyword'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _searchResults = data.map((json) => Restaurant.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load search results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Restaurants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search restaurants...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchRestaurants(value);
                } else {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return RestaurantListCard(
                  restaurant: _searchResults[index],
                  isFavorite: false,
                  onFavoritePressed: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}