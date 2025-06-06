import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class OverviewScreenAmountWidget extends StatelessWidget {
  final double monthlyBudget;
  final double spent;
  final bool isLoading;

  const OverviewScreenAmountWidget({
    super.key,
    required this.monthlyBudget,
    required this.spent,
    this.isLoading = false,
  });

  String formatAmount(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: proportionalSizes.scaleWidth(16),
                vertical: proportionalSizes.scaleHeight(8),
              ),
              child: Column(
                children: [
                  _buildRow('Monthly Budget', monthlyBudget, proportionalSizes),
                  SizedBox(height: proportionalSizes.scaleHeight(8)),
                  _buildRow('Spent', spent, proportionalSizes),
                  SizedBox(height: proportionalSizes.scaleHeight(8)),
                  _buildRow(
                    'Remaining',
                    monthlyBudget - spent,
                    proportionalSizes,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    double amount,
    ProportionalSizes proportionalSizes,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: proportionalSizes.scaleText(16),
            color: ColorPalette.primaryText,
          ),
        ),
        Text(
          formatAmount(amount),
          style: GoogleFonts.roboto(
            fontSize: proportionalSizes.scaleText(16),
            color: ColorPalette.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
