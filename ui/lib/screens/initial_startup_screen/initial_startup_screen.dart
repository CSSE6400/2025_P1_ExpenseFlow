// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/auth_service.dart' show AuthService;
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' show Provider;
// Common imports
import '../../common/color_palette.dart';
import '../../common/proportional_sizes.dart';
import '../../common/custom_button.dart';

class InitialStartupScreen extends StatefulWidget {
  /// Constructor for InitialStartupScreen
  const InitialStartupScreen({super.key});

  @override
  State<InitialStartupScreen> createState() => InitialStartupScreenState();
}

class InitialStartupScreenState extends State<InitialStartupScreen> {
  @override
  Widget build(BuildContext context) {
    // Colors and sizes
    final logoColor = ColorPalette.logoColor;
    final backgroundColor = ColorPalette.background;
    final proportionalSizes = ProportionalSizes(context: context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Centered Logo + App Name
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo/expenseflow_logo.png',
                        width: proportionalSizes.scaleWidth(60),
                        height: proportionalSizes.scaleHeight(60),
                        color: logoColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ExpenseFlow',
                        style: GoogleFonts.roboto(
                          fontSize: proportionalSizes.scaleText(24),
                          fontWeight: FontWeight.bold,
                          color: logoColor,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),

              // Log In Button at bottom
              CustomButton(
                label: 'Log In',
                onPressed: () async {
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );
                  await authService.login();
                },
                sizeType: ButtonSizeType.full,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
