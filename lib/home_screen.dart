import 'package:easy_fooods_delivery/component/home_screen_content.dart';
import 'package:easy_fooods_delivery/ui/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'component/account_screen.dart';
import 'component/cart_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'component/favourites_screen.dart';
import 'component/offers_screen.dart';
import 'component/restaurants_screen.dart';
import 'component/login_screen.dart';
import 'component/order_screen.dart'; // Import the order screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  String? _userName;
  String? _profileImage;

  final List<Widget> _screens = [
    HomeScreenContent(),
    FavouritesScreen(),
    OffersScreen(),
    RestaurantsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchUserProfile();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> _fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _userName = data['fullName'];
        });

        final imageResponse = await http.get(
          Uri.parse('http://localhost:8000/api/user/images/jwt'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (imageResponse.statusCode == 200) {
          final Map<String, dynamic> imageData = jsonDecode(imageResponse.body);
          setState(() {
            _profileImage = imageData['displayPicture'];
          });
        }
      }
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    setState(() {
      _isLoggedIn = false;
      _userName = null;
      _profileImage = null;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _checkLoginStatus();
    });

    if (!_isLoggedIn && index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery To',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'example: 358/A East Nakhalpara, Tejgaon, Dhaka-1215',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        titleTextStyle: TextStyle(color: Colors.white),
        backgroundColor: Colors.redAccent,
        iconTheme: IconThemeData(color: Colors.white, size: 20, weight: 4),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 130,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: _profileImage != null
                          ? MemoryImage(base64Decode(_profileImage!))
                          : null,
                      child: _profileImage == null
                          ? Icon(
                        Icons.person,
                        color: Colors.redAccent,
                        size: 50,
                      )
                          : null,
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName ?? 'Guest',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'View Profile',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.home, color: Colors.redAccent),
                      title: Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Arial',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(0);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.event_note, color: Colors.redAccent),
                      title: Text(
                        'Orders',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Arial',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/order_screen'); // Navigate to OrderScreen
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.local_activity, color: Colors.redAccent),
                      title: Text(
                        'Coupons & Offers',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Arial',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(2);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.account_circle, color: Colors.redAccent),
                      title: Text(
                        'Account',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Arial',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AccountScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.monetization_on_rounded, color: Colors.redAccent),
                      title: Text(
                        'Refund Policy',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Arial',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(1);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.perm_contact_cal_rounded, color: Colors.redAccent),
                      title: Text(
                        'Contact Us',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Arial',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(1);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.help, color: Colors.redAccent),
                      title: Text(
                        'Help & Support',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Arial',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(2);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.privacy_tip_outlined, color: Colors.redAccent),
                      title: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Arial',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(3);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              child: ListTile(
                title: _isLoggedIn ? Text('Logout') : Text('Login'),
                onTap: () {
                  Navigator.pop(context);
                  if (_isLoggedIn) {
                    _logout();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                },
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.facebook,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 10),
                      Icon(
                        FontAwesomeIcons.twitter,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 10),
                      Icon(
                        FontAwesomeIcons.instagram,
                        color: Colors.pink,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Follow us on social media',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: CustomSearchBar()

          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, color: Colors.black),
              label: 'Home',
              activeIcon: Icon(Icons.home, color: Colors.redAccent),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_outlined, color: Colors.black),
              activeIcon: Icon(Icons.favorite, color: Colors.redAccent),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined, color: Colors.black),
              activeIcon: Icon(Icons.local_offer, color: Colors.redAccent),
              label: 'Offers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined, color: Colors.black),
              activeIcon: Icon(Icons.restaurant, color: Colors.redAccent),
              label: 'Restaurants',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}