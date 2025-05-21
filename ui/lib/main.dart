// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/utils/config.dart' show Config;
import 'package:provider/provider.dart' show Provider;
// Screens
import '../../screens/initial_startup_screen/initial_startup_screen.dart';
import '../../screens/profile_setup_screen/profile_setup_screen.dart';
import '../../screens/profile_screen/profile_screen.dart';
import '../../screens/home_screen/home_screen.dart';
import '../../screens/add_expense_screen/add_expense_screen.dart';
import '../../screens/split_with_screen/split_with_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await Config.load();
  //final config = Config(auth0ClientId: "abc", auth0Domain: "abc", backendBaseUrl: "abc");

  runApp(Provider<Config>.value(value: config, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<Config>(context, listen: false);

    return MaterialApp (
      // title: 'Expense Flow - ${config.backendBaseUrl}',
      title: 'Expense Flow}',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Force light mode

      initialRoute: '/initial_startup',

      routes: {
        '/initial_startup': (context) => const InitialStartupScreen(),
        '/profile_setup': (context) => const ProfileSetupScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_expense': (context) => const AddExpenseScreen(),
        '/split_with': (context) => const SplitWithScreen(),
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
