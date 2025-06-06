import 'package:flutter/material.dart';
import 'proportional_sizes.dart';
import 'color_palette.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

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
