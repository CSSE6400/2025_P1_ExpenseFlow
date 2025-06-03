import 'package:flutter/material.dart';
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
import '../add_expense_screen/elements/add_expense_screen_main_body.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(screenName: 'Add Expense', showBackButton: true),

      body: AddExpenseScreenMainBody(),

      bottomNavigationBar: BottomNavBar(currentScreen: 'Add', inactive: false),
    );
  }
}
