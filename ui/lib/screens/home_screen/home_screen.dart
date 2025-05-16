// Flutter imports
import 'package:flutter/material.dart';
// Common
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
// Elements
import '../home_screen/elements/home_screen_main_body.dart';
import '../home_screen/elements/home_screen_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: HomeScreenAppBarWidget(),

      body: HomeScreenMainBody(),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Home',
        inactive: false,
      ),
    );
  }
}