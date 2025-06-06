import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'proportional_sizes.dart';
import 'color_palette.dart';

// helpful for common buttons
enum ButtonSizeType {
  full, // 363x50, fontSize 18
  half, // 220x40, fontSize 18
  quarter, // 90x30, fontSize 12
  custom,
}

enum ButtonState { enabled, disabled }

class CustomButton extends StatelessWidget {
  final String label;

  final VoidCallback onPressed;

  final Color? backgroundColor;

  final ButtonSizeType sizeType;

  final bool boundary;

  final ButtonState state;

  final double? customWidth;
  final double? customHeight;
  final double? customFontSize;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.sizeType = ButtonSizeType.custom,
    this.customWidth,
    this.customHeight,
    this.customFontSize,
    this.boundary = false,
    this.state = ButtonState.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    double width;
    double height;
    double fontSize;
    switch (sizeType) {
      case ButtonSizeType.full:
        width = proportionalSizes.scaleWidth(363);
        height = proportionalSizes.scaleHeight(50);
        fontSize = proportionalSizes.scaleText(18);
        break;
      case ButtonSizeType.half:
        width = proportionalSizes.scaleWidth(220);
        height = proportionalSizes.scaleHeight(40);
        fontSize = proportionalSizes.scaleText(18);
        break;
      case ButtonSizeType.quarter:
        width = proportionalSizes.scaleWidth(90);
        height = proportionalSizes.scaleHeight(30);
        fontSize = proportionalSizes.scaleText(12);
        break;
      case ButtonSizeType.custom:
        width = proportionalSizes.scaleWidth(customWidth ?? 220);
        height = proportionalSizes.scaleHeight(customHeight ?? 40);
        fontSize = proportionalSizes.scaleText(customFontSize ?? 18);
        break;
    }

    final bool isEnabled = state == ButtonState.enabled;

    final Color bgColor =
        isEnabled
            ? (backgroundColor ?? ColorPalette.primaryAction)
            : ColorPalette.secondaryAction;

    final Color textColor =
        isEnabled ? ColorPalette.buttonText : ColorPalette.secondaryText;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: boundary ? Colors.white : bgColor,
          side:
              boundary
                  ? BorderSide(
                    color: bgColor,
                    width: proportionalSizes.scaleWidth(2),
                  )
                  : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              proportionalSizes.scaleWidth(8),
            ),
          ),
        ),
        onPressed: isEnabled ? onPressed : null,
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: fontSize,
            color: boundary ? bgColor : textColor,
          ),
        ),
      ),
    );
  }
}
