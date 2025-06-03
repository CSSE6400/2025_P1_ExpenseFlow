import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/app_bar.dart';
import 'package:flutter_frontend/common/bottom_nav_bar.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
import 'package:flutter_frontend/models/enums.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/screens/expenses_screen/elements/expenses_screen_segment_control.dart'
    show ExpensesScreenSegmentControl;
import 'package:flutter_frontend/services/api_service.dart';
import 'package:flutter_frontend/widgets/expense_list_view.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import '../../../common/proportional_sizes.dart';

class IndFriendExpenseScreen extends StatefulWidget {
  final String userId;

  const IndFriendExpenseScreen({super.key, required this.userId});

  @override
  State<IndFriendExpenseScreen> createState() => _IndFriendExpenseScreenState();
}

class _IndFriendExpenseScreenState extends State<IndFriendExpenseScreen> {
  final Logger _logger = Logger("IndFriendExpenseScreen");
  UserRead? friend;
  List<ExpenseRead> expenses = [];
  bool isLoading = true;
  String selectedSegment = 'Active';
  String selectedPeriod = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final fetchedUser = await apiService.friendApi.getFriend(widget.userId);
      if (fetchedUser == null) {
        if (!mounted) return;
        showCustomSnackBar(context, normalText: 'Friend not found');
        return;
      }

      final fetchedExpenses = await apiService.friendApi.getFriendExpenses(
        widget.userId,
      );
      if (!mounted) return;

      setState(() {
        friend = fetchedUser;
        expenses = fetchedExpenses;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, normalText: 'Failed to fetch friend');
      setState(() => isLoading = false);
    }
  }

  List<ExpenseRead> get filteredExpenses {
    if (selectedSegment == 'Active') {
      return expenses.where((e) => e.status != ExpenseStatus.paid).toList();
    }
    return expenses;
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friend == null) {
      _logger.warning("Friend is null");
      return const Scaffold(body: Center(child: Text("Friend not found")));
    }

    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBarWidget(screenName: "View Friend", showBackButton: true),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: proportionalSizes.scaleWidth(20),
              vertical: proportionalSizes.scaleHeight(0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ExpensesScreenSegmentControl(
                  selectedSegment: selectedSegment,
                  onSegmentChanged:
                      (segment) => setState(() => selectedSegment = segment),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TimePeriodDropdown(
                    selectedPeriod: selectedPeriod,
                    onChanged: (period) {
                      if (period != null) {
                        setState(() => selectedPeriod = period);
                      }
                    },
                  ),
                ),
                SizedBox(height: proportionalSizes.scaleHeight(20)),
                ExpenseListView(
                  expenses: filteredExpenses,
                  onExpenseTap: (expense) {
                    Navigator.pushNamed(
                      context,
                      '/see_expense',
                      arguments: {'expenseId': expense.expenseId},
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentScreen: 'Individual Friend',
        inactive: false,
      ),
    );
  }
}
