// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/utils/config.dart' show Config;
import 'package:provider/provider.dart' show Provider;
// Screens
import '../../screens/initial_startup_screen/initial_startup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await Config.load();

  runApp(Provider<Config>.value(value: config, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dark mode set to false.
    const bool isDarkMode = false;
    final config = Provider.of<Config>(context, listen: false);

    return MaterialApp(
      // title: 'Expense Flow - ${config.backendBaseUrl}',
      title: 'Expense Flow}',
      debugShowCheckedModeBanner: false,

      home: const InitialStartupScreen(
        isDarkMode: isDarkMode,
      ), // default screen
      // TODO: Add login check and show appropriate screen
      // if (isLoggedIn) {
      //   return const HomeScreen();
      // } else {
      //   return const InitialStartupScreen();
      // }
    );
  }
}
