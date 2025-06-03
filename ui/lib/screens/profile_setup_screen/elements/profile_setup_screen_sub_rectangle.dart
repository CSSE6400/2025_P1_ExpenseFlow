import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;

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
  bool isBudgetValid = false;

  String _firstName = "John";
  String _lastName = "Doe";
  String _nickname = "johnny_doe";
  int _budget = 0;

  bool get isFormValid => isFirstNameValid && isLastNameValid && isBudgetValid;

  void _setValidity({bool? firstName, bool? lastName, bool? budget}) {
    setState(() {
      if (firstName != null) isFirstNameValid = firstName;
      if (lastName != null) isLastNameValid = lastName;
      if (budget != null) isBudgetValid = budget;
    });
  }

  Future<void> onSetup() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final nicknameExists = await apiService.userApi.checkNicknameExists(
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
      return;
    }

    try {
      await apiService.userApi.createUser(
        UserCreate(
          nickname: _nickname,
          firstName: _firstName,
          lastName: _lastName,
          budget: _budget,
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

  Widget _buildField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    Function(bool)? onValidityChanged,
    List<InputRuleType> inputRules = const [],
    bool Function(String)? validationRule,
    int? maxLength,
  }) {
    return Column(
      children: [
        GeneralField(
          label: label,
          initialValue: initialValue,
          isEditable: true,
          showStatusIcon: true,
          inputRules: inputRules,
          validationRule: validationRule,
          onValidityChanged: onValidityChanged,
          maxLength: maxLength,
          onChanged: onChanged,
        ),
        const CustomDivider(),
      ],
    );
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
            // Heading
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

            _buildField(
              label: 'First Name',
              initialValue: _firstName,
              inputRules: [InputRuleType.lettersOnly],
              validationRule: (value) {
                final nameRegex = RegExp(r"^[A-Za-z ]+$");
                final trimmed = value.trim();
                return nameRegex.hasMatch(trimmed) && trimmed.isNotEmpty;
              },
              onValidityChanged: (isValid) => _setValidity(firstName: isValid),
              maxLength: 50,
              onChanged: (value) => _firstName = value.trim(),
            ),

            _buildField(
              label: 'Last Name',
              initialValue: _lastName,
              inputRules: [InputRuleType.lettersOnly],
              validationRule: (value) {
                final nameRegex = RegExp(r"^[A-Za-z ]+$");
                final trimmed = value.trim();
                return nameRegex.hasMatch(trimmed) && trimmed.isNotEmpty;
              },
              onValidityChanged: (isValid) => _setValidity(lastName: isValid),
              maxLength: 50,
              onChanged: (value) => _lastName = value.trim(),
            ),

            _buildField(
              label: 'Nickname',
              initialValue: _nickname,
              inputRules: [InputRuleType.noSpaces],
              maxLength: 20,
              onChanged: (value) => _nickname = value.trim(),
            ),

            _buildField(
              label: 'Monthly Budget (\$)*',
              initialValue: _budget.toString(),
              inputRules: [InputRuleType.numericOnly],
              validationRule: (value) {
                final number = double.tryParse(value.trim());
                return number != null && number > 0;
              },
              onValidityChanged: (isValid) => _setValidity(budget: isValid),
              onChanged: (value) {
                final num = int.tryParse(value.trim());
                if (num != null) _budget = num;
              },
            ),

            SizedBox(height: proportionalSizes.scaleHeight(24)),

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
