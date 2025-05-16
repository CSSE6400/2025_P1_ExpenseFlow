// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
// Elements
import '../profile_setup_screen/elements/profile_setup_screen_main_body.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBarWidget(
        screenName: '',
        showBackButton: true,
      ),

      body: ProfileSetupScreenMainBody(),
    );
  }
}