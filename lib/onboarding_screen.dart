import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onGetStarted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          _buildPage(
            title: 'Welcome',
            content: 'This is the first step of the onboarding process.',
          ),
          _buildPage(
            title: 'Discover',
            content: 'This is the second step of the onboarding process.',
          ),
          _buildPage(
            title: 'Get Started',
            content: 'This is the last step of the onboarding process.',
            isLastPage: true,
          ),
        ],
      ),
      bottomSheet: _currentPage == 2
          ? Container(
        color: Colors.redAccent,
        child: TextButton(
          onPressed: _onGetStarted,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          child: Text('Get Started'),
        ),
      )
          : Container(
        color: Colors.redAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                _pageController.animateToPage(
                  2,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.linear,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: Text('Skip'),
            ),
            TextButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.linear,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String content,
    bool isLastPage = false,
  }) {
    return Container(
      color: Colors.redAccent,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}