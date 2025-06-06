import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_palette.dart';

enum SnackBarType { success, failed }

void showCustomSnackBar(
  BuildContext context, {
  required String normalText,
  SnackBarType type = SnackBarType.failed,
  String? boldText,
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
