import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/services/scrapbook_service.dart';
import 'package:safar/utils/map_background_utils.dart';
import 'package:safar/utils/layout_style_utils.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FreeformCollageEditorScreen extends StatefulWidget {
  final Itinerary itinerary;
  final List<XFile> initialImages;

  const FreeformCollageEditorScreen({
    super.key,
    required this.itinerary,
    required this.initialImages,
  });

  @override
  State<FreeformCollageEditorScreen> createState() => _FreeformCollageEditorScreenState();
}

class _FreeformCollageEditorScreenState extends State<FreeformCollageEditorScreen> {
  final ScrapbookService _scrapbookService = ScrapbookService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isUploading = false;
  List<XFile> _selectedImages = [];
  BackgroundStyle _selectedBackgroundStyle = BackgroundStyle.none;
  Color _backgroundColor = Colors.blueGrey.shade100;
  
  // Collage items for freeform editing
  List<CollageItem> _collageItems = [];
  CollageItem? _selectedItem;
  double _canvasWidth = 0;
  double _canvasHeight = 0;

  @override
  void initState() {
    super.initState();
    _selectedImages = widget.initialImages;
    _initializeCollageItems();
  }

  void _initializeCollageItems() {
    // Clear existing items
    _collageItems = [];
    
    // Initialize the items with default positions
    for (int i = 0; i < _selectedImages.length; i++) {
      // Calculate a grid-like initial position
      final int row = i ~/ 2; // Integer division by 2
      final int col = i % 2;
      
      _collageItems.add(CollageItem(
        id: i.toString(),
        file: _selectedImages[i],
        position: Offset(50.0 + (col * 150), 50.0 + (row * 150)),
        size: const Size(120, 120),
        rotation: 0,
        zIndex: i,
      ));
    }
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
        title: const Text('Freeform Collage Editor'),
        actions: [
          TextButton(
            onPressed: _collageItems.isNotEmpty ? _saveCollage : null,
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
          : Column(
              children: [
                Expanded(
                  child: _buildCollageEditor(),
                ),
                _buildControlPanel(),
              ],
            ),
    );
  }

  Widget _buildCollageEditor() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasWidth = constraints.maxWidth;
        _canvasHeight = constraints.maxHeight * 0.8;
        
        return Stack(
          children: [
            // Canvas background
            Container(
              width: _canvasWidth,
              height: _canvasHeight,
              color: _selectedBackgroundStyle == BackgroundStyle.solid
                  ? _backgroundColor
                  : Colors.white,
            ),
            
            // Collage items
            ..._collageItems.map(_buildDraggableItem).toList(),
            
            // Add image button if no images
            if (_collageItems.isEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDraggableItem(CollageItem item) {
    final isSelected = _selectedItem?.id == item.id;
    
    return Positioned(
      left: item.position.dx,
      top: item.position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedItem = item;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            final newDx = item.position.dx + details.delta.dx;
            final newDy = item.position.dy + details.delta.dy;
            
            // Constrain within canvas bounds
            final dx = newDx.clamp(0, _canvasWidth - item.size.width);
            final dy = newDy.clamp(0, _canvasHeight - item.size.height);
            
            // Update the item position
            final index = _collageItems.indexWhere((i) => i.id == item.id);
            if (index != -1) {
              _collageItems[index] = item.copyWith(
                position: Offset(dx.toDouble(), dy.toDouble()),
              );
              _selectedItem = _collageItems[index];
            }
          });
        },
        child: Transform.rotate(
          angle: item.rotation * (math.pi / 180),
          child: Container(
            width: item.size.width,
            height: item.size.height,
            decoration: BoxDecoration(
              border: isSelected 
                  ? Border.all(color: AppTheme.primaryColor, width: 2)
                  : null,
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isSelected ? 4 : 0),
                    child: Image.file(
                      File(item.file.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  // Resize handle
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          final newWidth = item.size.width + details.delta.dx;
                          final newHeight = item.size.height + details.delta.dy;
                          
                          // Ensure minimum size and maintain aspect ratio if desired
                          final width = newWidth.clamp(30.0, _canvasWidth - item.position.dx);
                          final height = newHeight.clamp(30.0, _canvasHeight - item.position.dy);
                          
                          // Update the item size
                          final index = _collageItems.indexWhere((i) => i.id == item.id);
                          if (index != -1) {
                            _collageItems[index] = item.copyWith(
                              size: Size(width, height),
                            );
                            _selectedItem = _collageItems[index];
                          }
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.open_with,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                  
                  // Rotation handle
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          // Calculate center of the item
                          final centerX = item.position.dx + item.size.width / 2;
                          final centerY = item.position.dy + item.size.height / 2;
                          
                          // Calculate angle from center to current touch position
                          final touchX = item.position.dx + item.size.width;
                          final touchY = item.position.dy;
                          final angle1 = math.atan2(touchY - centerY, touchX - centerX);
                          
                          // Calculate angle after drag
                          final newTouchX = touchX + details.delta.dx;
                          final newTouchY = touchY + details.delta.dy;
                          final angle2 = math.atan2(newTouchY - centerY, newTouchX - centerX);
                          
                          // Calculate rotation difference in degrees
                          final angleDiff = (angle2 - angle1) * (180 / math.pi);
                          
                          // Update the item rotation
                          final index = _collageItems.indexWhere((i) => i.id == item.id);
                          if (index != -1) {
                            _collageItems[index] = item.copyWith(
                              rotation: (item.rotation + angleDiff) % 360,
                            );
                            _selectedItem = _collageItems[index];
                          }
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.rotate_right,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                  
                  // Delete button
                  Positioned(
                    left: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _collageItems.removeWhere((i) => i.id == item.id);
                          _selectedItem = null;
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar for collage operations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToolbarButton(
                icon: Icons.add_photo_alternate,
                label: 'Add Photos',
                onTap: _pickImages,
              ),
              _buildToolbarButton(
                icon: Icons.color_lens,
                label: 'Background',
                onTap: _showBackgroundPicker,
              ),
              _buildToolbarButton(
                icon: Icons.layers,
                label: 'Arrange',
                onTap: _selectedItem != null ? _showArrangeOptions : null,
              ),
              _buildToolbarButton(
                icon: Icons.refresh,
                label: 'Reset',
                onTap: _initializeCollageItems,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Title and description fields
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Give your collage a title',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Write a caption or description',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
  
  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final images = await _scrapbookService.pickMultipleImages();
      
      if (images.isNotEmpty) {
        final newItems = <CollageItem>[];
        
        for (int i = 0; i < images.length; i++) {
          // Start new images in center of canvas
          newItems.add(CollageItem(
            id: (_collageItems.length + i).toString(),
            file: images[i],
            position: Offset(
              _canvasWidth / 2 - 60 + (i * 20), 
              _canvasHeight / 2 - 60 + (i * 20)
            ),
            size: const Size(120, 120),
            rotation: 0,
            zIndex: _collageItems.length + i,
          ));
        }
        
        setState(() {
          _collageItems.addAll(newItems);
          _selectedImages = [
            ..._selectedImages,
            ...images,
          ];
          
          // Select the last added item
          _selectedItem = newItems.last;
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
  
  void _showBackgroundPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Background',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBackgroundOption(
                        icon: Icons.format_color_reset,
                        label: 'None',
                        isSelected: _selectedBackgroundStyle == BackgroundStyle.none,
                        onTap: () {
                          setState(() {
                            _selectedBackgroundStyle = BackgroundStyle.none;
                          });
                          _updateBackgroundStyle(BackgroundStyle.none);
                        },
                      ),
                      _buildBackgroundOption(
                        icon: Icons.format_color_fill,
                        label: 'Solid Color',
                        isSelected: _selectedBackgroundStyle == BackgroundStyle.solid,
                        onTap: () {
                          setState(() {
                            _selectedBackgroundStyle = BackgroundStyle.solid;
                          });
                          _updateBackgroundStyle(BackgroundStyle.solid);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedBackgroundStyle == BackgroundStyle.solid) ...[
                    const Text(
                      'Select Color',
                      style: AppTheme.labelLarge,
                    ),
                    ColorPicker(
                      pickerColor: _backgroundColor,
                      onColorChanged: (color) {
                        setState(() {
                          _backgroundColor = color;
                        });
                        _updateBackgroundColor(color);
                      },
                      pickerAreaHeightPercent: 0.25,
                      enableAlpha: false,
                      displayThumbColor: true,
                      paletteType: PaletteType.hsvWithHue,
                      pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(10)),
                      labelTypes: const [],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildBackgroundOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _updateBackgroundStyle(BackgroundStyle style) {
    setState(() {
      _selectedBackgroundStyle = style;
    });
    Navigator.pop(context);
  }
  
  void _updateBackgroundColor(Color color) {
    setState(() {
      _backgroundColor = color;
    });
  }
  
  void _showArrangeOptions() {
    if (_selectedItem == null) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Arrange Element',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildArrangeButton(
                    icon: Icons.flip_to_front,
                    label: 'Bring Forward',
                    onTap: () {
                      _bringItemForward();
                      Navigator.pop(context);
                    },
                  ),
                  _buildArrangeButton(
                    icon: Icons.flip_to_back,
                    label: 'Send Backward',
                    onTap: () {
                      _sendItemBackward();
                      Navigator.pop(context);
                    },
                  ),
                  _buildArrangeButton(
                    icon: Icons.rotate_left,
                    label: 'Rotate -90°',
                    onTap: () {
                      _rotateItem(-90);
                      Navigator.pop(context);
                    },
                  ),
                  _buildArrangeButton(
                    icon: Icons.rotate_right,
                    label: 'Rotate +90°',
                    onTap: () {
                      _rotateItem(90);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildArrangeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _bringItemForward() {
    if (_selectedItem == null) return;
    
    setState(() {
      // Find the current index
      final index = _collageItems.indexWhere((item) => item.id == _selectedItem!.id);
      if (index != -1 && index < _collageItems.length - 1) {
        // Swap with the next item
        final temp = _collageItems[index];
        _collageItems[index] = _collageItems[index + 1];
        _collageItems[index + 1] = temp;
        _selectedItem = temp;
      }
    });
  }
  
  void _sendItemBackward() {
    if (_selectedItem == null) return;
    
    setState(() {
      // Find the current index
      final index = _collageItems.indexWhere((item) => item.id == _selectedItem!.id);
      if (index > 0) {
        // Swap with the previous item
        final temp = _collageItems[index];
        _collageItems[index] = _collageItems[index - 1];
        _collageItems[index - 1] = temp;
        _selectedItem = temp;
      }
    });
  }
  
  void _rotateItem(double degrees) {
    if (_selectedItem == null) return;
    
    setState(() {
      final index = _collageItems.indexWhere((item) => item.id == _selectedItem!.id);
      if (index != -1) {
        final newRotation = (_collageItems[index].rotation + degrees) % 360;
        _collageItems[index] = _collageItems[index].copyWith(
          rotation: newRotation,
        );
        _selectedItem = _collageItems[index];
      }
    });
  }

  Future<void> _saveCollage() async {
    if (_collageItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
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
          : 'Freeform Collage ${DateFormat('MMM d, yyyy').format(timestamp)}';
      
      final content = _contentController.text.isNotEmpty
          ? _contentController.text
          : 'A custom arranged photo collage';

      // Get all image files from the collage items
      final List<XFile> mediaFiles = _collageItems
          .map((item) => item.file)
          .toList();

      final collage = await _scrapbookService.addCollageEntry(
        itineraryId: widget.itinerary.id,
        title: title,
        content: content,
        timestamp: timestamp,
        mediaFiles: mediaFiles,
        collageLayout: CollageLayout.freeform, // Use the new freeform layout
        backgroundStyle: _selectedBackgroundStyle,
        backgroundColor: _selectedBackgroundStyle == BackgroundStyle.solid
            ? _backgroundColor
            : null,
      );

      if (mounted) {
        if (collage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Freeform collage created successfully!')),
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

// Class to represent a collage item
class CollageItem {
  final String id;
  final XFile file;
  final Offset position;
  final Size size;
  final double rotation;
  final int zIndex;
  
  CollageItem({
    required this.id,
    required this.file,
    required this.position,
    required this.size,
    required this.rotation,
    required this.zIndex,
  });
  
  CollageItem copyWith({
    String? id,
    XFile? file,
    Offset? position,
    Size? size,
    double? rotation,
    int? zIndex,
  }) {
    return CollageItem(
      id: id ?? this.id,
      file: file ?? this.file,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
    );
  }
} 