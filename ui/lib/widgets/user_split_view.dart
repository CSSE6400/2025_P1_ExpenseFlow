import 'package:flutter/material.dart';
import 'package:expenseflow/common/color_palette.dart';
import 'package:expenseflow/common/icon_maker.dart';
import 'package:expenseflow/screens/split_with_screen/split_with_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/proportional_sizes.dart';

class UserSplitWidget extends StatelessWidget {
  final UserSplit user;
  final bool isReadOnly;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;

  const UserSplitWidget({
    super.key,
    required this.user,
    required this.isReadOnly,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return GestureDetector(
      onTap: isReadOnly ? null : onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: proportionalSizes.scaleHeight(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              user.name,
              style: GoogleFonts.roboto(
                fontSize: proportionalSizes.scaleHeight(16),
                color: user.checked ? textColor : ColorPalette.secondaryText,
              ),
            ),
            Row(
              children: [
                if (user.checked)
                  Padding(
                    padding: EdgeInsets.only(
                      right: proportionalSizes.scaleWidth(6),
                    ),
                    child: IconMaker(
                      assetPath: 'assets/icons/check_nofilled.png',
                    ),
                  ),
                Container(
                  width: proportionalSizes.scaleWidth(70),
                  padding: EdgeInsets.symmetric(
                    horizontal: proportionalSizes.scaleWidth(8),
                    vertical: proportionalSizes.scaleHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color:
                        isReadOnly
                            ? ColorPalette.secondaryText.withAlpha(100)
                            : textColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(
                      proportionalSizes.scaleWidth(6),
                    ),
                  ),
                  child: TextField(
                    controller: user.controller,
                    enabled: !isReadOnly,
                    keyboardType: TextInputType.number,
                    onChanged: !isReadOnly ? onChanged : null,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: proportionalSizes.scaleHeight(14),
                      color:
                          isReadOnly ? textColor : ColorPalette.secondaryText,
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      suffixText: '%',
                      suffixStyle: TextStyle(color: Color(0xFF0F2F63)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
