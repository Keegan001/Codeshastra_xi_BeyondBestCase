import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safar/models/influencer_itinerary.dart';

class InfluencerItineraryService {
  Future<List<InfluencerItinerary>> getInfluencerItineraries() async {
    try {
      // Load the raw text file
      final String rawData = await rootBundle.loadString('assets/data/influencer_itineraries.txt');
      
      // Create itineraries with predefined influencer data
      return [
        InfluencerItinerary.fromRawText(
          '1',
          'Maldives',
          'Amelia Chen',
          '@ameliawanders',
          'Luxury travel specialist focusing on high-end resorts and underwater photography',
          _extractItinerarySection(rawData, '6-Day Maldives Itinerary'),
          const Color(0xFF1A73E8), // Ocean blue
          'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1476&q=80',
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
        ),
        InfluencerItinerary.fromRawText(
          '2',
          'Dubai',
          'Khalid Rahman',
          '@khalidtravels',
          'Luxury travel expert specializing in Middle Eastern destinations and cultural experiences',
          _extractItinerarySection(rawData, '6-Day Dubai Itinerary'),
          const Color(0xFFFFA000), // Desert gold
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
        ),
        InfluencerItinerary.fromRawText(
          '3',
          'Japan',
          'Yuki Tanaka',
          '@yukiexplores',
          'Travel photographer specializing in Japanese culture, street photography, and food',
          _extractItinerarySection(rawData, '6-Day Japan Itinerary'),
          const Color(0xFFE53935), // Cherry blossom red
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',
          'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
        ),
        InfluencerItinerary.fromRawText(
          '4',
          'Bali',
          'Isabella Rose',
          '@isabellarosetravels',
          'Lifestyle travel blogger focusing on wellness retreats, yoga, and sustainable tourism',
          _extractItinerarySection(rawData, '6-Day Bali Itinerary'),
          const Color(0xFF43A047), // Tropical green
          'https://images.unsplash.com/photo-1604999333679-b86d54738315?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1625&q=80',
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1471&q=80',
        ),
        InfluencerItinerary.fromRawText(
          '5',
          'Italy',
          'Marco Rossi',
          '@marcorossitravels',
          'Food and culture travel expert specializing in European destinations, architectural photography, and culinary experiences',
          _extractItinerarySection(rawData, '6-Day Italy Itinerary'),
          const Color(0xFF5E35B1), // Mediterranean purple
          'https://images.unsplash.com/photo-1523906834658-6e24ef2386f9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1483&q=80',
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
        ),
      ];
    } catch (e) {
      print('Error loading influencer itineraries: $e');
      return [];
    }
  }
  
  String _extractItinerarySection(String rawData, String sectionName) {
    // Find the section in the raw data
    int startIndex = rawData.indexOf(sectionName);
    if (startIndex == -1) return '';
    
    // Look for the next itinerary section
    String remainingText = rawData.substring(startIndex);
    int endIndex = rawData.length;
    
    // Find the next itinerary section (if there is one)
    RegExp nextItineraryPattern = RegExp(r'6-Day [A-Za-z]+ Itinerary', multiLine: true);
    Match? nextMatch = nextItineraryPattern.firstMatch(remainingText.substring(sectionName.length));
    
    if (nextMatch != null) {
      // Calculate the actual end index in the original string
      endIndex = startIndex + sectionName.length + nextMatch.start - 1;
    }
    
    // Extract the section
    String section = rawData.substring(startIndex, endIndex).trim();
    return section;
  }
} 