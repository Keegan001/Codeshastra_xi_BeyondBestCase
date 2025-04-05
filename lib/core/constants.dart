class AppConstants {
  // App Info
  static const String appName = 'Safar';
  static const String appVersion = 'v1.0.0';
  static const String appDescription = 'Your travel companion';
  
  // API & Network
  static const String baseUrl = 'https://api.safar.com';
  static const int apiTimeoutSeconds = 30;
  static const String imageBaseUrl = 'https://images.safar.com';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double defaultElevation = 4.0;
  static const double bottomNavBarHeight = 80.0;
  
  // Animation
  static const int animationDurationMs = 300;
  
  // Assets & Placeholders
  static const String placeholderImagePath = 'assets/images/placeholder.png';
  static const String userPlaceholderPath = 'assets/images/user_placeholder.png';
  static const String logoPath = 'assets/images/logo.png';
  
  // Cache
  static const int cacheDurationHours = 24;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // String Constants
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String noResultsFound = 'No results found';
  static const String loadingText = 'Loading...';
  
  // Feature Flags
  static const bool enableNotifications = true;
  static const bool enableDarkMode = false;
  static const bool enableOfflineMode = true;
  
  // Sample Data - For Phase 1 UI
  static const List<Map<String, dynamic>> popularDestinations = [
    {
      'name': 'Paris',
      'country': 'France',
      'image': 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Tokyo',
      'country': 'Japan',
      'image': 'https://images.unsplash.com/photo-1536098561742-ca998e48cbcc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'New York',
      'country': 'USA',
      'image': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Bali',
      'country': 'Indonesia',
      'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'Rome',
      'country': 'Italy',
      'image': 'https://images.unsplash.com/photo-1525874684015-58379d421a52?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80',
    },
    {
      'name': 'London',
      'country': 'UK',
      'image': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80',
    },
  ];
  
  // Travel Tips for Home Screen
  static const List<String> travelTips = [
    'Pack light and smart',
    'Make digital copies of important documents',
    'Learn a few local phrases',
    'Get travel insurance',
    'Use offline maps when possible',
    'Always carry a portable charger',
    'Try the local cuisine',
    'Stay hydrated during flights',
  ];
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String userId = 'user_id';
  static const String refreshToken = 'refresh_token';
  static const String userInfo = 'user_info';
  static const String settings = 'app_settings';
  static const String lastSyncTime = 'last_sync_time';
  static const String offlineData = 'offline_data';
  static const String language = 'app_language';
}

class RouteNames {
  static const String home = '/home';
  static const String explore = '/explore';
  static const String itineraries = '/itineraries';
  static const String itineraryDetails = '/itinerary/details';
  static const String itineraryCreate = '/itinerary/create';
  static const String itineraryEdit = '/itinerary/edit';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String settings = '/settings';
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String onboarding = '/onboarding';
  static const String destination = '/destination';
  static const String search = '/search';
  static const String notifications = '/notifications';
}

enum SortOptions {
  newest,
  oldest,
  nameAZ,
  nameZA,
  mostPopular,
  highestRated,
}

enum TravelMode {
  flight,
  train,
  car,
  bus,
  cruise,
  walking,
  other,
}

enum TripStatus {
  planning,
  booked,
  inProgress,
  completed,
  cancelled,
}

enum WeatherType {
  sunny,
  partlyCloudy,
  cloudy,
  rainy,
  snowy,
  stormy,
} 