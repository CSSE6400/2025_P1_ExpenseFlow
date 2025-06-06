import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/color_palette.dart';
import '../../common/proportional_sizes.dart';
import '../../common/icon_maker.dart';

class CustomIconField extends StatelessWidget {
  final String label;

  final String value;

  final String hintText;

  final String? trailingIconPath;

  final VoidCallback? onTap;

  final bool isEnabled;

  final bool inactive;

  const CustomIconField({
    super.key,
    required this.label,
    required this.value,
    required this.hintText,
    this.trailingIconPath,
    this.onTap,
    this.isEnabled = true,
    this.inactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final showHint = value.trim().isEmpty;
    final valueColor =
        showHint ? ColorPalette.secondaryText : ColorPalette.primaryText;
    final labelColor =
        (inactive && showHint)
            ? ColorPalette.secondaryText
            : ColorPalette.primaryText;
    final iconColor =
        showHint ? ColorPalette.secondaryText : ColorPalette.primaryText;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: proportionalSizes.scaleHeight(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Label text
            SizedBox(
              width: proportionalSizes.scaleWidth(100),
              child: Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(18),
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            SizedBox(width: proportionalSizes.scaleWidth(10)),
            // Value or Hint text
            Expanded(
              child: Text(
                showHint ? hintText : value,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(18),
                  color: valueColor,
                ),
              ),
            ),
            // Optional trailing icon with its own tap
            if (trailingIconPath != null)
              Padding(
                padding: EdgeInsets.only(left: proportionalSizes.scaleWidth(8)),
                child: IconMaker(
                  assetPath: trailingIconPath!,
                  color: iconColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
