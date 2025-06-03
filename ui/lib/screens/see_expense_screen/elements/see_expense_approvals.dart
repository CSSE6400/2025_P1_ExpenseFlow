import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/expense.dart';
import '../../../common/proportional_sizes.dart';
import '../elements/see_expense_screen_status.dart';

class SeeExpenseApprovals extends StatelessWidget {
  final ExpenseRead expense;
  final List<SplitStatusInfo> splitStatuses;

  const SeeExpenseApprovals({
    super.key,
    required this.expense,
    required this.splitStatuses,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: proportionalSizes.scaleWidth(20),
        vertical: proportionalSizes.scaleHeight(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SeeExpenseScreenActiveStatus(status: expense.status),
          SizedBox(height: proportionalSizes.scaleHeight(20)),
        ],
      ),
    );
  }
}
