// Flutter imports
import 'package:flutter/material.dart';
// Common
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class HomeScreenOverview extends StatelessWidget {
  final bool isDarkMode;

  const HomeScreenOverview({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = isDarkMode ? ColorPalette.buttonTextDark : ColorPalette.buttonText;

    return Container(
      width: double.infinity,
      height: proportionalSizes.scaleHeight(240),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          proportionalSizes.scaleWidth(10),
        ),
      ),

      // TODO: Add functionality to Overview Expenses here
    );
  }
}