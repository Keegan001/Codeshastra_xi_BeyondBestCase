import 'dart:io';
import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/services/scrapbook_service.dart';
import 'package:safar/features/itineraries/add_scrapbook_entry_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ScrapbookEntryDetailScreen extends StatefulWidget {
  final ScrapbookEntry entry;
  final Itinerary itinerary;

  const ScrapbookEntryDetailScreen({
    super.key,
    required this.entry,
    required this.itinerary,
  });

  @override
  State<ScrapbookEntryDetailScreen> createState() => _ScrapbookEntryDetailScreenState();
}

class _ScrapbookEntryDetailScreenState extends State<ScrapbookEntryDetailScreen> {
  final ScrapbookService _scrapbookService = ScrapbookService();
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editEntry,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Deleting entry...'),
                ],
              ),
            )
          : SingleChildScrollView(
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
                              DateFormat('MMMM d, yyyy • h:mm a').format(widget.entry.timestamp),
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.entry.title,
                          style: AppTheme.headingMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.entry.content,
                          style: AppTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        if (widget.entry.latitude != null && widget.entry.longitude != null) ...[
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
                                          widget.itinerary.destination,
                                          style: AppTheme.bodyMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Lat: ${widget.entry.latitude!.toStringAsFixed(6)}, Lng: ${widget.entry.longitude!.toStringAsFixed(6)}',
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
                                      image: NetworkImage(widget.itinerary.coverImage),
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
                                        widget.itinerary.title,
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.itinerary.destination,
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${DateFormat('MMM d').format(widget.itinerary.dateRange.start)} - ${DateFormat('MMM d, yyyy').format(widget.itinerary.dateRange.end)}',
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
                          'Share this Memory',
                          style: AppTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _shareEntry,
                            icon: const Icon(Icons.share),
                            label: const Text('Share with Friends'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
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

  Widget _buildMedia() {
    if (widget.entry.type == ScrapbookEntryType.photo && widget.entry.mediaUrl != null) {
      return _buildPhotoMedia(widget.entry.mediaUrl!);
    } else if (widget.entry.type == ScrapbookEntryType.video && widget.entry.mediaUrl != null) {
      return _buildVideoMedia(widget.entry.mediaUrl!);
    } else if (widget.entry.type == ScrapbookEntryType.audio) {
      return _buildAudioMedia();
    } else {
      return _buildPlaceholderMedia();
    }
  }

  Widget _buildPhotoMedia(String mediaUrl) {
    if (mediaUrl.startsWith('file://')) {
      final filePath = mediaUrl.replaceFirst('file://', '');
      return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(filePath)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(mediaUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  Widget _buildVideoMedia(String mediaUrl) {
    // In a real app, we'd display the video with a video player
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 300,
          color: Colors.black,
          child: mediaUrl.startsWith('file://')
              ? Center(
                  child: Icon(
                    Icons.videocam,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                )
              : Image.asset(
                  'assets/images/placeholder.png',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
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
              // In a real app, we'd play the video here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video playback not implemented in demo'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAudioMedia() {
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
              child: IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
                onPressed: () {
                  // In a real app, we'd play the audio here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Audio playback not implemented in demo'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
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
  }

  Widget _buildPlaceholderMedia() {
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

  void _editEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScrapbookEntryScreen(
          itinerary: widget.itinerary,
          entryToEdit: widget.entry,
        ),
      ),
    );
    
    if (result == true) {
      // Entry was updated
      Navigator.pop(context, true); // Return true to update the scrapbook screen
    }
  }

  void _confirmDelete() {
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
            onPressed: _deleteEntry,
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteEntry() async {
    Navigator.pop(context); // Close dialog
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      final success = await _scrapbookService.deleteEntry(
        widget.itinerary.id,
        widget.entry.id,
      );
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry deleted successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true); // Return true to refresh the scrapbook screen
        }
      } else {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete entry'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting entry: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _shareEntry() async {
    final String text = '${widget.entry.title}\n\n${widget.entry.content}\n\nFrom my trip to ${widget.itinerary.destination} on ${DateFormat('MMMM d, yyyy').format(widget.entry.timestamp)}';
    
    try {
      if (widget.entry.mediaUrl != null && widget.entry.type == ScrapbookEntryType.photo) {
        final String mediaUrl = widget.entry.mediaUrl!;
        if (mediaUrl.startsWith('file://')) {
          // Local file
          final filePath = mediaUrl.replaceFirst('file://', '');
          await Share.shareXFiles(
            [XFile(filePath)],
            text: text,
            subject: widget.entry.title,
          );
        } else {
          // Remote file - in a real app, we'd download it first
          await Share.share(
            '$text\n\nPhoto: $mediaUrl',
            subject: widget.entry.title,
          );
        }
      } else {
        // Share text only
        await Share.share(
          text,
          subject: widget.entry.title,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getAppBarTitle() {
    switch (widget.entry.type) {
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
    switch (widget.entry.type) {
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
    switch (widget.entry.type) {
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
    switch (widget.entry.type) {
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