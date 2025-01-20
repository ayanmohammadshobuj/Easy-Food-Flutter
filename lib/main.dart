import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'component/restaurant_view.dart';
import 'model/restaurant.dart';
import 'component/cart_screen.dart';
import 'component/order_screen.dart'; // Import the order screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;

  const MyApp({required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: seenOnboarding ? HomeScreen() : OnboardingScreen(),
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      routes: {
        '/order_screen': (context) => OrderScreen(), // Define the order screen route
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/restaurant-view') {
          final restaurant = settings.arguments as Restaurant;
          return MaterialPageRoute(
            builder: (context) => RestaurantView(restaurant: restaurant),
          );
        } else if (settings.name == '/cart') {
          return MaterialPageRoute(
            builder: (context) => CartScreen(), // Define the cart screen route
          );
        }
        return null;
      },
    );
  }
}