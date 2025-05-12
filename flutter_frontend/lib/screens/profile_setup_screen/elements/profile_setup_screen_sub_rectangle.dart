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

class ProfileSetupScreenSubRectangle extends StatefulWidget {
  final bool isDarkMode;

  const ProfileSetupScreenSubRectangle({super.key, required this.isDarkMode});

  @override
  State<ProfileSetupScreenSubRectangle> createState() =>
      _ProfileSetupScreenSubRectangleState();
}

class _ProfileSetupScreenSubRectangleState
    extends State<ProfileSetupScreenSubRectangle> {
  bool isNameValid = false;
  bool isEmailValid = false;
  bool isUsernameValid = false;
  bool isBudgetValid = false;

  bool get isFormValid =>
      isNameValid && isEmailValid && isUsernameValid && isBudgetValid;

  void updateNameValidity(bool isValid) {
    setState(() => isNameValid = isValid);
  }

  void updateEmailValidity(bool isValid) {
    setState(() => isEmailValid = isValid);
  }

  void updateUsernameValidity(bool isValid) {
    setState(() => isUsernameValid = isValid);
  }

  void updateBudgetValidity(bool isValid) {
    setState(() => isBudgetValid = isValid);
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = widget.isDarkMode
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
                color: widget.isDarkMode
                    ? ColorPalette.buttonText
                    : ColorPalette.buttonTextDark,
              ),
            ),
            SizedBox(height: proportionalSizes.scaleHeight(12)),

            // Name field
            GeneralField(
              label: 'Name*',
              initialValue: 'ABC',
              isDarkMode: widget.isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) {
                final nameRegex = RegExp(r"^[A-Za-z ]+$");
                return nameRegex.hasMatch(value.trim());
              },
              onValidityChanged: updateNameValidity,
            ),
            const CustomDivider(),

            // Email field
            GeneralField(
              label: 'Email ID*',
              initialValue: 'example@email.com',
              isDarkMode: widget.isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) {
                const pattern =
                    r'^[a-zA-Z\d._%+-]+@[a-zA-Z\d.-]+\.[a-zA-Z]{2,}$';
                return RegExp(pattern).hasMatch(value.trim());
              },
              onValidityChanged: updateEmailValidity,
            ),
            const CustomDivider(),

            // Username field
            GeneralField(
              label: 'Username*',
              initialValue: 'abcd1234',
              isDarkMode: widget.isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) {
                final usernameRegex = RegExp(r"^[a-zA-Z0-9_]{3,16}$");
                return usernameRegex.hasMatch(value.trim());
              },
              onValidityChanged: updateUsernameValidity,
            ),
            const CustomDivider(),

            // Budget field
            GeneralField(
              label: 'Monthly Budget (\$)*',
              initialValue: '1000',
              isDarkMode: widget.isDarkMode,
              isEditable: true,
              showStatusIcon: true,
              validationRule: (value) {
                final number = double.tryParse(value.trim());
                return number != null && number > 0;
              },
              onValidityChanged: updateBudgetValidity,
            ),
            SizedBox(height: proportionalSizes.scaleHeight(12)),

            // Save button
            CustomButton(
              label: 'Save',
              onPressed: isFormValid ? () => {} : () {},
              isDarkMode: widget.isDarkMode,
              sizeType: ButtonSizeType.full,
              state:
                  isFormValid ? ButtonState.enabled : ButtonState.disabled,
            ),

            SizedBox(height: proportionalSizes.scaleHeight(72)),
          ],
        ),
      ),
    );
  }
}