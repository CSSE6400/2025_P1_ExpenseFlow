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

    return MaterialApp(
      title: 'Expense Flow',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Force light mode

      home: const InitialStartupScreen(), // default screen

      // TODO: Add login check and show appropriate screen
      // if (isLoggedIn) {
      //   return const HomeScreen();
      // } else {
      //   return const InitialStartupScreen();
      // }
    );
  }
}