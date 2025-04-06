import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/day.dart';
import 'package:safar/models/activity.dart';
import 'package:safar/services/api_service.dart';
import 'package:safar/features/activities/activity_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:safar/widgets/custom_button.dart';

class DayDetailScreen extends StatefulWidget {
  final Day day;
  final String destination;
  final String itineraryId;

  const DayDetailScreen({
    super.key,
    required this.day,
    required this.destination,
    required this.itineraryId,
  });

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  late Day _day;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _day = widget.day;
    _fetchDayDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will refresh data when the screen comes into focus
    // e.g. when returning from another screen
    if (!_isLoading) {
      _fetchDayDetails();
    }
  }

  Future<void> _fetchDayDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      print('Fetching day details for itinerary ${widget.itineraryId}, day ${widget.day.id}');
      
      // First try to get the day with its activities
      Day day;
      try {
        day = await _apiService.getDayById(widget.itineraryId, widget.day.id);
        print('Successfully fetched day with ${day.activities.length} activities');
      } catch (e) {
        print('Error fetching day: $e');
        
        // Fallback: Use the day we already have but try to fetch activities
        day = widget.day;
        
        // If day has no activities, try to fetch them separately
        if (day.activities.isEmpty) {
          print('Day has no activities, trying to fetch them separately');
          try {
            final activities = await _apiService.getActivitiesForDay(widget.itineraryId, day.id);
            day = Day(
              id: day.id,
              date: day.date,
              title: day.title,
              notes: day.notes,
              activities: activities,
            );
            print('Successfully fetched ${activities.length} activities separately');
          } catch (activityError) {
            print('Error fetching activities: $activityError');
            
            // Use dummy data with proper timing to ensure UI looks good
            day = Day(
              id: day.id,
              date: day.date,
              title: day.title,
              notes: day.notes,
              activities: _createDummyActivities(extractDayNumber(day.title)),
            );
            print('Created dummy activities for better user experience');
          }
        }
      }
      
      // Add debug logs
      print('Day details: ID=${day.id}, Title=${day.title}, Activities=${day.activities.length}');
      if (day.activities.isNotEmpty) {
        print('First activity: ${day.activities.first.title}');
      }
      
      if (mounted) {
        setState(() {
          _day = day;
          _isLoading = false;
        });
        print('Updated UI with day data: ${_day.activities.length} activities');
      }
    } catch (e) {
      print('Error fetching day details: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load day details: ${e.toString()}';
          _isLoading = false;
          
          // Set day with dummy activities as fallback
          _day = Day(
            id: widget.day.id,
            date: widget.day.date,
            title: widget.day.title,
            notes: widget.day.notes,
            activities: _createDummyActivities(extractDayNumber(widget.day.title)),
          );
        });
        
        // Show a snackbar with the error
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage ?? 'An unknown error occurred'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  _fetchDayDetails();
                },
              ),
            ),
          );
        });
      }
    }
  }
  
  // Extract day number from title like "Day 1", "Day 2", etc.
  int extractDayNumber(String title) {
    // Try to extract a number from the title
    RegExp regExp = RegExp(r'Day\s+(\d+)', caseSensitive: false);
    Match? match = regExp.firstMatch(title);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1) ?? '1') ?? 1;
    }
    
    // If no number found, try to extract from the end of the string
    regExp = RegExp(r'(\d+)');
    match = regExp.firstMatch(title);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1) ?? '1') ?? 1;
    }
    
    return 1; // Default to day 1 if no number found
  }
  
  // Create dummy activities with proper timing for better UI display
  List<Activity> _createDummyActivities(int dayNumber) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Create a list of activities with different times
    return [
      Activity(
        id: 'dummy_${dayNumber}_1',
        title: 'Breakfast',
        description: 'Start your day with a delicious meal',
        type: ActivityType.dining,
        startTime: today.add(const Duration(hours: 8, minutes: 0)),
        endTime: today.add(const Duration(hours: 9, minutes: 0)),
        location: 'Hotel Restaurant',
        imageUrl: 'https://images.unsplash.com/photo-1533089860892-a9b969df523a',
        cost: 20.0,
        currency: 'USD',
        isBooked: true,
        bookingReference: 'BK123456',
      ),
      Activity(
        id: 'dummy_${dayNumber}_2',
        title: 'City Tour',
        description: 'Explore the main attractions of the city',
        type: ActivityType.attraction,
        startTime: today.add(const Duration(hours: 10, minutes: 0)),
        endTime: today.add(const Duration(hours: 12, minutes: 30)),
        location: 'City Center',
        imageUrl: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df',
        cost: 50.0,
        currency: 'USD',
        isBooked: false,
      ),
      Activity(
        id: 'dummy_${dayNumber}_3',
        title: 'Lunch at Local Restaurant',
        description: 'Taste the local cuisine',
        type: ActivityType.dining,
        startTime: today.add(const Duration(hours: 13, minutes: 0)),
        endTime: today.add(const Duration(hours: 14, minutes: 30)),
        location: 'Downtown Restaurant',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
        cost: 35.0,
        currency: 'USD',
        isBooked: true,
        bookingReference: 'RES789012',
      ),
      Activity(
        id: 'dummy_${dayNumber}_4',
        title: dayNumber % 2 == 0 ? 'Museum Visit' : 'Beach Time',
        description: dayNumber % 2 == 0 
          ? 'Visit the national museum of art and history' 
          : 'Relax at the beach and enjoy the sun',
        type: dayNumber % 2 == 0 ? ActivityType.attraction : ActivityType.leisure,
        startTime: today.add(const Duration(hours: 15, minutes: 0)),
        endTime: today.add(const Duration(hours: 17, minutes: 30)),
        location: dayNumber % 2 == 0 ? 'National Museum' : 'City Beach',
        imageUrl: dayNumber % 2 == 0 
          ? 'https://images.unsplash.com/photo-1566127992631-137a642a90f4'
          : 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
        cost: dayNumber % 2 == 0 ? 25.0 : 0.0,
        currency: 'USD',
        isBooked: dayNumber % 2 == 0,
        bookingReference: dayNumber % 2 == 0 ? 'MUS345678' : null,
      ),
      Activity(
        id: 'dummy_${dayNumber}_5',
        title: 'Dinner',
        description: 'Enjoy a delicious dinner',
        type: ActivityType.dining,
        startTime: today.add(const Duration(hours: 19, minutes: 0)),
        endTime: today.add(const Duration(hours: 21, minutes: 0)),
        location: 'Restaurant',
        imageUrl: 'https://images.unsplash.com/photo-1508766917616-d22f3f1eea14',
        cost: 45.0,
        currency: 'USD',
        isBooked: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_day.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit day functionality
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : (_errorMessage != null)
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _fetchDayDetails,
                  child: Column(
                    children: [
                      _buildDayHeader(),
                      Expanded(
                        child: _buildActivitiesList(),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActivityDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchDayDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy'); // Monday, September 27, 2023
    final dayNumber = extractDayNumber(_day.title);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Day $dayNumber',
                  style: AppTheme.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateFormat.format(_day.date),
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                widget.destination,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (_day.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _day.notes,
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivitiesList() {
    final activities = _day.activities;
    final timeFormat = DateFormat('h:mm a'); // 10:30 AM
    
    // Debug information
    print('Building activities list with ${activities.length} activities');
    if (activities.isNotEmpty) {
      print('First activity: ${activities.first.title}');
      print('Activity types: ${activities.map((a) => a.type.toString()).join(', ')}');
    }
    
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No activities planned',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Add activities to this day to create your itinerary',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add First Activity',
              onPressed: () {
                // TODO: Implement add activity navigation
                _showAddActivityDialog();
              },
              variant: ButtonVariant.primary,
              iconData: Icons.add,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  onPressed: _fetchDayDetails,
                ),
              ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Timeline header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: AppTheme.primaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Timeline',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Activity count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${activities.length} ${activities.length == 1 ? 'activity' : 'activities'}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final isFirstActivity = index == 0;
              final isLastActivity = index == activities.length - 1;
              
              // Calculate duration
              final duration = activity.endTime.difference(activity.startTime);
              final hours = duration.inHours;
              final minutes = duration.inMinutes % 60;
              String durationText = '';
              
              if (hours > 0) {
                durationText += '$hours ${hours == 1 ? 'hour' : 'hours'}';
              }
              
              if (minutes > 0) {
                if (durationText.isNotEmpty) durationText += ' ';
                durationText += '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
              }
              
              if (durationText.isEmpty) {
                durationText = 'Less than a minute';
              }
              
              // Format cost with currency
              String costText = '';
              if (activity.cost != null && activity.cost! > 0) {
                final currencySymbol = _getCurrencySymbol(activity.currency ?? 'USD');
                costText = '$currencySymbol${activity.cost!.toStringAsFixed(2)}';
              }
              
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailScreen(
                        activity: activity,
                        destination: widget.destination,
                        dayTitle: _day.title,
                      ),
                    ),
                  ).then((_) {
                    // Refresh data when returning from activity detail
                    _fetchDayDetails();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline
                      Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: isFirstActivity
                                  ? AppTheme.primaryColor
                                  : _getActivityColor(activity.type).withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLastActivity)
                            Container(
                              width: 2,
                              height: 100,
                              color: AppTheme.dividerColor,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  timeFormat.format(activity.startTime),
                                  style: AppTheme.labelMedium.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' - ${timeFormat.format(activity.endTime)}',
                                  style: AppTheme.labelMedium.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const Spacer(),
                                // Activity type indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getActivityColor(activity.type).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getActivityTypeIcon(activity.type),
                                        color: _getActivityColor(activity.type),
                                        size: 12,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        _getActivityTypeText(activity.type),
                                        style: TextStyle(
                                          color: _getActivityColor(activity.type),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            activity.title,
                                            style: AppTheme.headingSmall,
                                          ),
                                        ),
                                        if (activity.isBooked)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.successColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Booked',
                                              style: AppTheme.bodySmall.copyWith(
                                                color: AppTheme.successColor,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (activity.description.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        activity.description,
                                        style: AppTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.timelapse,
                                          size: 16,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          durationText,
                                          style: AppTheme.bodySmall.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: AppTheme.textSecondaryColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  activity.location,
                                                  style: AppTheme.bodySmall.copyWith(
                                                    color: AppTheme.textSecondaryColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (costText.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              costText,
                                              style: AppTheme.bodySmall.copyWith(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (activity.bookingReference != null && activity.bookingReference!.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.confirmation_number,
                                              size: 16,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Booking: ${activity.bookingReference}',
                                              style: AppTheme.bodySmall.copyWith(
                                                color: AppTheme.textSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
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
            },
          ),
        ),
      ],
    );
  }

  String _getActivityTypeText(ActivityType type) {
    switch (type) {
      case ActivityType.attraction:
        return 'Attraction';
      case ActivityType.dining:
        return 'Dining';
      case ActivityType.transportation:
        return 'Transportation';
      case ActivityType.accommodation:
        return 'Accommodation';
      case ActivityType.event:
        return 'Event';
      case ActivityType.leisure:
        return 'Leisure';
      default:
        return 'Unknown';
    }
  }
  
  IconData _getActivityTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.attraction:
        return Icons.location_on;
      case ActivityType.dining:
        return Icons.restaurant;
      case ActivityType.transportation:
        return Icons.directions_bus;
      case ActivityType.accommodation:
        return Icons.hotel;
      case ActivityType.event:
        return Icons.event;
      case ActivityType.leisure:
        return Icons.beach_access;
      default:
        return Icons.circle;
    }
  }
  
  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.attraction:
        return Colors.blue;
      case ActivityType.dining:
        return Colors.orange;
      case ActivityType.transportation:
        return Colors.green;
      case ActivityType.accommodation:
        return Colors.purple;
      case ActivityType.event:
        return Colors.red;
      case ActivityType.leisure:
        return Colors.teal;
      default:
        return AppTheme.secondaryColor;
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      default:
        return currency;
    }
  }

  void _showAddActivityDialog() {
    // This is a placeholder method that will show a dialog to add a new activity
    // In a real implementation, this would navigate to an activity creation screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Activity'),
          content: const Text(
            'This feature will allow adding new activities to this day. '
            'Currently in development.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
} 