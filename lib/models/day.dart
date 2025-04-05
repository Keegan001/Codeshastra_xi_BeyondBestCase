import 'package:safar/models/activity.dart';

class Day {
  final String id;
  final DateTime date;
  final String title;
  final String notes;
  final List<Activity> activities;

  Day({
    required this.id,
    required this.date,
    required this.title,
    this.notes = '',
    required this.activities,
  });

  // Create from JSON
  static Day fromJson(Map<String, dynamic> json) {
    return Day(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      notes: json['notes'] ?? '',
      activities: Activity.fromJsonList(json['activities'] ?? []),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'notes': notes,
      'activities': activities.map((activity) => activity.toJson()).toList(),
    };
  }

  // Create a list of Day from JSON list
  static List<Day> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Day.fromJson(json)).toList();
  }

  // Create dummy days for testing
  static List<Day> dummyDays() {
    final today = DateTime.now();
    
    return [
      Day(
        id: '1',
        date: today,
        title: 'Day 1 - Arrival & Exploration',
        notes: 'Check in at hotel by 2 PM',
        activities: Activity.dummyActivities(1),
      ),
      Day(
        id: '2',
        date: today.add(const Duration(days: 1)),
        title: 'Day 2 - Main Attractions',
        notes: 'Dress comfortably for a lot of walking',
        activities: Activity.dummyActivities(2),
      ),
      Day(
        id: '3',
        date: today.add(const Duration(days: 2)),
        title: 'Day 3 - Cultural Immersion',
        notes: 'Try local cuisine today',
        activities: Activity.dummyActivities(3),
      ),
      Day(
        id: '4',
        date: today.add(const Duration(days: 3)),
        title: 'Day 4 - Relaxation',
        notes: 'Spa reservation at 2 PM',
        activities: Activity.dummyActivities(4),
      ),
      Day(
        id: '5',
        date: today.add(const Duration(days: 4)),
        title: 'Day 5 - Adventure',
        notes: 'Bring sunscreen and water',
        activities: Activity.dummyActivities(5),
      ),
      Day(
        id: '6',
        date: today.add(const Duration(days: 5)),
        title: 'Day 6 - Shopping & Leisure',
        notes: 'Visit local markets',
        activities: Activity.dummyActivities(6),
      ),
      Day(
        id: '7',
        date: today.add(const Duration(days: 6)),
        title: 'Day 7 - Departure',
        notes: 'Check out by 11 AM',
        activities: Activity.dummyActivities(7),
      ),
    ];
  }
} 