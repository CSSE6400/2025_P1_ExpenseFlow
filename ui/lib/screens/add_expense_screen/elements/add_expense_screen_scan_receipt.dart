import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';
import '../../../common/scan_receipt.dart';

class AddExpenseScreenScanReceipt extends StatelessWidget {
  const AddExpenseScreenScanReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;
    final textColor = ColorPalette.primaryText;

    return InkWell(
      onTap: () {
        handleScanReceiptUpload(
          context: context,
        );
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconMaker(
              assetPath: 'assets/icons/scan.png',
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