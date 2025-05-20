// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/auth_service.dart' show AuthService;
import 'package:flutter_frontend/utils/config.dart' show Config;
import 'package:provider/provider.dart' show MultiProvider, Provider;
// Screens
import '../../screens/initial_startup_screen/initial_startup_screen.dart';
import '../../screens/profile_setup_screen/profile_setup_screen.dart';
import '../../screens/home_screen/home_screen.dart';
import '../../screens/add_expense_screen/add_expense_screen.dart';
import '../../screens/split_with_screen/split_with_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = await Config.load();
  final authService = AuthService(config.auth0Domain, config.auth0ClientId);
  await authService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<Config>.value(value: config),
        Provider<AuthService>.value(value: authService),
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
      routes: {
        '/initial_startup': (context) => const InitialStartupScreen(),
        '/profile_setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_expense': (context) => const AddExpenseScreen(),
        '/split_with': (context) => const SplitWithScreen(),
      },
    );
  }
}
