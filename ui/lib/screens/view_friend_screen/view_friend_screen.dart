import 'package:flutter/material.dart';
import 'package:expenseflow/common/app_bar.dart';
import 'package:expenseflow/common/bottom_nav_bar.dart';
import 'package:expenseflow/common/color_palette.dart';
import 'package:expenseflow/common/snack_bar.dart';
import 'package:expenseflow/models/expense.dart';
import 'package:expenseflow/models/user.dart';
import 'package:expenseflow/services/api_service.dart';
import 'package:expenseflow/widgets/expense_list_view.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import '../../../common/proportional_sizes.dart';

class ViewFriendScreen extends StatefulWidget {
  final String userId;

  const ViewFriendScreen({super.key, required this.userId});

  @override
  State<ViewFriendScreen> createState() => _ViewFriendScreenState();
}

class _ViewFriendScreenState extends State<ViewFriendScreen> {
  final Logger _logger = Logger("IndFriendExpenseScreen");
  UserRead? friend;
  List<ExpenseRead> expenses = [];
  bool isLoading = true;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: proportionalSizes.scaleHeight(16),
                    bottom: proportionalSizes.scaleHeight(16),
                  ),
                  child: Text(
                    "Nickname: ${friend!.nickname}",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.primaryText,
                    ),
                  ),
                ),
                ExpenseListView(
                  expenses: expenses,
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
      bottomNavigationBar: const BottomNavBar(inactive: false),
    );
  }
}
