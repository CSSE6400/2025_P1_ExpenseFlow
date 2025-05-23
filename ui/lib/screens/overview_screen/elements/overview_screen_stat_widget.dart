import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class OverviewScreenStatWidget extends StatefulWidget {
  const OverviewScreenStatWidget({super.key});

  @override
  State<OverviewScreenStatWidget> createState() => _OverviewScreenStatWidgetState();
}

class _OverviewScreenStatWidgetState extends State<OverviewScreenStatWidget> {
  late final List<_CategoryData> categories;

  final List<Color> availableColors = [
    Color(0xFF75E3EA), Color(0xFF4DC4D3), Color(0xFF3C74A6), Color(0xFF6C539F),
    Color(0xFF7B438D), Color(0xFFFD9BBA), Color(0xFFFFC785), Color(0xFF9FE6A0),
    Color(0xFFFFD6E0), Color(0xFFB7C0EE), Color(0xFFADC698), Color(0xFF71B3B7),
    Color(0xFFBCA9F5), Color(0xFFF5C3AF), Color(0xFF92E3A9), Color(0xFFDA9BCB),
    Color(0xFFFCB9AA), Color(0xFF84B6F4), Color(0xFFF9F871), Color(0xFFE0A9F5),
  ];

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // TODO: Replace with actual data from backend
    categories = [
      _CategoryData(name: 'Rent', amount: 1200),
      _CategoryData(name: 'Bills', amount: 300),
      _CategoryData(name: 'Groceries', amount: 450),
      _CategoryData(name: 'Subscriptions', amount: 80),
      _CategoryData(name: 'Dining Out', amount: 200),
      _CategoryData(name: 'Transport', amount: 150),
      _CategoryData(name: 'Insurance', amount: 220),
      _CategoryData(name: 'Utilities', amount: 130),
      _CategoryData(name: 'Medical', amount: 100),
      _CategoryData(name: 'Education', amount: 180),
      _CategoryData(name: 'Shopping', amount: 250),
      _CategoryData(name: 'Pets', amount: 90),
      _CategoryData(name: 'Entertainment', amount: 160),
      _CategoryData(name: 'Fitness', amount: 75),
      _CategoryData(name: 'Remaining', amount: 300),
    ];

    for (var category in categories) {
      category.color = availableColors[_random.nextInt(availableColors.length)];
    }
  }

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
        borderRadius: BorderRadius.circular(
          proportionalSizes.scaleWidth(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildDonutChart(chartSize)),
          SizedBox(height: proportionalSizes.scaleHeight(20)),
          ..._buildCategoryList(proportionalSizes),
        ],
      ),
    );
  }

  Widget _buildDonutChart(double chartSize) {return SizedBox(
      width: chartSize,
      height: chartSize,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: chartSize * 0.35,
          startDegreeOffset: -90,
          sections: categories.map((category) {
            return PieChartSectionData(
              color: category.color!,
              value: category.amount,
              title: '',
              radius: chartSize * 0.2,
              titleStyle: const TextStyle(fontSize: 0),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildCategoryList(ProportionalSizes proportionalSizes) {
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
            // Price tag
            Container(
              padding: EdgeInsets.symmetric(
                vertical: proportionalSizes.scaleHeight(4),
                horizontal: proportionalSizes.scaleWidth(8),
              ),
              decoration: BoxDecoration(
                color: category.color!.withValues(alpha: 0.1),
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

class _CategoryData {
  final String name;
  final double amount;
  Color? color;

  _CategoryData({
    required this.name,
    required this.amount,
  });
}