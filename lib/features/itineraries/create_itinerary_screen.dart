import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/models/day.dart';
import 'package:safar/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:safar/features/itineraries/itinerary_detail_screen.dart';

class CreateItineraryScreen extends StatefulWidget {
  const CreateItineraryScreen({super.key});

  @override
  State<CreateItineraryScreen> createState() => _CreateItineraryScreenState();
}

class _CreateItineraryScreenState extends State<CreateItineraryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _transportationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().add(const Duration(days: 7)),
    end: DateTime.now().add(const Duration(days: 14)),
  );
  
  int _numberOfDays = 7;
  BudgetTier _selectedBudgetTier = BudgetTier.standard;
  PackageType _selectedPackageType = PackageType.couple;
  bool _isPrivate = false;
  bool _isCreating = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _transportationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Itinerary'),
      ),
      body: _isCreating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creating your itinerary...'),
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
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Trip Title',
                        hintText: 'Enter a title for your trip',
                        prefixIcon: Icon(Icons.edit),
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
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        hintText: 'Where are you going?',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a destination';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateRangePicker(),
                    const SizedBox(height: 24),
                    _buildDaySlider(),
                    const SizedBox(height: 24),
                    _buildBudgetSelector(),
                    const SizedBox(height: 24),
                    _buildPackageTypeSelector(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _transportationController,
                      decoration: const InputDecoration(
                        labelText: 'Transportation Mode',
                        hintText: 'How will you travel? (Flight, Car, Train, etc.)',
                        prefixIcon: Icon(Icons.directions),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter transportation mode';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildPrivacyToggle(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Trip Notes (Optional)',
                        hintText: 'Add any additional notes for your trip',
                        prefixIcon: Icon(Icons.note),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createItinerary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Create Itinerary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  Widget _buildDateRangePicker() {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trip Dates',
          style: AppTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateRange,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dateFormat.format(_dateRange.start)} - ${dateFormat.format(_dateRange.end)}',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_dateRange.duration.inDays + 1} days',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Number of Days',
              style: AppTheme.labelLarge,
            ),
            Text(
              '$_numberOfDays days',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _numberOfDays.toDouble(),
          min: 1,
          max: 30,
          divisions: 29,
          label: '$_numberOfDays days',
          activeColor: AppTheme.primaryColor,
          onChanged: (value) {
            setState(() {
              _numberOfDays = value.toInt();
              
              // Update date range based on number of days
              _dateRange = DateTimeRange(
                start: _dateRange.start,
                end: _dateRange.start.add(Duration(days: _numberOfDays - 1)),
              );
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('1 day', style: AppTheme.bodySmall),
            const Text('30 days', style: AppTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget',
          style: AppTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBudgetOption(
                BudgetTier.cheap,
                'Budget-Friendly',
                Icons.savings,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBudgetOption(
                BudgetTier.budget,
                'Moderate',
                Icons.account_balance_wallet,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildBudgetOption(
                BudgetTier.standard,
                'Standard',
                Icons.credit_card,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBudgetOption(
                BudgetTier.luxury,
                'Luxury',
                Icons.diamond,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetOption(
    BudgetTier tier,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedBudgetTier == tier;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBudgetTier = tier;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? color : AppTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trip Type',
          style: AppTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPackageTypeOption(
              PackageType.solo,
              'Solo',
              Icons.person,
            ),
            _buildPackageTypeOption(
              PackageType.couple,
              'Couple',
              Icons.favorite,
            ),
            _buildPackageTypeOption(
              PackageType.family,
              'Family',
              Icons.family_restroom,
            ),
            _buildPackageTypeOption(
              PackageType.friends,
              'Friends',
              Icons.groups,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackageTypeOption(
    PackageType type,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedPackageType == type;
    
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPackageType = type;
          });
        }
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildPrivacyToggle() {
    return Row(
      children: [
        Expanded(
          child: const Text(
            'Trip Visibility',
            style: AppTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Text(
              _isPrivate ? 'Private' : 'Public',
              style: AppTheme.bodyMedium.copyWith(
                color: _isPrivate ? AppTheme.textSecondaryColor : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: _isPrivate,
              onChanged: (value) {
                setState(() {
                  _isPrivate = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _numberOfDays = picked.duration.inDays + 1;
      });
    }
  }

  void _createItinerary() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreating = true;
      });

      // Generate days based on the date range
      final days = <Day>[];
      for (int i = 0; i < _numberOfDays; i++) {
        final day = Day(
          id: 'day${i + 1}',
          date: _dateRange.start.add(Duration(days: i)),
          title: 'Day ${i + 1} - ${i == 0 ? 'Arrival' : i == _numberOfDays - 1 ? 'Departure' : 'Exploring'}',
          notes: i == 0 ? 'Arrival day - check in to hotel' : i == _numberOfDays - 1 ? 'Departure day - check out of hotel' : '',
          activities: [],
        );
        days.add(day);
      }
      
      // Create the itinerary
      final itinerary = Itinerary(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        destination: _destinationController.text,
        dateRange: _dateRange,
        budgetTier: _selectedBudgetTier,
        transportationMode: _transportationController.text,
        isPrivate: _isPrivate,
        days: days,
        packageType: _selectedPackageType,
        coverImage: _getCoverImageForDestination(_destinationController.text),
        notes: _notesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Navigate to the newly created itinerary
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItineraryDetailScreen(
            itinerary: itinerary,
          ),
        ),
      );
    }
  }

  String _getCoverImageForDestination(String destination) {
    // In a real app, this would fetch an appropriate image based on the destination
    // For now, just return a placeholder based on the destination name
    final normalizedDestination = destination.toLowerCase();
    
    if (normalizedDestination.contains('paris')) {
      return 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a';
    } else if (normalizedDestination.contains('tokyo')) {
      return 'https://images.unsplash.com/photo-1536098561742-ca998e48cbcc';
    } else if (normalizedDestination.contains('new york')) {
      return 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9';
    } else if (normalizedDestination.contains('bali')) {
      return 'https://images.unsplash.com/photo-1537996194471-e657df975ab4';
    } else if (normalizedDestination.contains('rome')) {
      return 'https://images.unsplash.com/photo-1525874684015-58379d421a52';
    } else if (normalizedDestination.contains('london')) {
      return 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad';
    } else {
      return 'https://images.unsplash.com/photo-1500835556837-99ac94a94552';
    }
  }
} 