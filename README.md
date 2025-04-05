# Safar - Travel Itinerary Planner

Safar is a mobile app designed to help users plan, organize, and share their travel itineraries. The app provides a seamless experience for managing travel plans, discovering destinations, and connecting with other travelers.

## Features

- **Itinerary Management**: Create and manage detailed travel itineraries with day-by-day planning
- **Destination Discovery**: Explore popular and trending destinations with curated information
- **Social Sharing**: Share your itineraries with friends or make them public for the community
- **Profile & Stats**: Track your travel history, visited countries, and upcoming trips
- **Offline Access**: Access your itineraries even without internet connection

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/safar.git
cd safar
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants.dart  # App-wide constants
│   └── theme.dart      # App theme and styling
├── features/
│   ├── home/           # Home screen
│   ├── explore/        # Destination discovery
│   ├── itineraries/    # Itinerary management
│   └── profile/        # User profile
├── models/
│   ├── user.dart       # User model
│   ├── itinerary.dart  # Itinerary model
│   ├── day.dart        # Day model
│   └── activity.dart   # Activity model
├── services/
│   ├── api_service.dart     # API interactions
│   └── storage_service.dart # Local storage
├── utils/
│   ├── formatters.dart  # Date, currency formatters
│   └── validators.dart  # Input validation
└── widgets/
    ├── custom_button.dart   # Reusable button
    ├── custom_card.dart     # Reusable card
    ├── custom_nav_bar.dart  # Navigation bar
    └── itinerary_card.dart  # Itinerary display
```

## Tech Stack

- **Flutter**: UI framework
- **Provider**: State management
- **Shared Preferences**: Local storage
- **HTTP**: API communication
- **Intl**: Internationalization and formatting
- **Flutter Map**: Map integration

## Roadmap

- **Phase 1**: Core functionality and UI implementation (Current)
- **Phase 2**: Backend integration and real API implementation
- **Phase 3**: Advanced features (Weather integration, AI recommendations)
- **Phase 4**: Social features and sharing enhancements

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Design inspiration from various travel apps
- Flutter team for the amazing framework
- All contributors who help improve the app
