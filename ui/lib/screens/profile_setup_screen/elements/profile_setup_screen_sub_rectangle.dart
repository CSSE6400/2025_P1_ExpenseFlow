// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/custom_button.dart';

class ProfileSetupScreenSubRectangle extends StatefulWidget {
  const ProfileSetupScreenSubRectangle({super.key});

  @override
  State<ProfileSetupScreenSubRectangle> createState() =>
      _ProfileSetupScreenSubRectangleState();
}

class _ProfileSetupScreenSubRectangleState
    extends State<ProfileSetupScreenSubRectangle> {
  bool isNameValid = false;
  bool isEmailValid = false;
  bool isBudgetValid = false;

  bool get isFormValid =>
      isNameValid && isEmailValid && isBudgetValid;

  void updateNameValidity(bool isValid) {
    setState(() => isNameValid = isValid);
  }

  void updateUsernameValidity(bool isValid) {
    setState(() => isEmailValid = isValid);
  }

  void updateBudgetValidity(bool isValid) {
    setState(() => isBudgetValid = isValid);
  }

  Future <void> onSave() async {
    // TODO: Handle save functionality
    Navigator.pushNamed(context, '/home');
  }

  bool isUsernameUnique(String username) {
    // TODO: Replace with actual backend API call to check uniqueness
    return true; // temporary mock return
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heading text
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Setup Your Account',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(22),
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryText,
                ),
              ),
            ),
            SizedBox(height: proportionalSizes.scaleHeight(12)),

            // Name field
            GeneralField(
              label: 'Name*',
              initialValue: 'ABC',
              isEditable: true,
              showStatusIcon: true,
              inputRules: [InputRuleType.lettersOnly],
              validationRule: (value) {
                final nameRegex = RegExp(r"^[A-Za-z ]+$");
                return nameRegex.hasMatch(value.trim());
              },
              onValidityChanged: updateNameValidity,
              maxLength: 50,
              onChanged: (value) {
                // TODO: Save name field value
              },
            ),
            CustomDivider(),

            // Username field
            GeneralField(
              label: 'Username*',
              initialValue: 'user_name',
              isEditable: true,
              showStatusIcon: true,
              inputRules: [
                InputRuleType.noSpaces, // prevent accidental space
              ],
              validationRule: (value) {
                final username = value.trim();
                // Rule 1: Length
                if (username.length < 5 || username.length > 20) return false;
                // Rule 2: Alphanumeric + - and _
                final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
                if (!regex.hasMatch(username)) return false;
                // Rule 3: Unique username check (mock logic now)
                return isUsernameUnique(username);
              },
              onValidityChanged: updateUsernameValidity,
              maxLength: 20,
              focusInstruction: 'Username must be 5–20 characters and may contain letters, numbers, - or _',
              onChanged: (value) {
                // TODO: Save username field value
              },
            ),
            CustomDivider(),

            // Budget field
            GeneralField(
              label: 'Monthly Budget (\$)*',
              initialValue: '1000',
              isEditable: true,
              showStatusIcon: true,
              inputRules: [InputRuleType.decimalWithTwoPlaces],
              validationRule: (value) {
                final number = double.tryParse(value.trim());
                return number != null && number > 0;
              },
              onValidityChanged: updateBudgetValidity,
              maxLength: 10,
              onChanged: (value) {
                // TODO: Save monthly budget field value
              },
            ),
            SizedBox(height: proportionalSizes.scaleHeight(24)),

            // Save button
            CustomButton(
              label: 'Save',
              onPressed: isFormValid ? onSave : () {},
              sizeType: ButtonSizeType.full,
              state:
                  isFormValid ? ButtonState.enabled : ButtonState.disabled,
            ),

            SizedBox(height: proportionalSizes.scaleHeight(96)),
          ],
        ),
      ),
    );
  }
}