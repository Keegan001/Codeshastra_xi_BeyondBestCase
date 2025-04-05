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
    
    if (json['categories'] != null && json['categories'] is Map) {
      categoriesMap = {};
      (json['categories'] as Map).forEach((key, value) {
        if (value != null) {
          double doubleValue = 0.0;
          if (value is num) {
            doubleValue = value.toDouble();
          } else if (value is String) {
            doubleValue = double.tryParse(value) ?? 0.0;
          }
          categoriesMap![key.toString()] = doubleValue;
        }
      });
    }

    // Parse total field
    double totalValue = 0.0;
    if (json['total'] != null) {
      if (json['total'] is num) {
        totalValue = (json['total'] as num).toDouble();
      } else if (json['total'] is String) {
        totalValue = double.tryParse(json['total']) ?? 0.0;
      }
    }

    // Parse spent field
    double spentValue = 0.0;
    if (json['spent'] != null) {
      if (json['spent'] is num) {
        spentValue = (json['spent'] as num).toDouble();
      } else if (json['spent'] is String) {
        spentValue = double.tryParse(json['spent']) ?? 0.0;
      }
    }

    return Budget(
      currency: json['currency']?.toString() ?? 'USD',
      total: totalValue,
      spent: spentValue,
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
    // Handle mode field - could be missing or of wrong type
    String transportMode = 'mixed';
    if (json['mode'] != null) {
      transportMode = json['mode'].toString();
    }

    // Handle details field - ensure it's a map
    Map<String, dynamic>? transportDetails;
    if (json['details'] != null && json['details'] is Map) {
      transportDetails = Map<String, dynamic>.from(json['details']);
    }

    return Transportation(
      mode: transportMode,
      details: transportDetails,
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
  final Map<String, dynamic>? additionalSuggestions;
  final User? owner;
  final List<Collaborator>? collaborators;
  final List<JoinRequest>? joinRequests;

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
    this.additionalSuggestions,
    this.owner,
    this.collaborators,
    this.joinRequests,
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

  // Factory constructor to parse the API response format
  factory Itinerary.fromJson(Map<String, dynamic> json) {
    try {
      String id = json['_id'] ?? json['id'] ?? '';
      String title = json['title'] ?? 'Untitled Itinerary';
      
      // Parse destination
      String destination = '';
      if (json['destination'] != null) {
        if (json['destination'] is Map) {
          destination = json['destination']['name'] ?? '';
        } else {
          destination = json['destination'].toString();
        }
      }
      
      // Parse date range
      DateTimeRange dateRange;
      if (json['dateRange'] != null) {
        DateTime start = DateTime.now();
        DateTime end = DateTime.now().add(const Duration(days: 7));
        
        if (json['dateRange'] is Map) {
          if (json['dateRange']['start'] != null) {
            try {
              start = DateTime.parse(json['dateRange']['start'].toString());
            } catch (e) {
              // Keep default if parsing fails
            }
          }
          if (json['dateRange']['end'] != null) {
            try {
              end = DateTime.parse(json['dateRange']['end'].toString());
            } catch (e) {
              // Keep default if parsing fails
            }
          }
        }
        dateRange = DateTimeRange(start: start, end: end);
      } else {
        dateRange = DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 7)),
        );
      }
      
      // Parse budget tier (default to standard)
      BudgetTier budgetTier = BudgetTier.standard;
      if (json['budget'] != null) {
        try {
          if (json['budget'] is Map && json['budget']['total'] != null) {
            final totalVal = json['budget']['total'];
            final total = totalVal is num ? totalVal.toDouble() : 
                          totalVal is String ? double.tryParse(totalVal) ?? 500.0 : 500.0;
                          
            if (total < 200) {
              budgetTier = BudgetTier.cheap;
            } else if (total < 500) {
              budgetTier = BudgetTier.budget;
            } else if (total < 1000) {
              budgetTier = BudgetTier.standard;
            } else {
              budgetTier = BudgetTier.luxury;
            }
          }
        } catch (e) {
          // Use default if there's any error
        }
      }
      
      // Parse transport mode
      String transportationMode = 'mixed';
      if (json['transportation'] != null) {
        if (json['transportation'] is Map && json['transportation']['mode'] != null) {
          transportationMode = json['transportation']['mode'].toString();
        } else if (json['transportation'] is String) {
          transportationMode = json['transportation'];
        }
      }
      
      // Parse is private
      bool isPrivate = json['isPrivate'] == true; // Ensure it's a boolean
      
      // Parse days (assuming day IDs for now, to be loaded separately)
      List<Day> days = [];
      if (json['days'] != null) {
        if (json['days'] is List) {
          days = (json['days'] as List).map((dayData) {
            if (dayData is Map<String, dynamic>) {
              try {
                // Use Day.fromJson if available, but handle errors gracefully
                final String dayId = dayData['_id']?.toString() ?? dayData['id']?.toString() ?? '';
                DateTime dayDate;
                try {
                  dayDate = dayData['date'] != null 
                      ? DateTime.parse(dayData['date'].toString()) 
                      : DateTime.now().add(Duration(days: days.length));
                } catch (e) {
                  dayDate = DateTime.now().add(Duration(days: days.length));
                }
                
                return Day(
                  id: dayId,
                  date: dayDate,
                  title: dayData['title']?.toString() ?? 'Day ${days.length + 1}',
                  notes: dayData['notes']?.toString() ?? '',
                  activities: [], // We'll load activities separately if needed
                );
              } catch (e) {
                // If parsing fails, create a placeholder
                return Day(
                  id: dayData['_id']?.toString() ?? '',
                  date: DateTime.now().add(Duration(days: days.length)),
                  title: 'Day ${days.length + 1}',
                  activities: [],
                  notes: '',
                );
              }
            } else {
              // If it's just an ID
              return Day(
                id: dayData.toString(),
                date: DateTime.now(),
                title: 'Day ${days.length + 1}',
                activities: [],
                notes: '',
              );
            }
          }).toList();
        }
      }
      
      // Default to solo package type
      PackageType packageType = PackageType.solo;
      
      // Use a default cover image if none provided
      String coverImage = json['coverImage'] ?? 
          'https://images.unsplash.com/photo-1500835556837-99ac94a94552';
      
      // Parse notes
      String notes = json['notes']?.toString() ?? '';
      
      // Parse timestamps
      DateTime createdAt;
      try {
        createdAt = json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'].toString()) 
            : DateTime.now();
      } catch (e) {
        createdAt = DateTime.now();
      }
      
      DateTime updatedAt;
      try {
        updatedAt = json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt'].toString()) 
            : DateTime.now();
      } catch (e) {
        updatedAt = DateTime.now();
      }
      
      // Parse description
      String? description = json['description']?.toString();
      
      // Parse budget
      Budget? budget;
      if (json['budget'] != null && json['budget'] is Map) {
        try {
          budget = Budget.fromJson(json['budget'] as Map<String, dynamic>);
        } catch (e) {
          // Leave as null if parsing fails
        }
      }
      
      // Parse transportation
      Transportation? transportation;
      if (json['transportation'] != null && json['transportation'] is Map) {
        try {
          transportation = Transportation.fromJson(json['transportation'] as Map<String, dynamic>);
        } catch (e) {
          // Leave as null if parsing fails
        }
      }
      
      // Parse additional suggestions
      Map<String, dynamic>? additionalSuggestions;
      if (json['additionalSuggestions'] != null && json['additionalSuggestions'] is Map) {
        additionalSuggestions = json['additionalSuggestions'] as Map<String, dynamic>;
      }
      
      // Parse owner
      User? owner;
      if (json['owner'] != null) {
        try {
          if (json['owner'] is Map) {
            owner = User.fromJson(json['owner'] as Map<String, dynamic>);
          } else if (json['owner'] is String) {
            // Owner might just be an ID
            owner = User(
              id: json['owner'].toString(),
              name: 'User',
              email: '',
              role: 'user',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        } catch (e) {
          // Leave as null if parsing fails
        }
      }
      
      // Parse collaborators
      List<Collaborator>? collaborators;
      if (json['collaborators'] != null && json['collaborators'] is List) {
        try {
          collaborators = (json['collaborators'] as List)
              .map((c) => c is Map<String, dynamic> 
                  ? Collaborator.fromJson(c) 
                  : Collaborator(
                      user: User(
                        id: '', 
                        name: 'Unknown', 
                        email: '',
                        role: 'user',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                      role: 'viewer'
                    ))
              .toList();
        } catch (e) {
          // Leave as null if parsing fails
        }
      }
      
      // Parse join requests
      List<JoinRequest>? joinRequests;
      if (json['joinRequests'] != null && json['joinRequests'] is List) {
        try {
          joinRequests = (json['joinRequests'] as List)
              .map((jr) => jr is Map<String, dynamic> 
                  ? JoinRequest.fromJson(jr)
                  : JoinRequest(
                      user: User(
                        id: '', 
                        name: 'Unknown', 
                        email: '',
                        role: 'user',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                      status: 'pending',
                      requestedAt: DateTime.now()
                    ))
              .toList();
        } catch (e) {
          // Leave as null if parsing fails
        }
      }
      
      // Parse scrapbook entries
      List<ScrapbookEntry> scrapbookEntries = [];
      if (json['scrapbookEntries'] != null && json['scrapbookEntries'] is List) {
        try {
          scrapbookEntries = (json['scrapbookEntries'] as List)
              .where((entry) => entry is Map<String, dynamic>)
              .map((entry) => ScrapbookEntry.fromJson(entry as Map<String, dynamic>))
              .toList();
        } catch (e) {
          // Use empty list if parsing fails
        }
      }
      
      return Itinerary(
        id: id,
        title: title,
        destination: destination,
        dateRange: dateRange,
        budgetTier: budgetTier,
        transportationMode: transportationMode,
        isPrivate: isPrivate,
        days: days,
        scrapbookEntries: scrapbookEntries,
        packageType: packageType,
        coverImage: coverImage,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        description: description,
        budget: budget,
        transportation: transportation,
        additionalSuggestions: additionalSuggestions,
        owner: owner,
        collaborators: collaborators,
        joinRequests: joinRequests,
      );
    } catch (e) {
      print('Error in Itinerary.fromJson: $e');
      // Return a default itinerary to avoid crashing
      return Itinerary(
        id: '',
        title: 'Error Loading',
        destination: 'Unknown',
        dateRange: DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 7)),
        ),
        budgetTier: BudgetTier.standard,
        transportationMode: 'mixed',
        isPrivate: true,
        days: [],
        packageType: PackageType.solo,
        coverImage: 'https://images.unsplash.com/photo-1500835556837-99ac94a94552',
        notes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
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
    Map<String, dynamic>? additionalSuggestions,
    User? owner,
    List<Collaborator>? collaborators,
    List<JoinRequest>? joinRequests,
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
      description: description ?? this.description,
      budget: budget ?? this.budget,
      transportation: transportation ?? this.transportation,
      additionalSuggestions: additionalSuggestions ?? this.additionalSuggestions,
      owner: owner ?? this.owner,
      collaborators: collaborators ?? this.collaborators,
      joinRequests: joinRequests ?? this.joinRequests,
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