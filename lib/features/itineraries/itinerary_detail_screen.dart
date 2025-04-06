import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/widgets/custom_button.dart';
import 'package:safar/models/day.dart';
import 'package:safar/models/activity.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/features/itineraries/scrapbook_screen.dart';
import 'package:safar/features/itineraries/day_detail_screen.dart';
import 'package:safar/features/itineraries/scrapbook_entry_detail_screen.dart';
import 'package:safar/services/api_service.dart';
import 'package:intl/intl.dart';

import 'add_scrapbook_entry_screen.dart';

class ItineraryDetailScreen extends StatefulWidget {
  final Itinerary itinerary;

  const ItineraryDetailScreen({
    super.key,
    required this.itinerary,
  });

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  late Itinerary _itinerary;
  bool _isLoading = true;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _itinerary = widget.itinerary;
    _loadCompleteItinerary();
  }

  Future<void> _loadCompleteItinerary() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      print('Loading complete itinerary with ID: ${_itinerary.id}');
      
      // First attempt with complete data
      try {
        final completeItinerary = await _apiService.getCompleteItineraryById(_itinerary.id);
        setState(() {
          _itinerary = completeItinerary;
          _isLoading = false;
        });
        print('Successfully loaded complete itinerary');
        return; // Exit early if successful
      } catch (e) {
        print('Error loading complete itinerary: $e');
        
        // If complete load fails, try getting just the days
        try {
          final days = await _apiService.getDaysForItinerary(_itinerary.id);
          setState(() {
            _itinerary = _itinerary.copyWith(days: days);
            _isLoading = false;
          });
          print('Successfully loaded days');
          return; // Exit if this succeeds
        } catch (daysError) {
          print('Error loading days: $daysError');
          
          // If all else fails, just use the existing itinerary
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to load additional itinerary details. Some features may be limited.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load itinerary details: ${e.toString()}';
        _isLoading = false;
      });
      print('Fatal error in _loadCompleteItinerary: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTripDetails(),
                _buildTabBar(),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItineraryTab(),
                _buildInfoTab(),
                _buildScrapbookTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // Will be used to edit itinerary
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.itinerary.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.itinerary.coverImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                );
              },
            ),
            // Gradient overlay for better text visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            widget.itinerary.isPrivate ? Icons.lock : Icons.public,
            color: Colors.white,
          ),
          onPressed: () {
            // Toggle privacy
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.share,
            color: Colors.white,
          ),
          onPressed: () {
            // Share itinerary
          },
        ),
      ],
    );
  }

  Widget _buildTripDetails() {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.itinerary.destination,
                  style: AppTheme.headingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.calendar_today,
                  '${dateFormat.format(widget.itinerary.dateRange.start)} - ${dateFormat.format(widget.itinerary.dateRange.end)}',
                  'Dates',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.attach_money,
                  widget.itinerary.budgetTierText,
                  'Budget',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.flight,
                  widget.itinerary.transportationMode,
                  'Transportation',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.people,
                  widget.itinerary.packageTypeText,
                  'Trip Type',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.secondaryColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondaryColor,
        tabs: const [
          Tab(text: 'Itinerary'),
          Tab(text: 'Info'),
          Tab(text: 'Scrapbook'),
        ],
      ),
    );
  }

  Widget _buildItineraryTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Retry',
              onPressed: _loadCompleteItinerary,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      );
    }
    
    if (_itinerary.days.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 48, color: AppTheme.secondaryColor),
            const SizedBox(height: 16),
            Text(
              'No days added to this itinerary yet.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Add Day',
              onPressed: () {
                // Add day functionality
              },
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      );
    }
    
    // Sort days by date
    final sortedDays = List<Day>.from(_itinerary.days)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        return _buildDayCard(day, index);
      },
    );
  }

  Widget _buildDayCard(Day day, int dayIndex) {
    final dayNumber = dayIndex + 1;
    final dateFormat = DateFormat('EEE, MMM d');
    
    // Debug info
    print('Building day card for day ${day.id} with ${day.activities.length} activities');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Check if the day has activities
          if (day.activities.isEmpty) {
            print('Day has no activities, preloading them before navigation');
            _preloadActivitiesAndNavigate(day);
          } else {
            print('Day already has ${day.activities.length} activities, navigating directly');
            _navigateToDayDetail(day);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          dateFormat.format(day.date),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (day.activities.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: day.activities.length > 3 ? 3 : day.activities.length,
                itemBuilder: (context, index) {
                  final activity = day.activities[index];
                  return ListTile(
                    leading: _getActivityIcon(activity.type),
                    title: Text(activity.title),
                    subtitle: Text(
                      _getActivityTimeRange(activity.startTime, activity.endTime),
                      style: AppTheme.bodySmall,
                    ),
                    trailing: activity.cost != null && activity.cost! > 0
                        ? Text(
                            '\$${activity.cost!.toStringAsFixed(0)}',
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryColor),
                          )
                        : null,
                  );
                },
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No activities scheduled for this day'),
              ),
            if (day.activities.length > 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  '+ ${day.activities.length - 3} more activities',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryColor),
                ),
              ),
            if (day.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes:',
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.notes,
                      style: AppTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Text(
                'View Details',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryColor),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActivityIcon(ActivityType type) {
    IconData iconData;
    Color color;
    
    switch (type) {
      case ActivityType.attraction:
        iconData = Icons.photo_camera;
        color = Colors.blue;
        break;
      case ActivityType.dining:
        iconData = Icons.restaurant;
        color = Colors.orange;
        break;
      case ActivityType.transportation:
        iconData = Icons.directions_car;
        color = Colors.green;
        break;
      case ActivityType.accommodation:
        iconData = Icons.hotel;
        color = Colors.purple;
        break;
      case ActivityType.event:
        iconData = Icons.event;
        color = Colors.red;
        break;
      case ActivityType.leisure:
        iconData = Icons.beach_access;
        color = Colors.teal;
        break;
      default:
        iconData = Icons.pin_drop;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _getActivityTimeRange(DateTime start, DateTime end) {
    final timeFormat = DateFormat('h:mm a');
    return '${timeFormat.format(start)} - ${timeFormat.format(end)}';
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notes section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.note, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Trip Notes',
                        style: AppTheme.headingSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.itinerary.notes.isEmpty
                        ? 'No notes added for this trip yet.'
                        : widget.itinerary.notes,
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Edit Notes',
                    onPressed: () {
                      // Edit notes functionality
                    },
                    variant: ButtonVariant.outlined,
                    iconData: Icons.edit,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Created and updated info
          Text(
            'Created: ${DateFormat('MMM d, yyyy').format(widget.itinerary.createdAt)}',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last Updated: ${DateFormat('MMM d, yyyy').format(widget.itinerary.updatedAt)}',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Trip actions
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Delete Trip',
                  onPressed: () {
                    // Delete trip functionality with confirmation
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Trip'),
                        content: const Text(
                          'Are you sure you want to delete this trip? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Delete trip
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Go back to previous screen
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: AppTheme.errorColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  variant: ButtonVariant.outlined,
                  iconData: Icons.delete,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Duplicate Trip',
                  onPressed: () {
                    // Duplicate trip functionality
                  },
                  variant: ButtonVariant.outlined,
                  iconData: Icons.copy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrapbookTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: 'View Full Scrapbook',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScrapbookScreen(
                    itinerary: _itinerary,
                  ),
                ),
              ).then((_) {
                // Refresh data when returning from scrapbook
                _loadCompleteItinerary();
              });
            },
            variant: ButtonVariant.primary,
            iconData: Icons.photo_album,
            isFullWidth: true,
          ),
        ),
        Expanded(
          child: _itinerary.scrapbookEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.photo_album_outlined,
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No scrapbook entries yet',
                        style: AppTheme.headingSmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Capture memories from your trip with photos, videos, and notes',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Add First Entry',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddScrapbookEntryScreen(
                                itinerary: _itinerary,
                              ),
                            ),
                          ).then((_) {
                            // Refresh data when returning from adding an entry
                            _loadCompleteItinerary();
                          });
                        },
                        variant: ButtonVariant.primary,
                        iconData: Icons.add_photo_alternate,
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _itinerary.scrapbookEntries.length > 4 
                      ? 4 // Show only the first 4 entries in preview
                      : _itinerary.scrapbookEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _itinerary.scrapbookEntries[index];
                    return _buildScrapbookEntryCard(entry);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildScrapbookEntryCard(ScrapbookEntry entry) {
    return InkWell(
      onTap: () {
        // View entry detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScrapbookEntryDetailScreen(
              entry: entry,
              itinerary: widget.itinerary,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          image: entry.mediaUrl != null
              ? DecorationImage(
                  image: NetworkImage(entry.mediaUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          color: entry.mediaUrl == null ? AppTheme.secondaryColor : null,
        ),
        child: Stack(
          children: [
            // Gradient overlay for text visibility
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: AppTheme.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d').format(entry.timestamp),
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getScrapbookEntryTypeIcon(entry.type),
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getScrapbookEntryTypeIcon(ScrapbookEntryType type) {
    switch (type) {
      case ScrapbookEntryType.photo:
        return Icons.photo;
      case ScrapbookEntryType.video:
        return Icons.videocam;
      case ScrapbookEntryType.note:
        return Icons.note;
      case ScrapbookEntryType.audio:
        return Icons.mic;
    }
  }

  Future<void> _preloadActivitiesAndNavigate(Day day) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loading activities...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    try {
      // Try to fetch activities for the day
      final activities = await _apiService.getActivitiesForDay(_itinerary.id, day.id);
      print('Preloaded ${activities.length} activities for day ${day.id}');
      
      // Create a new day with the activities
      final dayWithActivities = Day(
        id: day.id,
        date: day.date,
        title: day.title,
        notes: day.notes,
        activities: activities,
      );
      
      // Navigate to the day detail screen
      _navigateToDayDetail(dayWithActivities);
    } catch (e) {
      print('Error preloading activities: $e');
      // Navigate with the original day, the detail screen will handle fetching
      _navigateToDayDetail(day);
    }
  }
  
  void _navigateToDayDetail(Day day) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayDetailScreen(
          day: day,
          destination: _itinerary.destination,
          itineraryId: _itinerary.id,
        ),
      ),
    );
  }
} 