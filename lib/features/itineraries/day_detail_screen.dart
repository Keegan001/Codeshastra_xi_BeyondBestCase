import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/day.dart';
import 'package:safar/models/activity.dart';
import 'package:intl/intl.dart';

class DayDetailScreen extends StatelessWidget {
  final Day day;
  final String destination;

  const DayDetailScreen({
    super.key,
    required this.day,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(day.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit day functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDayHeader(),
          Expanded(
            child: _buildActivitiesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new activity
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDayHeader() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy'); // Monday, September 27, 2023
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(day.date),
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                destination,
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
          if (day.notes.isNotEmpty) ...[
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
                      day.notes,
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
    final activities = day.activities;
    final timeFormat = DateFormat('h:mm a'); // 10:30 AM
    
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
                'Add activities to plan your day',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
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
        
        return InkWell(
          onTap: () {
            // View activity details
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
                            : AppTheme.secondaryColor,
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
                      Text(
                        timeFormat.format(activity.startTime),
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.primaryColor,
                        ),
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
                                  Icon(
                                    _getActivityTypeIcon(activity.type),
                                    color: _getActivityColor(activity.type),
                                  ),
                                  const SizedBox(width: 8),
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
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            size: 12,
                                            color: AppTheme.successColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Booked',
                                            style: AppTheme.labelSmall.copyWith(
                                              color: AppTheme.successColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                activity.description,
                                style: AppTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${timeFormat.format(activity.startTime)} - ${timeFormat.format(activity.endTime)} ($durationText)',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
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
                              if (activity.cost != null && activity.cost! > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_money,
                                      size: 16,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '\$${activity.cost!.toStringAsFixed(2)}',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (activity.bookingReference != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.confirmation_number,
                                      size: 16,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ref: ${activity.bookingReference}',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (activity.imageUrl != null) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    activity.imageUrl!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        width: double.infinity,
                                        color: AppTheme.backgroundColor,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
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
    );
  }

  IconData _getActivityTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.attraction:
        return Icons.attractions;
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
        return Icons.schedule;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.attraction:
        return Colors.orange;
      case ActivityType.dining:
        return Colors.red;
      case ActivityType.transportation:
        return Colors.blue;
      case ActivityType.accommodation:
        return Colors.purple;
      case ActivityType.event:
        return Colors.green;
      case ActivityType.leisure:
        return Colors.teal;
      default:
        return AppTheme.primaryColor;
    }
  }
} 