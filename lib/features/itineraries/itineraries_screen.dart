import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/widgets/custom_button.dart';
import 'package:safar/widgets/itinerary_card.dart';
import 'package:safar/features/itineraries/itinerary_detail_screen.dart';
import 'package:safar/features/itineraries/create_itinerary_screen.dart';

class ItinerariesScreen extends StatefulWidget {
  const ItinerariesScreen({super.key});

  @override
  State<ItinerariesScreen> createState() => _ItinerariesScreenState();
}

class _ItinerariesScreenState extends State<ItinerariesScreen> {
  // Dummy data for phase 1
  final List<Itinerary> _itineraries = Itinerary.dummyList();
  
  // Filter options
  String _currentFilter = 'All';
  final List<String> _filterOptions = ['All', 'Upcoming', 'Past', 'Private', 'Public'];
  
  // Filtered itineraries
  List<Itinerary> get _filteredItineraries {
    final now = DateTime.now();
    
    switch (_currentFilter) {
      case 'Upcoming':
        return _itineraries
            .where((itinerary) => itinerary.dateRange.start.isAfter(now))
            .toList();
      case 'Past':
        return _itineraries
            .where((itinerary) => itinerary.dateRange.end.isBefore(now))
            .toList();
      case 'Private':
        return _itineraries
            .where((itinerary) => itinerary.isPrivate)
            .toList();
      case 'Public':
        return _itineraries
            .where((itinerary) => !itinerary.isPrivate)
            .toList();
      case 'All':
      default:
        return _itineraries;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar with Title
            _buildAppBar(),
            
            // Filter Chips
            _buildFilterChips(),
            
            // Itineraries List or Empty State
            Expanded(
              child: _filteredItineraries.isEmpty
                  ? _buildEmptyState()
                  : _buildItinerariesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create itinerary - will be implemented in phase 2
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('New Itinerary'),
      ),
    );
  }

  // App Bar with Title and Back Button
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Itineraries',
                style: AppTheme.headingMedium,
              ),
              Text(
                'Manage your travel plans',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Filter Chips for itinerary types
  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _currentFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryColor.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected 
                    ? AppTheme.primaryColor 
                    : AppTheme.textSecondaryColor,
                fontWeight: isSelected 
                    ? FontWeight.w600 
                    : FontWeight.normal,
              ),
              checkmarkColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.dividerColor,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          );
        },
      ),
    );
  }

  // Itineraries List
  Widget _buildItinerariesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItineraries.length,
      itemBuilder: (context, index) {
        final itinerary = _filteredItineraries[index];
        return ItineraryCard(
          itinerary: itinerary,
          isDetailed: true,
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
        );
      },
    );
  }

  // Empty State when no itineraries match filter
  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (_currentFilter) {
      case 'Upcoming':
        message = 'No upcoming itineraries';
        icon = Icons.event;
        break;
      case 'Past':
        message = 'No past itineraries';
        icon = Icons.history;
        break;
      case 'Private':
        message = 'No private itineraries';
        icon = Icons.lock;
        break;
      case 'Public':
        message = 'No public itineraries';
        icon = Icons.public;
        break;
      case 'All':
      default:
        message = 'No itineraries found';
        icon = Icons.map;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilter != 'All'
                  ? 'Try changing your filter or create a new itinerary'
                  : 'Create your first itinerary to get started',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Create New Itinerary',
              onPressed: () {
                // Navigate to create itinerary
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateItineraryScreen(),
                  ),
                );
              },
              variant: ButtonVariant.primary,
              iconData: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
} 