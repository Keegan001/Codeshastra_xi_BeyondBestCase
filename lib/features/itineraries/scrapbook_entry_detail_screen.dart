import 'dart:io';
import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/services/scrapbook_service.dart';
import 'package:safar/features/itineraries/add_scrapbook_entry_screen.dart';
import 'package:safar/features/itineraries/edit_scrapbook_layout_screen.dart';
import 'package:safar/utils/map_background_utils.dart';
import 'package:safar/utils/layout_style_utils.dart';
import 'package:safar/features/settings/theme_provider.dart';
import 'package:provider/provider.dart';
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
  late ScrapbookEntry _currentEntry;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
  }

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
              child: Container(
                decoration: _getBackgroundDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMedia(),
                    Padding(
                      padding: LayoutStyleUtils.getLayoutContentPadding(_currentEntry.layoutStyle),
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
                                DateFormat('MMMM d, yyyy • h:mm a').format(_currentEntry.timestamp),
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentEntry.title,
                            style: LayoutStyleUtils.getTitleTextStyle(
                              _currentEntry.layoutStyle,
                              isDarkMode: Theme.of(context).brightness == Brightness.dark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentEntry.content,
                            style: LayoutStyleUtils.getContentTextStyle(
                              _currentEntry.layoutStyle,
                              isDarkMode: Theme.of(context).brightness == Brightness.dark,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_currentEntry.latitude != null && _currentEntry.longitude != null) ...[
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
                                            'Lat: ${_currentEntry.latitude!.toStringAsFixed(6)}, Lng: ${_currentEntry.longitude!.toStringAsFixed(6)}',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.map),
                                      onPressed: () {
                                        MapBackgroundUtils.openInGoogleMaps(
                                          _currentEntry.latitude!,
                                          _currentEntry.longitude!,
                                        );
                                      },
                                      tooltip: 'Open in Maps',
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
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _customizeLayout,
                                  icon: const Icon(Icons.style),
                                  label: const Text('Customize Layout'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.secondaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
            ),
    );
  }

  BoxDecoration _getBackgroundDecoration() {
    // For map backgrounds
    DecorationImage? backgroundImage;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    if (MapBackgroundUtils.isMapStyle(_currentEntry.backgroundStyle) &&
        _currentEntry.latitude != null &&
        _currentEntry.longitude != null) {
      backgroundImage = MapBackgroundUtils.getMapBackgroundDecoration(
        style: _currentEntry.backgroundStyle,
        latitude: _currentEntry.latitude!,
        longitude: _currentEntry.longitude!,
        zoom: _currentEntry.zoomLevel ?? 14.0,
        darkMode: isDarkMode,
      );
    }
    
    // Get layout decoration
    return LayoutStyleUtils.getLayoutDecoration(
      _currentEntry.layoutStyle,
      backgroundImage: backgroundImage,
      backgroundColor: _currentEntry.backgroundStyle == BackgroundStyle.solid 
          ? _currentEntry.backgroundColor
          : null,
      isDarkMode: isDarkMode,
    );
  }

  Widget _buildMedia() {
    if (_currentEntry.type == ScrapbookEntryType.photo && _currentEntry.mediaUrl != null) {
      return _buildPhotoMedia(_currentEntry.mediaUrl!);
    } else if (_currentEntry.type == ScrapbookEntryType.video && _currentEntry.mediaUrl != null) {
      return _buildVideoMedia(_currentEntry.mediaUrl!);
    } else if (_currentEntry.type == ScrapbookEntryType.audio && _currentEntry.mediaUrl != null) {
      return _buildAudioMedia();
    } else if (_currentEntry.type == ScrapbookEntryType.collage && _currentEntry.mediaUrls != null && _currentEntry.mediaUrls!.isNotEmpty) {
      return _buildCollageMedia(_currentEntry.mediaUrls!);
    }
    
    return const SizedBox();
  }
  
  Widget _buildPhotoMedia(String url) {
    final image = url.startsWith('http')
        ? Image.network(url, fit: BoxFit.cover)
        : Image.file(
            File(url.replaceFirst('file://', '')),
            fit: BoxFit.cover,
          );
    
    // For certain layouts, we want a border around the image
    switch (_currentEntry.layoutStyle) {
      case LayoutStyle.polaroid:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: image,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
        
      case LayoutStyle.postcard:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: image,
          ),
        );
        
      case LayoutStyle.journal:
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.brown.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                spreadRadius: 1,
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: image,
          ),
        );
        
      default:
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: image,
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

  Widget _buildCollageMedia(List<String> mediaUrls) {
    final collageLayout = _currentEntry.collageLayout ?? CollageLayout.grid2x2;
    
    switch (collageLayout) {
      case CollageLayout.grid2x2:
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          children: mediaUrls
              .take(4)
              .map(_buildCollageImage)
              .toList(),
        );
      case CollageLayout.grid3x3:
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          children: mediaUrls
              .take(9)
              .map(_buildCollageImage)
              .toList(),
        );
      case CollageLayout.horizontal:
        return SizedBox(
          height: 200,
          child: Row(
            children: mediaUrls
                .take(3)
                .map((url) => Expanded(child: _buildCollageImage(url)))
                .toList(),
          ),
        );
      case CollageLayout.vertical:
        return Column(
          children: mediaUrls
              .take(3)
              .map((url) => SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: _buildCollageImage(url),
                  ))
              .toList(),
        );
      case CollageLayout.featured:
        if (mediaUrls.isEmpty) return const SizedBox();
        if (mediaUrls.length == 1) {
          return _buildCollageImage(mediaUrls.first);
        }
        return Column(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: _buildCollageImage(mediaUrls.first),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 100,
              child: Row(
                children: mediaUrls
                    .skip(1)
                    .take(3)
                    .map((url) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            child: _buildCollageImage(url),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        );
      default:
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          children: mediaUrls
              .take(4)
              .map(_buildCollageImage)
              .toList(),
        );
    }
  }
  
  Widget _buildCollageImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.grey,
                size: 40,
              ),
            ),
          );
        },
      );
    } else if (url.startsWith('file://')) {
      return Image.file(
        File(url.replaceFirst('file://', '')),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.grey,
                size: 40,
              ),
            ),
          );
        },
      );
    }
    
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }

  Future<void> _customizeLayout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScrapbookLayoutScreen(
          entry: _currentEntry,
          itinerary: widget.itinerary,
        ),
      ),
    );
    
    if (result == true) {
      // Reload the entry
      final updatedEntries = await _scrapbookService.getEntriesForItinerary(widget.itinerary.id);
      final updatedEntry = updatedEntries.firstWhere(
        (e) => e.id == _currentEntry.id,
        orElse: () => _currentEntry,
      );
      
      if (mounted) {
        setState(() {
          _currentEntry = updatedEntry;
        });
      }
    }
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
    switch (_currentEntry.type) {
      case ScrapbookEntryType.photo:
        return 'Photo Memory';
      case ScrapbookEntryType.video:
        return 'Video Memory';
      case ScrapbookEntryType.note:
        return 'Note Memory';
      case ScrapbookEntryType.audio:
        return 'Audio Memory';
      case ScrapbookEntryType.collage:
        return 'Photo Collage';
    }
  }

  IconData _getEntryTypeIcon() {
    switch (_currentEntry.type) {
      case ScrapbookEntryType.photo:
        return Icons.photo_camera;
      case ScrapbookEntryType.video:
        return Icons.videocam;
      case ScrapbookEntryType.note:
        return Icons.note;
      case ScrapbookEntryType.audio:
        return Icons.mic;
      case ScrapbookEntryType.collage:
        return Icons.collections;
    }
  }

  Color _getEntryTypeColor() {
    switch (_currentEntry.type) {
      case ScrapbookEntryType.photo:
        return Colors.blue;
      case ScrapbookEntryType.video:
        return Colors.red;
      case ScrapbookEntryType.note:
        return Colors.green;
      case ScrapbookEntryType.audio:
        return Colors.purple;
      case ScrapbookEntryType.collage:
        return Colors.orange;
    }
  }

  String _getEntryTypeText() {
    switch (_currentEntry.type) {
      case ScrapbookEntryType.photo:
        return 'Photo';
      case ScrapbookEntryType.video:
        return 'Video';
      case ScrapbookEntryType.note:
        return 'Note';
      case ScrapbookEntryType.audio:
        return 'Audio';
      case ScrapbookEntryType.collage:
        return 'Collage';
    }
  }
} 