// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../../../common/color_palette.dart';
import '../../../../common/proportional_sizes.dart';
import '../../../../common/fields/general_field.dart';
import '../../../../common/custom_divider.dart';

class ProfileSetupScreenSubRectangle extends StatelessWidget {
  final bool isDarkMode;

  const ProfileSetupScreenSubRectangle({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = isDarkMode
        ? ColorPalette.buttonTextDark
        : ColorPalette.buttonText;

    return Container(
      width: double.infinity,
      height: proportionalSizes.scaleHeight(611),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(44)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: proportionalSizes.scaleWidth(20),
        vertical: proportionalSizes.scaleHeight(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading text
            Text(
              'Setup Your Account',
              style: GoogleFonts.roboto(
                fontSize: proportionalSizes.scaleText(22),
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? ColorPalette.buttonText
                    : ColorPalette.buttonTextDark,
              ),
            ),
            SizedBox(height: proportionalSizes.scaleHeight(12)),
            GeneralField(
              label: 'Name*',
              initialValue: 'ABC',
              isDarkMode: isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) => value.isNotEmpty,
            ),
            const CustomDivider(),
            GeneralField(
              label: 'Email ID*',
              initialValue: 'example@email.com',
              isDarkMode: isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) => value.isNotEmpty,
            ),
            const CustomDivider(),
            GeneralField(
              label: 'Username*',
              initialValue: 'abcd1234',
              isDarkMode: isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) => value.isNotEmpty,
            ),
            const CustomDivider(),
            GeneralField(
              label: 'Monthly Budget (\$)*',
              initialValue: '1000',
              isDarkMode: isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) => value.isNotEmpty,
            ),
            const CustomDivider(),
            // TODO: Add profile input fields and save button here
          ],
        ),
      ),
    );
  }
}