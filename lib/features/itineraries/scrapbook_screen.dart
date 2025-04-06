import 'dart:io';
import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/features/itineraries/scrapbook_entry_detail_screen.dart';
import 'package:safar/features/itineraries/add_scrapbook_entry_screen.dart';
import 'package:safar/features/itineraries/collage_creator_screen.dart';
import 'package:safar/services/scrapbook_service.dart';
import 'package:safar/utils/map_background_utils.dart';
import 'package:safar/utils/layout_style_utils.dart';
import 'package:safar/features/settings/theme_provider.dart';
import 'package:provider/provider.dart';
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
  bool _isGridView = false; // Toggle between list and grid view

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
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
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
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
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
            icon: const Icon(Icons.photo_camera),
            tooltip: 'Add Memory',
          ),
          ActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CollageCreatorScreen(
                    itinerary: widget.itinerary,
                  ),
                ),
              );
              
              if (result == true) {
                // Refresh entries if a new one was added
                _loadEntries();
              }
            },
            icon: const Icon(Icons.collections),
            tooltip: 'Create Collage',
          ),
        ],
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
    
    // Choose between grid and list view
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return _buildGridEntryCard(entries[index]);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return _buildListEntryCard(entries[index]);
        },
      );
    }
  }
  
  Widget _buildGridEntryCard(ScrapbookEntry entry) {
    // Prepare background decoration
    DecorationImage? backgroundImage;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    if (MapBackgroundUtils.isMapStyle(entry.backgroundStyle) &&
        entry.latitude != null &&
        entry.longitude != null) {
      backgroundImage = MapBackgroundUtils.getMapBackgroundDecoration(
        style: entry.backgroundStyle,
        latitude: entry.latitude!,
        longitude: entry.longitude!,
        zoom: entry.zoomLevel ?? 14.0,
        darkMode: isDarkMode,
      );
    }
    
    // Use layout style for decoration
    final decoration = LayoutStyleUtils.getLayoutDecoration(
      entry.layoutStyle,
      backgroundImage: backgroundImage,
      backgroundColor: entry.backgroundStyle == BackgroundStyle.solid 
          ? entry.backgroundColor 
          : null,
      isDarkMode: isDarkMode,
    );
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToEntryDetail(entry),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: decoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.type == ScrapbookEntryType.photo && entry.mediaUrl != null)
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: _buildMediaImage(entry.mediaUrl!),
                  ),
                ),
              if (entry.type == ScrapbookEntryType.video && entry.mediaUrl != null)
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildMediaImage(entry.mediaUrl!),
                        const CircleAvatar(
                          backgroundColor: Colors.black45,
                          radius: 20,
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (entry.type == ScrapbookEntryType.collage && entry.mediaUrls != null && entry.mediaUrls!.isNotEmpty)
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: _buildCollagePreview(entry),
                  ),
                ),
              Expanded(
                flex: (entry.mediaUrl != null && 
                      (entry.type == ScrapbookEntryType.photo || 
                       entry.type == ScrapbookEntryType.video)) ||
                      (entry.type == ScrapbookEntryType.collage && 
                       entry.mediaUrls != null && 
                       entry.mediaUrls!.isNotEmpty)
                     ? 2 : 5,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getEntryTypeColor(entry.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getEntryTypeIcon(entry.type),
                                  size: 12,
                                  color: _getEntryTypeColor(entry.type),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _getEntryTypeText(entry.type),
                                  style: AppTheme.labelSmall.copyWith(
                                    color: _getEntryTypeColor(entry.type),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.title,
                        style: LayoutStyleUtils.getTitleTextStyle(
                          entry.layoutStyle,
                          isDarkMode: isDarkMode,
                        ).copyWith(
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          entry.content,
                          style: LayoutStyleUtils.getContentTextStyle(
                            entry.layoutStyle,
                            isDarkMode: isDarkMode,
                          ).copyWith(
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(entry.timestamp),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildListEntryCard(ScrapbookEntry entry) {
    // Prepare background decoration
    DecorationImage? backgroundImage;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    if (MapBackgroundUtils.isMapStyle(entry.backgroundStyle) &&
        entry.latitude != null &&
        entry.longitude != null) {
      backgroundImage = MapBackgroundUtils.getMapBackgroundDecoration(
        style: entry.backgroundStyle,
        latitude: entry.latitude!,
        longitude: entry.longitude!,
        zoom: entry.zoomLevel ?? 14.0,
        darkMode: isDarkMode,
      );
    }
    
    final decoration = LayoutStyleUtils.getLayoutDecoration(
      entry.layoutStyle,
      borderRadius: BorderRadius.circular(16),
      backgroundImage: backgroundImage,
      backgroundColor: entry.backgroundStyle == BackgroundStyle.solid 
          ? entry.backgroundColor 
          : null,
      isDarkMode: isDarkMode,
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: decoration,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToEntryDetail(entry),
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
                      _buildMediaImage(entry.mediaUrl!),
                      const CircleAvatar(
                        backgroundColor: Colors.black45,
                        radius: 24,
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: LayoutStyleUtils.getLayoutContentPadding(entry.layoutStyle),
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
                      style: LayoutStyleUtils.getTitleTextStyle(
                        entry.layoutStyle,
                        isDarkMode: isDarkMode,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.content,
                      style: LayoutStyleUtils.getContentTextStyle(
                        entry.layoutStyle,
                        isDarkMode: isDarkMode,
                      ),
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
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Location attached',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.grey,
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
      ),
    );
  }
  
  Future<void> _navigateToEntryDetail(ScrapbookEntry entry) async {
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
  }

  Widget _buildMediaImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
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
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
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
      width: double.infinity,
      height: 200,
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
      case ScrapbookEntryType.collage:
        return Colors.orange;
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
      case ScrapbookEntryType.collage:
        return 'Collage';
    }
  }

  Widget _buildCollagePreview(ScrapbookEntry entry) {
    if (entry.mediaUrls == null || entry.mediaUrls!.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(child: Text('No images')),
      );
    }

    final mediaUrls = entry.mediaUrls!;
    
    switch (entry.collageLayout) {
      case CollageLayout.grid2x2:
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          children: mediaUrls
              .take(4)
              .map((url) => _buildMediaImage(url))
              .toList(),
        );
      case CollageLayout.grid3x3:
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          children: mediaUrls
              .take(9)
              .map((url) => _buildMediaImage(url))
              .toList(),
        );
      case CollageLayout.horizontal:
        return Row(
          children: mediaUrls
              .take(3)
              .map((url) => Expanded(child: _buildMediaImage(url)))
              .toList(),
        );
      case CollageLayout.vertical:
        return Column(
          children: mediaUrls
              .take(3)
              .map((url) => Expanded(child: _buildMediaImage(url)))
              .toList(),
        );
      case CollageLayout.featured:
        if (mediaUrls.length == 1) {
          return _buildMediaImage(mediaUrls.first);
        }
        return Column(
          children: [
            Expanded(flex: 2, child: _buildMediaImage(mediaUrls.first)),
            const SizedBox(height: 2),
            Expanded(
              child: Row(
                children: mediaUrls
                    .skip(1)
                    .take(3)
                    .map((url) => Expanded(child: _buildMediaImage(url)))
                    .toList(),
              ),
            ),
          ],
        );
      default:
        // Default grid2x2
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          children: mediaUrls
              .take(4)
              .map((url) => _buildMediaImage(url))
              .toList(),
        );
    }
  }
}

// Expandable FAB implementation
class ExpandableFab extends StatefulWidget {
  final double distance;
  final List<Widget> children;

  const ExpandableFab({
    super.key,
    required this.distance,
    required this.children,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);

    for (var i = 0; i < count; i++) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: 90.0 - (step * i),
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }

    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton.extended(
            onPressed: _toggle,
            icon: const Icon(Icons.add),
            label: const Text('Add Memory'),
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (3.14 / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * 3.14 / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String? tooltip;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final Widget button = FloatingActionButton(
      heroTag: null,
      onPressed: onPressed,
      backgroundColor: AppTheme.secondaryColor,
      child: icon,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
} 