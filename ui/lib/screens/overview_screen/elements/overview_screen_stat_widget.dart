import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_frontend/types.dart' show CategoryData;
import 'package:google_fonts/google_fonts.dart';
// Common imports
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
            child: _DonutChartWithHover(
              categories: categories,
              chartSize: chartSize,
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

class _DonutChartWithHover extends StatefulWidget {
  final List<CategoryData> categories;
  final double chartSize;

  const _DonutChartWithHover({
    required this.categories,
    required this.chartSize,
  });

  @override
  State<_DonutChartWithHover> createState() => _DonutChartWithHoverState();
}

class _DonutChartWithHoverState extends State<_DonutChartWithHover> {
  int? hoveredSectionIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.chartSize,
      height: widget.chartSize,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: widget.chartSize * 0.35,
          startDegreeOffset: -90,
          pieTouchData: PieTouchData(
            enabled: true,
            touchCallback: (event, response) {
              setState(() {
                if (event is FlPointerHoverEvent) {
                  hoveredSectionIndex =
                      response?.touchedSection?.touchedSectionIndex;
                } else if (event is FlPointerExitEvent) {
                  hoveredSectionIndex = null;
                }
              });
            },
          ),
          sections:
              widget.categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final isHovered = hoveredSectionIndex == index;

                return PieChartSectionData(
                  color: category.color!,
                  value: category.amount,
                  title: '',
                  radius:
                      isHovered
                          ? widget.chartSize * 0.22
                          : widget.chartSize * 0.2,
                  titleStyle: const TextStyle(fontSize: 0),
                  badgeWidget:
                      isHovered ? _buildTooltip(context, category) : null,
                  badgePositionPercentageOffset: 1.3,
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildTooltip(BuildContext context, CategoryData category) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: proportionalSizes.scaleWidth(12),
        vertical: proportionalSizes.scaleHeight(8),
      ),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.name,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: proportionalSizes.scaleText(14),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '\$${category.amount.toStringAsFixed(2)}',
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: proportionalSizes.scaleText(12),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
