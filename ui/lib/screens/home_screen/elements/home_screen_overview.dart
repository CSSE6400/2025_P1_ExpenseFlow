// Flutter imports
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class HomeScreenOverview extends StatelessWidget {
  const HomeScreenOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/overview');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(proportionalSizes.scaleWidth(16)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            proportionalSizes.scaleWidth(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: GoogleFonts.roboto(
                fontSize: proportionalSizes.scaleText(24),
                fontWeight: FontWeight.bold,
                color: ColorPalette.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}