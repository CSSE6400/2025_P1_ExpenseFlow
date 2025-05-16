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
  const CustomDivider({super.key,});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final lineColor = ColorPalette.secondaryAction;

    return Divider(
      color: lineColor,
      thickness: proportionalSizes.scaleHeight(0.5),
      height: proportionalSizes.scaleHeight(0),
    );
  }
}