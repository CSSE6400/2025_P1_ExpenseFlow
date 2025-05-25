// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
import 'elements/overview_screen_main_body.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: 'Overview',
        showBackButton: true,
      ),

      body: const OverviewScreenMainBody(),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Overview',
        inactive: false,
      ),
    );
  }
}