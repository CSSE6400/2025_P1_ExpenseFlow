import 'package:flutter/material.dart';
import 'package:expenseflow/common/null_custom_dropdown.dart'
    show NullableCustomDropdown;
import 'package:expenseflow/common/search_bar.dart' as search;
import 'package:expenseflow/models/enums.dart' show EntityKind, ExpenseStatus;
import 'package:expenseflow/models/expense.dart';
import 'package:expenseflow/models/user.dart' show UserRead;
import 'package:expenseflow/services/auth_guard_provider.dart'
    show AuthGuardProvider;
import 'package:expenseflow/widgets/expense_list_segment_control.dart';
import 'package:expenseflow/widgets/expense_view.dart';
import 'package:expenseflow/widgets/time_period_dropdown.dart';
import 'package:expenseflow/common/proportional_sizes.dart';
import 'package:provider/provider.dart' show Provider;

enum ExpenseViewType { mine, friend, group }

class ExpenseListView extends StatefulWidget {
  final List<ExpenseRead> expenses;
  final void Function(ExpenseRead) onExpenseTap;

  const ExpenseListView({
    super.key,
    required this.expenses,
    required this.onExpenseTap,
  });

  @override
  State<ExpenseListView> createState() => _ExpenseListViewState();
}

class _ExpenseListViewState extends State<ExpenseListView> {
  String selectedPeriod = 'Last 30 Days';
  String searchText = '';
  ExpenseListSegment selectedSegment = ExpenseListSegment.unpaid;
  ExpenseViewType? selectedViewType; // New filter dropdown state
  late UserRead user;
  List<(ExpenseRead, ExpenseViewType)> expenseViews = [];

  @override
  void initState() {
    super.initState();
    final authGuard = Provider.of<AuthGuardProvider>(context, listen: false);
    user = authGuard.mustGetUser(context);

    expenseViews = expensesWithType(user, widget.expenses);
  }

  List<(ExpenseRead, ExpenseViewType)> expensesWithType(
    UserRead user,
    List<ExpenseRead> expenses,
  ) {
    return expenses.map((expense) {
      final type =
          expense.uploader.userId == user.userId
              ? ExpenseViewType.mine
              : (expense.parentKind == EntityKind.group
                  ? ExpenseViewType.group
                  : ExpenseViewType.friend);
      return (expense, type);
    }).toList();
  }

  List<(ExpenseRead, ExpenseViewType)> get filteredExpenses {
    final now = DateTime.now();
    DateTime cutoff;

    switch (selectedPeriod) {
      case 'Last 7 Days':
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case 'Last 30 Days':
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case 'Last 90 Days':
        cutoff = now.subtract(const Duration(days: 90));
        break;
      default:
        cutoff = DateTime.fromMillisecondsSinceEpoch(0);
    }

    var filteredByPeriod = widget.expenses.where((expense) {
      final expenseDate = expense.expenseDate;
      return expenseDate.isAfter(cutoff);
    });

    if (selectedSegment == ExpenseListSegment.unpaid) {
      filteredByPeriod = filteredByPeriod.where(
        (e) => e.status != ExpenseStatus.paid,
      );
    }

    var expensesWithTypes = expensesWithType(user, filteredByPeriod.toList());

    if (searchText.isNotEmpty) {
      final lowerSearch = searchText.toLowerCase();
      expensesWithTypes =
          expensesWithTypes.where((e) {
            final name = e.$1.name.toLowerCase();
            final desc = e.$1.description.toLowerCase();
            return name.contains(lowerSearch) || desc.contains(lowerSearch);
          }).toList();
    }

    if (selectedViewType != null) {
      expensesWithTypes =
          expensesWithTypes.where((e) => e.$2 == selectedViewType).toList();
    }

    return expensesWithTypes;
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpenseListSegmentControl(
          selectedSegment: selectedSegment,
          onSegmentChanged: (segment) {
            setState(() => selectedSegment = segment);
          },
        ),
        SizedBox(height: proportionalSizes.scaleHeight(16)),
        search.SearchBar(
          hintText: 'Search expenses',
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
        ),
        SizedBox(height: proportionalSizes.scaleHeight(12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NullableCustomDropdown<ExpenseViewType>(
              selected: selectedViewType,
              options: [
                null,
                ExpenseViewType.mine,
                ExpenseViewType.friend,
                ExpenseViewType.group,
              ],
              onChanged: (value) => setState(() => selectedViewType = value),
              labelBuilder:
                  (val) =>
                      val == null
                          ? "All Types"
                          : val == ExpenseViewType.mine
                          ? "My Expenses"
                          : val == ExpenseViewType.friend
                          ? "Split with Friend"
                          : "Split with Group",
            ),
            TimePeriodDropdown(
              selectedPeriod: selectedPeriod,
              onChanged: (value) => setState(() => selectedPeriod = value),
            ),
          ],
        ),
        SizedBox(height: proportionalSizes.scaleHeight(12)),
        if (filteredExpenses.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: proportionalSizes.scaleHeight(20),
            ),
            child: const Center(
              child: Text('No expenses found.', style: TextStyle(fontSize: 16)),
            ),
          )
        else
          ...filteredExpenses.map(
            (expense) => ExpenseView(
              expense: expense.$1,
              onButtonPressed: () => widget.onExpenseTap(expense.$1),
              type: expense.$2,
            ),
          ),
      ],
    );
  }
}
