// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../../../../common/color_palette.dart';
import '../../../../../common/proportional_sizes.dart';

// Custom field for user input.
/// This widget is used to create a general input field with validation
/// and optional status icons. It is designed to be reusable across different screens.
class GeneralField extends StatefulWidget {
  /// Label for the input field
  final String label;

  /// Initial value for the input field
  final String initialValue;

  /// Dark mode toggle passed from screen
  final bool isDarkMode;

  /// Whether to show a check/cross icon
  final bool showStatusIcon;

  /// Rule to decide if input is valid
  final bool Function(String value)? validationRule;

  /// Whether field is editable
  final bool isEditable;

  /// Callback to inform parent when validity changes
  final void Function(bool isValid)? onValidityChanged;

  const GeneralField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.isDarkMode,
    this.showStatusIcon = false,
    this.validationRule,
    this.isEditable = true,
    this.onValidityChanged,
  });

  @override
  State<GeneralField> createState() => GeneralFieldState();
}

class GeneralFieldState extends State<GeneralField> {
  late TextEditingController _controller;
  bool _isValid = false;

  /// Initializes the TextEditingController and sets up a listener to update validation
  /// status based on the input text.
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(); // Leave empty, use hintText only
    _updateValidation('');
    _controller.addListener(() {
      _updateValidation(_controller.text);
    });
  }

  /// Updates the validation status based on the current text in the field.
  /// If the validation rule is provided, it checks if the trimmed text is valid.
  /// If the validity changes, it updates the state and calls the callback if provided.
  /// This method is called whenever the text in the field changes.
  /// It also trims the text to remove leading and trailing spaces.
  void _updateValidation(String text) {
    final trimmed = text.trim();
    if (widget.validationRule != null) {
      final isNowValid = widget.validationRule!(trimmed);
      if (isNowValid != _isValid) {
        setState(() {
          _isValid = isNowValid;
        });
        if (widget.onValidityChanged != null) {
          widget.onValidityChanged!(isNowValid);
        }
      }
    }
  }

  /// Disposes the TextEditingController when the widget is removed from the widget tree.
  /// This is important to free up resources and avoid memory leaks.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns input formatter based on the field's label
  List<TextInputFormatter>? _getInputFormatters() {
    final labelLower = widget.label.toLowerCase();

    if (labelLower.contains('username')) {
      return [FilteringTextInputFormatter.deny(RegExp(r'\s'))]; // disallow spaces
    } else if (labelLower.contains('budget')) {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // allow decimals
      ];
    }
    return null; // no restrictions
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final labelColor = widget.isDarkMode
        ? ColorPalette.primaryTextDark
        : ColorPalette.primaryText;
    final hintColor = widget.isDarkMode
        ? ColorPalette.secondaryTextDark
        : ColorPalette.secondaryText;
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  widget.label,
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(17),
                    fontWeight: FontWeight.w500,
                    color: labelColor
                  ),
                ),
                SizedBox(height: proportionalSizes.scaleHeight(4)),
                // Input field
                TextField(
                  controller: _controller,
                  readOnly: !widget.isEditable,
                  inputFormatters: _getInputFormatters(),
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(17),
                    color: labelColor,
                  ),
                  // Hint Text
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                    hintText: widget.initialValue,
                    hintStyle: GoogleFonts.roboto(
                      color: hintColor,
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
                size: proportionalSizes.scaleWidth(24),
              ),
            ),
        ],
      ),
    );
  }
}