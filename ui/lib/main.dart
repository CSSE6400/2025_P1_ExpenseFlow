import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/screens/add_friends_to_group_screen/add_friends_to_group_screen.dart';
import 'package:flutter_frontend/screens/create_group_screen/create_group_screen.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:flutter_frontend/services/auth_guard.dart' show AuthGuardWidget;
import 'package:flutter_frontend/services/auth_guard_provider.dart'
    show AuthGuardProvider;
import 'package:flutter_frontend/services/auth_service.dart' show AuthService;
import 'package:flutter_frontend/screens/overview_screen/overview_screen.dart';
import 'package:flutter_frontend/utils/config.dart' show Config;
import 'package:provider/provider.dart'
    show ChangeNotifierProvider, MultiProvider, Provider;
import 'package:logging/logging.dart' show Level, Logger;
import '../../screens/initial_startup_screen/initial_startup_screen.dart';
import '../../screens/profile_setup_screen/profile_setup_screen.dart';
import '../../screens/profile_screen/profile_screen.dart';
import '../../screens/home_screen/home_screen.dart';
import '../../screens/add_expense_screen/add_expense_screen.dart';
import 'screens/expenses_screen/expenses_screen.dart';
import 'screens/see_expense_screen/see_expense_screen.dart';
import '../../screens/groups_and_friends_screen/groups_and_friends_screen.dart';
import 'screens/view_friend_screen/view_friend_screen.dart';
import 'screens/view_group_screen/view_group_screen.dart';
import '../../screens/manage_friends_screen/manage_friends_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });

  final logger = Logger("main");

  final config = await Config.load();
  final authService = AuthService(
    config.auth0Domain,
    config.auth0ClientId,
    config.jwtAudience,
  );
  await authService.init();

  final apiService = ApiService(
    authService.authenticatedClient,
    config.backendBaseUrl,
  );

  logger.info("Starting App");
  // create route observer for navigation events
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  runApp(
    MultiProvider(
      providers: [
        Provider<Config>.value(value: config),
        Provider<AuthService>.value(value: authService),
        Provider<ApiService>.value(value: apiService),
        Provider<RouteObserver<PageRoute>>.value(value: routeObserver),
        ChangeNotifierProvider<AuthGuardProvider>(
          create: (context) => AuthGuardProvider(authService, apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    final routeObserver = Provider.of<RouteObserver<PageRoute>>(
      context,
      listen: false,
    );

    return MaterialApp(
      title: 'Expense Flow',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      navigatorObservers: [routeObserver], // Add the route observer

      initialRoute: auth.isLoggedIn ? '/' : '/initial_startup',
      onGenerateRoute: (RouteSettings settings) {
        Widget screen;

        switch (settings.name) {
          case '/':
            screen = HomeScreen();
            break;
          case '/initial_startup':
            screen = InitialStartupScreen();
            break;
          case '/profile_setup':
            screen = ProfileSetupScreen();
            break;
          case '/profile':
            screen = ProfileScreen();
            break;
          case '/add_expense':
            screen = AddExpenseScreen();
            break;
          case '/expenses':
            screen = ExpensesScreen();
            break;
          case '/groups_and_friends':
            screen = GroupsAndFriendsScreen();
            break;
          case '/overview':
            screen = OverviewScreen();
            break;
          case '/manage_friends':
            screen = ManageFriendsScreen();
            break;
          case '/create_group':
            screen = CreateGroupScreen();
            break;
          case '/select_friends':
            screen = AddFriendsScreen();
            break;
          case '/see_expense':
            final args = settings.arguments as Map<String, dynamic>?;
            final expenseId = args?['expenseId'] as String?;
            if (expenseId == null) {
              return null;
            } else {
              screen = SeeExpenseScreen(expenseId: expenseId);
            }
            break;
          case '/view_friend':
            final args = settings.arguments as Map<String, dynamic>?;
            final userId = args?['userId'] as String?;

            if (userId == null) {
              return null;
            } else {
              screen = ViewFriendScreen(userId: userId);
            }
            break;

          case '/view_group':
            final args = settings.arguments as Map<String, dynamic>?;
            final groupId = args?['groupId'] as String?;

            if (groupId == null) {
              return null;
            } else {
              screen = ViewGroupScreen(groupId: groupId);
            }
            break;
          default:
            final logger = Logger("MyApp");
            logger.warning("Unknown route: ${settings.name}");
            return null;
        }

        return MaterialPageRoute(
          builder:
              (context) => AuthGuardWidget(builder: (context, user) => screen),
          settings: settings,
        );
      },
      onUnknownRoute: (RouteSettings settings) {
        final logger = Logger("MyApp");
        logger.warning("Unknown route (onUnknownRoute): ${settings.name}");
        return MaterialPageRoute(
          builder:
              (context) =>
                  AuthGuardWidget(builder: (context, user) => HomeScreen()),
          settings: settings,
        );
      },
    );
  }
}
