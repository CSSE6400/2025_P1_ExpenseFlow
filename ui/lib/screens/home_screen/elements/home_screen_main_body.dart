import 'package:flutter/material.dart';
// Common
import '../../../common/proportional_sizes.dart';
// Elements
import 'home_screen_overview.dart';
import 'home_screen_add_an_expense.dart';
import 'home_screen_recent_expenses.dart';

class HomeScreenMainBody extends StatelessWidget {
  final bool isDarkMode;

  const HomeScreenMainBody({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview
              HomeScreenOverview(isDarkMode: isDarkMode),
              SizedBox(height: proportionalSizes.scaleHeight(20)),

              // Add an expense
              HomeScreenAddAnExpense(isDarkMode: isDarkMode),
              SizedBox(height: proportionalSizes.scaleHeight(20)),

              // Recent expenses
              HomeScreenRecentExpenses(isDarkMode: isDarkMode),
            ],
          ),
        ),
      ),
    );
  }
}