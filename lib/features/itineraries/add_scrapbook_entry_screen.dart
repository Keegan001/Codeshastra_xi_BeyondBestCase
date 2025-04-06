import 'dart:io';
import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/services/scrapbook_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class AddScrapbookEntryScreen extends StatefulWidget {
  final Itinerary itinerary;
  final ScrapbookEntry? entryToEdit;

  const AddScrapbookEntryScreen({
    super.key,
    required this.itinerary,
    this.entryToEdit,
  });

  @override
  State<AddScrapbookEntryScreen> createState() => _AddScrapbookEntryScreenState();
}

class _AddScrapbookEntryScreenState extends State<AddScrapbookEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrapbookService _scrapbookService = ScrapbookService();
  
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  ScrapbookEntryType _selectedType = ScrapbookEntryType.note;
  XFile? _selectedMediaFile;
  bool _isExistingMedia = false;
  String? _existingMediaPath;
  double? _latitude;
  double? _longitude;
  bool _isUploading = false;
  bool _useCurrentLocation = true;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _titleController = TextEditingController(text: widget.entryToEdit?.title ?? '');
    _contentController = TextEditingController(text: widget.entryToEdit?.content ?? '');
    
    // Initialize date and time
    if (widget.entryToEdit != null) {
      _selectedDate = widget.entryToEdit!.timestamp;
      _selectedTime = TimeOfDay.fromDateTime(widget.entryToEdit!.timestamp);
      _selectedType = widget.entryToEdit!.type;
      _latitude = widget.entryToEdit!.latitude;
      _longitude = widget.entryToEdit!.longitude;
      _existingMediaPath = widget.entryToEdit!.mediaUrl;
      _isExistingMedia = _existingMediaPath != null;
      _useCurrentLocation = _latitude == null;
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
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
        title: Text(widget.entryToEdit == null ? 'Add Scrapbook Entry' : 'Edit Scrapbook Entry'),
        actions: [
          TextButton(
            onPressed: _saveEntry,
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
                  Text('Saving entry...'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 16),
                    _buildMediaSelector(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter a title for this memory',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Write about this memory',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Date & Time',
                      style: AppTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('MMM d, yyyy').format(_selectedDate),
                                    style: AppTheme.bodyMedium,
                                  ),
                                  const Icon(Icons.calendar_today, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: _selectTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Time',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedTime.format(context),
                                    style: AppTheme.bodyMedium,
                                  ),
                                  const Icon(Icons.access_time, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Location',
                      style: AppTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Use current location'),
                            value: _useCurrentLocation,
                            onChanged: (value) {
                              setState(() {
                                _useCurrentLocation = value;
                                if (value) {
                                  // Would get current location in a real app
                                  _latitude = null;
                                  _longitude = null;
                                }
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (!_useCurrentLocation)
                          IconButton(
                            icon: const Icon(Icons.map),
                            onPressed: () {
                              // Open map to select location
                              // For now, just set a dummy location
                              setState(() {
                                _latitude = 40.7128;
                                _longitude = -74.0060;
                              });
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Location selected: New York City'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    if (!_useCurrentLocation && (_latitude != null || _longitude != null))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.entryToEdit == null ? 'Save Memory' : 'Update Memory',
                          style: AppTheme.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Memory Type',
          style: AppTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        SegmentedButton<ScrapbookEntryType>(
          segments: const [
            ButtonSegment<ScrapbookEntryType>(
              value: ScrapbookEntryType.note,
              label: Text('Note'),
              icon: Icon(Icons.note),
            ),
            ButtonSegment<ScrapbookEntryType>(
              value: ScrapbookEntryType.photo,
              label: Text('Photo'),
              icon: Icon(Icons.photo),
            ),
            ButtonSegment<ScrapbookEntryType>(
              value: ScrapbookEntryType.video,
              label: Text('Video'),
              icon: Icon(Icons.videocam),
            ),
            ButtonSegment<ScrapbookEntryType>(
              value: ScrapbookEntryType.audio,
              label: Text('Audio'),
              icon: Icon(Icons.mic),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (Set<ScrapbookEntryType> selected) {
            setState(() {
              _selectedType = selected.first;
              // Reset media selection if type changes
              if (_selectedType != ScrapbookEntryType.note && !_isExistingMedia) {
                _selectedMediaFile = null;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildMediaSelector() {
    if (_selectedType == ScrapbookEntryType.note) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Media',
          style: AppTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        if (_isExistingMedia && _existingMediaPath != null) ...[
          _selectedType == ScrapbookEntryType.photo
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _existingMediaPath!.startsWith('file://') 
                        ? _existingMediaPath!.replaceFirst('file://', '') 
                        : _existingMediaPath!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
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
                    },
                  ),
                )
              : Container(
                  height: 100,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedType == ScrapbookEntryType.video
                            ? Icons.videocam
                            : Icons.mic,
                        size: 36,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _selectedType == ScrapbookEntryType.video
                              ? 'Video selected'
                              : 'Audio recording selected',
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isExistingMedia = false;
                  _existingMediaPath = null;
                  _selectedMediaFile = null;
                });
              },
              icon: const Icon(Icons.delete),
              label: const Text('Remove'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
              ),
            ),
          ),
        ] else if (_selectedMediaFile != null) ...[
          _selectedType == ScrapbookEntryType.photo
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedMediaFile!.path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  height: 100,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedType == ScrapbookEntryType.video
                            ? Icons.videocam
                            : Icons.mic,
                        size: 36,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _selectedType == ScrapbookEntryType.video
                              ? 'Video selected'
                              : 'Audio recording selected',
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedMediaFile = null;
                });
              },
              icon: const Icon(Icons.delete),
              label: const Text('Remove'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
              ),
            ),
          ),
        ] else ...[
          GestureDetector(
            onTap: _selectMedia,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getMediaIcon(),
                    size: 48,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getMediaText(),
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getMediaIcon() {
    switch (_selectedType) {
      case ScrapbookEntryType.photo:
        return Icons.add_photo_alternate;
      case ScrapbookEntryType.video:
        return Icons.videocam;
      case ScrapbookEntryType.audio:
        return Icons.mic;
      default:
        return Icons.note_add;
    }
  }

  String _getMediaText() {
    switch (_selectedType) {
      case ScrapbookEntryType.photo:
        return 'Tap to add a photo';
      case ScrapbookEntryType.video:
        return 'Tap to add a video';
      case ScrapbookEntryType.audio:
        return 'Tap to record audio';
      default:
        return '';
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectMedia() async {
    XFile? file;
    
    try {
      switch (_selectedType) {
        case ScrapbookEntryType.photo:
          file = await _scrapbookService.pickImage();
          break;
        case ScrapbookEntryType.video:
          file = await _scrapbookService.pickVideo();
          break;
        case ScrapbookEntryType.audio:
          file = await _scrapbookService.recordAudio();
          break;
        default:
          file = null;
      }
      
      if (file != null) {
        setState(() {
          _selectedMediaFile = file;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting media: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      try {
        // Create timestamp from date and time
        final timestamp = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        
        // Handle location
        if (_useCurrentLocation) {
          // In a real app, would get current location here
          // For this demo, use some default coordinates
          _latitude = 40.7128;
          _longitude = -74.0060;
        }
        
        // Add or update entry
        if (widget.entryToEdit == null) {
          // Create new entry
          final newEntry = await _scrapbookService.addEntry(
            itineraryId: widget.itinerary.id,
            title: _titleController.text,
            content: _contentController.text,
            type: _selectedType,
            timestamp: timestamp,
            latitude: _latitude,
            longitude: _longitude,
            mediaFile: _selectedMediaFile,
          );
          
          if (newEntry != null) {
            // Successfully added
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Memory saved!')),
              );
              Navigator.pop(context, true); // Return success
            }
          } else {
            // Error adding
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error saving memory'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {
                _isUploading = false;
              });
            }
          }
        } else {
          // Update existing entry
          final updatedEntry = widget.entryToEdit!.copyWith(
            id: widget.entryToEdit!.id,
            title: _titleController.text,
            content: _contentController.text,
            type: _selectedType,
            timestamp: timestamp,
            latitude: _latitude,
            longitude: _longitude,
            mediaUrl: _isExistingMedia ? _existingMediaPath : null,
            // Preserve these properties from the original entry
            backgroundStyle: widget.entryToEdit!.backgroundStyle,
            layoutStyle: widget.entryToEdit!.layoutStyle,
            zoomLevel: widget.entryToEdit!.zoomLevel,
            backgroundColor: widget.entryToEdit!.backgroundColor,
          );
          
          final success = await _scrapbookService.updateEntry(
            itineraryId: widget.itinerary.id,
            updatedEntry: updatedEntry,
            newMediaFile: _selectedMediaFile,
          );
          
          if (success) {
            // Successfully updated
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Memory updated!')),
              );
              Navigator.pop(context, true); // Return success
            }
          } else {
            // Error updating
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error updating memory'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {
                _isUploading = false;
              });
            }
          }
        }
      } catch (e) {
        // Handle errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }
} 