import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
import '../../common/bottom_nav_bar.dart';

class IndGroupExpenseScreen extends StatefulWidget {
  final String groupName;

  const IndGroupExpenseScreen({
    super.key,
    required this.groupName,
  });

  @override
  State<IndGroupExpenseScreen> createState() => _IndGroupExpenseScreenState();
}

class _IndGroupExpenseScreenState extends State<IndGroupExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: widget.groupName,
        showBackButton: true,
      ),

      body: Center(
        child: Text(
          'Expenses for group "${widget.groupName}"',
          style: TextStyle(
            fontSize: 18,
            color: ColorPalette.primaryText,
          ),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Individual Group',
        inactive: false,
      ),
    );
  }
}