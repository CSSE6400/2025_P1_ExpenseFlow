import 'package:flutter/material.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
// Elements
import 'home_screen_overview.dart';
import 'home_screen_add_an_expense.dart';
import 'home_screen_recent_expenses.dart';

class HomeScreenMainBody extends StatefulWidget {
  const HomeScreenMainBody({super.key});

  @override
  State<HomeScreenMainBody> createState() => HomeScreenMainBodyState();
}

class HomeScreenMainBodyState extends State<HomeScreenMainBody>
    with WidgetsBindingObserver {
  // Create a key to force refresh the overview widget
  final GlobalKey<HomeScreenOverviewState> _overviewKey =
      GlobalKey<HomeScreenOverviewState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app is resumed
      _refreshOverview();
    }
  }

  void _refreshOverview() {
    if (_overviewKey.currentState != null) {
      _overviewKey.currentState!.refreshData();
    }
  }

  // Method to access the overview state
  HomeScreenOverviewState? getOverviewState() {
    return _overviewKey.currentState;
  }

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
              HomeScreenOverview(key: _overviewKey),
              SizedBox(height: proportionalSizes.scaleHeight(20)),

              // Add an expense
              HomeScreenAddAnExpense(),
              SizedBox(height: proportionalSizes.scaleHeight(20)),

              // Recent expenses
              HomeScreenRecentExpenses(),
            ],
          ),
        ),
      ),
    );
  }
}
