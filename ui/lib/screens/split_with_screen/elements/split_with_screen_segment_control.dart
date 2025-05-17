// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class SplitWithScreenSegmentControl extends StatelessWidget {
  const SplitWithScreenSegmentControl({super.key});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;

    return Container(
      width: double.infinity,
      height: proportionalSizes.scaleHeight(240),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          proportionalSizes.scaleWidth(10),
        ),
      ),
      
      // TODO: Add segmented control (tabs, toggles, etc.) here
    );
  }
}