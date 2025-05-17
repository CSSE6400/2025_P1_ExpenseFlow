// Flutter imports
import 'dart:ui';
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../proportional_sizes.dart';
import '../color_palette.dart';
import '../icon_maker.dart';
import '../dialogs/app_add_dialog_box.dart';

class DropdownField extends StatefulWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String?>? onChanged;
  final String? placeholder;
  final String addDialogHeading;
  final String addDialogHintText;
  final int addDialogMaxLength;
  final bool isEditable;

  const DropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.addDialogHeading,
    required this.addDialogHintText,
    required this.addDialogMaxLength,
    this.onChanged,
    this.placeholder,
    this.isEditable = true,
  });

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  String? selectedOption;
  late List<String> options;

  @override
  void initState() {
    super.initState();
    options = List<String>.from(widget.options);
  }

  void _showDropdownDialog(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);
    final proportionalSizes = ProportionalSizes(context: context);
    final labelColor = ColorPalette.primaryText;
    final hintColor = ColorPalette.secondaryText;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: position.dx + proportionalSizes.scaleWidth(95),
              top: position.dy - proportionalSizes.scaleHeight(20),
              child: GestureDetector(
                onTap: () {},
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
                        height: proportionalSizes.scaleHeight(200),
                        width: button.size.width -
                            proportionalSizes.scaleWidth(150),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 30),
                          borderRadius: BorderRadius.circular(
                            proportionalSizes.scaleWidth(8),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: options.length + 2, // +1 for placeholder, +1 for add new
                          itemExtent: proportionalSizes.scaleHeight(40),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Placeholder
                              return InkWell(
                                onTap: () {
                                  setState(() => selectedOption = null);
                                  widget.onChanged?.call(null);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        proportionalSizes.scaleWidth(16),
                                  ),
                                  child: Text(
                                    widget.placeholder ?? 'Select',
                                    style: GoogleFonts.roboto(
                                      color: hintColor,
                                      fontSize:
                                          proportionalSizes.scaleText(16),
                                    ),
                                  ),
                                ),
                              );
                            } else if (index == options.length + 1) {
                              // Add new category
                              return InkWell(
                                onTap: () async {
                                  final newCategory = await showAddCategoryDialog(
                                    context,
                                    heading: widget.addDialogHeading,
                                    hintText: widget.addDialogHintText,
                                    maxLength: widget.addDialogMaxLength,
                                  );
                                  if (newCategory != null &&
                                      newCategory.trim().isNotEmpty) {
                                    setState(() {
                                      options.add(newCategory);
                                      selectedOption = newCategory;
                                    });
                                    widget.onChanged?.call(newCategory);
                                    // TODO: Save new category to persistent store
                                  }
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: proportionalSizes.scaleWidth(16),
                                  ),
                                  child: Text(
                                    '+ Add New Category',
                                    style: GoogleFonts.roboto(
                                      color: ColorPalette.primaryAction,
                                      fontSize: proportionalSizes.scaleText(16),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final option = options[index - 1];
                            final isSelected = option == selectedOption;

                            return InkWell(
                              onTap: () {
                                setState(() => selectedOption = option);
                                widget.onChanged?.call(option);
                                Navigator.pop(context);
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      proportionalSizes.scaleWidth(16),
                                ),
                                color: isSelected
                                    ? labelColor.withValues(alpha: 80)
                                    : Colors.transparent,
                                child: Text(
                                  option,
                                  style: GoogleFonts.roboto(
                                    color: labelColor,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize:
                                        proportionalSizes.scaleText(16),
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

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: proportionalSizes.scaleHeight(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: proportionalSizes.scaleWidth(100),
            child: Text(
              widget.label,
              style: GoogleFonts.roboto(
                color: labelColor,
                fontSize: proportionalSizes.scaleText(18),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
          SizedBox(width: proportionalSizes.scaleWidth(8)),
          Expanded(
            child: GestureDetector(
              onTap: widget.isEditable ? () => _showDropdownDialog(context) : null,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: proportionalSizes.scaleHeight(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedOption ?? (widget.placeholder ?? 'Select'),
                      style: GoogleFonts.roboto(
                        color: selectedOption == null
                            ? hintColor
                            : labelColor,
                        fontSize: proportionalSizes.scaleText(18),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: proportionalSizes.scaleWidth(8),
                      ),
                      child: IconMaker(
                        assetPath: 'assets/icons/dropdown.png',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}