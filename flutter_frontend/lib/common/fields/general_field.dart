import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../common/color_palette.dart';
import '../../../../../common/proportional_sizes.dart';

class GeneralField extends StatefulWidget {
  final String label;
  final String initialValue;
  final bool isDarkMode;

  /// Whether to show a check/cross icon
  final bool showStatusIcon;

  /// Rule to decide if input is valid
  final bool Function(String value)? validationRule;

  /// Whether field is editable
  final bool isEditable;

  const GeneralField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.isDarkMode,
    this.showStatusIcon = false,
    this.validationRule,
    this.isEditable = true,
  });

  @override
  State<GeneralField> createState() => _GeneralFieldState();
}

class _GeneralFieldState extends State<GeneralField> {
  late TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(); // No pre-filled value
    _updateValidation('');

    _controller.addListener(() {
      _updateValidation(_controller.text);
    });
  }

  void _updateValidation(String text) {
    if (widget.validationRule != null) {
      final isNowValid = widget.validationRule!(text.trim());
      if (isNowValid != _isValid) {
        setState(() {
          _isValid = isNowValid;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final iconColor = _isValid
        ? (widget.isDarkMode
            ? ColorPalette.primaryActionDark
            : ColorPalette.primaryAction)
        : ColorPalette.error;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: proportionalSizes.scaleHeight(10),
      ),
      child: Row(
        children: [
          // Label and TextField
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(14),
                    fontWeight: FontWeight.w500,
                    color: widget.isDarkMode
                        ? Colors.white.withOpacity(0.9)
                        : ColorPalette.backgroundDark,
                  ),
                ),
                SizedBox(height: proportionalSizes.scaleHeight(4)),
                TextField(
                  controller: _controller,
                  readOnly: !widget.isEditable,
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(17),
                    color: widget.isEditable
                        ? null
                        : Colors.grey[600],
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                    hintText: widget.initialValue,
                    hintStyle: GoogleFonts.roboto(
                      color: Colors.grey[500],
                      fontSize: proportionalSizes.scaleText(17),
                    ),
                  ),
                  cursorColor: Colors.blue,
                ),
              ],
            ),
          ),

          // Status Icon (check or cross)
          if (widget.showStatusIcon && widget.validationRule != null)
            Padding(
              padding: EdgeInsets.only(
                left: proportionalSizes.scaleWidth(8),
              ),
              child: Icon(
                _isValid ? Icons.check_circle : Icons.cancel,
                color: iconColor,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}