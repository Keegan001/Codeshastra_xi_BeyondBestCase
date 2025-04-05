import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/models/itinerary.dart';
import 'package:intl/intl.dart';

class ScrapbookEntryDetailScreen extends StatelessWidget {
  final ScrapbookEntry entry;
  final Itinerary itinerary;

  const ScrapbookEntryDetailScreen({
    super.key,
    required this.entry,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit scrapbook entry
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Delete scrapbook entry with confirmation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Entry'),
                  content: const Text('Are you sure you want to delete this scrapbook entry? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Delete entry
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to scrapbook screen
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMedia(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getEntryTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getEntryTypeIcon(),
                              size: 16,
                              color: _getEntryTypeColor(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getEntryTypeText(),
                              style: AppTheme.labelSmall.copyWith(
                                color: _getEntryTypeColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMMM d, yyyy • h:mm a').format(entry.timestamp),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    entry.title,
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    entry.content,
                    style: AppTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  if (entry.latitude != null && entry.longitude != null) ...[
                    const Text(
                      'Location',
                      style: AppTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppTheme.secondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itinerary.destination,
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lat: ${entry.latitude!.toStringAsFixed(6)}, Lng: ${entry.longitude!.toStringAsFixed(6)}',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Open in maps
                              },
                              icon: const Icon(Icons.map),
                              label: const Text('View on Map'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Part of Itinerary',
                    style: AppTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(itinerary.coverImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itinerary.title,
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  itinerary.destination,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${DateFormat('MMM d').format(itinerary.dateRange.start)} - ${DateFormat('MMM d, yyyy').format(itinerary.dateRange.end)}',
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
                  const SizedBox(height: 24),
                  const Text(
                    'Additional Options',
                    style: AppTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Share entry
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share Memory'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Download or export
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (entry.type == ScrapbookEntryType.photo && entry.mediaUrl != null) {
      return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(entry.mediaUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (entry.type == ScrapbookEntryType.video && entry.mediaUrl != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.black,
            child: Center(
              child: Image.asset(
                'assets/images/placeholder.png',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
              onPressed: () {
                // Play video
              },
            ),
          ),
        ],
      );
    } else if (entry.type == ScrapbookEntryType.audio) {
      return Container(
        width: double.infinity,
        height: 150,
        color: AppTheme.backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Play Audio Recording',
                style: AppTheme.labelMedium,
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 150,
        color: AppTheme.backgroundColor,
        child: Center(
          child: Icon(
            _getEntryTypeIcon(),
            size: 64,
            color: _getEntryTypeColor().withOpacity(0.5),
          ),
        ),
      );
    }
  }

  String _getAppBarTitle() {
    switch (entry.type) {
      case ScrapbookEntryType.photo:
        return 'Photo';
      case ScrapbookEntryType.video:
        return 'Video';
      case ScrapbookEntryType.note:
        return 'Note';
      case ScrapbookEntryType.audio:
        return 'Audio';
    }
  }

  IconData _getEntryTypeIcon() {
    switch (entry.type) {
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

  String _getEntryTypeText() {
    switch (entry.type) {
      case ScrapbookEntryType.photo:
        return 'Photo';
      case ScrapbookEntryType.video:
        return 'Video';
      case ScrapbookEntryType.note:
        return 'Note';
      case ScrapbookEntryType.audio:
        return 'Audio';
    }
  }

  Color _getEntryTypeColor() {
    switch (entry.type) {
      case ScrapbookEntryType.photo:
        return Colors.blue;
      case ScrapbookEntryType.video:
        return Colors.red;
      case ScrapbookEntryType.note:
        return Colors.green;
      case ScrapbookEntryType.audio:
        return Colors.purple;
    }
  }
} 