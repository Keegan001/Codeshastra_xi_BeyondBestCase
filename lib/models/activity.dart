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
    this.isBooked = false,
    this.bookingReference,
    this.latitude,
    this.longitude,
  });

  // Create from JSON
  static Activity fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ActivityType.values[json['type']],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      imageUrl: json['imageUrl'],
      cost: json['cost'],
      isBooked: json['isBooked'] ?? false,
      bookingReference: json['bookingReference'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'cost': cost,
      'isBooked': isBooked,
      'bookingReference': bookingReference,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Create a list of Activity from JSON list
  static List<Activity> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Activity.fromJson(json)).toList();
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