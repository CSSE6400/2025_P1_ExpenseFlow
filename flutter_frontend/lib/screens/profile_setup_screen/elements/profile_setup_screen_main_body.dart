import 'package:flutter/material.dart';
// Common
import '../../../../common/proportional_sizes.dart';
// Elements
import 'profile_setup_screen_avatar_icon.dart';
import 'profile_setup_screen_sub_rectangle.dart';

class ProfileSetupScreenMainBody extends StatelessWidget {
  final bool isDarkMode;

  const ProfileSetupScreenMainBody({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard
      },
      child: SafeArea(
        child: SingleChildScrollView(
          // Prevents overflow
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Icon
              Align(
                alignment: Alignment.topLeft,
                child: ProfileSetupScreenAvatarIcon(isDarkMode: isDarkMode),
              ),

              SizedBox(height: proportionalSizes.scaleHeight(20)),

              // Sub Rectangle
              ProfileSetupScreenSubRectangle(isDarkMode: isDarkMode),
            ],
          ),
        ),
      ),
    );
  }
}