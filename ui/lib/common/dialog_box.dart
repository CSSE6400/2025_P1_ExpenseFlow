// Flutter imports
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Common
import 'proportional_sizes.dart';
import 'custom_button.dart';

/// A reusable dialog box that supports 1 or 2 buttons with custom text, styling, and behavior.
class AppDialogBox extends StatelessWidget {
  final String heading;
  final String description;
  final int buttonCount; // Accepts 1 or 2
  final String button1Text;
  final VoidCallback onButton1Pressed;
  final String? button2Text;
  final VoidCallback? onButton2Pressed;
  final Color? button1Color;
  final Color? button2Color;

  const AppDialogBox({
    super.key,
    required this.heading,
    required this.description,
    required this.buttonCount,
    required this.button1Text,
    required this.onButton1Pressed,
    this.button2Text,
    this.onButton2Pressed,
    this.button1Color,
    this.button2Color,
  }) : assert(buttonCount == 1 || buttonCount == 2);

  @override
  Widget build(BuildContext context) {
    final scaler = ProportionalSizes(context: context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(scaler.scaleWidth(20)),
      ),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(scaler.scaleWidth(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: scaler.scaleWidth(15.0),
            sigmaY: scaler.scaleWidth(15.0),
          ),
          child: Container(
            padding: EdgeInsets.all(scaler.scaleWidth(20)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(scaler.scaleWidth(20)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  heading,
                  style: GoogleFonts.roboto(
                    fontSize: scaler.scaleText(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: scaler.scaleHeight(12)),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: scaler.scaleText(15),
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: scaler.scaleHeight(20)),
                if (buttonCount == 1)
                  CustomButton(
                    label: button1Text,
                    onPressed: onButton1Pressed,
                    backgroundColor: button1Color,
                    sizeType: ButtonSizeType.quarter,
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        label: button1Text,
                        onPressed: onButton1Pressed,
                        backgroundColor: button1Color,
                        sizeType: ButtonSizeType.quarter,
                      ),
                      CustomButton(
                        label: button2Text ?? '',
                        onPressed: onButton2Pressed ?? () {},
                        backgroundColor: button2Color,
                        sizeType: ButtonSizeType.quarter,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Call this method to show the dialog
  static Future<void> show(
    BuildContext context, {
    required String heading,
    required String description,
    required int buttonCount,
    required String button1Text,
    required VoidCallback onButton1Pressed,
    String? button2Text,
    VoidCallback? onButton2Pressed,
    Color? button1Color,
    Color? button2Color,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (_) => AppDialogBox(
        heading: heading,
        description: description,
        buttonCount: buttonCount,
        button1Text: button1Text,
        onButton1Pressed: onButton1Pressed,
        button2Text: button2Text,
        onButton2Pressed: onButton2Pressed,
        button1Color: button1Color,
        button2Color: button2Color,
      ),
    );
  }
}