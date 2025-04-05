import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:intl/intl.dart';

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
  
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  ScrapbookEntryType _selectedType = ScrapbookEntryType.note;
  String? _mediaPath;
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
      _mediaPath = widget.entryToEdit!.mediaUrl;
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
                  Text('Uploading...'),
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
        if (_mediaPath != null) ...[
          _selectedType == ScrapbookEntryType.photo
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _mediaPath!,
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
                  _mediaPath = null;
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
    // This would use image_picker or file_picker in a real implementation
    // For now, just simulate selecting media
    
    setState(() {
      // Simulate media path
      if (_selectedType == ScrapbookEntryType.photo) {
        _mediaPath = 'https://images.unsplash.com/photo-1491555103944-7c647fd857e6';
      } else if (_selectedType == ScrapbookEntryType.video) {
        _mediaPath = 'https://example.com/video123.mp4';
      } else if (_selectedType == ScrapbookEntryType.audio) {
        _mediaPath = 'https://example.com/audio123.mp3';
      }
    });
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      // Simulate uploading
      Future.delayed(const Duration(seconds: 2), () {
        // In a real app, this would save to a database
        
        // Get the combined date and time
        final DateTime timestamp = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        
        if (_useCurrentLocation) {
          // Simulate getting current location
          _latitude = 40.7128;
          _longitude = -74.0060;
        }
        
        // This would create a new entry in a real app
        final ScrapbookEntry entry = ScrapbookEntry(
          id: widget.entryToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          content: _contentController.text,
          type: _selectedType,
          timestamp: timestamp,
          latitude: _latitude,
          longitude: _longitude,
          mediaUrl: _mediaPath,
        );
        
        // Navigate back when complete
        Navigator.pop(context);
      });
    }
  }
} 