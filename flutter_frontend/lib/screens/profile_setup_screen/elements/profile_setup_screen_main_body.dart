// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../../../common/color_palette.dart';
import '../../../../common/proportional_sizes.dart';
import '../../../../common/custom_button.dart';

class ProfileSetupScreenMainBody extends StatelessWidget {
  final bool isDarkMode;

  const ProfileSetupScreenMainBody({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final logoColor = ColorPalette.logoColor;
    final proportionalSizes = ProportionalSizes(context: context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: proportionalSizes.scaleWidth(20),
          vertical: proportionalSizes.scaleHeight(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Profile Setup Header
            Expanded(
              child: Center(
                child: Text(
                  'Set Up Your Profile',
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(24),
                    fontWeight: FontWeight.bold,
                    color: logoColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Continue Button
            CustomButton(
              label: 'Continue',
              onPressed: () {
                // TODO: Navigate to next setup step
              },
              sizeType: ButtonSizeType.full,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }
}