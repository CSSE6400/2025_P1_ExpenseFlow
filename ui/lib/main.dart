// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/add_friends_to_group_screen/add_friends_to_group_screen.dart';
import 'package:flutter_frontend/screens/manage_groups_screen/manage_groups_screen.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:flutter_frontend/services/auth_service.dart' show AuthService;
import 'package:flutter_frontend/screens/overview_screen/overview_screen.dart';
import 'package:flutter_frontend/utils/config.dart' show Config;
import 'package:provider/provider.dart' show MultiProvider, Provider;
import 'package:logging/logging.dart' show Level, Logger;
// Screens
import '../../screens/initial_startup_screen/initial_startup_screen.dart';
import '../../screens/profile_setup_screen/profile_setup_screen.dart';
import '../../screens/profile_screen/profile_screen.dart';
import '../../screens/home_screen/home_screen.dart';
import '../../screens/add_expense_screen/add_expense_screen.dart';
import '../../screens/split_with_screen/split_with_screen.dart';
import '../../screens/add_items_screen/add_items_screen.dart';
import 'screens/expenses_screen/expenses_screen.dart';
import 'screens/see_expense_screen/see_expense_screen.dart';
import '../../screens/groups_and_friends_screen/groups_and_friends_screen.dart';
import '../../screens/ind_friend_expense_screen/ind_friend_expense_screen.dart';
import '../../screens/ind_group_expense_screen/ind_group_expense_screen.dart';
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
        switch (settings.name) {
          case '/initial_startup':
            return MaterialPageRoute(
              builder: (_) => const InitialStartupScreen(),
            );
          case '/profile_setup':
            return MaterialPageRoute(
              builder: (_) => const ProfileSetupScreen(),
            );
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/add_expense':
            return MaterialPageRoute(builder: (_) => const AddExpenseScreen());
          case '/expenses':
            return MaterialPageRoute(builder: (_) => const ExpensesScreen());
          case '/groups_and_friends':
            return MaterialPageRoute(
              builder: (_) => const GroupsAndFriendsScreen(),
            );
          case '/overview':
            return MaterialPageRoute(builder: (_) => const OverviewScreen());
          case '/manage_friends':
            return MaterialPageRoute(
              builder: (_) => const ManageFriendsScreen(),
            );
          case '/manage_groups':
            return MaterialPageRoute(
              builder: (_) => const ManageGroupsScreen(),
            );
          case '/select_friends':
            return MaterialPageRoute(builder: (_) => const AddFriendsScreen());
          case '/split_with':
            final args = settings.arguments as Map<String, dynamic>?;

            final transactionId = args?['transactionId'] as String?;
            final isReadOnly = args?['isReadOnly'] as bool? ?? false;
            // TODO: friends/ group to split with

            return MaterialPageRoute(
              builder:
                  (_) => SplitWithScreen(
                    transactionId: transactionId,
                    isReadOnly: isReadOnly,
                  ),
            );
          case '/add_items':
            final args = settings.arguments as Map<String, dynamic>?;

            final transactionId = args?['transactionId'] as String?;
            final isReadOnly = args?['isReadOnly'] as bool? ?? false;

            return MaterialPageRoute(
              builder:
                  (_) => AddItemsScreen(
                    amount: args?['amount'],
                    transactionId: transactionId,
                    isReadOnly: isReadOnly,
                  ),
            );
          case '/see_expenses':
            final args = settings.arguments as Map<String, dynamic>?;
            final transactionId = args?['transactionId'] as String?;
            if (transactionId == null) {
              return MaterialPageRoute(
                builder:
                    (_) => const Scaffold(
                      body: Center(
                        child: Text('Error: Missing transaction ID'),
                      ),
                    ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => SeeExpenseScreen(transactionId: transactionId),
            );
          case '/friend_expense':
            final args = settings.arguments as Map<String, dynamic>?;
            final username = args?['username'] as String?;

            if (username == null) {
              return MaterialPageRoute(
                builder:
                    (_) => const Scaffold(
                      body: Center(child: Text('Error: Missing username')),
                    ),
              );
            }

            return MaterialPageRoute(
              builder: (_) => IndFriendExpenseScreen(username: username),
            );
          case '/group_expense':
            final args = settings.arguments as Map<String, dynamic>?;
            final groupName = args?['groupName'] as String?;
            final groupUUID = args?['groupUUID'] as String?;

            if (groupName == null) {
              return MaterialPageRoute(
                builder:
                    (_) => const Scaffold(
                      body: Center(child: Text('Error: Missing group name')),
                    ),
              );
            }

            return MaterialPageRoute(
              builder:
                  (_) => IndGroupExpenseScreen(
                    groupName: groupName,
                    groupUUID: groupUUID!,
                  ),
            );
          default:
            final logger = Logger("MyApp");
            logger.warning("Unknown route: ${settings.name}");
            return MaterialPageRoute(
              builder:
                  (_) => const Scaffold(
                    body: Center(child: Text('404: Page not found')),
                  ),
            );
        }
      },
    );
  }
}
