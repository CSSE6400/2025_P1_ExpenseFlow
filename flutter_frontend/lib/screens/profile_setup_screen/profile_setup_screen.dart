// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../common/color_palette.dart';
import '../../common/proportional_sizes.dart';
import '../../common/custom_button.dart';
import '../../common/app_bar.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isDarkMode;

  const ProfileSetupScreen({super.key, required this.isDarkMode});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final logoColor = ColorPalette.logoColor;
    final backgroundColor = widget.isDarkMode
        ? ColorPalette.backgroundDark
        : ColorPalette.background;
    final proportionalSizes = ProportionalSizes(context: context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: '',
        showBackButton: true,
        isDarkMode: widget.isDarkMode,
      ),
      body: SafeArea(
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
                isDarkMode: widget.isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}