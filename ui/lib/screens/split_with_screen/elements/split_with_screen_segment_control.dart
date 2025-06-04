import 'package:flutter/cupertino.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/utils/string_utils.dart' show titleCaseString;
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../../common/proportional_sizes.dart';

enum SplitWithSegment {
  friend,
  group;

  String get label => titleCaseString(name);
}

class SplitWithScreenSegmentControl extends StatelessWidget {
  final SplitWithSegment selectedSegment;
  final void Function(SplitWithSegment) onSegmentChanged;

  const SplitWithScreenSegmentControl({
    super.key,
    required this.selectedSegment,
    required this.onSegmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.background;
    final selectedColor = ColorPalette.buttonText;
    final selectedTextColor = ColorPalette.primaryText;
    final unselectedTextColor = ColorPalette.secondaryText;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: proportionalSizes.scaleWidth(0),
        vertical: proportionalSizes.scaleHeight(8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(height: 40),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              proportionalSizes.scaleWidth(10),
            ),
          ),
          child: CupertinoSlidingSegmentedControl<String>(
            groupValue: selectedSegment.label,
            thumbColor: selectedColor,
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.all(4),
            children: {
              'Friend': Center(
                child: Text(
                  'Friend',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color:
                        selectedSegment == SplitWithSegment.friend
                            ? selectedTextColor
                            : unselectedTextColor,
                  ),
                ),
              ),
              'Group': Center(
                child: Text(
                  'Group',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color:
                        selectedSegment == SplitWithSegment.group
                            ? selectedTextColor
                            : unselectedTextColor,
                  ),
                ),
              ),
            },
            onValueChanged: (String? value) {
              // convert string value back to ExpenseListSegment
              SplitWithSegment? valueSegment;
              if (value == 'Friend') {
                valueSegment = SplitWithSegment.friend;
              } else if (value == 'Group') {
                valueSegment = SplitWithSegment.group;
              }

              if (valueSegment != null) {
                onSegmentChanged(valueSegment);
              }
            },
          ),
        ),
      ),
    );
  }
}
