import 'package:flutter/material.dart';

enum ScrapbookEntryType {
  photo,
  video,
  note,
  audio
}

class ScrapbookEntry {
  final String id;
  final String title;
  final String content;
  final ScrapbookEntryType type;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? mediaUrl;

  ScrapbookEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.mediaUrl,
  });

  // Create from JSON
  static ScrapbookEntry fromJson(Map<String, dynamic> json) {
    return ScrapbookEntry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: ScrapbookEntryType.values[json['type']],
      timestamp: DateTime.parse(json['timestamp']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      mediaUrl: json['mediaUrl'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'mediaUrl': mediaUrl,
    };
  }

  // Create a list of ScrapbookEntry from JSON list
  static List<ScrapbookEntry> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ScrapbookEntry.fromJson(json)).toList();
  }

  // Factory method to create dummy entries for testing
  static List<ScrapbookEntry> dummyEntries(String location) {
    final now = DateTime.now();
    
    switch (location) {
      case 'Paris':
        return [
          ScrapbookEntry(
            id: '1',
            title: 'Eiffel Tower',
            content: 'Amazing view from the top!',
            type: ScrapbookEntryType.photo,
            timestamp: now.subtract(const Duration(days: 5)),
            latitude: 48.8584,
            longitude: 2.2945,
            mediaUrl: 'https://images.unsplash.com/photo-1543349689-9a4d426bee8e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1501&q=80',
          ),
          ScrapbookEntry(
            id: '2',
            title: 'Louvre Museum',
            content: 'The Mona Lisa is smaller than I expected',
            type: ScrapbookEntryType.note,
            timestamp: now.subtract(const Duration(days: 4)),
            latitude: 48.8606,
            longitude: 2.3376,
          ),
          ScrapbookEntry(
            id: '3',
            title: 'Seine River Cruise',
            content: 'Beautiful sunset cruise along the Seine',
            type: ScrapbookEntryType.video,
            timestamp: now.subtract(const Duration(days: 3)),
            latitude: 48.8566,
            longitude: 2.3522,
            mediaUrl: 'https://example.com/video1.mp4',
          ),
        ];
      case 'Tokyo':
        return [
          ScrapbookEntry(
            id: '4',
            title: 'Shibuya Crossing',
            content: 'So many people crossing at once!',
            type: ScrapbookEntryType.photo,
            timestamp: now.subtract(const Duration(days: 15)),
            latitude: 35.6595,
            longitude: 139.7004,
            mediaUrl: 'https://images.unsplash.com/photo-1542051841857-5f90071e7989?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          ),
          ScrapbookEntry(
            id: '5',
            title: 'Tokyo Skytree',
            content: 'Amazing views of the city',
            type: ScrapbookEntryType.photo,
            timestamp: now.subtract(const Duration(days: 14)),
            latitude: 35.7101,
            longitude: 139.8107,
            mediaUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1488&q=80',
          ),
        ];
      case 'New York':
        return [
          ScrapbookEntry(
            id: '6',
            title: 'Times Square',
            content: 'The lights and billboards are mesmerizing',
            type: ScrapbookEntryType.note,
            timestamp: now.subtract(const Duration(days: 2)),
            latitude: 40.7580,
            longitude: -73.9855,
          ),
        ];
      case 'Bali':
        return [
          ScrapbookEntry(
            id: '7',
            title: 'Ubud Monkey Forest',
            content: 'Monkeys are everywhere!',
            type: ScrapbookEntryType.photo,
            timestamp: now.subtract(const Duration(days: 20)),
            latitude: -8.5188,
            longitude: 115.2582,
            mediaUrl: 'https://images.unsplash.com/photo-1557093793-e196ae071479?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          ),
          ScrapbookEntry(
            id: '8',
            title: 'Kuta Beach',
            content: 'Beautiful sunset at the beach',
            type: ScrapbookEntryType.video,
            timestamp: now.subtract(const Duration(days: 19)),
            latitude: -8.7183,
            longitude: 115.1686,
            mediaUrl: 'https://example.com/video2.mp4',
          ),
        ];
      default:
        return [];
    }
  }
} 