import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/app_bar.dart';
import 'package:flutter_frontend/common/bottom_nav_bar.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:flutter_frontend/widgets/expense_list_view.dart';
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
            // TODO: add a header with friend's name
            child: ExpenseListView(
              expenses: expenses, // Pass full list; filtering is now internal
              onExpenseTap: (expense) {
                Navigator.pushNamed(
                  context,
                  '/see_expense',
                  arguments: {'expenseId': expense.expenseId},
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(inactive: false),
    );
  }
}
