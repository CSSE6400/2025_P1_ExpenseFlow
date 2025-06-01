// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
import '../../common/bottom_nav_bar.dart';
// Elements
import '../profile_screen/elements/profile_screen_main_body.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBarWidget(
        screenName: '',
        showBackButton: true,
      ),

      body: ProfileScreenMainBody(),

      bottomNavigationBar: BottomNavBar(currentScreen: 'Profile', inactive: false),
    );
  }
}