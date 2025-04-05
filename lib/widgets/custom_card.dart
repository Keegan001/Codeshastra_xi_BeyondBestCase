import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';

enum CardVariant {
  regular,
  elevated,
  outlined,
  gradient,
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final CardVariant variant;
  final LinearGradient? gradient;
  final double elevation;
  final double? width;
  final double? height;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius,
    this.variant = CardVariant.regular,
    this.gradient,
    this.elevation = 4,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = BorderRadius.circular(16);
    final usedBorderRadius = borderRadius ?? defaultBorderRadius;
    
    // Determine card properties based on variant
    Color? cardColor;
    BoxBorder? border;
    double cardElevation = 0;
    LinearGradient? cardGradient;
    
    switch (variant) {
      case CardVariant.regular:
        cardColor = backgroundColor ?? AppTheme.cardColor;
        cardElevation = 0;
        break;
      case CardVariant.elevated:
        cardColor = backgroundColor ?? AppTheme.cardColor;
        cardElevation = elevation;
        break;
      case CardVariant.outlined:
        cardColor = backgroundColor ?? Colors.transparent;
        border = Border.all(
          color: AppTheme.dividerColor,
          width: 1.5,
        );
        break;
      case CardVariant.gradient:
        cardColor = Colors.transparent;
        cardGradient = gradient ?? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
          ],
        );
        cardElevation = elevation;
        break;
    }
    
    // Create card content
    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: usedBorderRadius,
        border: border,
        gradient: cardGradient,
        boxShadow: cardElevation > 0 ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: cardElevation,
            offset: Offset(0, cardElevation / 2),
          ),
        ] : null,
      ),
      child: child,
    );
    
    // Add tap functionality if provided
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: usedBorderRadius,
        child: cardContent,
      );
    }
    
    return cardContent;
  }
} 