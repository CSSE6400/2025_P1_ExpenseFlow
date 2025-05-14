// Flutter imports
import 'package:flutter/material.dart';
// Common
import 'proportional_sizes.dart';
import 'color_palette.dart';

/// A reusable divider widget for separating profile fields.
/// - Thin grey line
/// - Proportional thickness and spacing
class CustomDivider extends StatelessWidget {
  /// Whether the screen is in dark mode
  final bool isDarkMode;

  const CustomDivider({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final lineColor = isDarkMode
        ? ColorPalette.secondaryActionDark
        : ColorPalette.secondaryAction;

    return Divider(
      color: lineColor,
      thickness: proportionalSizes.scaleHeight(0.5),
      height: proportionalSizes.scaleHeight(0),
    );
  }
}