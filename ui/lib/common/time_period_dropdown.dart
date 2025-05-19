import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import '../../../common/color_palette.dart';
import '../../../common/icon_maker.dart';

class TimePeriodDropdown extends StatefulWidget {
  final String selectedPeriod;
  final void Function(String?) onChanged;

  const TimePeriodDropdown({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  State<TimePeriodDropdown> createState() => _TimePeriodDropdownState();
}

class _TimePeriodDropdownState extends State<TimePeriodDropdown> {
  final GlobalKey _dropdownKey = GlobalKey();
  final List<String> options = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 60 Days',
    'Last 90 Days',
    'Last 120 Days',
    'Last 180 Days',
    'Last 365 Days',
    'From Start',
  ];

  void _showDropdownDialog() {
    final RenderBox box = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final proportionalSizes = ProportionalSizes(context: context);
    final labelColor = ColorPalette.primaryText;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy + size.height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  proportionalSizes.scaleWidth(8),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: proportionalSizes.scaleWidth(15),
                    sigmaY: proportionalSizes.scaleHeight(15),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      height: proportionalSizes.scaleHeight(280),
                      width: size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(30),
                        borderRadius: BorderRadius.circular(
                          proportionalSizes.scaleWidth(8),
                        ),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemExtent: proportionalSizes.scaleHeight(40),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final isSelected = option == widget.selectedPeriod;

                          return InkWell(
                            onTap: () {
                              widget.onChanged(option);
                              Navigator.pop(context);
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                horizontal: proportionalSizes.scaleWidth(16),
                              ),
                              color: isSelected
                                  ? labelColor.withAlpha(80)
                                  : Colors.transparent,
                              child: Text(
                                option,
                                style: GoogleFonts.roboto(
                                  color: labelColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: proportionalSizes.scaleText(16),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final labelColor = ColorPalette.primaryText;
    final hintColor = ColorPalette.secondaryText;
    final backgroundColor = ColorPalette.buttonText;

    return GestureDetector(
      key: _dropdownKey,
      onTap: _showDropdownDialog,
      child: Container(
        width: proportionalSizes.scaleWidth(180),
        padding: EdgeInsets.symmetric(
          vertical: proportionalSizes.scaleHeight(4),
          horizontal: proportionalSizes.scaleWidth(12),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              widget.selectedPeriod,
              style: GoogleFonts.roboto(
                color: widget.selectedPeriod.isEmpty ? hintColor : labelColor,
                fontSize: proportionalSizes.scaleText(16),
              ),
            ),
            SizedBox(width: proportionalSizes.scaleWidth(8)),
            IconMaker(assetPath: 'assets/icons/dropdown.png'),
          ],
        ),
      ),
    );
  }
}