import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/user.dart' show UserRead;
import 'package:flutter_frontend/screens/initial_startup_screen/initial_startup_screen.dart'
    show InitialStartupScreen;
import 'package:flutter_frontend/screens/profile_setup_screen/profile_setup_screen.dart'
    show ProfileSetupScreen;
import 'package:flutter_frontend/services/auth_service.dart' show AuthService;
import 'package:provider/provider.dart';
import 'auth_guard_provider.dart';

class AuthGuardWidget extends StatelessWidget {
  final Widget Function(BuildContext context, UserRead user) builder;

  const AuthGuardWidget({required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    final authGuard = context.watch<AuthGuardProvider>();
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authGuard.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authService.isLoggedIn) {
      // redirect or show startup screen
      return const InitialStartupScreen();
    }

    if (authGuard.user == null) {
      // Show setup screen if no user
      return const ProfileSetupScreen();
    }

    // user is loaded
    return builder(context, authGuard.user!);
  }
}
