import 'package:flutter/material.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/core/theme.dart';

class LayoutStyleUtils {
  // Get a descriptive name for the layout style
  static String getLayoutStyleName(LayoutStyle style) {
    switch (style) {
      case LayoutStyle.standard:
        return 'Standard';
      case LayoutStyle.polaroid:
        return 'Polaroid';
      case LayoutStyle.postcard:
        return 'Postcard';
      case LayoutStyle.journal:
        return 'Journal';
      case LayoutStyle.collage:
        return 'Collage';
    }
  }
  
  // Get an icon for the layout style
  static IconData getLayoutStyleIcon(LayoutStyle style) {
    switch (style) {
      case LayoutStyle.standard:
        return Icons.crop_square;
      case LayoutStyle.polaroid:
        return Icons.photo_camera;
      case LayoutStyle.postcard:
        return Icons.mail;
      case LayoutStyle.journal:
        return Icons.book;
      case LayoutStyle.collage:
        return Icons.dashboard;
    }
  }
  
  // Get a color for the layout style chip
  static Color getLayoutStyleColor(LayoutStyle style) {
    switch (style) {
      case LayoutStyle.standard:
        return Colors.blue;
      case LayoutStyle.polaroid:
        return Colors.amber;
      case LayoutStyle.postcard:
        return Colors.green;
      case LayoutStyle.journal:
        return Colors.brown;
      case LayoutStyle.collage:
        return Colors.purple;
    }
  }
  
  // Apply layout style to a container with media content
  static BoxDecoration getLayoutDecoration(
    LayoutStyle style, {
    BorderRadius? borderRadius,
    DecorationImage? backgroundImage,
    Color? backgroundColor,
    bool isDarkMode = false,
  }) {
    switch (style) {
      case LayoutStyle.standard:
        return BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          image: backgroundImage,
          color: backgroundColor ?? (isDarkMode ? Colors.grey.shade800 : Colors.white),
        );
        
      case LayoutStyle.polaroid:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.2),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade800 : Colors.white,
            width: 12,
          ),
          image: backgroundImage,
        );
        
      case LayoutStyle.postcard:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            width: 1,
          ),
          image: backgroundImage,
        );
        
      case LayoutStyle.journal:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          color: isDarkMode ? Colors.brown.shade900 : Colors.amber.shade50,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.15),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(2, 2),
            ),
          ],
          border: Border.all(
            color: isDarkMode ? Colors.brown.shade800 : Colors.brown.shade200,
            width: 1,
          ),
          image: backgroundImage,
        );
        
      case LayoutStyle.collage:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
          image: backgroundImage,
        );
    }
  }
  
  // Get padding for the content based on layout style
  static EdgeInsets getLayoutContentPadding(LayoutStyle style) {
    switch (style) {
      case LayoutStyle.standard:
        return const EdgeInsets.all(16);
      case LayoutStyle.polaroid:
        return const EdgeInsets.only(top: 8, bottom: 24, left: 8, right: 8);
      case LayoutStyle.postcard:
        return const EdgeInsets.all(16);
      case LayoutStyle.journal:
        return const EdgeInsets.all(24);
      case LayoutStyle.collage:
        return const EdgeInsets.all(12);
    }
  }
  
  // Apply text style based on layout style
  static TextStyle getTitleTextStyle(LayoutStyle style, {bool isDarkMode = false}) {
    switch (style) {
      case LayoutStyle.standard:
        return isDarkMode 
            ? AppTheme.headingMedium.copyWith(color: AppTheme.darkTextPrimaryColor) 
            : AppTheme.headingMedium;
      case LayoutStyle.polaroid:
        return AppTheme.headingSmall.copyWith(
          fontFamily: 'Handwriting',
          color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
        );
      case LayoutStyle.postcard:
        return AppTheme.headingSmall.copyWith(
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.lightBlue.shade200 : Colors.indigo.shade800,
        );
      case LayoutStyle.journal:
        return AppTheme.headingSmall.copyWith(
          fontFamily: 'Handwriting',
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.amber.shade200 : Colors.brown.shade800,
        );
      case LayoutStyle.collage:
        return AppTheme.headingSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
        );
    }
  }
  
  // Apply content text style based on layout style
  static TextStyle getContentTextStyle(LayoutStyle style, {bool isDarkMode = false}) {
    switch (style) {
      case LayoutStyle.standard:
        return isDarkMode 
            ? AppTheme.bodyLarge.copyWith(color: AppTheme.darkTextPrimaryColor) 
            : AppTheme.bodyLarge;
      case LayoutStyle.polaroid:
        return AppTheme.bodyMedium.copyWith(
          fontFamily: 'Handwriting',
          color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
        );
      case LayoutStyle.postcard:
        return AppTheme.bodyMedium.copyWith(
          letterSpacing: 0.5,
          color: isDarkMode ? Colors.grey.shade300 : Colors.indigo.shade900,
        );
      case LayoutStyle.journal:
        return AppTheme.bodyMedium.copyWith(
          fontFamily: 'Handwriting',
          color: isDarkMode ? Colors.amber.shade100 : Colors.brown.shade800,
          height: 1.5,
        );
      case LayoutStyle.collage:
        return isDarkMode 
            ? AppTheme.bodyMedium.copyWith(color: AppTheme.darkTextPrimaryColor)
            : AppTheme.bodyMedium;
    }
  }
  
  // Get overlay color based on layout style
  static Color? getOverlayColor(LayoutStyle style, {bool isDarkMode = false}) {
    switch (style) {
      case LayoutStyle.standard:
        return null;
      case LayoutStyle.polaroid:
        return (isDarkMode ? Colors.black : Colors.white).withOpacity(0.1);
      case LayoutStyle.postcard:
        return (isDarkMode ? Colors.black : Colors.white).withOpacity(0.3);
      case LayoutStyle.journal:
        return (isDarkMode ? Colors.brown.shade900 : Colors.amber.shade50).withOpacity(0.7);
      case LayoutStyle.collage:
        return null;
    }
  }
} 