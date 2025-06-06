import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'proportional_sizes.dart';

class IconMaker extends StatelessWidget {
  final String assetPath;

  final double? width;

  final double? height;

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
    final iconColor = color ?? ColorPalette.primaryAction;

    return Image.asset(
      assetPath,
      width: width ?? proportionalSizes.scaleWidth(24),
      height: height ?? proportionalSizes.scaleHeight(24),
      color: iconColor,
    );
  }
}
