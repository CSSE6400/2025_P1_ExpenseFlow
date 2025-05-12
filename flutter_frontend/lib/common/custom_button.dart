// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../common/proportional_sizes.dart';
import '../common/color_palette.dart';

/// Enum representing predefined button sizes.
enum ButtonSizeType {
  full,     // 363x50, fontSize 18
  half,     // 220x40, fontSize 18
  quarter,  // 90x30, fontSize 12
  custom,   // Custom dimensions provided manually
}

/// A highly reusable and responsive button widget
/// Supports full, half, quarter, and custom sizes
/// Adapts to dark mode and accepts optional border-only styling
class CustomButton extends StatelessWidget {
  /// Text shown on the button
  final String label;

  /// Action to execute when button is tapped
  final VoidCallback onPressed;

  /// Background color override (optional)
  /// If not provided, primaryAction/primaryActionDark is used based on dark mode
  final Color? backgroundColor;

  /// Button size type (full, half, quarter, or custom)
  final ButtonSizeType sizeType;

  /// If true, button will show only border with white background
  final bool boundary;

  /// Determines whether to use dark or light theme styles
  final bool isDarkMode;

  // Only used when sizeType == custom
  final double? customWidth;
  final double? customHeight;
  final double? customFontSize;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.sizeType = ButtonSizeType.custom,
    this.customWidth,
    this.customHeight,
    this.customFontSize,
    this.boundary = false,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize proportional scaler to adjust sizes responsively
    final proportionalSizes = ProportionalSizes(context: context);

    // Fallback to default primary colors if no backgroundColor provided
    final Color bgColor = backgroundColor ??
        (isDarkMode
            ? ColorPalette.primaryActionDark
            : ColorPalette.primaryAction);

    // Determine appropriate text color for dark/light mode
    final Color textColor = isDarkMode
        ? ColorPalette.buttonTextDark
        : ColorPalette.buttonText;

    double width;
    double height;
    double fontSize;

    // Set size and font based on enum type or custom inputs
    switch (sizeType) {
      case ButtonSizeType.full:
        width = proportionalSizes.scaleWidth(363);
        height = proportionalSizes.scaleHeight(50);
        fontSize = proportionalSizes.scaleText(18);
        break;
      case ButtonSizeType.half:
        width = proportionalSizes.scaleWidth(220);
        height = proportionalSizes.scaleHeight(40);
        fontSize = proportionalSizes.scaleText(18);
        break;
      case ButtonSizeType.quarter:
        width = proportionalSizes.scaleWidth(90);
        height = proportionalSizes.scaleHeight(30);
        fontSize = proportionalSizes.scaleText(12);
        break;
      case ButtonSizeType.custom:
        width = proportionalSizes.scaleWidth(customWidth ?? 220);
        height = proportionalSizes.scaleHeight(customHeight ?? 40);
        fontSize = proportionalSizes.scaleText(customFontSize ?? 18);
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: boundary ? Colors.white : bgColor,
          side: boundary
              ? BorderSide(
                  color: bgColor,
                  width: proportionalSizes.scaleWidth(2),
                )
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              proportionalSizes.scaleWidth(8),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: fontSize,
            color: boundary ? bgColor : textColor,
          ),
        ),
      ),
    );
  }
}