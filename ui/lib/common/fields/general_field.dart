import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/color_palette.dart';
import '../../common/proportional_sizes.dart';
import '../../common/icon_maker.dart';
import '../../common/snack_bar.dart';

enum InputRuleType { noSpaces, numericOnly, decimalWithTwoPlaces, lettersOnly }

class GeneralField extends StatefulWidget {
  final String label;

  final String initialValue;

  final String? filledValue;

  final bool showStatusIcon;

  final List<InputRuleType>? inputRules;

  final bool Function(String value)? validationRule;

  final bool isEditable;

  final void Function(bool isValid)? onValidityChanged;

  final ValueChanged<String>? onChanged;

  final int? maxLength;

  final String? focusInstruction;

  final TextEditingController? controller;

  const GeneralField({
    super.key,
    required this.label,
    this.initialValue = '',
    this.showStatusIcon = false,
    this.validationRule,
    this.isEditable = true,
    this.inputRules,
    this.onValidityChanged,
    this.onChanged,
    this.maxLength,
    this.focusInstruction,
    this.filledValue,
    this.controller,
  });

  @override
  State<GeneralField> createState() => GeneralFieldState();
}

class GeneralFieldState extends State<GeneralField> {
  late TextEditingController _controller;
  bool _isValid = false;
  bool isLabelExpanded = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller ??
        TextEditingController(
          text:
              widget.filledValue?.isNotEmpty == true
                  ? widget.filledValue
                  : widget.initialValue,
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateValidation(_controller.text);
    });

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
        showCustomSnackBar(context, normalText: widget.focusInstruction!);
      }
    });
  }

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

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

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
    final iconColor =
        _isValid ? ColorPalette.primaryAction : ColorPalette.error;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: proportionalSizes.scaleHeight(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                overflow:
                    isLabelExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(18),
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
          ),

          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              readOnly: !widget.isEditable,
              inputFormatters: _buildInputFormatters(),
              style: GoogleFonts.roboto(
                fontSize: proportionalSizes.scaleText(18),
                color:
                    !widget.isEditable
                        ? (widget.filledValue?.isNotEmpty == true
                            ? labelColor
                            : Colors.grey[600])
                        : labelColor,
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

          if (widget.showStatusIcon && widget.validationRule != null)
            Padding(
              padding: EdgeInsets.only(left: proportionalSizes.scaleWidth(8)),
              child: IconMaker(
                assetPath:
                    _isValid
                        ? 'assets/icons/check.png'
                        : 'assets/icons/cross.png',
                color: iconColor,
              ),
            ),
        ],
      ),
    );
  }
}
