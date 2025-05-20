// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:flutter_frontend/services/auth_service.dart' show AuthService;
import 'package:flutter_frontend/utils/config.dart' show Config;
import 'package:provider/provider.dart' show MultiProvider, Provider;
import 'package:logging/logging.dart' show Logger;
// Screens
import '../../screens/initial_startup_screen/initial_startup_screen.dart';
import '../../screens/profile_setup_screen/profile_setup_screen.dart';
import '../../screens/home_screen/home_screen.dart';
import '../../screens/add_expense_screen/add_expense_screen.dart';
import '../../screens/split_with_screen/split_with_screen.dart';
import '../../screens/add_items_screen/add_items_screen.dart';
import 'screens/expenses_screen/expenses_screen.dart';
import 'screens/see_expense_screen/see_expense_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger("main");

  final config = await Config.load();
  final authService = AuthService(config.auth0Domain, config.auth0ClientId);
  await authService.init();

  final apiService = ApiService(
    authService.authenticatedClient,
    config.backendBaseUrl,
  );

  logger.info("Starting App");
  runApp(
    MultiProvider(
      providers: [
        Provider<Config>.value(value: config),
        Provider<AuthService>.value(value: authService),
        Provider<ApiService>.value(value: apiService),
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

    return MaterialApp(
      title: 'Expense Flow',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,

      initialRoute: auth.isLoggedIn ? '/home' : '/initial_startup',
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
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/add_expense':
            return MaterialPageRoute(builder: (_) => const AddExpenseScreen());
          case '/split_with':
            return MaterialPageRoute(builder: (_) => const SplitWithScreen());
          case '/expenses':
            return MaterialPageRoute(builder: (_) => const ExpensesScreen());
          case '/add_items':
            final args = settings.arguments as Map<String, dynamic>?;

            return MaterialPageRoute(
              builder: (_) => AddItemsScreen(amount: args?['amount']),
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
