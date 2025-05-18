// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
// Elements
import '../split_with_screen/elements/split_with_screen_main_body.dart';

class SplitWithScreen extends StatefulWidget {
  const SplitWithScreen({super.key});

  @override
  State<SplitWithScreen> createState() => _SplitWithScreenState();
}

class _SplitWithScreenState extends State<SplitWithScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: 'Split With',
        showBackButton: true,
      ),

      body: SplitWithScreenMainBody(),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Add',
        inactive: true,
      ),
    );
  }
}