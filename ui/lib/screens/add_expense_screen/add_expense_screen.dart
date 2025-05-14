// Flutter imports
import 'package:flutter/material.dart';
// Common
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';

class AddExpenseScreen extends StatefulWidget {
  final bool isDarkMode;

  const AddExpenseScreen({super.key, required this.isDarkMode});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode
        ? ColorPalette.backgroundDark
        : ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: 'Add Expense',
        showBackButton: true,
        isDarkMode: widget.isDarkMode,
      ),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Add',
        isDarkMode: widget.isDarkMode,
        inactive: false,
      ),
    );
  }
}