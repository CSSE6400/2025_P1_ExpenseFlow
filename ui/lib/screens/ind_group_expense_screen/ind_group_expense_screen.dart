import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/ind_group_expense_screen/elements/ind_group_expense_screen_main_body.dart';
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

      body: IndGroupExpenseScreenMainBody(
        groupName: widget.groupName,
      ),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Individual Group',
        inactive: false,
      ),
    );
  }
}