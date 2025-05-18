// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';
import '../../../common/dialog_box.dart';
import '../../../common/web_file_helper.dart';
import '../../../common/snack_bar.dart';

class HomeScreenAddAnExpense extends StatefulWidget {
  const HomeScreenAddAnExpense({super.key});

  @override
  State<HomeScreenAddAnExpense> createState() => _HomeScreenAddAnExpenseState();
}

class _HomeScreenAddAnExpenseState extends State<HomeScreenAddAnExpense> {
  Future<void> _pickImage() async {
    final imageInfo = await WebImageInfo.pickImage();

    if (!mounted) return;

    if (imageInfo != null) {
      await AppDialogBox.show(
        context,
        heading: 'Image Captured',
        description: 'Filename: ${imageInfo.filename}',
        buttonCount: 1,
        button1Text: 'OK',
        onButton1Pressed: () => Navigator.of(context).pop(),
      );
    } else {
      showCustomSnackBar(
        context,
        boldText: 'Error:',
        normalText: 'Something went wrong while uploading.',
      );
    }
  }

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
        borderRadius: BorderRadius.circular(
          proportionalSizes.scaleWidth(16),
        ),
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
              leading: IconMaker(
                assetPath: 'assets/icons/manual_entry.png',
              ),
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
              leading: IconMaker(
                assetPath: 'assets/icons/scan.png',
              ),
              title: Text(
                'Camera Scan',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(18),
                  color: textColor,
                ),
              ),
              onTap: () => _pickImage(),
            ),
          ),
        ],
      ),
    );
  }
}