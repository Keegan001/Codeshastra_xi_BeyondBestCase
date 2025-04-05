import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/widgets/custom_button.dart';
import 'package:safar/models/day.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/features/itineraries/scrapbook_screen.dart';
import 'package:safar/features/itineraries/day_detail_screen.dart';
import 'package:safar/features/itineraries/scrapbook_entry_detail_screen.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
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
    final days = widget.itinerary.days;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        return _buildDayCard(day, index);
      },
    );
  }

  Widget _buildDayCard(Day day, int dayIndex) {
    final activities = day.activities;
    final dateFormatter = DateFormat('E, MMM d'); // Wed, Sep 27
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DayDetailScreen(
                day: day,
                destination: widget.itinerary.destination,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Day ${dayIndex + 1}',
                    style: AppTheme.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${dateFormatter.format(day.date)}',
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.title,
                    style: AppTheme.headingSmall,
                  ),
                  if (day.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        day.notes,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    '${activities.length} Activities',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length > 3 ? 3 : activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(_getActivityTypeIcon(activity.type)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activity.title,
                                style: AppTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (activities.length > 3)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DayDetailScreen(
                                day: day,
                                destination: widget.itinerary.destination,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'View All ${activities.length} Activities',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.primaryColor,
                          ),
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
    final scrapbookEntries = widget.itinerary.scrapbookEntries;
    
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
                    itinerary: widget.itinerary,
                  ),
                ),
              );
            },
            variant: ButtonVariant.primary,
            iconData: Icons.photo_album,
            isFullWidth: true,
          ),
        ),
        Expanded(
          child: scrapbookEntries.isEmpty
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
                          // Add scrapbook entry functionality
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
                  itemCount: scrapbookEntries.length,
                  itemBuilder: (context, index) {
                    final entry = scrapbookEntries[index];
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

  IconData _getActivityTypeIcon(dynamic type) {
    if (type == null) return Icons.access_time;
    
    switch (type) {
      case 0: // attraction
        return Icons.attractions;
      case 1: // dining
        return Icons.restaurant;
      case 2: // transportation
        return Icons.directions_car;
      case 3: // accommodation
        return Icons.hotel;
      case 4: // event
        return Icons.event;
      case 5: // leisure
        return Icons.beach_access;
      default:
        return Icons.schedule;
    }
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
} 