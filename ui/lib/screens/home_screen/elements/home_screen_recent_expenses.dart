import 'package:flutter/material.dart';
import 'package:expenseflow/models/expense.dart' show ExpenseRead;
import 'package:expenseflow/widgets/expense_view_basic.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class HomeScreenRecentExpenses extends StatelessWidget {
  final List<ExpenseRead> expenses;
  final bool isLoading;
  final VoidCallback? onTap;

  const HomeScreenRecentExpenses({
    super.key,
    required this.expenses,
    required this.isLoading,
    this.onTap,
  });

  String formatPrice(String price) {
    return '\$${double.parse(price).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(proportionalSizes.scaleWidth(16)),
              child: Text(
                'Recent Expenses By Me',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(24),
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryText,
                ),
              ),
            ),

            if (isLoading)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: proportionalSizes.scaleHeight(20),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorPalette.primaryAction,
                  ),
                ),
              )
            else if (expenses.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: proportionalSizes.scaleHeight(20),
                ),
                child: Center(
                  child: Text(
                    "You've got no recent expenses",
                    style: TextStyle(
                      fontSize: proportionalSizes.scaleText(16),
                      color: ColorPalette.primaryText.withValues(alpha: .7),
                    ),
                  ),
                ),
              )
            else
              ...expenses.map(
                (expense) => ExpenseViewBasic(
                  expense: expense,
                  proportionalSizes: proportionalSizes,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
