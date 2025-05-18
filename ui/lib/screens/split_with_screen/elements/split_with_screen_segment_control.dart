import 'package:flutter/cupertino.dart';
import 'package:flutter_frontend/common/color_palette.dart';
// Common
import '../../../common/proportional_sizes.dart';

class SplitWithScreenSegmentControl extends StatefulWidget {
  const SplitWithScreenSegmentControl({super.key});

  @override
  State<SplitWithScreenSegmentControl> createState() =>
      _SplitWithScreenSegmentControlState();
}

class _SplitWithScreenSegmentControlState
    extends State<SplitWithScreenSegmentControl> {
  String selectedSegment = 'Friend';

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
            groupValue: selectedSegment,
            thumbColor: selectedColor,
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.all(4),
            children: {
              'Friend': Center(
                child: Text(
                  'Friend',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selectedSegment == 'Friend'
                        ? selectedTextColor
                        : unselectedTextColor,
                  ),
                ),
              ),
              'Group': Center(
                child: Text(
                  'Group',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selectedSegment == 'Group'
                        ? selectedTextColor
                        : unselectedTextColor,
                  ),
                ),
              ),
            },
            onValueChanged: (String? value) {
              if (value != null) {
                setState(() {
                  selectedSegment = value;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}