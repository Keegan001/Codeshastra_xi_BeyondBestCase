import 'package:flutter/material.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:safar/features/settings/theme_provider.dart';

class MapBackgroundUtils {
  // Sample Google Maps API Key - replace with your actual key in production
  static const String googleMapsApiKey = 'YOUR_API_KEY_HERE';
  
  // Get a map background image URL based on the style and coordinates
  static String getMapBackgroundUrl({
    required BackgroundStyle style,
    required double latitude,
    required double longitude,
    double zoom = 14.0,
    int width = 600,
    int height = 400,
    bool darkMode = false,
  }) {
    String mapType;
    
    switch (style) {
      case BackgroundStyle.mapSatellite:
        mapType = 'satellite';
        break;
      case BackgroundStyle.mapTerrain:
        mapType = 'terrain';
        break;
      case BackgroundStyle.mapHybrid:
        mapType = 'hybrid';
        break;
      case BackgroundStyle.mapStandard:
      default:
        mapType = 'roadmap';
        break;
    }
    
    // Add dark mode styling if needed
    String darkModeParam = '';
    if (darkMode && mapType == 'roadmap') {
      darkModeParam = '&style=element:geometry%7Ccolor:0x212121&style=element:labels.icon%7Cvisibility:off&style=element:labels.text.fill%7Ccolor:0x757575&style=element:labels.text.stroke%7Ccolor:0x212121&style=feature:administrative%7Celement:geometry%7Ccolor:0x757575&style=feature:administrative.country%7Celement:labels.text.fill%7Ccolor:0x9e9e9e&style=feature:administrative.land_parcel%7Cvisibility:off&style=feature:administrative.locality%7Celement:labels.text.fill%7Ccolor:0xbdbdbd&style=feature:poi%7Celement:labels.text.fill%7Ccolor:0x757575&style=feature:poi.park%7Celement:geometry%7Ccolor:0x181818&style=feature:poi.park%7Celement:labels.text.fill%7Ccolor:0x616161&style=feature:poi.park%7Celement:labels.text.stroke%7Ccolor:0x1b1b1b&style=feature:road%7Celement:geometry.fill%7Ccolor:0x2c2c2c&style=feature:road%7Celement:labels.text.fill%7Ccolor:0x8a8a8a&style=feature:road.arterial%7Celement:geometry%7Ccolor:0x373737&style=feature:road.highway%7Celement:geometry%7Ccolor:0x3c3c3c&style=feature:road.highway.controlled_access%7Celement:geometry%7Ccolor:0x4e4e4e&style=feature:road.local%7Celement:labels.text.fill%7Ccolor:0x616161&style=feature:transit%7Celement:labels.text.fill%7Ccolor:0x757575&style=feature:water%7Celement:geometry%7Ccolor:0x000000&style=feature:water%7Celement:labels.text.fill%7Ccolor:0x3d3d3d';
    }
    
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=$zoom&size=${width}x${height}&maptype=$mapType&markers=color:red%7C$latitude,$longitude&key=$googleMapsApiKey$darkModeParam';
  }
  
  // Get a map background DecorationImage for use in a Container
  static DecorationImage getMapBackgroundDecoration({
    required BackgroundStyle style,
    required double latitude,
    required double longitude,
    double zoom = 14.0,
    int width = 600,
    int height = 400,
    bool darkMode = false,
  }) {
    if (style == BackgroundStyle.none || style == BackgroundStyle.solid) {
      throw ArgumentError('Cannot create map decoration for non-map background styles');
    }
    
    final String url = getMapBackgroundUrl(
      style: style, 
      latitude: latitude, 
      longitude: longitude,
      zoom: zoom,
      width: width,
      height: height,
      darkMode: darkMode,
    );
    
    return DecorationImage(
      image: NetworkImage(url),
      fit: BoxFit.cover,
    );
  }
  
  // Get a map background DecorationImage using the current theme context
  static DecorationImage getMapBackgroundDecorationWithContext({
    required BuildContext context,
    required BackgroundStyle style,
    required double latitude,
    required double longitude,
    double zoom = 14.0,
    int width = 600,
    int height = 400,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    return getMapBackgroundDecoration(
      style: style,
      latitude: latitude,
      longitude: longitude,
      zoom: zoom,
      width: width,
      height: height,
      darkMode: isDarkMode,
    );
  }
  
  // Get a solid color background
  static Color getSolidBackgroundColor(Color? specifiedColor, bool darkMode) {
    if (specifiedColor != null) {
      return specifiedColor;
    }
    return darkMode ? Colors.grey.shade800 : Colors.blueGrey.shade100;
  }
  
  // Open the location in Google Maps app
  static Future<void> openInGoogleMaps(double latitude, double longitude) async {
    final String url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      print('Could not launch Google Maps: $e');
    }
  }
  
  // Get a description of the background style
  static String getBackgroundStyleName(BackgroundStyle style) {
    switch (style) {
      case BackgroundStyle.none:
        return 'None';
      case BackgroundStyle.mapSatellite:
        return 'Satellite Map';
      case BackgroundStyle.mapTerrain:
        return 'Terrain Map';
      case BackgroundStyle.mapStandard:
        return 'Standard Map';
      case BackgroundStyle.mapHybrid:
        return 'Hybrid Map';
      case BackgroundStyle.solid:
        return 'Solid Color';
    }
  }
  
  // Get a color for the background style chip
  static Color getBackgroundStyleColor(BackgroundStyle style) {
    switch (style) {
      case BackgroundStyle.none:
        return Colors.grey;
      case BackgroundStyle.mapSatellite:
        return Colors.blueGrey;
      case BackgroundStyle.mapTerrain:
        return Colors.green.shade700;
      case BackgroundStyle.mapStandard:
        return Colors.blue.shade700;
      case BackgroundStyle.mapHybrid:
        return Colors.indigo;
      case BackgroundStyle.solid:
        return Colors.amber.shade700;
    }
  }
  
  // Get an icon for the background style
  static IconData getBackgroundStyleIcon(BackgroundStyle style) {
    switch (style) {
      case BackgroundStyle.none:
        return Icons.hide_image;
      case BackgroundStyle.mapSatellite:
        return Icons.satellite_alt;
      case BackgroundStyle.mapTerrain:
        return Icons.terrain;
      case BackgroundStyle.mapStandard:
        return Icons.map;
      case BackgroundStyle.mapHybrid:
        return Icons.layers;
      case BackgroundStyle.solid:
        return Icons.format_color_fill;
    }
  }
  
  // Check if a background style is a map type
  static bool isMapStyle(BackgroundStyle style) {
    return style == BackgroundStyle.mapSatellite ||
           style == BackgroundStyle.mapTerrain ||
           style == BackgroundStyle.mapStandard ||
           style == BackgroundStyle.mapHybrid;
  }
} 