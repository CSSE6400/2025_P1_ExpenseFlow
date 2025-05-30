import 'package:flutter/cupertino.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../../common/proportional_sizes.dart';

class ManageGroupsSegmentControl extends StatefulWidget {
  final String selectedSegment;
  final void Function(String) onSegmentChanged;

  const ManageGroupsSegmentControl({
    super.key,
    required this.selectedSegment,
    required this.onSegmentChanged,
  });

  @override
  State<ManageGroupsSegmentControl> createState() =>
      _ManageGroupsSegmentControlState();
}

class _ManageGroupsSegmentControlState
    extends State<ManageGroupsSegmentControl> {
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
            groupValue: widget.selectedSegment,
            thumbColor: selectedColor,
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.all(4),
            children: {
              'Groups': Center(
                child: Text(
                  'Groups',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color: widget.selectedSegment == 'Groups'
                        ? selectedTextColor
                        : unselectedTextColor,
                  ),
                ),
              ),
              'Find': Center(
                child: Text(
                  'Find',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color: widget.selectedSegment == 'Find'
                        ? selectedTextColor
                        : unselectedTextColor,
                  ),
                ),
              ),
              'Create': Center(
                child: Text(
                  'Create',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color: widget.selectedSegment == 'Create'
                        ? selectedTextColor
                        : unselectedTextColor,
                  ),
                ),
              ),
            },
            onValueChanged: (String? value) {
              if (value != null) {
                widget.onSegmentChanged(value);
              }
            },
          ),
        ),
      ),
    );
  }
}