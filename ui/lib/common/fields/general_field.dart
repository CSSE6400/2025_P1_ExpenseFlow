// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/proportional_sizes.dart';
import '../../common/icon_maker.dart';
import '../../common/snack_bar.dart';

enum InputRuleType {
  noSpaces,
  numericOnly,
  decimalWithTwoPlaces,
  lettersOnly,
}

/// Custom field for user input.
/// This widget is used to create a general input field with validation
/// and optional status icons. It is designed to be reusable across different screens.
class GeneralField extends StatefulWidget {
  /// Label for the input field
  final String label;

  /// Initial value for the input field
  final String initialValue;

  /// Whether to show a check/cross icon
  final bool showStatusIcon;

  /// Function to validate the input
  final List<InputRuleType>? inputRules;

  /// Rule to decide if input is valid
  final bool Function(String value)? validationRule;

  /// Whether field is editable
  final bool isEditable;

  /// Callback to inform parent when validity changes
  final void Function(bool isValid)? onValidityChanged;

  /// Constructor for the GeneralField widget.
  final ValueChanged<String>? onChanged;

  /// Maximum length of the input
  final int? maxLength;

  /// Focus instruction for the field
  final String? focusInstruction;

  const GeneralField({
    super.key,
    required this.label,
    required this.initialValue,
    this.showStatusIcon = false,
    this.validationRule,
    this.isEditable = true,
    this.inputRules,
    this.onValidityChanged,
    this.onChanged,
    this.maxLength,
    this.focusInstruction,
  });

  @override
  State<GeneralField> createState() => GeneralFieldState();
}

class GeneralFieldState extends State<GeneralField> {
  late TextEditingController _controller;
  bool _isValid = false;
  bool isLabelExpanded = true;
  late FocusNode _focusNode;

  /// Initializes the TextEditingController and sets up a listener to update validation
  /// status based on the input text.
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(); // Leave empty, use hintText only
    _updateValidation('');
    _controller.addListener(() {
      final currentText = _controller.text;
      _updateValidation(currentText);
      if (widget.onChanged != null) {
        widget.onChanged!(currentText);
      }
    });
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.focusInstruction != null) {
        showCustomSnackBar(
          context,
          normalText: widget.focusInstruction!,
        );
      }
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
    _focusNode.dispose();
    super.dispose();
  }

  /// Builds a list of input formatters based on the provided input rules.
  List<TextInputFormatter>? _buildInputFormatters() {
    if (widget.inputRules == null) return null;

    List<TextInputFormatter> formatters = [];

    for (final rule in widget.inputRules!) {
      switch (rule) {
        case InputRuleType.noSpaces:
          formatters.add(FilteringTextInputFormatter.deny(RegExp(r'\s')));
          break;
        case InputRuleType.numericOnly:
          formatters.add(FilteringTextInputFormatter.digitsOnly);
          break;
        case InputRuleType.decimalWithTwoPlaces:
          formatters.add(
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          );
          break;
        case InputRuleType.lettersOnly:
          formatters.add(
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
          );
          break;
      }
    }

    return formatters;
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final labelColor = ColorPalette.primaryText;
    final hintColor = ColorPalette.secondaryText;
    final iconColor = _isValid
        ? ColorPalette.primaryAction
        : ColorPalette.error;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: proportionalSizes.scaleHeight(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label aligned to the left
          GestureDetector(
            onTap: () {
              setState(() {
                isLabelExpanded = !isLabelExpanded;
              });
            },
            child: SizedBox(
              width: proportionalSizes.scaleWidth(110),
              child: Text(
                widget.label,
                maxLines: isLabelExpanded ? null : 1,
                overflow: isLabelExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(18),
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
          ),

          // TextField fills remaining horizontal space
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              readOnly: !widget.isEditable,
              inputFormatters: _buildInputFormatters(),
              style: GoogleFonts.roboto(
                fontSize: proportionalSizes.scaleText(18),
                color: widget.isEditable ? labelColor : Colors.grey[600],
              ),
              maxLength: widget.maxLength,
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                hintText: widget.initialValue,
                hintStyle: GoogleFonts.roboto(
                  color: hintColor,
                  fontSize: proportionalSizes.scaleText(18),
                ),
              ),
              cursorColor: Colors.blue,
            ),
          ),

          // Status Icon (check or cross)
          if (widget.showStatusIcon && widget.validationRule != null)
            Padding(
              padding: EdgeInsets.only(
                left: proportionalSizes.scaleWidth(8),
              ),
              child: IconMaker(
                assetPath: _isValid ? 'assets/icons/check.png' : 'assets/icons/cross.png',
                color: iconColor,
              ),
            ),
        ],
      ),
    );
  }
}