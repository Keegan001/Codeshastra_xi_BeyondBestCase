import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/features/home/home_screen.dart';
import 'package:safar/features/explore/explore_screen.dart';
import 'package:safar/features/itineraries/itineraries_screen.dart';
import 'package:safar/features/profile/profile_screen.dart';
import 'package:safar/features/settings/theme_provider.dart';
import 'package:safar/widgets/custom_nav_bar.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const SafarApp(),
    ),
  );
}

class SafarApp extends StatelessWidget {
  const SafarApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Force portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Safar',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    ItinerariesScreen(),
    ProfileScreen(),
  ];
  
  final List<String> _titles = [
    'Home',
    'Explore',
    'Itineraries',
    'Profile',
  ];
  
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
