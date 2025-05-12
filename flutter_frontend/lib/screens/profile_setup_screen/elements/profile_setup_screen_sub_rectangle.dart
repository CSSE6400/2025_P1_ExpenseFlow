// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../../../common/color_palette.dart';
import '../../../../common/proportional_sizes.dart';
import '../../../../common/fields/general_field.dart';
import '../../../../common/custom_divider.dart';
import '../../../common/custom_button.dart';

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
              validationRule: (value) {
                final nameRegex = RegExp(r"^[A-Za-z ]+$");
                return nameRegex.hasMatch(value.trim());
              },
            ),
            const CustomDivider(),

            GeneralField(
              label: 'Email ID*',
              initialValue: 'example@email.com',
              isDarkMode: isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) {
                const pattern = r'^[a-zA-Z\d._%+-]+@[a-zA-Z\d.-]+\.[a-zA-Z]{2,}$';
                return RegExp(pattern).hasMatch(value.trim());
              },
            ),
            const CustomDivider(),
            GeneralField(
              label: 'Username*',
              initialValue: 'abcd1234',
              isDarkMode: isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) {
                final usernameRegex = RegExp(r"^[a-zA-Z0-9_]{3,16}$");
                return usernameRegex.hasMatch(value.trim());
              },
            ),
            const CustomDivider(),

            GeneralField(
              label: 'Monthly Budget (\$)*',
              initialValue: '1000',
              isDarkMode: isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) {
                final number = double.tryParse(value.trim());
                return number != null && number > 0;
              },
            ),
            SizedBox(height: proportionalSizes.scaleHeight(12)),
            CustomButton(
              label: 'Save',
              onPressed: () {},
              isDarkMode: false,
              sizeType: ButtonSizeType.full,
              state: ButtonState.disabled,
            ),
            SizedBox(height: proportionalSizes.scaleHeight(72)),
          ],
        ),
      ),
    );
  }
}