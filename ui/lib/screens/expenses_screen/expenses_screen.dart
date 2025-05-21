// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
import '../expenses_screen/elements/expenses_screen_main_body.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: 'Expenses',
        showBackButton: true,
      ),

      body: const ExpensesScreenMainBody(),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Expenses',
        inactive: false,
      ),
    );
  }
}