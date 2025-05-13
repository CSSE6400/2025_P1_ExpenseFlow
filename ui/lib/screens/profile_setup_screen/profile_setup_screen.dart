// Flutter imports
import 'package:flutter/material.dart';
// Common
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
// Elements
import '../profile_setup_screen/elements/profile_setup_screen_main_body.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isDarkMode;

  const ProfileSetupScreen({super.key, required this.isDarkMode});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode
        ? ColorPalette.backgroundDark
        : ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: '',
        showBackButton: true,
        isDarkMode: widget.isDarkMode,
      ),
      body: ProfileSetupScreenMainBody(isDarkMode: widget.isDarkMode),
    );
  }
}