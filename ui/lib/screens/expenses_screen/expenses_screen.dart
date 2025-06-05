import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/proportional_sizes.dart'
    show ProportionalSizes;
import 'package:flutter_frontend/common/snack_bar.dart' show showCustomSnackBar;
import 'package:flutter_frontend/common/swipe_detector.dart' show SwipeDetector;
import 'package:flutter_frontend/models/expense.dart' show ExpenseRead;
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:flutter_frontend/widgets/expense_list_view.dart'
    show ExpenseListView;
import 'package:provider/provider.dart' show Provider;
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool isLoading = true;
  List<ExpenseRead> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final fetchedExpenses =
          await apiService.expenseApi.getExpensesUploadedByMe();

      setState(() {
        expenses = fetchedExpenses;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, normalText: 'Failed to fetch expenses');
      setState(() => isLoading = false);
    }
  }

  void onExpenseTap(ExpenseRead expense) {
    Navigator.pushNamed(
      context,
      '/see_expense',
      arguments: {'expenseId': expense.expenseId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;
    final proportionalSizes = ProportionalSizes(context: context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: "View My Personal Expenses",
        showBackButton: false,
      ),

      body: SwipeDetector(
        onDragLeft: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: proportionalSizes.scaleWidth(20),
              vertical: proportionalSizes.scaleHeight(20),
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ExpenseListView(expenses: expenses, onExpenseTap: onExpenseTap),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentScreen: BottomNavBarScreen.expenses,
        inactive: false,
      ),
    );
  }
}
