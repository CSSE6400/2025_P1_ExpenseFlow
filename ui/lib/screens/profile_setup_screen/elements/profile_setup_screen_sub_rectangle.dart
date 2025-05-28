// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
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
  final Logger _logger = Logger("ProfileSetupScreenSubRectangle");
  bool isFirstNameValid = false;
  bool isLastNameValid = false;

  String _firstName = "";
  String _lastName = "";
  String _nickname = "";

  bool get isFormValid => isFirstNameValid && isLastNameValid;

  void updateFirstNameValidity(bool isValid) {
    setState(() => isFirstNameValid = isValid);
  }

  void updateLastNameValidity(bool isValid) {
    setState(() => isLastNameValid = isValid);
  }

  Future<void> onSetup() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      bool nicknameExists = await apiService.userApi.checkNicknameExists(
        _nickname,
      );

      if (nicknameExists) {
        if (!mounted) return;
        showCustomSnackBar(
          context,
          normalText: "Nickname '$_nickname' is already being used.",
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(
        context,
        normalText: "Unable to check nickname uniqueness.",
      );
      _logger.severe("Unable to check nickname uniqueness $e");
    }

    try {
      await apiService.userApi.createUser(
        UserCreate(
          nickname: _nickname,
          firstName: _firstName,
          lastName: _lastName,
        ),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, normalText: "Unable to create user.");
      _logger.severe('Error creating user: $e');
    }
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
              maxLength: 20,
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
