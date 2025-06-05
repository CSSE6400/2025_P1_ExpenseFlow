import 'package:flutter/material.dart';
import 'package:expenseflow/common/color_palette.dart' show ColorPalette;
import 'package:expenseflow/common/proportional_sizes.dart'
    show ProportionalSizes;
import 'package:expenseflow/models/expense.dart' show ExpenseRead;

String formatPrice(String price) {
  return '\$${double.parse(price).toStringAsFixed(2)}';
}

class ExpenseViewBasic extends StatelessWidget {
  final ExpenseRead expense;
  final ProportionalSizes proportionalSizes;

  const ExpenseViewBasic({
    super.key,
    required this.expense,
    required this.proportionalSizes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: proportionalSizes.scaleWidth(16),
        vertical: proportionalSizes.scaleHeight(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            expense.name,
            style: TextStyle(
              fontSize: proportionalSizes.scaleText(18),
              color: ColorPalette.primaryText,
            ),
          ),
          Text(
            formatPrice(expense.expenseTotal.toString()),
            style: TextStyle(
              fontSize: proportionalSizes.scaleText(18),
              color: ColorPalette.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
