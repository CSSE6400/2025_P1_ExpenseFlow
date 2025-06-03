import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/proportional_sizes.dart'
    show ProportionalSizes;
import 'package:flutter_frontend/common/snack_bar.dart' show showCustomSnackBar;
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/group.dart' show GroupCreate, GroupRead;
import 'package:flutter_frontend/models/user.dart' show UserGroupRead;
import 'package:flutter_frontend/screens/ind_group_expense_screen/elements/ind_group_edit.dart';
import 'package:flutter_frontend/screens/ind_group_expense_screen/elements/ind_group_group_members.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:flutter_frontend/widgets/expense_list_view.dart';
import 'package:provider/provider.dart' show Provider;
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
import '../../common/bottom_nav_bar.dart';

class IndGroupExpenseScreen extends StatefulWidget {
  final String groupId;

  const IndGroupExpenseScreen({super.key, required this.groupId});

  @override
  State<IndGroupExpenseScreen> createState() => _IndGroupExpenseScreenState();
}

class _IndGroupExpenseScreenState extends State<IndGroupExpenseScreen> {
  GroupRead? group;
  bool isLoading = true;
  List<ExpenseRead> expenses = [];
  List<UserGroupRead> groupMembers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final fetchedGroup = await apiService.groupApi.getGroup(widget.groupId);
      if (fetchedGroup == null) {
        if (!mounted) return;
        showCustomSnackBar(context, normalText: 'Group not found');
        return;
      }

      setState(() {
        group = fetchedGroup;
      });

      final fetchedGroupMembers = await apiService.groupApi.getGroupUsers(
        widget.groupId,
      );

      setState(() {
        groupMembers = fetchedGroupMembers;
      });

      final fetchedExpenses = await apiService.groupApi.getGroupExpenses(
        widget.groupId,
      );

      setState(() {
        expenses = fetchedExpenses;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, normalText: 'Failed to fetch group');
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

  void onSave(String name, String description) async {
    if (group == null) return;

    final updateGroup = GroupCreate(name: name, description: description);

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final updatedGroup = await apiService.groupApi.updateGroup(
        group!.groupId,
        updateGroup,
      );

      setState(() {
        group = updatedGroup;
      });
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, normalText: 'Failed to update group');
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;
    final proportionalSizes = ProportionalSizes(context: context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (group == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: Text("Group not found")),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(screenName: "View Group", showBackButton: true),

      body: (GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: proportionalSizes.scaleWidth(20),
              vertical: proportionalSizes.scaleHeight(0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GroupMembersSection(groupMembers: groupMembers),
                GroupEditor(
                  name: group!.name,
                  description: group!.description,
                  onSave: onSave,
                ),
                SizedBox(height: proportionalSizes.scaleHeight(8)),
                ExpenseListView(expenses: expenses, onExpenseTap: onExpenseTap),
              ],
            ),
          ),
        ),
      )),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Individual Group',
        inactive: false,
      ),
    );
  }
}
