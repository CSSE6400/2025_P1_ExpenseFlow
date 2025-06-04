import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/color_palette.dart' show ColorPalette;
import 'package:flutter_frontend/common/proportional_sizes.dart'
    show ProportionalSizes;
import 'package:flutter_frontend/models/expense.dart' show ExpenseRead;

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
