import 'package:safar/models/user.dart';
import 'package:flutter/material.dart';
import 'package:safar/models/day.dart';
import 'package:safar/models/scrapbook_entry.dart';

// Extension on DateTimeRange to provide the durationInDays property
extension DateTimeRangeExtension on DateTimeRange {
  int get durationInDays => duration.inDays + 1;
}

class Location {
  final String name;
  final String? description;
  final String? placeId;
  final double? longitude;
  final double? latitude;

  Location({
    required this.name,
    this.description,
    this.placeId,
    this.longitude,
    this.latitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    final coordinates = json['location'] != null ? 
        (json['location']['coordinates'] as List<dynamic>?) : null;
    
    return Location(
      name: json['name'] ?? '',
      description: json['description'],
      placeId: json['placeId'],
      longitude: coordinates != null && coordinates.isNotEmpty ? 
          coordinates[0]?.toDouble() : null,
      latitude: coordinates != null && coordinates.length > 1 ? 
          coordinates[1]?.toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'placeId': placeId,
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
    };
  }
}

class Collaborator {
  final User user;
  final String role;

  Collaborator({
    required this.user,
    required this.role,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      user: User.fromJson(json['user']),
      role: json['role'] ?? 'viewer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'role': role,
    };
  }
}

class JoinRequest {
  final User user;
  final String status;
  final DateTime requestedAt;

  JoinRequest({
    required this.user,
    required this.status,
    required this.requestedAt,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      user: User.fromJson(json['user']),
      status: json['status'] ?? 'pending',
      requestedAt: json['requestedAt'] != null 
          ? DateTime.parse(json['requestedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
    };
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({
    required this.start,
    required this.end,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: json['start'] != null 
          ? DateTime.parse(json['start']) 
          : DateTime.now(),
      end: json['end'] != null 
          ? DateTime.parse(json['end']) 
          : DateTime.now().add(const Duration(days: 7)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  int get durationInDays {
    return end.difference(start).inDays + 1;
  }
}

class Budget {
  final String currency;
  final double total;
  final double spent;
  final Map<String, double>? categories;

  Budget({
    required this.currency,
    required this.total,
    required this.spent,
    this.categories,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    Map<String, double>? categoriesMap;
    
    if (json['categories'] != null) {
      categoriesMap = {};
      json['categories'].forEach((key, value) {
        categoriesMap![key] = (value as num).toDouble();
      });
    }

    return Budget(
      currency: json['currency'] ?? 'USD',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      categories: categoriesMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'total': total,
      'spent': spent,
      'categories': categories,
    };
  }
}

class Transportation {
  final String mode;
  final Map<String, dynamic>? details;

  Transportation({
    required this.mode,
    this.details,
  });

  factory Transportation.fromJson(Map<String, dynamic> json) {
    return Transportation(
      mode: json['mode'] ?? 'mixed',
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'details': details,
    };
  }
}

enum BudgetTier {
  cheap,
  budget,
  standard,
  luxury,
}

enum PackageType {
  solo,
  couple,
  family,
  friends,
}

class Itinerary {
  final String id;
  final String title;
  final String destination;
  final DateTimeRange dateRange;
  final BudgetTier budgetTier;
  final String transportationMode;
  final bool isPrivate;
  final List<Day> days;
  final List<ScrapbookEntry> scrapbookEntries;
  final PackageType packageType;
  final String coverImage;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final Budget? budget;
  final Transportation? transportation;

  Itinerary({
    required this.id,
    required this.title,
    required this.destination,
    required this.dateRange,
    required this.budgetTier,
    required this.transportationMode,
    this.isPrivate = true,
    required this.days,
    this.scrapbookEntries = const [],
    required this.packageType,
    required this.coverImage,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.budget,
    this.transportation,
  });

  // Get the number of days
  int get numberOfDays => dateRange.durationInDays;

  // Get the formatted budget tier
  String get budgetTierText {
    switch (budgetTier) {
      case BudgetTier.cheap:
        return 'Budget-Friendly';
      case BudgetTier.budget:
        return 'Moderate';
      case BudgetTier.standard:
        return 'Standard';
      case BudgetTier.luxury:
        return 'Luxury';
    }
  }

  // Get the formatted package type
  String get packageTypeText {
    switch (packageType) {
      case PackageType.solo:
        return 'Solo Travel';
      case PackageType.couple:
        return 'Couple';
      case PackageType.family:
        return 'Family';
      case PackageType.friends:
        return 'Friends Group';
    }
  }

  // Copy with method for updating
  Itinerary copyWith({
    String? id,
    String? title,
    String? destination,
    DateTimeRange? dateRange,
    BudgetTier? budgetTier,
    String? transportationMode,
    bool? isPrivate,
    List<Day>? days,
    List<ScrapbookEntry>? scrapbookEntries,
    PackageType? packageType,
    String? coverImage,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    Budget? budget,
    Transportation? transportation,
  }) {
    return Itinerary(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      dateRange: dateRange ?? this.dateRange,
      budgetTier: budgetTier ?? this.budgetTier,
      transportationMode: transportationMode ?? this.transportationMode,
      isPrivate: isPrivate ?? this.isPrivate,
      days: days ?? this.days,
      scrapbookEntries: scrapbookEntries ?? this.scrapbookEntries,
      packageType: packageType ?? this.packageType,
      coverImage: coverImage ?? this.coverImage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description,
      budget: budget,
      transportation: transportation,
    );
  }

  // Create dummy itineraries
  static List<Itinerary> dummyList() {
    return [
      Itinerary(
        id: '1',
        title: 'Summer in Paris',
        destination: 'Paris, France',
        dateRange: DateTimeRange(
          start: DateTime(2023, 6, 15),
          end: DateTime(2023, 6, 22),
        ),
        budgetTier: BudgetTier.standard,
        transportationMode: 'Flight',
        isPrivate: false,
        days: Day.dummyDays(),
        packageType: PackageType.couple,
        coverImage: 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        scrapbookEntries: ScrapbookEntry.dummyEntries('Paris'),
      ),
      Itinerary(
        id: '2',
        title: 'Tokyo Adventure',
        destination: 'Tokyo, Japan',
        dateRange: DateTimeRange(
          start: DateTime(2023, 8, 10),
          end: DateTime(2023, 8, 20),
        ),
        budgetTier: BudgetTier.luxury,
        transportationMode: 'Flight',
        isPrivate: true,
        days: Day.dummyDays(),
        packageType: PackageType.friends,
        coverImage: 'https://images.unsplash.com/photo-1536098561742-ca998e48cbcc',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
        scrapbookEntries: ScrapbookEntry.dummyEntries('Tokyo'),
      ),
      Itinerary(
        id: '3',
        title: 'Weekend in New York',
        destination: 'New York, USA',
        dateRange: DateTimeRange(
          start: DateTime.now().add(const Duration(days: 15)),
          end: DateTime.now().add(const Duration(days: 17)),
        ),
        budgetTier: BudgetTier.budget,
        transportationMode: 'Train',
        isPrivate: true,
        days: Day.dummyDays(),
        packageType: PackageType.solo,
        coverImage: 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        scrapbookEntries: ScrapbookEntry.dummyEntries('New York'),
      ),
      Itinerary(
        id: '4',
        title: 'Bali Family Retreat',
        destination: 'Bali, Indonesia',
        dateRange: DateTimeRange(
          start: DateTime.now().add(const Duration(days: 45)),
          end: DateTime.now().add(const Duration(days: 60)),
        ),
        budgetTier: BudgetTier.luxury,
        transportationMode: 'Flight',
        isPrivate: false,
        days: Day.dummyDays(),
        packageType: PackageType.family,
        coverImage: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        scrapbookEntries: ScrapbookEntry.dummyEntries('Bali'),
      ),
    ];
  }
} 