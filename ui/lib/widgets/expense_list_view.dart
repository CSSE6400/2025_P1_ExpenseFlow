import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/search_bar.dart' as search;
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/widgets/expense_view.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
import 'package:flutter_frontend/common/proportional_sizes.dart';

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

  List<ExpenseRead> get filteredExpenses {
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

    final filteredByPeriod = widget.expenses.where((expense) {
      final expenseDate = expense.expenseDate;
      return expenseDate.isAfter(cutoff);
    });

    if (searchText.isEmpty) {
      return filteredByPeriod.toList();
    }

    final lowerSearch = searchText.toLowerCase();

    return filteredByPeriod.where((expense) {
      final name = expense.name.toLowerCase();
      final description = expense.description.toLowerCase();
      return name.contains(lowerSearch) || description.contains(lowerSearch);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(
          hintText: 'Search expenses',
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
        ),
        const SizedBox(height: 16),
        SizedBox(height: proportionalSizes.scaleHeight(8)),
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
        SizedBox(height: proportionalSizes.scaleHeight(12)),
        if (filteredExpenses.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: proportionalSizes.scaleHeight(20),
            ),
            child: Center(
              child: Text('No expenses found.', style: TextStyle(fontSize: 16)),
            ),
          )
        else
          ...filteredExpenses.map(
            (expense) => ExpenseView(
              expense: expense,
              onButtonPressed: () => widget.onExpenseTap(expense),
            ),
          ),
      ],
    );
  }
}
