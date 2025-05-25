// Flutter imports
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class OverviewScreenAmountWidget extends StatefulWidget {
  const OverviewScreenAmountWidget({super.key});

  @override
  State<OverviewScreenAmountWidget> createState() => _OverviewScreenAmountWidgetState();
}

class _OverviewScreenAmountWidgetState extends State<OverviewScreenAmountWidget> {
  double monthlyBudget = 0.0;
  double spent = 0.0;
  double remaining = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccountOverview();
  }

  Future<void> _loadAccountOverview() async {
    // TODO: Replace with actual data from backend
    const double fetchedBudget = 5000.00;
    const double fetchedSpent = 3560.00;
    final double fetchedRemaining = fetchedBudget - fetchedSpent;

    if (mounted) {
      setState(() {
        monthlyBudget = fetchedBudget;
        spent = fetchedSpent;
        remaining = fetchedRemaining;
        isLoading = false;
      });
    }
  }

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
        borderRadius: BorderRadius.circular(
          proportionalSizes.scaleWidth(10),
        ),
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
                  _buildRow('Remaining', remaining, proportionalSizes),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, ProportionalSizes proportionalSizes) {
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