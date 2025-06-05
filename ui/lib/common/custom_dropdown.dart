import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/color_palette.dart';
import '../../../common/icon_maker.dart';

class CustomDropdown<T> extends StatefulWidget {
  final T selected;
  final List<T> options;
  final void Function(T) onChanged;
  final String Function(T) labelBuilder;
  final double? width;

  const CustomDropdown({
    super.key,
    required this.selected,
    required this.options,
    required this.onChanged,
    required this.labelBuilder,
    this.width,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final GlobalKey _dropdownKey = GlobalKey();

  void _showDropdownDialog() {
    final box = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final ps = ProportionalSizes(context: context);
    final labelColor = ColorPalette.primaryText;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) {
        return Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy + size.height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ps.scaleWidth(8)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: ps.scaleWidth(15),
                    sigmaY: ps.scaleHeight(15),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      height: ps.scaleHeight(280),
                      width: size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(30),
                        borderRadius: BorderRadius.circular(ps.scaleWidth(8)),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemExtent: ps.scaleHeight(40),
                        itemCount: widget.options.length,
                        itemBuilder: (context, index) {
                          final option = widget.options[index];
                          final isSelected = option == widget.selected;
                          return InkWell(
                            onTap: () {
                              widget.onChanged(option);
                              Navigator.pop(context);
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(
                                horizontal: ps.scaleWidth(16),
                              ),
                              color:
                                  isSelected
                                      ? labelColor.withAlpha(80)
                                      : Colors.transparent,
                              child: Text(
                                widget.labelBuilder(option),
                                style: GoogleFonts.roboto(
                                  color: labelColor,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  fontSize: ps.scaleText(16),
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
    final ps = ProportionalSizes(context: context);
    final labelColor = ColorPalette.primaryText;
    final hintColor = ColorPalette.secondaryText;
    final backgroundColor = ColorPalette.buttonText;

    return GestureDetector(
      key: _dropdownKey,
      onTap: _showDropdownDialog,
      child: Container(
        width: widget.width ?? ps.scaleWidth(180),
        padding: EdgeInsets.symmetric(
          vertical: ps.scaleHeight(4),
          horizontal: ps.scaleWidth(12),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(ps.scaleWidth(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                widget.labelBuilder(widget.selected),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  color:
                      widget.selected.toString().isEmpty
                          ? hintColor
                          : labelColor,
                  fontSize: ps.scaleText(16),
                ),
              ),
            ),
            SizedBox(width: ps.scaleWidth(8)),
            IconMaker(assetPath: 'assets/icons/dropdown.png'),
          ],
        ),
      ),
    );
  }
}
