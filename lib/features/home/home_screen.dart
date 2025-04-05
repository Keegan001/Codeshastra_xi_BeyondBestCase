import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/core/constants.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/widgets/custom_button.dart';
import 'package:safar/widgets/custom_card.dart';
import 'package:safar/features/itineraries/itinerary_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Dummy data - would come from an API in phase 2
    final dummyItineraries = Itinerary.dummyList();
    final popularDestinations = AppConstants.popularDestinations;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar with Profile
              _buildAppBar(),
              
              // Hero Section
              _buildHeroSection(context),
              
              // My Itineraries Section
              const SizedBox(height: 24),
              _buildSectionHeader(
                'My Itineraries', 
                'View All',
                onPressed: () {
                  // Navigate to Itineraries screen
                  // Will be implemented in navigation setup
                },
              ),
              const SizedBox(height: 16),
              _buildItinerariesList(dummyItineraries),
              
              // Discover Destinations
              const SizedBox(height: 32),
              _buildSectionHeader('Discover Destinations', 'Explore'),
              const SizedBox(height: 16),
              _buildDestinationsList(popularDestinations),
              
              // Travel Tips
              const SizedBox(height: 32),
              _buildSectionHeader('Travel Tips', 'More'),
              const SizedBox(height: 16),
              _buildTravelTips(),
              
              // Bottom spacing
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Custom App Bar with Profile
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, John',
                style: AppTheme.headingMedium,
              ),
              Text(
                'Ready to plan your next adventure?',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor,
            backgroundImage: const NetworkImage(
              'https://ui-avatars.com/api/?name=John+Doe&background=4F46E5&color=fff',
            ),
          ),
        ],
      ),
    );
  }

  // Hero Section with Search
  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomCard(
        variant: CardVariant.gradient,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Where to next?',
                        style: AppTheme.headingSmall.copyWith(
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a new itinerary for your next dream destination',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flight_takeoff,
                    size: 28,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Create New Itinerary',
              onPressed: () {
                // Navigate to create itinerary screen
                // Will be implemented in navigation setup
              },
              iconData: Icons.add,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  // Section Header with Title and Action Button
  Widget _buildSectionHeader(String title, String actionText, {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.headingSmall,
          ),
          TextButton(
            onPressed: onPressed ?? () {},
            child: Row(
              children: [
                Text(
                  actionText,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Itineraries Horizontal List
  Widget _buildItinerariesList(List<Itinerary> itineraries) {
    if (itineraries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.map_outlined,
                size: 48,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No itineraries yet',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first itinerary to get started',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Create Itinerary',
                onPressed: () {
                  // Navigate to create itinerary
                },
                variant: ButtonVariant.primary,
                size: ButtonSize.medium,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: itineraries.length,
        itemBuilder: (context, index) {
          final itinerary = itineraries[index];
          return _buildItineraryCard(itinerary);
        },
      ),
    );
  }

  // Single Itinerary Card
  Widget _buildItineraryCard(Itinerary itinerary) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: CustomCard(
        variant: CardVariant.gradient,
        onTap: () {
          // Navigate to itinerary details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItineraryDetailScreen(
                itinerary: itinerary,
              ),
            ),
          );
        },
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: NetworkImage(_getImageForDestination(itinerary.destination)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                  
                  // Destination name
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itinerary.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          itinerary.destination,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Private indicator
                  if (itinerary.isPrivate)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Private',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Info section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateRange(
                          itinerary.dateRange.start, 
                          itinerary.dateRange.end,
                        ),
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${itinerary.dateRange.durationInDays} days',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Destinations Horizontal List
  Widget _buildDestinationsList(List<Map<String, dynamic>> destinations) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final destination = destinations[index];
          return _buildDestinationCard(
            name: destination['name'],
            country: destination['country'],
            imageUrl: destination['image'],
            isFeatured: index == 0, // First item is featured
          );
        },
      ),
    );
  }

  // Single Destination Card
  Widget _buildDestinationCard({
    required String name,
    required String country,
    required String imageUrl,
    bool isFeatured = false,
  }) {
    // For phase 1, we'll use placeholder images
    String imageUrlPlaceholder;
    if (name.toLowerCase().contains('paris')) {
      imageUrlPlaceholder = 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else if (name.toLowerCase().contains('tokyo')) {
      imageUrlPlaceholder = 'https://images.unsplash.com/photo-1536098561742-ca998e48cbcc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else if (name.toLowerCase().contains('new york')) {
      imageUrlPlaceholder = 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else if (name.toLowerCase().contains('bali')) {
      imageUrlPlaceholder = 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else if (name.toLowerCase().contains('rome')) {
      imageUrlPlaceholder = 'https://images.unsplash.com/photo-1525874684015-58379d421a52?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else {
      imageUrlPlaceholder = 'https://images.unsplash.com/photo-1500835556837-99ac94a94552?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    }
    
    return Container(
      width: isFeatured ? 260 : 180,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          // Navigate to destination detail or create itinerary
        },
        child: Stack(
          children: [
            // Image and gradient
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrlPlaceholder,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  );
                },
              ),
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isFeatured ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.place,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        country,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Featured badge
            if (isFeatured)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Popular',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Travel Tips Section
  Widget _buildTravelTips() {
    final tips = AppConstants.travelTips;
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            child: CustomCard(
              variant: CardVariant.gradient,
              onTap: () {
                // Show tip detail or related content
              },
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTipIcon(index),
                      size: 28,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tip #${index + 1}',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip,
                          style: const TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Helper method to get an icon for a tip
  IconData _getTipIcon(int index) {
    final icons = [
      Icons.luggage,
      Icons.description,
      Icons.translate,
      Icons.health_and_safety,
      Icons.map,
    ];
    
    return icons[index % icons.length];
  }
  
  // Helper method to get image for a destination
  String _getImageForDestination(String destination) {
    if (destination.toLowerCase().contains('paris')) {
      return 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else if (destination.toLowerCase().contains('tokyo')) {
      return 'https://images.unsplash.com/photo-1536098561742-ca998e48cbcc?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else if (destination.toLowerCase().contains('bali')) {
      return 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else if (destination.toLowerCase().contains('new york')) {
      return 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else if (destination.toLowerCase().contains('rome')) {
      return 'https://images.unsplash.com/photo-1525874684015-58379d421a52?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    } else {
      return 'https://images.unsplash.com/photo-1500835556837-99ac94a94552?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=600&q=80';
    }
  }
  
  // Helper method to format a date range
  String _formatDateRange(DateTime start, DateTime end) {
    // Simple date formatting
    final startMonth = _getShortMonthName(start.month);
    final endMonth = _getShortMonthName(end.month);
    
    if (start.year == end.year && start.month == end.month) {
      return '$startMonth ${start.day}-${end.day}';
    } else if (start.year == end.year) {
      return '$startMonth ${start.day} - $endMonth ${end.day}';
    } else {
      return '$startMonth ${start.year} - $endMonth ${end.year}';
    }
  }
  
  // Helper method to get short month name
  String _getShortMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
} 