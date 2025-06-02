// Flutter imports
import 'package:flutter/material.dart';
import 'package:logging/logging.dart' show Logger;
// Common imports
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/services/auth_service.dart';
import 'package:flutter_frontend/services/api_service.dart';
import '../home_screen/elements/home_screen_main_body.dart';
import '../home_screen/elements/home_screen_app_bar.dart';
import '../home_screen/elements/home_screen_overview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  bool _checkedUser = false;
  final Logger _logger = Logger("Home_Screen");
  final GlobalKey<HomeScreenMainBodyState> _mainBodyKey =
      GlobalKey<HomeScreenMainBodyState>();
  RouteObserver<PageRoute>? _routeObserver;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  void didPush() {
    _refreshData();
  }

  @override
  void didPopNext() {
    _refreshData();
  }

  void _refreshData() {
    if (_mainBodyKey.currentState != null) {
      // refreshOverview method
      final mainBodyState = _mainBodyKey.currentState;
      if (mainBodyState != null) {
        final overviewState = mainBodyState.getOverviewState();
        if (overviewState != null) {
          overviewState.refreshData();
        }
      }
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

    if (!_checkedUser) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: HomeScreenAppBarWidget(),
      body: HomeScreenMainBody(key: _mainBodyKey),
      bottomNavigationBar: BottomNavBar(currentScreen: 'Home', inactive: false),
    );
  }
}
