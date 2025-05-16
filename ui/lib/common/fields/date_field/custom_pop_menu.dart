import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Common Files
import '../../proportional_sizes.dart';
import '../../color_palette.dart';

/// Returns the full English month name (e.g., "January") from its 1-based index.
String monthName(int month) {
  const List<String> monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  return monthNames[month - 1];
}

/// A custom popup menu widget for displaying a scrollable list of items,
/// from which the user can make a single selection.
///
/// Features:
/// - Highlights the currently selected item.
/// - Supports dark mode styling.
/// - Displays items in a compact dialog that appears at the widget's position.
class CustomPopupMenu<T> extends StatelessWidget {
  /// The current selection in the menu.
  final T initialValue;

  /// The list of items to be displayed and selectable.
  final List<T> items;

  /// A function that converts an item to its string representation for display.
  final String Function(T) itemBuilder;

  /// Callback for when a user selects an item.
  final ValueChanged<T> onSelected;

  /// Whether to apply dark mode styling.
  final bool isDarkMode;

  const CustomPopupMenu({
    super.key,
    required this.initialValue,
    required this.items,
    required this.itemBuilder,
    required this.onSelected,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
      final primaryColor = isDarkMode
        ? ColorPalette.primaryTextDark
        : ColorPalette.primaryText;
  final backgroundColor = isDarkMode
        ? ColorPalette.buttonTextDark
        : ColorPalette.buttonText;

    return GestureDetector(
      // Displays the text for the currently selected item.
      child: Text(
        itemBuilder(initialValue),
        style: GoogleFonts.roboto(
          color: primaryColor,
          fontSize: proportionalSizes.scaleText(16),
        ),
      ),
      onTap: () {
        // Position the menu near the tapped widget.
        final RenderBox button = context.findRenderObject() as RenderBox;
        final Offset position = button.localToGlobal(Offset.zero);

        // Show a dialog-based dropdown at the computed position.
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          builder: (BuildContext context) {
            // Finds the selected item's index to auto-scroll near it.
            final currentIndex = items.indexOf(initialValue);
            final scrollController = ScrollController(
              initialScrollOffset:
                  currentIndex * proportionalSizes.scaleHeight(40.0)
                  - proportionalSizes.scaleHeight(120.0),
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
                      borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(8)),
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
                                  color: isSelected
                                      ? primaryColor.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  itemBuilder(item),
                                  style: GoogleFonts.roboto(
                                    color: primaryColor,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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