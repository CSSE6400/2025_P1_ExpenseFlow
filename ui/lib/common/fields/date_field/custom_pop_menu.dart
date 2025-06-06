import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../proportional_sizes.dart';
import '../../color_palette.dart';

String monthName(int month) {
  const List<String> monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  return monthNames[month - 1];
}

class CustomPopupMenu<T> extends StatelessWidget {
  final T initialValue;

  final List<T> items;

  final String Function(T) itemBuilder;

  final ValueChanged<T> onSelected;

  const CustomPopupMenu({
    super.key,
    required this.initialValue,
    required this.items,
    required this.itemBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final primaryColor = ColorPalette.primaryText;
    final backgroundColor = ColorPalette.buttonText;

    return GestureDetector(
      child: Text(
        itemBuilder(initialValue),
        style: GoogleFonts.roboto(
          color: primaryColor,
          fontSize: proportionalSizes.scaleText(16),
        ),
      ),
      onTap: () {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final Offset position = button.localToGlobal(Offset.zero);

        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          builder: (BuildContext context) {
            // Finds the selected item's index to auto-scroll near it.
            final currentIndex = items.indexOf(initialValue);
            final scrollController = ScrollController(
              initialScrollOffset:
                  currentIndex * proportionalSizes.scaleHeight(40.0) -
                  proportionalSizes.scaleHeight(120.0),
            );

            return Stack(
              children: [
                Positioned(
                  left: position.dx - proportionalSizes.scaleWidth(20),
                  top: position.dy - proportionalSizes.scaleHeight(40),
                  child: GestureDetector(
                    onTap: () {}, // Prevents closing when tapped inside
                    child: Material(
                      elevation: proportionalSizes.scaleHeight(8),
                      borderRadius: BorderRadius.circular(
                        proportionalSizes.scaleWidth(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        height: proportionalSizes.scaleHeight(360),
                        width: proportionalSizes.scaleWidth(120),
                        color: backgroundColor,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: items.length,
                          itemExtent: proportionalSizes.scaleHeight(40),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isSelected = item == initialValue;

                            return InkWell(
                              onTap: () {
                                onSelected(item);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: proportionalSizes.scaleWidth(16),
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? primaryColor.withValues(alpha: 0.1)
                                          : Colors.transparent,
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  itemBuilder(item),
                                  style: GoogleFonts.roboto(
                                    color: primaryColor,
                                    fontWeight:
                                        isSelected
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
              ],
            );
          },
        );
      },
    );
  }
}
