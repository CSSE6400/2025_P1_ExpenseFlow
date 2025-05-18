// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/proportional_sizes.dart';
import '../../common/icon_maker.dart';

/// A reusable row field with an optional trailing icon and value or hint.
/// Typically used for navigation or visual indication, not input.
class CustomIconField extends StatelessWidget {
  /// Text label shown on the left side
  final String label;

  /// Text value shown on the right side
  final String value;

  /// Placeholder shown if value is empty
  final String hintText;

  /// Optional trailing icon path
  final String? trailingIconPath;

  /// Optional tap action (e.g., navigate to another screen)
  final VoidCallback? onTap;

  /// Whether field is editable
  final bool isEnabled;

  /// If true, dims the label (typically for inactive fields)
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
    final hintColor = ColorPalette.secondaryText;
    final labelColor = inactive ? hintColor : ColorPalette.primaryText;
    final showHint = value.trim().isEmpty;

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
                  color: showHint ? hintColor : labelColor,
                ),
              ),
            ),
            // Optional trailing icon with its own tap
            if (trailingIconPath != null)
              Padding(
                padding: EdgeInsets.only(
                  left: proportionalSizes.scaleWidth(8),
                ),
                child: IconMaker(
                  assetPath: trailingIconPath!,
                  color: inactive ? hintColor : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}