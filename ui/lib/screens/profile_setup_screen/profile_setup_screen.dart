// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
import '../../common/proportional_sizes.dart';
// Elements
import 'elements/profile_setup_screen_avatar_icon.dart';
import 'elements/profile_setup_screen_sub_rectangle.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;
    final proportionalSizes = ProportionalSizes(context: context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(screenName: '', showBackButton: true),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss keyboard
        },
        child: SafeArea(
          child: SingleChildScrollView(
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
                  child: ProfileSetupScreenAvatarIcon(),
                ),
                SizedBox(height: proportionalSizes.scaleHeight(20)),
                // Sub Rectangle
                ProfileSetupScreenSubRectangle(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
