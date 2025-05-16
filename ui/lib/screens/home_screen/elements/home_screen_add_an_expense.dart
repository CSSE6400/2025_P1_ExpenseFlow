// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';
import '../../../common/dialog_box.dart';
import '../../add_expense_screen/add_expense_screen.dart';
import '../../../common/web_file_helper.dart';
import '../../../common/snack_bar.dart';

class HomeScreenAddAnExpense extends StatelessWidget {
  const HomeScreenAddAnExpense({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final imageInfo = await WebImageInfo.pickImage();

    // TODO: Modify this code to save and process the image
    // Currently, it only shows a dialog with the filename.
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddExpenseScreen(),
                  ),
                );
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
              onTap: () => _pickImage(context),
            ),
          ),
        ],
      ),
    );
  }
}