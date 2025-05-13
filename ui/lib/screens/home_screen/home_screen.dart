// Flutter imports
import 'package:flutter/material.dart';
// Common
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;

  const HomeScreen({super.key, required this.isDarkMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    );
  }
}