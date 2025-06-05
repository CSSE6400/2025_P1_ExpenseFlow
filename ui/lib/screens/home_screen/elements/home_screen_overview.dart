import 'package:flutter/material.dart';
import 'package:flutter_frontend/types.dart' show CategoryData;
import 'package:flutter_frontend/widgets/donut_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class HomeScreenOverview extends StatelessWidget {
  final bool isLoading;
  final double monthlyBudget;
  final List<CategoryData> categories;
  final double spent;

  const HomeScreenOverview({
    super.key,
    required this.isLoading,
    required this.monthlyBudget,
    required this.categories,
    required this.spent,
  });

  double get remaining => monthlyBudget - spent;

  List<Widget> _buildTopCategories(ProportionalSizes proportionalSizes) {
    return categories.map((category) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: proportionalSizes.scaleHeight(4),
        ),
        child: Row(
          children: [
            Container(
              width: proportionalSizes.scaleWidth(12),
              height: proportionalSizes.scaleHeight(12),
              margin: EdgeInsets.only(right: proportionalSizes.scaleWidth(8)),
              decoration: BoxDecoration(
                color: category.color!,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text(
              category.name,
              style: GoogleFonts.roboto(
                fontSize: proportionalSizes.scaleText(14),
                color: ColorPalette.primaryText,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildAmountRow(
    String label,
    double value,
    ProportionalSizes proportionalSizes,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: proportionalSizes.scaleHeight(2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: proportionalSizes.scaleText(14),
              color: ColorPalette.primaryText,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(0)}',
            style: GoogleFonts.roboto(
              fontSize: proportionalSizes.scaleText(14),
              fontWeight: FontWeight.bold,
              color: ColorPalette.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;
    final chartSize = proportionalSizes.scaleWidth(140);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/overview');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(proportionalSizes.scaleWidth(16)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(16)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Donut chart with hover
            DonutChartWithHover(
              categories: categories,
              chartSize: chartSize,
              enableHover: false,
            ),
            SizedBox(width: proportionalSizes.scaleWidth(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: GoogleFonts.roboto(
                      fontSize: proportionalSizes.scaleText(24),
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.primaryText,
                    ),
                  ),
                  SizedBox(height: proportionalSizes.scaleHeight(12)),
                  ..._buildTopCategories(proportionalSizes),
                  Divider(
                    color: ColorPalette.primaryText.withValues(alpha: .5),
                  ),
                  _buildAmountRow('Budget:', monthlyBudget, proportionalSizes),
                  _buildAmountRow('Spent:', spent, proportionalSizes),
                  _buildAmountRow('Remaining:', remaining, proportionalSizes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
