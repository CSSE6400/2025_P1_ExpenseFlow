import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class HomeScreenOverview extends StatefulWidget {
  const HomeScreenOverview({super.key});

  @override
  State<HomeScreenOverview> createState() => _HomeScreenOverviewState();
}

class _HomeScreenOverviewState extends State<HomeScreenOverview> {
  late final List<_CategoryData> categories;
  late List<_CategoryData> visibleCategories;
  final List<Color> availableColors = [
    Color(0xFF75E3EA), Color(0xFF4DC4D3), Color(0xFF3C74A6), Color(0xFF6C539F),
    Color(0xFF7B438D), Color(0xFFFD9BBA), Color(0xFFFFC785), Color(0xFF9FE6A0),
    Color(0xFFFFD6E0), Color(0xFFB7C0EE), Color(0xFFADC698), Color(0xFF71B3B7),
    Color(0xFFBCA9F5), Color(0xFFF5C3AF), Color(0xFF92E3A9), Color(0xFFDA9BCB),
    Color(0xFFFCB9AA), Color(0xFF84B6F4), Color(0xFFF9F871), Color(0xFFE0A9F5),
  ];

  double monthlyBudget = 0.0;
  double spent = 0.0;
  double remaining = 0.0;
  bool isLoading = true;

  final _random = Random();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // TODO: Replace with actual backend call
    monthlyBudget = 5000.0;
    final rawCategories = [
      _CategoryData(name: 'Rent', amount: 1200),
      _CategoryData(name: 'Bills', amount: 300),
      _CategoryData(name: 'Groceries', amount: 450),
      _CategoryData(name: 'Subscriptions', amount: 80),
      _CategoryData(name: 'Dining Out', amount: 200),
    ];

    for (var category in rawCategories) {
      category.color = availableColors[_random.nextInt(availableColors.length)];
    }

    spent = rawCategories.fold(0, (sum, cat) => sum + cat.amount);
    remaining = monthlyBudget - spent;

    final top3 = rawCategories.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final displayed = top3.take(3).toList();
    final otherAmount = top3.skip(3).fold(0.0, (sum, c) => sum + c.amount);

    visibleCategories = [...displayed];
    if (otherAmount > 0) {
      final otherColor = availableColors[_random.nextInt(availableColors.length)];
      visibleCategories.add(_CategoryData(name: 'Others', amount: otherAmount)..color = otherColor);
    }

    final remainingColor = availableColors[_random.nextInt(availableColors.length)];
    visibleCategories.add(_CategoryData(name: 'Remaining', amount: remaining)..color = remainingColor);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;
    final chartSize = proportionalSizes.scaleWidth(140);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/overview');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(proportionalSizes.scaleWidth(16)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            proportionalSizes.scaleWidth(16),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // donut chart, it constantly changed colours but shssss
            SizedBox(
              width: chartSize,
              height: chartSize,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: chartSize * 0.35,
                  startDegreeOffset: -90,
                  sections: _buildPieSections(chartSize),
                ),
              ),
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
                  Divider(color: ColorPalette.primaryText.withValues(alpha: 0.5)),
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

  List<PieChartSectionData> _buildPieSections(double chartSize) {
    return visibleCategories.map((category) {
      return PieChartSectionData(
        color: category.color!,
        value: category.amount,
        title: '',
        radius: chartSize * 0.2,
      );
    }).toList();
  }

  List<Widget> _buildTopCategories(ProportionalSizes proportionalSizes) {
    return visibleCategories.map((category) {
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

  Widget _buildAmountRow(String label, double value, ProportionalSizes proportionalSizes) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: proportionalSizes.scaleHeight(2),
      ),
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
}

class _CategoryData {
  final String name;
  final double amount;
  Color? color;

  _CategoryData({required this.name, required this.amount});
}