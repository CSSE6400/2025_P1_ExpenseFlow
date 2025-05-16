import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';

class AddExpenseScreenScanReceipt extends StatelessWidget {
  final bool isDarkMode;

  const AddExpenseScreenScanReceipt({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = isDarkMode 
        ? ColorPalette.buttonTextDark 
        : ColorPalette.buttonText;
    final textColor = isDarkMode
        ? ColorPalette.primaryTextDark
        : ColorPalette.primaryText;

    return InkWell(
      onTap: () {
        // TODO: Implement scan receipt functionality
      },
      borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(12)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: proportionalSizes.scaleHeight(12),
          horizontal: proportionalSizes.scaleWidth(16),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            proportionalSizes.scaleWidth(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconMaker(
              assetPath: 'assets/icons/scan.png',
              isDarkMode: isDarkMode,
            ),
            SizedBox(width: proportionalSizes.scaleWidth(12)),
            Text(
              'Scan Receipt',
              style: GoogleFonts.roboto(
                fontSize: proportionalSizes.scaleWidth(16),
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}