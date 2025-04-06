import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/services/scrapbook_service.dart';
import 'package:safar/utils/map_background_utils.dart';
import 'package:safar/utils/layout_style_utils.dart';
import 'package:safar/features/settings/theme_provider.dart';
import 'package:safar/features/itineraries/freeform_collage_editor_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CollageCreatorScreen extends StatefulWidget {
  final Itinerary itinerary;

  const CollageCreatorScreen({
    super.key,
    required this.itinerary,
  });

  @override
  State<CollageCreatorScreen> createState() => _CollageCreatorScreenState();
}

class _CollageCreatorScreenState extends State<CollageCreatorScreen> {
  final ScrapbookService _scrapbookService = ScrapbookService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isUploading = false;
  List<XFile> _selectedImages = [];
  BackgroundStyle _selectedBackgroundStyle = BackgroundStyle.none;
  CollageLayout _selectedCollageLayout = CollageLayout.grid2x2;
  Color _backgroundColor = Colors.blueGrey.shade100;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    // Instead of relying on itinerary location, we'll let users pick their location
    // or we'll get it when they save the collage
    _latitude = null; 
    _longitude = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Photo Collage'),
        actions: [
          TextButton(
            onPressed: _selectedImages.isNotEmpty ? _saveCollage : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creating collage...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSelector(),
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildCollagePreview(),
                    const SizedBox(height: 24),
                    _buildCollageLayoutSelector(),
                    const SizedBox(height: 24),
                    _buildTitleAndContent(),
                    const SizedBox(height: 24),
                    _buildBackgroundStyleSelector(),
                    const SizedBox(height: 24),
                    if (_selectedBackgroundStyle == BackgroundStyle.solid)
                      _buildColorPicker(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Photos',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(_selectedImages.isEmpty
                  ? 'Select Images'
                  : 'Change Images (${_selectedImages.length})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedImages = [];
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedImages.isEmpty)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.collections,
                  size: 64,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select 2-6 photos for your collage',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCollagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collage Preview',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _selectedBackgroundStyle == BackgroundStyle.solid
                ? _backgroundColor
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildCollageLayout(),
        ),
      ],
    );
  }

  Widget _buildCollageLayout() {
    // Limit the number of images based on layout
    int maxImages = 4;
    if (_selectedCollageLayout == CollageLayout.grid3x3) {
      maxImages = 9;
    } else if (_selectedCollageLayout == CollageLayout.featured) {
      maxImages = 4;
    } else if (_selectedCollageLayout == CollageLayout.horizontal ||
        _selectedCollageLayout == CollageLayout.vertical) {
      maxImages = 3;
    }

    final displayImages = _selectedImages.length > maxImages
        ? _selectedImages.sublist(0, maxImages)
        : _selectedImages;

    switch (_selectedCollageLayout) {
      case CollageLayout.grid2x2:
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          children: displayImages.map(_buildCollageImage).toList(),
        );
      case CollageLayout.grid3x3:
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          children: displayImages.map(_buildCollageImage).toList(),
        );
      case CollageLayout.horizontal:
        return Row(
          children: displayImages.map((image) {
            return Expanded(child: _buildCollageImage(image));
          }).toList(),
        );
      case CollageLayout.vertical:
        return Column(
          children: displayImages.map((image) {
            return SizedBox(
              height: 150,
              width: double.infinity,
              child: _buildCollageImage(image),
            );
          }).toList(),
        );
      case CollageLayout.featured:
        if (displayImages.isEmpty) return const SizedBox();
        if (displayImages.length == 1) {
          return _buildCollageImage(displayImages[0]);
        }
        return Column(
          children: [
            _buildCollageImage(displayImages[0]),
            const SizedBox(height: 2),
            Row(
              children: displayImages
                  .skip(1)
                  .take(3)
                  .map((image) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          child: _buildCollageImage(image),
                        ),
                      ))
                  .toList(),
            ),
          ],
        );
      default:
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          children: displayImages.map(_buildCollageImage).toList(),
        );
    }
  }

  Widget _buildCollageImage(XFile image) {
    return Image.file(
      File(image.path),
      fit: BoxFit.cover,
      height: 150,
      width: double.infinity,
    );
  }

  Widget _buildCollageLayoutSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collage Layout',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCollageLayoutOption(
                CollageLayout.grid2x2,
                'Grid 2×2',
                Icons.grid_view,
              ),
              _buildCollageLayoutOption(
                CollageLayout.grid3x3,
                'Grid 3×3',
                Icons.grid_on,
              ),
              _buildCollageLayoutOption(
                CollageLayout.horizontal,
                'Horizontal',
                Icons.view_week,
              ),
              _buildCollageLayoutOption(
                CollageLayout.vertical,
                'Vertical',
                Icons.view_agenda,
              ),
              _buildCollageLayoutOption(
                CollageLayout.featured,
                'Featured',
                Icons.view_quilt,
              ),
              _buildFreeformEditorButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollageLayoutOption(
      CollageLayout layout, String name, IconData icon) {
    final isSelected = layout == _selectedCollageLayout;
    final color = isSelected ? AppTheme.primaryColor : Colors.grey.shade400;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCollageLayout = layout;
        });
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeformEditorButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to the freeform editor if we have images
        if (_selectedImages.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one image first'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FreeformCollageEditorScreen(
              itinerary: widget.itinerary,
              initialImages: _selectedImages,
            ),
          ),
        ).then((result) {
          if (result == true) {
            // If a collage was created in the freeform editor, return to previous screen
            Navigator.pop(context, true);
          }
        });
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.amber,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.dashboard_customize,
                  color: Colors.amber,
                  size: 32,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Freeform Editor',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title & Description',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Give your collage a title',
            border: OutlineInputBorder(),
          ),
          maxLength: 50,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Write a caption or description for your collage',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 200,
        ),
      ],
    );
  }

  Widget _buildBackgroundStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Background Style',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: BackgroundStyle.values.length,
            itemBuilder: (context, index) {
              final style = BackgroundStyle.values[index];
              final isSelected = style == _selectedBackgroundStyle;
              
              // Skip map styles if there are no coordinates
              if (MapBackgroundUtils.isMapStyle(style) && 
                 (_latitude == null || _longitude == null)) {
                return const SizedBox();
              }
              
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedBackgroundStyle = style;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? MapBackgroundUtils.getBackgroundStyleColor(style) 
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: MapBackgroundUtils.getBackgroundStyleColor(style).withOpacity(0.8),
                                  width: 3,
                                )
                              : null,
                        ),
                        child: Icon(
                          MapBackgroundUtils.getBackgroundStyleIcon(style),
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        MapBackgroundUtils.getBackgroundStyleName(style),
                        style: TextStyle(
                          color: isSelected 
                              ? MapBackgroundUtils.getBackgroundStyleColor(style) 
                              : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Background Color',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 12),
        Center(
          child: ColorPicker(
            pickerColor: _backgroundColor,
            onColorChanged: (color) {
              setState(() {
                _backgroundColor = color;
              });
            },
            pickerAreaHeightPercent: 0.25,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
            pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(10)),
            labelTypes: const [],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      final images = await _scrapbookService.pickMultipleImages();
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveCollage() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final timestamp = DateTime.now();
      final title = _titleController.text.isNotEmpty
          ? _titleController.text
          : 'Collage ${DateFormat('MMM d, yyyy').format(timestamp)}';
      
      final content = _contentController.text.isNotEmpty
          ? _contentController.text
          : 'A photo collage from ${widget.itinerary.destination}';

      final collage = await _scrapbookService.addCollageEntry(
        itineraryId: widget.itinerary.id,
        title: title,
        content: content,
        timestamp: timestamp,
        mediaFiles: _selectedImages,
        collageLayout: _selectedCollageLayout,
        latitude: _latitude,
        longitude: _longitude,
        backgroundStyle: _selectedBackgroundStyle,
        backgroundColor: _selectedBackgroundStyle == BackgroundStyle.solid
            ? _backgroundColor
            : null,
      );

      if (mounted) {
        if (collage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Collage created successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error creating collage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 