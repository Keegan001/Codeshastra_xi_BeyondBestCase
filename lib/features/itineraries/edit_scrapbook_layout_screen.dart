import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/services/scrapbook_service.dart';
import 'package:safar/utils/map_background_utils.dart';
import 'package:safar/utils/layout_style_utils.dart';
import 'package:safar/features/settings/theme_provider.dart';
import 'package:provider/provider.dart';

class EditScrapbookLayoutScreen extends StatefulWidget {
  final ScrapbookEntry entry;
  final Itinerary itinerary;

  const EditScrapbookLayoutScreen({
    super.key,
    required this.entry,
    required this.itinerary,
  });

  @override
  State<EditScrapbookLayoutScreen> createState() => _EditScrapbookLayoutScreenState();
}

class _EditScrapbookLayoutScreenState extends State<EditScrapbookLayoutScreen> {
  final ScrapbookService _scrapbookService = ScrapbookService();
  bool _isSaving = false;
  
  late BackgroundStyle _selectedBackgroundStyle;
  late LayoutStyle _selectedLayoutStyle;
  double _zoomLevel = 14.0;
  Color _backgroundColor = Colors.blueGrey.shade100;
  
  @override
  void initState() {
    super.initState();
    _selectedBackgroundStyle = widget.entry.backgroundStyle;
    _selectedLayoutStyle = widget.entry.layoutStyle;
    _zoomLevel = widget.entry.zoomLevel ?? 14.0;
    _backgroundColor = widget.entry.backgroundColor ?? Colors.blueGrey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Layout'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreview(),
                  const SizedBox(height: 24),
                  _buildLayoutStyleSelector(),
                  const SizedBox(height: 24),
                  _buildBackgroundStyleSelector(),
                  const SizedBox(height: 24),
                  if (MapBackgroundUtils.isMapStyle(_selectedBackgroundStyle) && 
                      widget.entry.latitude != null &&
                      widget.entry.longitude != null)
                    _buildMapControls(),
                  if (_selectedBackgroundStyle == BackgroundStyle.solid)
                    _buildColorPicker(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: _getPreviewDecoration(),
            child: Column(
              children: [
                if (widget.entry.mediaUrl != null && widget.entry.type == ScrapbookEntryType.photo)
                  _buildMediaPreview(),
                Padding(
                  padding: LayoutStyleUtils.getLayoutContentPadding(_selectedLayoutStyle),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.entry.title,
                        style: LayoutStyleUtils.getTitleTextStyle(_selectedLayoutStyle),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.entry.content,
                        style: LayoutStyleUtils.getContentTextStyle(_selectedLayoutStyle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  BoxDecoration _getPreviewDecoration() {
    DecorationImage? backgroundImage;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    if (MapBackgroundUtils.isMapStyle(_selectedBackgroundStyle) &&
        widget.entry.latitude != null &&
        widget.entry.longitude != null) {
      backgroundImage = MapBackgroundUtils.getMapBackgroundDecoration(
        style: _selectedBackgroundStyle,
        latitude: widget.entry.latitude!,
        longitude: widget.entry.longitude!,
        zoom: _zoomLevel,
        darkMode: isDarkMode,
      );
    }
    
    return LayoutStyleUtils.getLayoutDecoration(
      _selectedLayoutStyle,
      backgroundImage: backgroundImage,
      backgroundColor: _selectedBackgroundStyle == BackgroundStyle.solid 
          ? _backgroundColor 
          : null,
      isDarkMode: isDarkMode,
    );
  }
  
  Widget _buildMediaPreview() {
    final mediaUrl = widget.entry.mediaUrl;
    if (mediaUrl == null) return const SizedBox();
    
    if (mediaUrl.startsWith('http')) {
      return Image.network(
        mediaUrl,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (mediaUrl.startsWith('file://')) {
      return Image.file(
        File(mediaUrl.replaceFirst('file://', '')),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    
    return const SizedBox();
  }
  
  Widget _buildLayoutStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Layout Style',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: LayoutStyle.values.length,
            itemBuilder: (context, index) {
              final style = LayoutStyle.values[index];
              final isSelected = style == _selectedLayoutStyle;
              
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedLayoutStyle = style;
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
                              ? LayoutStyleUtils.getLayoutStyleColor(style) 
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: LayoutStyleUtils.getLayoutStyleColor(style).withOpacity(0.8),
                                  width: 3,
                                )
                              : null,
                        ),
                        child: Icon(
                          LayoutStyleUtils.getLayoutStyleIcon(style),
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LayoutStyleUtils.getLayoutStyleName(style),
                        style: TextStyle(
                          color: isSelected 
                              ? LayoutStyleUtils.getLayoutStyleColor(style) 
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
                 (widget.entry.latitude == null || widget.entry.longitude == null)) {
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
  
  Widget _buildMapControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Map Zoom Level',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.zoom_out, color: Colors.grey),
            Expanded(
              child: Slider(
                value: _zoomLevel,
                min: 4.0,
                max: 18.0,
                divisions: 14,
                label: _zoomLevel.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _zoomLevel = value;
                  });
                },
              ),
            ),
            const Icon(Icons.zoom_in, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (widget.entry.latitude != null && widget.entry.longitude != null) {
                MapBackgroundUtils.openInGoogleMaps(
                  widget.entry.latitude!,
                  widget.entry.longitude!,
                );
              }
            },
            icon: const Icon(Icons.map),
            label: const Text('View in Google Maps'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
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
  
  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Create updated entry
      final updatedEntry = widget.entry.copyWith(
        backgroundStyle: _selectedBackgroundStyle,
        layoutStyle: _selectedLayoutStyle,
        zoomLevel: _zoomLevel,
        backgroundColor: _selectedBackgroundStyle == BackgroundStyle.solid ? _backgroundColor : null,
      );
      
      // Save to storage
      final success = await _scrapbookService.updateEntry(
        itineraryId: widget.itinerary.id,
        updatedEntry: updatedEntry,
      );
      
      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving changes'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      print('Error saving layout changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
} 