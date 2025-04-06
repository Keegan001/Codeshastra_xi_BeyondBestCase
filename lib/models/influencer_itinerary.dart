import 'package:flutter/material.dart';
import 'package:safar/models/day.dart';

class InfluencerItinerary {
  final String id;
  final String destination;
  final String influencerName;
  final String influencerHandle;
  final String influencerImageUrl;
  final String description;
  final List<ItineraryDay> days;
  final String heroImageUrl;
  final Color themeColor;

  InfluencerItinerary({
    required this.id,
    required this.destination,
    required this.influencerName,
    required this.influencerHandle,
    required this.influencerImageUrl,
    required this.description,
    required this.days,
    required this.heroImageUrl,
    required this.themeColor,
  });

  factory InfluencerItinerary.fromRawText(
    String id,
    String destination,
    String influencerName,
    String influencerHandle,
    String description,
    String rawText,
    Color themeColor,
    String heroImageUrl,
    String influencerImageUrl,
  ) {
    List<ItineraryDay> days = [];
    
    // Split the text by "Day" and make sure it's followed by a number
    RegExp dayPattern = RegExp(r'Day \d+:.*?(?=Day \d+:|$)', dotAll: true);
    
    // Find all day sections
    Iterable<RegExpMatch> matches = dayPattern.allMatches(rawText);
    
    // If no matches found, try alternate format with newlines
    if (matches.isEmpty) {
      // Try to find day sections with the format "Day X: Title"
      RegExp altDayPattern = RegExp(r'Day \d+:.*?(?=\n\nDay \d+:|$)', dotAll: true);
      matches = altDayPattern.allMatches(rawText);
      
      // If still no matches, manually split by "Day X:"
      if (matches.isEmpty) {
        final lines = rawText.split('\n');
        int currentDay = 0;
        String title = '';
        List<String> activities = [];
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          
          // Skip empty lines
          if (line.isEmpty) continue;
          
          // Check if this line is a day header
          if (line.startsWith('Day ') && line.contains(':')) {
            // If we've been collecting activities for a previous day, add it to days
            if (currentDay > 0 && activities.isNotEmpty) {
              days.add(ItineraryDay(
                dayNumber: currentDay,
                title: title,
                activities: activities,
              ));
              activities = [];
            }
            
            // Parse the new day
            final dayParts = line.split(':');
            title = line;
            currentDay = int.tryParse(dayParts[0].replaceAll('Day ', '').trim()) ?? currentDay + 1;
          } 
          // If it doesn't start with "Day" and we have a current day, it's an activity
          else if (currentDay > 0 && line.isNotEmpty) {
            activities.add(line);
          }
        }
        
        // Add the last day if needed
        if (currentDay > 0 && activities.isNotEmpty) {
          days.add(ItineraryDay(
            dayNumber: currentDay,
            title: title,
            activities: activities,
          ));
        }
      } else {
        // Process matches for alternate format
        for (final match in matches) {
          String dayText = match.group(0) ?? '';
          
          // Extract day number and title
          RegExp dayNumPattern = RegExp(r'Day (\d+):');
          final dayNumMatch = dayNumPattern.firstMatch(dayText);
          int dayNumber = 0;
          
          if (dayNumMatch != null) {
            dayNumber = int.tryParse(dayNumMatch.group(1) ?? '0') ?? 0;
          }
          
          if (dayNumber == 0) continue;
          
          // Get title - everything until the first newline
          int firstNewline = dayText.indexOf('\n');
          String title = firstNewline > 0 ? 
            dayText.substring(0, firstNewline).trim() : 
            'Day $dayNumber';
          
          // Rest of the text contains activities
          String activitiesText = firstNewline > 0 ? 
            dayText.substring(firstNewline).trim() : 
            dayText;
          
          // Split activities by newlines
          List<String> activities = activitiesText
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .toList();
          
          // First activity might actually be part of the title, so skip it if it's already included
          if (activities.isNotEmpty && title.contains(activities.first)) {
            activities = activities.sublist(1);
          }
          
          days.add(ItineraryDay(
            dayNumber: dayNumber,
            title: title,
            activities: activities,
          ));
        }
      }
    } else {
      // Process normal format matches
      for (final match in matches) {
        String dayText = match.group(0) ?? '';
        
        // Extract day number
        RegExp dayNumPattern = RegExp(r'Day (\d+):');
        final dayNumMatch = dayNumPattern.firstMatch(dayText);
        int dayNumber = 0;
        
        if (dayNumMatch != null) {
          dayNumber = int.tryParse(dayNumMatch.group(1) ?? '0') ?? 0;
        }
        
        if (dayNumber == 0) continue;
        
        // Extract title
        final titleEnd = dayText.indexOf('\n');
        String title = titleEnd > 0 ? 
          dayText.substring(0, titleEnd).trim() : 
          'Day $dayNumber';
        
        // Split the remaining text into activities
        String activitiesText = titleEnd > 0 ? 
          dayText.substring(titleEnd).trim() : 
          '';
        
        List<String> activities = activitiesText
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();
        
        days.add(ItineraryDay(
          dayNumber: dayNumber,
          title: title,
          activities: activities,
        ));
      }
    }
    
    // Sort days by day number
    days.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    
    return InfluencerItinerary(
      id: id,
      destination: destination,
      influencerName: influencerName,
      influencerHandle: influencerHandle,
      influencerImageUrl: influencerImageUrl,
      description: description,
      days: days,
      heroImageUrl: heroImageUrl,
      themeColor: themeColor,
    );
  }
}

class ItineraryDay {
  final int dayNumber;
  final String title;
  final List<String> activities;

  ItineraryDay({
    required this.dayNumber,
    required this.title,
    required this.activities,
  });
} 