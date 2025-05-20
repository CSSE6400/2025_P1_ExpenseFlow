// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;
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
  Logger _logger = Logger("ProfileSetupScreenSubRectangle");
  bool isFirstNameValid = false;
  bool isLastNameValid = false;
  bool isNicknameValid = false;

  String _firstName = "";
  String _lastName = "";
  String _nickname = "";

  bool get isFormValid =>
      isFirstNameValid && isLastNameValid && isNicknameValid;

  void updateFirstNameValidity(bool isValid) {
    setState(() => isFirstNameValid = isValid);
  }

  void updateLastNameValidity(bool isValid) {
    setState(() => isLastNameValid = isValid);
  }

  void updateNicknameValidty(bool isValid) {
    setState(() => isNicknameValid = isValid);
  }

  Future<void> onSetup() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.createUser(
        UserCreate(
          nickname: _nickname,
          firstName: _firstName,
          lastName: _lastName,
        ),
      );
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      _logger.severe('Error creating user: $e');
    }
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

            // First Name field
            GeneralField(
              label: 'First Name',
              initialValue: 'John',
              isEditable: true,
              showStatusIcon: true,
              inputRules: [InputRuleType.lettersOnly],
              validationRule: (value) {
                final nameRegex = RegExp(r"^[A-Za-z ]+$");
                return nameRegex.hasMatch(value.trim());
              },
              onValidityChanged: updateFirstNameValidity,
              maxLength: 50,
              onChanged: (value) {
                _firstName = value.trim();
              },
            ),
            CustomDivider(),

            // Last Name field
            GeneralField(
              label: 'Last Name',
              initialValue: 'Doe',
              isEditable: true,
              showStatusIcon: true,
              inputRules: [InputRuleType.lettersOnly],
              validationRule: (value) {
                final nameRegex = RegExp(r"^[A-Za-z ]+$");
                return nameRegex.hasMatch(value.trim());
              },
              onValidityChanged: updateLastNameValidity,
              maxLength: 50,
              onChanged: (value) {
                _lastName = value.trim();
              },
            ),
            CustomDivider(),

            // Nickname field
            GeneralField(
              label: 'Nickname',
              initialValue: 'Johnny',
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
              onValidityChanged: updateNicknameValidty,
              maxLength: 20,
              focusInstruction:
                  'Username must be 5–20 characters and may contain letters, numbers, - or _',
              onChanged: (value) {
                _nickname = value.trim();
              },
            ),
            CustomDivider(),

            SizedBox(height: proportionalSizes.scaleHeight(24)),

            // Save button
            CustomButton(
              label: 'Setup Profile',
              onPressed: isFormValid ? onSetup : () {},
              sizeType: ButtonSizeType.full,
              state: isFormValid ? ButtonState.enabled : ButtonState.disabled,
            ),

            SizedBox(height: proportionalSizes.scaleHeight(96)),
          ],
        ),
      ),
    );
  }
}
