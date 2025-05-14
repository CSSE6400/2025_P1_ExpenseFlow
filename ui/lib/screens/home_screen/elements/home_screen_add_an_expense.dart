// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';

class HomeScreenAddAnExpense extends StatelessWidget {
  final bool isDarkMode;

  const HomeScreenAddAnExpense({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    // Outer background remains same as original (for the full widget)
    final outerBackgroundColor = isDarkMode
        ? ColorPalette.buttonTextDark
        : ColorPalette.buttonText;

    // Button background (for the two clickable buttons)
    final buttonBackgroundColor = isDarkMode
        ? ColorPalette.backgroundDark
        : ColorPalette.background;

    final textColor = isDarkMode
        ? ColorPalette.primaryTextDark
        : ColorPalette.primaryText;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(proportionalSizes.scaleWidth(16)),
      decoration: BoxDecoration(
        color: outerBackgroundColor, // ← This stays as buttonText / buttonTextDark
        borderRadius: BorderRadius.circular(
          proportionalSizes.scaleWidth(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Add a Transaction',
            style: GoogleFonts.roboto(
              fontSize: proportionalSizes.scaleText(24),
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          SizedBox(height: proportionalSizes.scaleHeight(8)),

          // Manual Entry Button
          Container(
            decoration: BoxDecoration(
              color: buttonBackgroundColor, // ← Correct background for button
              borderRadius: BorderRadius.circular(
                proportionalSizes.scaleWidth(12),
              ),
            ),
            child: ListTile(
              leading: IconMaker(
                assetPath: 'assets/icons/manual_entry.png',
                isDarkMode: isDarkMode,
              ),
              title: Text(
                'Manual Entry',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(18),
                  color: textColor,
                ),
              ),
              onTap: () {
                // TODO: Navigate to Manual Entry Screen
              },
            ),
          ),

          SizedBox(height: proportionalSizes.scaleHeight(8)),

          // Camera Scan Button
          Container(
            decoration: BoxDecoration(
              color: buttonBackgroundColor, // ← Correct background for button
              borderRadius: BorderRadius.circular(
                proportionalSizes.scaleWidth(12),
              ),
            ),
            child: ListTile(
              leading: IconMaker(
                assetPath: 'assets/icons/scan.png',
                isDarkMode: isDarkMode,
              ),
              title: Text(
                'Camera Scan',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(18),
                  color: textColor,
                ),
              ),
              onTap: () {
                // TODO: Navigate to Camera Scan Screen
              },
            ),
          ),
        ],
      ),
    );
  }
}