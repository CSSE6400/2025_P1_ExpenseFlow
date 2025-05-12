// Flutter imports
import 'package:flutter/material.dart';
// Screens
import '../../screens/initial_startup_screen/initial_startup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dark mode set to false.
    const bool isDarkMode = false;

    return MaterialApp(
      title: 'Expense Flow',
      debugShowCheckedModeBanner: false,

      home: const InitialStartupScreen(isDarkMode: isDarkMode,), // default screen

      // TODO: Add login check and show appropriate screen
      // if (isLoggedIn) {
      //   return const HomeScreen();
      // } else {
      //   return const InitialStartupScreen();
      // }
    );
  }
}