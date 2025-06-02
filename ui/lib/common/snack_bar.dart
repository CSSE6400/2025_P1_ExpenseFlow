// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common imports
import 'color_palette.dart';

/// Shows a customizable snackbar with optional bold and normal text,
/// and a type (success or failed) that sets the background color.
enum SnackBarType { success, failed }

void showCustomSnackBar(
  BuildContext context, {
  required String normalText, // Required normal part
  SnackBarType type = SnackBarType.failed,
  String? boldText, // Optional bold part
  Color? textColor,
}) {
  final bgColor =
      type == SnackBarType.success ? Colors.green : ColorPalette.error;
  final fgColor = textColor ?? ColorPalette.buttonText;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: bgColor,
      content: RichText(
        text: TextSpan(
          style: GoogleFonts.roboto(fontSize: 14, color: fgColor),
          children: [
            if (boldText != null)
              TextSpan(
                text: '$boldText ',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                  fontSize: 14,
                ),
              ),
            TextSpan(text: normalText),
          ],
        ),
      ),
    ),
  );
}
