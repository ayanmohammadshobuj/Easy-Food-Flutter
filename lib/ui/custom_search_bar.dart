// lib/ui/custom_search_bar.dart
import 'package:flutter/material.dart';
import 'package:easy_fooods_delivery/component/restaurant_search_screen.dart';

class CustomSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 5.0),
      child: Row(
        children: [
          // Search TextField
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RestaurantSearchScreen()),
                );
              },
              child: Container(
                height: 35.0,
                decoration: BoxDecoration(
                  color: Colors.white, // Light background color
                  borderRadius: BorderRadius.circular(6.0), // Border radius
                ),
                child: Row(
                  children: [
                    // Search Icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.search, color: Colors.black54), // White icon color
                    ),
                    // Placeholder Text
                    Expanded(
                      child: Text(
                        "Search",
                        style: TextStyle(fontSize: 14, color: Colors.black), // White input text color
                      ),
                    ),
                    // Mic Icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.mic, color: Colors.red), // White icon color
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0), // Space between input and filter icon
          // Filter Icon
          Container(
            height: 35.0,
            width: 40.0,
            decoration: BoxDecoration(
              color: Colors.white, // Light background color
              borderRadius: BorderRadius.circular(4.0), // Border radius
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list, color: Colors.black), // RedAccent icon color
              onPressed: () {
                // Handle filter action here
                print("Filter clicked");
              },
            ),
          ),
        ],
      ),
    );
  }
}