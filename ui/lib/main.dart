// Flutter imports
import 'package:flutter/material.dart';
// Screens
import '../../screens/initial_startup_screen/initial_startup_screen.dart';
import '../../screens/profile_setup_screen/profile_setup_screen.dart';
import '../../screens/home_screen/home_screen.dart';
import '../../screens/add_expense_screen/add_expense_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Expense Flow',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Force light mode

      initialRoute: '/initial_startup',

      routes: {
        '/initial_startup': (context) => const InitialStartupScreen(),
        '/profile_setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_expense': (context) => const AddExpenseScreen(),
      },

      // TODO: Add login check and show appropriate screen
      // if (isLoggedIn) {
      //   return const HomeScreen();
      // } else {
      //   return const InitialStartupScreen();
      // }
    );
  }
}