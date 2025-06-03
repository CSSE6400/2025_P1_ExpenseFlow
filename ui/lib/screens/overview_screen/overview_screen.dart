import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
import 'package:flutter_frontend/screens/overview_screen/elements/overview_screen_report_widget.dart';
import 'package:flutter_frontend/screens/overview_screen/elements/overview_screen_stat_widget.dart';
import 'package:flutter_frontend/screens/overview_screen/elements/overview_screen_amount_widget.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/types.dart'
    show CategoryData, assignRandomColors;
import 'package:provider/provider.dart';

import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
import '../../common/proportional_sizes.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  String selectedPeriod = 'Last 30 Days';
  ExpenseOverview? overview;
  UserRead? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final fetchedUser = await apiService.userApi.mustGetCurrentUser();
      final fetchedOverview = await apiService.expenseApi.getOverview();
      if (!mounted) return;

      setState(() {
        user = fetchedUser;
        overview = fetchedOverview;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, normalText: 'Failed to load overview data');
      setState(() => isLoading = false);
    }
  }

  void handleTimePeriodChange(String? newPeriod) {
    if (newPeriod != null) {
      setState(() {
        selectedPeriod = newPeriod;
      });
      // TODO: Refresh on time period change
    }
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final List<Color> availableColors = [
      Color(0xFF75E3EA),
      Color(0xFF4DC4D3),
      Color(0xFF3C74A6),
      Color(0xFF6C539F),
      Color(0xFF7B438D),
      Color(0xFFFD9BBA),
      Color(0xFFFFC785),
      Color(0xFF9FE6A0),
      Color(0xFFFFD6E0),
      Color(0xFFB7C0EE),
      Color(0xFFADC698),
      Color(0xFF71B3B7),
      Color(0xFFBCA9F5),
      Color(0xFFF5C3AF),
      Color(0xFF92E3A9),
      Color(0xFFDA9BCB),
      Color(0xFFFCB9AA),
      Color(0xFF84B6F4),
      Color(0xFFF9F871),
      Color(0xFFE0A9F5),
    ];

    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBarWidget(screenName: 'Overview', showBackButton: true),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: proportionalSizes.scaleWidth(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IgnorePointer(
                            child: TimePeriodDropdown(
                              selectedPeriod: selectedPeriod,
                              onChanged: handleTimePeriodChange,
                            ),
                          ),
                        ),
                        SizedBox(height: proportionalSizes.scaleHeight(20)),

                        OverviewScreenStatWidget(
                          categories: assignRandomColors(
                            overview!.categories
                                .map(
                                  (c) => CategoryData(
                                    name: c.category.name,
                                    amount: c.total.toDouble(),
                                  ),
                                )
                                .toList(),
                            availableColors,
                          ),
                        ),

                        SizedBox(height: proportionalSizes.scaleHeight(20)),

                        OverviewScreenAmountWidget(
                          monthlyBudget: user!.budget.toDouble(),
                          spent: overview!.total.toDouble(),
                          isLoading: isLoading,
                        ),

                        SizedBox(height: proportionalSizes.scaleHeight(20)),
                        const OverviewScreenReportWidget(),
                        SizedBox(height: proportionalSizes.scaleHeight(20)),
                      ],
                    ),
                  ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Overview',
        inactive: false,
      ),
    );
  }
}
