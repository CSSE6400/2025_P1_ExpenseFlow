// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import 'proportional_sizes.dart';
import 'color_palette.dart';

/// Enum representing predefined button sizes.
enum ButtonSizeType {
  full,     // 363x50, fontSize 18
  half,     // 220x40, fontSize 18
  quarter,  // 90x30, fontSize 12
  custom,   // Custom dimensions provided manually
}

/// Enum to control whether the button is enabled or disabled.
enum ButtonState {
  enabled,
  disabled,
}

/// A highly reusable and responsive button widget
/// Supports full, half, quarter, and custom sizes
/// Adapts to dark mode and supports enabled/disabled state
class CustomButton extends StatelessWidget {
  /// Text shown on the button
  final String label;

  /// Action to execute when button is tapped (only if enabled)
  final VoidCallback onPressed;

  /// Background color override (optional)
  final Color? backgroundColor;

  /// Button size type (full, half, quarter, or custom)
  final ButtonSizeType sizeType;

  /// If true, button will show only border with white background
  final bool boundary;

  /// Current state of the button (enabled or disabled)
  final ButtonState state;

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
    this.state = ButtonState.enabled,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize proportional scaler to adjust sizes responsively
    final scaler = ProportionalSizes(context: context);

    // Set size and font based on button type
    double width;
    double height;
    double fontSize;
    switch (sizeType) {
      case ButtonSizeType.full:
        width = scaler.scaleWidth(363);
        height = scaler.scaleHeight(50);
        fontSize = scaler.scaleText(18);
        break;
      case ButtonSizeType.half:
        width = scaler.scaleWidth(220);
        height = scaler.scaleHeight(40);
        fontSize = scaler.scaleText(18);
        break;
      case ButtonSizeType.quarter:
        width = scaler.scaleWidth(90);
        height = scaler.scaleHeight(30);
        fontSize = scaler.scaleText(12);
        break;
      case ButtonSizeType.custom:
        width = scaler.scaleWidth(customWidth ?? 220);
        height = scaler.scaleHeight(customHeight ?? 40);
        fontSize = scaler.scaleText(customFontSize ?? 18);
        break;
    }

    // Determine actual background and text color based on state
    final bool isEnabled = state == ButtonState.enabled;

    final Color bgColor = isEnabled
        ? (backgroundColor ?? ColorPalette.primaryAction)
        : ColorPalette.secondaryAction;

    final Color textColor = isEnabled
        ? ColorPalette.buttonText
        : ColorPalette.secondaryText;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: boundary ? Colors.white : bgColor,
          side: boundary
              ? BorderSide(
                  color: bgColor,
                  width: scaler.scaleWidth(2),
                )
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scaler.scaleWidth(8)),
          ),
        ),
        onPressed: isEnabled ? onPressed : null,
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