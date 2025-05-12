import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Common
import '../common/proportional_sizes.dart';
import '../common/color_palette.dart';

enum ButtonSizeType {
  full,
  half,
  quarter,
  custom,
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  /// Optional override for background color. If null, primary color will be used.
  final Color? backgroundColor;

  /// Button style type (full, half, quarter, or custom)
  final ButtonSizeType sizeType;

  /// Whether the button should use border-only (outline) style
  final bool boundary;

  /// Dark mode status (passed down from screen)
  final bool isDarkMode;

  // Only used if sizeType == custom
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
    // Choose color based on dark mode and overrides
    final Color bgColor = backgroundColor ??
        (isDarkMode
            ? ColorPalette.primaryActionDark
            : ColorPalette.primaryAction);
    final Color textColor = isDarkMode
        ? ColorPalette.primaryTextDark
        : ColorPalette.primaryText;
    final proportionalSizes = ProportionalSizes(context: context);

    double width;
    double height;
    double fontSize;

    // Determine size & font based on type
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
              ? BorderSide(color: bgColor, width: proportionalSizes.scaleWidth(2))
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(8)),
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