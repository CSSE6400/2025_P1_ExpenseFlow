import 'package:flutter/cupertino.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/utils/string_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/proportional_sizes.dart';

enum ExpenseListSegment {
  unpaid,
  all;

  String get label => titleCaseString(name);
}

class ExpenseListSegmentControl extends StatelessWidget {
  final ExpenseListSegment selectedSegment;
  final void Function(ExpenseListSegment) onSegmentChanged;

  const ExpenseListSegmentControl({
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
              'Unpaid': Center(
                child: Text(
                  'Unpaid',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color:
                        selectedSegment == ExpenseListSegment.unpaid
                            ? selectedTextColor
                            : unselectedTextColor,
                  ),
                ),
              ),
              'All': Center(
                child: Text(
                  'All',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color:
                        selectedSegment == ExpenseListSegment.all
                            ? selectedTextColor
                            : unselectedTextColor,
                  ),
                ),
              ),
            },
            onValueChanged: (String? value) {
              // convert string value back to ExpenseListSegment
              ExpenseListSegment? valueSegment;
              if (value == 'Unpaid') {
                valueSegment = ExpenseListSegment.unpaid;
              } else if (value == 'All') {
                valueSegment = ExpenseListSegment.all;
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
