import 'package:flutter/material.dart';
import 'package:expenseflow/common/snack_bar.dart' show showCustomSnackBar;
import 'package:expenseflow/models/expense.dart'
    show ExpenseOverview, ExpenseRead;
import 'package:expenseflow/models/user.dart' show UserRead;
import 'package:expenseflow/services/auth_guard_provider.dart'
    show AuthGuardProvider;
import 'package:expenseflow/types.dart' show CategoryData;
import 'package:logging/logging.dart' show Logger;
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:expenseflow/services/api_service.dart';
import '../home_screen/elements/home_screen_overview.dart';
import '../home_screen/elements/home_screen_add_an_expense.dart';
import '../home_screen/elements/home_screen_recent_expenses.dart';
import '../home_screen/elements/home_screen_app_bar.dart';
import '../../../common/proportional_sizes.dart';

List<CategoryData> assignColorsInOrder(
  List<CategoryData> categories,
  List<Color> colors,
) {
  for (int i = 0; i < categories.length; i++) {
    categories[i].color = colors[i % colors.length];
  }
  return categories;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger _logger = Logger("Home_Screen");

  bool isOverviewLoading = true;
  ExpenseOverview? overview;
  UserRead? user;

  bool isRecentExpensesLoading = true;
  List<ExpenseRead> expenses = [];

  @override
  void initState() {
    final authGuard = Provider.of<AuthGuardProvider>(context, listen: false);
    user = authGuard.mustGetUser(context);

    super.initState();
    _loadRecentExpenses();
    _loadOverview();
  }

  Future<void> _refreshData() async {
    _loadOverview();
    _loadRecentExpenses();
  }

  Future<void> _loadOverview() async {
    setState(() {
      isOverviewLoading = true;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final fetchedOverview = await apiService.expenseApi.getOverview();
      if (!mounted) return;

      setState(() {
        overview = fetchedOverview;
        isOverviewLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, normalText: 'Failed to load overview data');
      setState(() => isOverviewLoading = false);
    }
  }

  Future<void> _loadRecentExpenses() async {
    if (!mounted) return;
    setState(() {
      isRecentExpensesLoading = true;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final loadedExpenses =
          await apiService.expenseApi.getExpensesUploadedByMe();

      if (!mounted) return;

      setState(() {
        expenses = loadedExpenses;
        isRecentExpensesLoading = false;
      });

      _logger.info("number of expenses: ${expenses.length}");
    } catch (e) {
      if (!mounted) return;
      _logger.warning("Failed to get recent expenses: $e");
      setState(() {
        isRecentExpensesLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;
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
      backgroundColor: backgroundColor,
      appBar: HomeScreenAppBarWidget(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: proportionalSizes.scaleWidth(20),
                vertical: proportionalSizes.scaleHeight(20),
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (!isOverviewLoading &&
                    overview != null &&
                    overview!.categories.isNotEmpty) ...[
                  HomeScreenOverview(
                    isLoading: false,
                    monthlyBudget: user?.budget.toDouble() ?? 0.0,
                    categories: assignColorsInOrder(
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
                    spent: overview!.total.toDouble(),
                  ),
                  SizedBox(height: proportionalSizes.scaleHeight(20)),
                ],
                SizedBox(height: proportionalSizes.scaleHeight(20)),
                HomeScreenAddAnExpense(),
                SizedBox(height: proportionalSizes.scaleHeight(20)),
                HomeScreenRecentExpenses(
                  expenses: expenses.take(3).toList(),
                  isLoading: isRecentExpensesLoading,
                  onTap: () => Navigator.pushNamed(context, '/expenses'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentScreen: BottomNavBarScreen.home,
        inactive: false,
      ),
    );
  }
}
