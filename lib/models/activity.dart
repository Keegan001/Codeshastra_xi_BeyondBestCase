import 'dart:math';
import 'package:safar/models/itinerary.dart';

enum ActivityType {
  attraction,
  dining,
  transportation,
  accommodation,
  event,
  leisure,
}

class Activity {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? imageUrl;
  final double? cost;
  final String? currency;
  final bool isBooked;
  final String? bookingReference;
  final double? latitude;
  final double? longitude;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.imageUrl,
    this.cost,
    this.currency = 'USD',
    this.isBooked = false,
    this.bookingReference,
    this.latitude,
    this.longitude,
  });

  // Convert from JSON
  static Activity fromJson(Map<String, dynamic> json) {
    // Convert backend activity type to frontend ActivityType
    ActivityType getActivityTypeFromBackend(dynamic backendType) {
      if (backendType == null) return ActivityType.leisure;
      
      switch (backendType.toString().toLowerCase()) {
        case 'attraction':
          return ActivityType.attraction;
        case 'food':
        case 'dining':
          return ActivityType.dining;
        case 'transport':
        case 'transportation':
          return ActivityType.transportation;
        case 'accommodation':
          return ActivityType.accommodation;
        case 'event':
          return ActivityType.event;
        case 'leisure':
        case 'other':
          return ActivityType.leisure;
        default:
          print('Unknown activity type: $backendType, defaulting to leisure');
          return ActivityType.leisure;
      }
    }

    // Parse time fields safely
    DateTime parseTimeField(dynamic timeValue, DateTime defaultTime) {
      if (timeValue == null) return defaultTime;
      
      try {
        if (timeValue is String) {
          return DateTime.parse(timeValue);
        } else if (timeValue is Map && timeValue.containsKey('start')) {
          return DateTime.parse(timeValue['start']);
        }
      } catch (e) {
        print('Error parsing time: $e for value $timeValue');
      }
      
      return defaultTime;
    }
    
    // Create default times based on the current day
    final now = DateTime.now();
    final defaultStartTime = DateTime(now.year, now.month, now.day, 9, 0);
    final defaultEndTime = DateTime(now.year, now.month, now.day, 10, 0);
    
    // Get location info
    String locationName = '';
    if (json['location'] != null) {
      if (json['location'] is String) {
        locationName = json['location'];
      } else if (json['location'] is Map) {
        locationName = json['location']['name'] ?? '';
        if (locationName.isEmpty && json['location']['address'] != null) {
          locationName = json['location']['address'];
        }
      }
    }
    
    // Get cost info
    double? cost;
    String? currency = 'USD';
    if (json['cost'] != null) {
      if (json['cost'] is double || json['cost'] is int) {
        cost = (json['cost'] as num).toDouble();
      } else if (json['cost'] is Map) {
        cost = json['cost']['amount'] != null ? (json['cost']['amount'] as num).toDouble() : null;
        currency = json['cost']['currency'] ?? 'USD';
      }
    }

    // Determine start and end times
    DateTime startTime;
    DateTime endTime;
    
    if (json['timeRange'] != null) {
      // Backend format
      startTime = parseTimeField(json['timeRange']['start'], defaultStartTime);
      endTime = parseTimeField(json['timeRange']['end'], defaultEndTime);
    } else {
      // Frontend format
      startTime = parseTimeField(json['startTime'], defaultStartTime);
      endTime = parseTimeField(json['endTime'], defaultEndTime);
    }
    
    return Activity(
      id: json['id'] ?? json['_id'] ?? json['uuid'] ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? 'Untitled Activity',
      description: json['description'] ?? json['notes'] ?? '',
      type: getActivityTypeFromBackend(json['type']),
      startTime: startTime,
      endTime: endTime,
      location: locationName,
      imageUrl: json['imageUrl'],
      cost: cost,
      currency: currency,
      isBooked: json['isBooked'] ?? json['reservationInfo'] != null,
      bookingReference: json['bookingReference'] ?? json['reservationInfo'],
      latitude: json['latitude'] ?? (json['location'] is Map && 
          json['location']['coordinates'] is Map &&
          json['location']['coordinates']['coordinates'] is List ? 
          json['location']['coordinates']['coordinates'][1] : null),
      longitude: json['longitude'] ?? (json['location'] is Map && 
          json['location']['coordinates'] is Map &&
          json['location']['coordinates']['coordinates'] is List ? 
          json['location']['coordinates']['coordinates'][0] : null),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    // Convert frontend ActivityType to backend format
    String getBackendActivityType(ActivityType type) {
      switch (type) {
        case ActivityType.attraction:
          return 'attraction';
        case ActivityType.dining:
          return 'food';
        case ActivityType.transportation:
          return 'transport';
        case ActivityType.accommodation:
          return 'accommodation';
        case ActivityType.event:
          return 'event';
        case ActivityType.leisure:
          return 'other';
        default:
          return 'other';
      }
    }
    
    // Basic fields
    final Map<String, dynamic> json = {
      'title': title,
      'type': getBackendActivityType(type),
      'notes': description,
    };
    
    // ID field - use uuid for backend
    if (id.isNotEmpty) {
      if (id.startsWith('unknown_')) {
        // This is a new activity, don't include ID
      } else {
        json['uuid'] = id;
      }
    }
    
    // Time range
    json['timeRange'] = {
      'start': startTime.toIso8601String(),
      'end': endTime.toIso8601String(),
    };
    
    // Location
    json['location'] = {
      'name': location,
    };
    
    // Add coordinates if available
    if (latitude != null && longitude != null) {
      json['location']['coordinates'] = {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      };
    }
    
    // Cost
    if (cost != null) {
      json['cost'] = {
        'amount': cost,
        'currency': currency ?? 'USD',
      };
    }
    
    // Booking info
    if (bookingReference != null && bookingReference!.isNotEmpty) {
      json['reservationInfo'] = bookingReference;
    }
    
    return json;
  }

  // Create a list of Activity from JSON list
  static List<Activity> fromJsonList(List<dynamic> jsonList) {
    final List<Activity> activities = [];
    
    for (var json in jsonList) {
      try {
        final activity = Activity.fromJson(json);
        activities.add(activity);
      } catch (e) {
        print('Error parsing activity: $e');
        print('Problematic JSON: $json');
        // Skip this activity rather than failing the entire list
        continue;
      }
    }
    
    return activities;
  }

  // Create dummy activities for a given day number
  static List<Activity> dummyActivities(int dayNumber) {
    final today = DateTime.now();
    final baseDate = today.add(Duration(days: dayNumber - 1));
    final random = Random();
    
    switch (dayNumber) {
      case 1: // Arrival Day
        return [
          Activity(
            id: '1_1',
            title: 'Airport Arrival',
            description: 'Arrive at the airport and collect luggage',
            type: ActivityType.transportation,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 10, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 11, 30),
            location: 'International Airport',
            cost: 0,
          ),
          Activity(
            id: '1_2',
            title: 'Hotel Check-in',
            description: 'Check in at the hotel and freshen up',
            type: ActivityType.accommodation,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 14, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 15, 0),
            location: 'Luxury Hotel',
            cost: 0,
            isBooked: true,
            bookingReference: 'BK12345',
          ),
          Activity(
            id: '1_3',
            title: 'Welcome Dinner',
            description: 'Enjoy a welcome dinner at a local restaurant',
            type: ActivityType.dining,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 19, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 21, 0),
            location: 'Downtown Restaurant',
            cost: 35.0,
            imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          ),
        ];
      
      case 2: // Main Attractions
        return [
          Activity(
            id: '2_1',
            title: 'Breakfast at Hotel',
            description: 'Buffet breakfast at the hotel restaurant',
            type: ActivityType.dining,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 8, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 0),
            location: 'Hotel Restaurant',
            cost: 0,
          ),
          Activity(
            id: '2_2',
            title: 'City Tour',
            description: 'Guided tour of the main city attractions',
            type: ActivityType.attraction,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 10, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 14, 0),
            location: 'City Center',
            cost: 50.0,
            imageUrl: 'https://images.unsplash.com/photo-1467269204594-9661b134dd2b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          ),
          Activity(
            id: '2_3',
            title: 'Lunch at Local Eatery',
            description: 'Try local cuisine for lunch',
            type: ActivityType.dining,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 14, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 15, 30),
            location: 'Street Food Market',
            cost: 15.0,
          ),
          Activity(
            id: '2_4',
            title: 'Museum Visit',
            description: 'Visit the famous national museum',
            type: ActivityType.attraction,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 16, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 18, 0),
            location: 'National Museum',
            cost: 20.0,
            isBooked: true,
            bookingReference: 'MUS789',
            imageUrl: 'https://images.unsplash.com/photo-1544979567-4b427ca5aeec?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          ),
        ];
      
      case 3: // Cultural Immersion
        return [
          Activity(
            id: '3_1',
            title: 'Cultural Workshop',
            description: 'Participate in a local craft workshop',
            type: ActivityType.event,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 12, 0),
            location: 'Cultural Center',
            cost: 40.0,
            imageUrl: 'https://images.unsplash.com/photo-1527856263669-12c3a0af2aa6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          ),
          Activity(
            id: '3_2',
            title: 'Traditional Lunch',
            description: 'Authentic local meal with a host family',
            type: ActivityType.dining,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 13, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 15, 0),
            location: 'Local Home',
            cost: 25.0,
          ),
        ];
      
      case 4: // Relaxation
        return [
          Activity(
            id: '4_1',
            title: 'Spa Treatment',
            description: 'Relaxing massage and spa treatment',
            type: ActivityType.leisure,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 10, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 12, 0),
            location: 'Hotel Spa',
            cost: 80.0,
            isBooked: true,
            bookingReference: 'SPA456',
            imageUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          ),
          Activity(
            id: '4_2',
            title: 'Beach Time',
            description: 'Relax on the beach',
            type: ActivityType.leisure,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 14, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 17, 0),
            location: 'Public Beach',
            cost: 0,
            imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1473&q=80',
          ),
        ];
      
      case 5: // Adventure
        return [
          Activity(
            id: '5_1',
            title: 'Hiking Trip',
            description: 'Guided hiking tour in the mountains',
            type: ActivityType.leisure,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 8, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 14, 0),
            location: 'Mountain Trail',
            cost: 60.0,
            isBooked: true,
            bookingReference: 'HTK789',
            imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          ),
          Activity(
            id: '5_2',
            title: 'Dinner at Scenic Restaurant',
            description: 'Dinner with a view',
            type: ActivityType.dining,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 19, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 21, 0),
            location: 'Hilltop Restaurant',
            cost: 55.0,
            imageUrl: 'https://images.unsplash.com/photo-1579027989536-b7b1f875659b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          ),
        ];
      
      case 6: // Shopping & Leisure
        return [
          Activity(
            id: '6_1',
            title: 'Market Shopping',
            description: 'Shop for souvenirs at local markets',
            type: ActivityType.leisure,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 10, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 13, 0),
            location: 'Local Market',
            cost: 0,
            imageUrl: 'https://images.unsplash.com/photo-1555443805-658637491dd4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          ),
          Activity(
            id: '6_2',
            title: 'Free Time',
            description: 'Personal time to explore or rest',
            type: ActivityType.leisure,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 14, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 18, 0),
            location: 'Various',
            cost: 0,
          ),
        ];
      
      case 7: // Departure
        return [
          Activity(
            id: '7_1',
            title: 'Hotel Checkout',
            description: 'Check out from the hotel',
            type: ActivityType.accommodation,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 10, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 11, 0),
            location: 'Hotel',
            cost: 0,
          ),
          Activity(
            id: '7_2',
            title: 'Airport Transfer',
            description: 'Transportation to the airport',
            type: ActivityType.transportation,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 12, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 13, 0),
            location: 'Hotel to Airport',
            cost: 25.0,
            isBooked: true,
            bookingReference: 'TRF123',
          ),
          Activity(
            id: '7_3',
            title: 'Departure Flight',
            description: 'Return flight home',
            type: ActivityType.transportation,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 15, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 18, 0),
            location: 'International Airport',
            cost: 0,
            isBooked: true,
            bookingReference: 'FL987',
          ),
        ];
      
      default:
        return [
          Activity(
            id: '${dayNumber}_1',
            title: 'Free Day',
            description: 'No planned activities',
            type: ActivityType.leisure,
            startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 9, 0),
            endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 18, 0),
            location: 'Various',
            cost: 0,
          ),
        ];
    }
  }
} 