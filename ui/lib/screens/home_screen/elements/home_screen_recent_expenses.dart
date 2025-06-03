import 'package:flutter/material.dart';
import 'package:flutter_frontend/types.dart' show RecentExpense;
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class HomeScreenRecentExpenses extends StatelessWidget {
  final List<RecentExpense> recentExpenses;
  final bool isLoading;
  final VoidCallback? onTap;

  const HomeScreenRecentExpenses({
    super.key,
    required this.recentExpenses,
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
                'Recent Expenses',
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
            else
              ...recentExpenses.map(
                (expense) => Padding(
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
                        formatPrice(expense.price),
                        style: TextStyle(
                          fontSize: proportionalSizes.scaleText(18),
                          color: ColorPalette.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
