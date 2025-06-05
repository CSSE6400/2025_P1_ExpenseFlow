import 'package:flutter/material.dart';
import 'package:expenseflow/types.dart' show CategoryData;
import 'package:expenseflow/widgets/donut_chart.dart' show DonutChartWithHover;
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class OverviewScreenStatWidget extends StatelessWidget {
  final List<CategoryData> categories;

  const OverviewScreenStatWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;
    final chartSize = proportionalSizes.scaleWidth(180);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(proportionalSizes.scaleWidth(16)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: DonutChartWithHover(
              categories: categories,
              chartSize: chartSize,
              enableHover: true,
            ),
          ),
          SizedBox(height: proportionalSizes.scaleHeight(20)),
          ..._buildCategoryList(context, categories),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryList(
    BuildContext context,
    List<CategoryData> categories,
  ) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return categories.map((category) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: proportionalSizes.scaleHeight(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: proportionalSizes.scaleWidth(20),
                  height: proportionalSizes.scaleHeight(20),
                  decoration: BoxDecoration(
                    color: category.color!,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: proportionalSizes.scaleWidth(10)),
                Text(
                  category.name,
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(16),
                    fontWeight: FontWeight.w500,
                    color: ColorPalette.primaryText,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: proportionalSizes.scaleHeight(4),
                horizontal: proportionalSizes.scaleWidth(8),
              ),
              decoration: BoxDecoration(
                color: category.color!.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(
                  proportionalSizes.scaleWidth(8),
                ),
              ),
              child: Text(
                '\$${category.amount.toStringAsFixed(2)}',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: proportionalSizes.scaleText(14),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
