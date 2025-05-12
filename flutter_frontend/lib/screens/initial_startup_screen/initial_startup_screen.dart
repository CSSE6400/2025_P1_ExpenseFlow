import 'dart:async';
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../common/color_palette.dart';
import '../../common/proportional_sizes.dart';

class InitialStartupScreen extends StatefulWidget {
  final bool isDarkMode;

  const InitialStartupScreen({super.key, required this.isDarkMode});

  @override
  State<InitialStartupScreen> createState() => InitialStartupScreenState();
}

class InitialStartupScreenState extends State<InitialStartupScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      // TODO: Uncomment the following line to navigate to the next screen. Specify the screen you want to navigate to.
      // Navigate to the next screen after a delay
      /* Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const <Screen Name>), // Replace with your screen
      ); */
    });
  }

  @override
  Widget build(BuildContext context) {
    final logoColor = ColorPalette.logoColor;
    final backgroundColor = widget.isDarkMode
        ? ColorPalette.backgroundDark
        : ColorPalette.background;
    final proportionalSizes = ProportionalSizes(context: context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/expenseflow_logo.png',
              width: proportionalSizes.scaleWidth(60),
              height: proportionalSizes.scaleHeight(60),
              color: logoColor,
            ),
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
    );
  }
}