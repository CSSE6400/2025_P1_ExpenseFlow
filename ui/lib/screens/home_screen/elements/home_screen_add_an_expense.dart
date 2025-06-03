import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';
import '../../../common/scan_receipt.dart';

class HomeScreenAddAnExpense extends StatelessWidget {
  const HomeScreenAddAnExpense({super.key});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    final outerBackgroundColor = ColorPalette.buttonText;

    final buttonBackgroundColor = ColorPalette.background;

    final textColor = ColorPalette.primaryText;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(proportionalSizes.scaleWidth(16)),
      decoration: BoxDecoration(
        color: outerBackgroundColor,
        borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a Transaction',
            style: GoogleFonts.roboto(
              fontSize: proportionalSizes.scaleText(24),
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: proportionalSizes.scaleHeight(8)),
          Container(
            decoration: BoxDecoration(
              color: buttonBackgroundColor,
              borderRadius: BorderRadius.circular(
                proportionalSizes.scaleWidth(12),
              ),
            ),
            child: ListTile(
              leading: IconMaker(assetPath: 'assets/icons/manual_entry.png'),
              title: Text(
                'Manual Entry',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(18),
                  color: textColor,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/add_expense');
              },
            ),
          ),
          SizedBox(height: proportionalSizes.scaleHeight(8)),
          Container(
            decoration: BoxDecoration(
              color: buttonBackgroundColor,
              borderRadius: BorderRadius.circular(
                proportionalSizes.scaleWidth(12),
              ),
            ),
            child: ListTile(
              leading: IconMaker(assetPath: 'assets/icons/scan.png'),
              title: Text(
                'Camera Scan',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(18),
                  color: textColor,
                ),
              ),
              onTap: () {
                handleScanReceiptUpload(context: context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
