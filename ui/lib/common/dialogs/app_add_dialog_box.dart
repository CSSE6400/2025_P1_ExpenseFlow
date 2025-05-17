import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../proportional_sizes.dart';
import '../custom_button.dart';
import '../color_palette.dart';

Future<String?> showAddCategoryDialog(
  BuildContext context, {
  required String heading,
  required String hintText,
  required int maxLength,
}) async {
  final proportionalSizes = ProportionalSizes(context: context);
  final TextEditingController controller = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();
  final boundaryColor = ColorPalette.primaryAction;
  final hintColor = ColorPalette.secondaryText;
  String? result;

  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withAlpha(50),
    builder: (context) {
      return GestureDetector(
        onTap: () {
          // Dismiss keyboard if user taps outside
          FocusScope.of(context).unfocus();
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(20)),
          ),
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: proportionalSizes.scaleWidth(15),
                sigmaY: proportionalSizes.scaleHeight(15),
              ),
              child: Container(
                padding: EdgeInsets.all(proportionalSizes.scaleWidth(20)),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(100),
                  borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(20)),
                  border: Border.all(color: Colors.white.withAlpha(50)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      heading,
                      style: GoogleFonts.roboto(
                        fontSize: proportionalSizes.scaleText(18),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: proportionalSizes.scaleHeight(12)),
                    TextField(
                      controller: controller,
                      focusNode: inputFocusNode,
                      autofocus: true,
                      maxLength: maxLength,
                      textCapitalization: TextCapitalization.none,
                      style: GoogleFonts.roboto(
                        fontSize: proportionalSizes.scaleText(16),
                      ),
                      onChanged: (value) {
                        // Filter: keep only letters, numbers, and spaces
                        final cleaned = value.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');

                        // Format: each word starts with uppercase
                        final formatted = cleaned
                            .split(' ')
                            .map((word) => word.isEmpty
                                ? ''
                                : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
                            .join(' ');

                        // Update the field only if formatting changed
                        if (formatted != controller.text) {
                          controller.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                      },
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: GoogleFonts.roboto(
                          fontSize: proportionalSizes.scaleText(15),
                          color: hintColor,
                        ),
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(12)),
                          borderSide: BorderSide(color: boundaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(12)),
                          borderSide: BorderSide(color: boundaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(12)),
                          borderSide: BorderSide(color: boundaryColor, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: proportionalSizes.scaleHeight(12),
                          horizontal: proportionalSizes.scaleWidth(16),
                        ),
                      ),
                    ),
                    SizedBox(height: proportionalSizes.scaleHeight(20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                          label: 'Cancel',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          backgroundColor: Colors.grey,
                          sizeType: ButtonSizeType.quarter,
                        ),
                        CustomButton(
                          label: 'Add',
                          onPressed: () {
                            result = controller.text.trim();
                            Navigator.pop(context);
                          },
                          sizeType: ButtonSizeType.quarter,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  return result;
}