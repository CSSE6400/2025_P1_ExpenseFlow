import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/proportional_sizes.dart'
    show ProportionalSizes;
import 'package:flutter_frontend/screens/profile_screen/elements/profile_screen_avatar_icon.dart'
    show ProfileScreenAvatarIcon;
import 'package:flutter_frontend/screens/profile_screen/elements/profile_screen_form.dart';
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
import '../../common/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;
    final proportionalSizes = ProportionalSizes(context: context);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBarWidget(screenName: 'ProfileScreen', showBackButton: true),
      body: (GestureDetector(
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
                  child: ProfileScreenAvatarIcon(),
                ),

                SizedBox(height: proportionalSizes.scaleHeight(20)),

                ProfileScreenForm(),
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: BottomNavBar(inactive: true),
    );
  }
}
