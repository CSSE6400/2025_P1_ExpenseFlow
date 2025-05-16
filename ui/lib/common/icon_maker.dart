// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import 'color_palette.dart';
import 'proportional_sizes.dart';

/// A common widget for creating consistently styled icons across the app.
/// - Uses default size 24x24 (scalable)
/// - Applies dark mode-aware coloring unless overridden
class IconMaker extends StatelessWidget {
  /// Path to the image asset, e.g., 'assets/icons/back_button.png'
  final String assetPath;

  /// Optional override for width
  final double? width;

  /// Optional override for height
  final double? height;

  /// Optional override for icon color
  final Color? color;

  const IconMaker({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final iconColor = color ??
        ColorPalette.primaryAction;

    return Image.asset(
      assetPath,
      width: width ?? proportionalSizes.scaleWidth(24),
      height: height ?? proportionalSizes.scaleHeight(24),
      color: iconColor,
    );
  }
}