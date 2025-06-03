import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/widgets/expense_view.dart';

class ExpenseListView extends StatelessWidget {
  final List<ExpenseRead> expenses;
  final void Function(ExpenseRead) onExpenseTap;

  const ExpenseListView({
    super.key,
    required this.expenses,
    required this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          expenses
              .map(
                (expense) => ExpenseView(
                  expense: expense,
                  onButtonPressed: () => onExpenseTap(expense),
                ),
              )
              .toList(),
    );
  }
}
