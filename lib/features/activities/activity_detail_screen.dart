import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/activity.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safar/widgets/custom_button.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Activity activity;
  final String destination;
  final String dayTitle;

  const ActivityDetailScreen({
    Key? key,
    required this.activity,
    required this.destination,
    required this.dayTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildDetails(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Edit activity functionality
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          activity.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (activity.imageUrl != null)
              Image.network(
                activity.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: _getActivityColor(activity.type).withOpacity(0.3),
                    child: Center(
                      child: Icon(
                        _getActivityTypeIcon(activity.type),
                        size: 64,
                        color: _getActivityColor(activity.type),
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                color: _getActivityColor(activity.type).withOpacity(0.3),
                child: Center(
                  child: Icon(
                    _getActivityTypeIcon(activity.type),
                    size: 64,
                    color: _getActivityColor(activity.type),
                  ),
                ),
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
        if (activity.isBooked)
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Booked',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
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
    String costText = 'Free';
    if (activity.cost != null && activity.cost! > 0) {
      final currencySymbol = _getCurrencySymbol(activity.currency ?? 'USD');
      costText = '$currencySymbol${activity.cost!.toStringAsFixed(2)}';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity type and day
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
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
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getActivityTypeText(activity.type),
                      style: TextStyle(
                        color: _getActivityColor(activity.type),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dayTitle,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Time and Duration
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(activity.startTime),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Time',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              timeFormat.format(activity.startTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End Time',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              timeFormat.format(activity.endTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Duration',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              durationText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Location Card with Map
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                  title: const Text('Location'),
                  subtitle: Text(activity.location),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => _openMap(context),
                ),
                if (activity.latitude != null && activity.longitude != null)
                  GestureDetector(
                    onTap: () => _openMap(context),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://maps.googleapis.com/maps/api/staticmap?center=${activity.latitude},${activity.longitude}&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7C${activity.latitude},${activity.longitude}&key=YOUR_API_KEY',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Open in Maps',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cost and Booking Section
          Card(
            elevation: 1,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cost',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              costText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: activity.cost != null && activity.cost! > 0
                                    ? AppTheme.primaryColor
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (activity.isBooked && activity.bookingReference != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Booking Reference',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                activity.bookingReference!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (!activity.isBooked) ...[
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Make Reservation',
                      onPressed: () {
                        // Make reservation functionality
                      },
                      variant: ButtonVariant.primary,
                      iconData: Icons.confirmation_number,
                      isFullWidth: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          if (activity.description.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              activity.description,
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Share',
                  onPressed: () {
                    // Share activity functionality
                  },
                  variant: ButtonVariant.outlined,
                  iconData: Icons.share,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: activity.isBooked ? 'View Booking' : 'Add to Calendar',
                  onPressed: () {
                    // Add to calendar or view booking functionality
                  },
                  variant: ButtonVariant.outlined,
                  iconData: activity.isBooked ? Icons.confirmation_number : Icons.calendar_today,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 50), // For FAB spacing
        ],
      ),
    );
  }

  void _openMap(BuildContext context) async {
    String mapUrl;
    
    if (activity.latitude != null && activity.longitude != null) {
      // Open with coordinates
      mapUrl = 'https://www.google.com/maps/search/?api=1&query=${activity.latitude},${activity.longitude}';
    } else {
      // Open with location name
      final encodedLocation = Uri.encodeComponent('${activity.location}, $destination');
      mapUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
    }
    
    if (await canLaunchUrl(Uri.parse(mapUrl))) {
      await launchUrl(Uri.parse(mapUrl));
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open map application'),
          ),
        );
      }
    }
  }

  IconData _getActivityTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.attraction:
        return Icons.photo_camera;
      case ActivityType.dining:
        return Icons.restaurant;
      case ActivityType.transportation:
        return Icons.directions_car;
      case ActivityType.accommodation:
        return Icons.hotel;
      case ActivityType.event:
        return Icons.event;
      case ActivityType.leisure:
        return Icons.beach_access;
      default:
        return Icons.pin_drop;
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
        return Colors.grey;
    }
  }

  String _getActivityTypeText(ActivityType type) {
    switch (type) {
      case ActivityType.attraction:
        return 'Attraction';
      case ActivityType.dining:
        return 'Dining';
      case ActivityType.transportation:
        return 'Transport';
      case ActivityType.accommodation:
        return 'Accommodation';
      case ActivityType.event:
        return 'Event';
      case ActivityType.leisure:
        return 'Leisure';
      default:
        return 'Activity';
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
} 