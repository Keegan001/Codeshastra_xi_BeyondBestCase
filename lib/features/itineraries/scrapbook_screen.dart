import 'dart:io';
import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/features/itineraries/scrapbook_entry_detail_screen.dart';
import 'package:safar/features/itineraries/add_scrapbook_entry_screen.dart';
import 'package:safar/services/scrapbook_service.dart';
import 'package:intl/intl.dart';

class ScrapbookScreen extends StatefulWidget {
  final Itinerary itinerary;

  const ScrapbookScreen({
    super.key,
    required this.itinerary,
  });

  @override
  State<ScrapbookScreen> createState() => _ScrapbookScreenState();
}

class _ScrapbookScreenState extends State<ScrapbookScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Photos', 'Videos', 'Notes', 'Audio'];
  final ScrapbookService _scrapbookService = ScrapbookService();
  bool _isLoading = true;
  List<ScrapbookEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final entries = await _scrapbookService.getEntriesForItinerary(widget.itinerary.id);
      
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading scrapbook entries: $e');
      if (mounted) {
        setState(() {
          _entries = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading entries: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.itinerary.title} Scrapbook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEntries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildScrapbookEntries(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScrapbookEntryScreen(
                itinerary: widget.itinerary,
              ),
            ),
          );
          
          if (result == true) {
            // Refresh entries if a new one was added
            _loadEntries();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Memory'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
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

  Widget _buildScrapbookEntries() {
    final entries = _getFilteredEntries();
    
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(),
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(),
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _getEmptyStateMessage(),
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
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScrapbookEntryDetailScreen(
                    entry: entry,
                    itinerary: widget.itinerary,
                  ),
                ),
              );
              
              if (result == true) {
                // Refresh if entry was updated or deleted
                _loadEntries();
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.mediaUrl != null && entry.type == ScrapbookEntryType.photo)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: _buildMediaImage(entry.mediaUrl!),
                  ),
                if (entry.mediaUrl != null && entry.type == ScrapbookEntryType.video)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.black,
                          child: _buildVideoThumbnail(entry.mediaUrl!),
                        ),
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                              color: _getEntryTypeColor(entry.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getEntryTypeIcon(entry.type),
                                  size: 16,
                                  color: _getEntryTypeColor(entry.type),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getEntryTypeText(entry.type),
                                  style: AppTheme.labelSmall.copyWith(
                                    color: _getEntryTypeColor(entry.type),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('MMM d, yyyy').format(entry.timestamp),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        entry.title,
                        style: AppTheme.headingSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.content,
                        style: AppTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entry.latitude != null && entry.longitude != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppTheme.secondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${entry.latitude!.toStringAsFixed(4)}, ${entry.longitude!.toStringAsFixed(4)}',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildMediaImage(String mediaUrl) {
    if (mediaUrl.startsWith('file://')) {
      final filePath = mediaUrl.replaceFirst('file://', '');
      return Image.file(
        File(filePath),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    } else {
      return Image.network(
        mediaUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    }
  }

  Widget _buildVideoThumbnail(String mediaUrl) {
    // In a real app, we'd generate a thumbnail for videos
    // For now, just show a placeholder or image with play button
    return Container(
      color: Colors.black,
      child: Center(
        child: Icon(
          Icons.videocam,
          size: 48,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppTheme.backgroundColor,
      child: const Icon(
        Icons.image_not_supported,
        color: AppTheme.textSecondaryColor,
        size: 64,
      ),
    );
  }

  List<ScrapbookEntry> _getFilteredEntries() {
    if (_selectedFilter == 'All') {
      return _entries;
    }
    
    ScrapbookEntryType? typeFilter;
    switch (_selectedFilter) {
      case 'Photos':
        typeFilter = ScrapbookEntryType.photo;
        break;
      case 'Videos':
        typeFilter = ScrapbookEntryType.video;
        break;
      case 'Notes':
        typeFilter = ScrapbookEntryType.note;
        break;
      case 'Audio':
        typeFilter = ScrapbookEntryType.audio;
        break;
    }
    
    return _entries.where((entry) => entry.type == typeFilter).toList();
  }

  IconData _getEmptyStateIcon() {
    switch (_selectedFilter) {
      case 'Photos':
        return Icons.photo_library;
      case 'Videos':
        return Icons.videocam;
      case 'Notes':
        return Icons.note;
      case 'Audio':
        return Icons.mic;
      default:
        return Icons.photo_album;
    }
  }

  String _getEmptyStateTitle() {
    switch (_selectedFilter) {
      case 'Photos':
        return 'No photos yet';
      case 'Videos':
        return 'No videos yet';
      case 'Notes':
        return 'No notes yet';
      case 'Audio':
        return 'No audio recordings yet';
      default:
        return 'No scrapbook entries yet';
    }
  }

  String _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case 'Photos':
        return 'Capture memorable moments from your trip with photos';
      case 'Videos':
        return 'Record videos to remember the special moments';
      case 'Notes':
        return 'Write down your thoughts and experiences';
      case 'Audio':
        return 'Record audio notes or sounds from your journey';
      default:
        return 'Start capturing memories from your trip with photos, videos, notes, and audio recordings';
    }
  }

  IconData _getEntryTypeIcon(ScrapbookEntryType type) {
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

  String _getEntryTypeText(ScrapbookEntryType type) {
    switch (type) {
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

  Color _getEntryTypeColor(ScrapbookEntryType type) {
    switch (type) {
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