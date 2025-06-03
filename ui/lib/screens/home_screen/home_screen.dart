import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart' show showCustomSnackBar;
import 'package:flutter_frontend/models/expense.dart' show ExpenseOverview;
import 'package:flutter_frontend/models/user.dart' show UserRead;
import 'package:flutter_frontend/types.dart'
    show CategoryData, Expense, assignRandomColors;
import 'package:logging/logging.dart' show Logger;
// Common imports
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/services/auth_service.dart';
import 'package:flutter_frontend/services/api_service.dart';
import '../home_screen/elements/home_screen_overview.dart';
import '../home_screen/elements/home_screen_add_an_expense.dart';
import '../home_screen/elements/home_screen_recent_expenses.dart';
import '../home_screen/elements/home_screen_app_bar.dart';
import '../../../common/proportional_sizes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with RouteAware, WidgetsBindingObserver {
  final Logger _logger = Logger("Home_Screen");
  RouteObserver<PageRoute>? _routeObserver;
  bool _checkedUser = false;

  bool isOverviewLoading = true;
  ExpenseOverview? overview;
  UserRead? user;

  bool isRecentExpensesLoading = true;
  List<Expense> recentExpenses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // check auth before loading data
    _checkAuth();

    // get singleton route observer
    _routeObserver = Provider.of<RouteObserver<PageRoute>>(
      context,
      listen: false,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver?.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPush() => _refreshOverview();
  @override
  void didPopNext() => _refreshOverview();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshOverview();
    }
  }

  void _refreshOverview() {
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    setState(() {
      isOverviewLoading = true;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final fetchedUser = await apiService.userApi.mustGetCurrentUser();
      final fetchedOverview = await apiService.expenseApi.getOverview();
      if (!mounted) return;
      setState(() {
        user = fetchedUser;
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
    setState(() {
      isRecentExpensesLoading = true;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.expenseApi.getExpensesUploadedByMe();

      final loadedExpenses =
          userReads.map((expense) {
            return Expense(
              name: expense.name,
              price: expense.expenseTotal.toString(),
              expenseId: expense.expenseId,
            );
          }).toList();

      setState(() {
        recentExpenses = loadedExpenses;
        isRecentExpensesLoading = false;
      });

      _logger.info("number of recent expenses: ${recentExpenses.length}");
    } catch (e) {
      _logger.warning("Failed to get recent expenses: $e");
      setState(() {
        isRecentExpensesLoading = false;
      });
    }
  }

  Future<void> _checkAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/initial_startup');
      });
      return;
    }
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final user = await apiService.userApi.getCurrentUser();
      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/profile_setup');
        });
        return;
      }
      setState(() {
        _checkedUser = true;
      });

      _loadRecentExpenses();
      _loadOverview();
    } catch (e) {
      _logger.warning(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/initial_startup');
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

    if (!_checkedUser) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: HomeScreenAppBarWidget(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: proportionalSizes.scaleWidth(20),
              vertical: proportionalSizes.scaleHeight(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isOverviewLoading &&
                    overview != null &&
                    overview!.categories.isNotEmpty) ...[
                  HomeScreenOverview(
                    isLoading: false,
                    monthlyBudget: user?.budget.toDouble() ?? 0.0,
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
                    spent: overview!.total.toDouble(),
                  ),
                  SizedBox(height: proportionalSizes.scaleHeight(20)),
                ],
                SizedBox(height: proportionalSizes.scaleHeight(20)),
                HomeScreenAddAnExpense(),
                SizedBox(height: proportionalSizes.scaleHeight(20)),
                HomeScreenRecentExpenses(
                  recentExpenses: recentExpenses,
                  isLoading: isRecentExpensesLoading,
                  onTap: () => Navigator.pushNamed(context, '/expenses'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentScreen: 'Home', inactive: false),
    );
  }
}
