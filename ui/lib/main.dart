// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/utils/config.dart' show Config;
import 'package:provider/provider.dart' show Provider;
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
  final config = await Config.load();

  runApp(Provider<Config>.value(value: config, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<Config>(context, listen: false);

    return MaterialApp(
      // title: 'Expense Flow - ${config.backendBaseUrl}',
      title: 'Expense Flow}',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Force light mode

      initialRoute: '/initial_startup',

      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/initial_startup':
            return MaterialPageRoute(builder: (_) => const InitialStartupScreen());
          case '/profile_setup':
            return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
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
              builder: (_) => AddItemsScreen(
                amount: args?['amount'],
              ),
            );
          case '/see_expenses':
            final args = settings.arguments as Map<String, dynamic>?;
            final transactionId = args?['transactionId'] as String?;
            if (transactionId == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Error: Missing transaction ID')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => SeeExpenseScreen(transactionId: transactionId),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('404: Page not found')),
              ),
            );
        }
      },

      // TODO: Add login check and show appropriate screen. Use "isLoggedIn" method to determine if the user is logged in or not.
      // if (isLoggedIn) {
      //   return const HomeScreen();
      // } else {
      //   return const InitialStartupScreen();
      // }
    );
  }
}
