import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? iconData;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isFullWidth;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.iconData,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildElevatedButton();
      case ButtonVariant.secondary:
        return _buildElevatedButton(isSecondary: true);
      case ButtonVariant.outlined:
        return _buildOutlinedButton();
      case ButtonVariant.text:
        return _buildTextButton();
    }
  }

  Widget _buildElevatedButton({bool isSecondary = false}) {
    final Color backgroundColor = isSecondary 
        ? AppTheme.secondaryColor 
        : AppTheme.primaryColor;
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(Colors.white),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
      child: _buildButtonContent(AppTheme.primaryColor),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        padding: _getPadding(),
      ),
      child: _buildButtonContent(AppTheme.primaryColor),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (iconData != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle(),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(),
    );
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle() {
    TextStyle baseStyle = variant == ButtonVariant.text 
        ? AppTheme.labelMedium
        : AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w600);
    
    switch (size) {
      case ButtonSize.small:
        return baseStyle.copyWith(fontSize: 12);
      case ButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14);
      case ButtonSize.large:
        return baseStyle.copyWith(fontSize: 16);
    }
  }
} 