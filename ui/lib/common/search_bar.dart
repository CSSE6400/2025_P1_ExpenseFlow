import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final void Function(String)? onChanged;

  const SearchBar({
    super.key,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        width: double.infinity,
        height: proportionalSizes.scaleHeight(40),
        padding: EdgeInsets.symmetric(
          horizontal: proportionalSizes.scaleWidth(12),
        ),
        decoration: BoxDecoration(
          color: ColorPalette.buttonText,
          borderRadius: BorderRadius.circular(
            proportionalSizes.scaleWidth(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: TextField(
                  onChanged: onChanged,
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleHeight(18),
                    color: ColorPalette.primaryText,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: hintText,
                    hintStyle: GoogleFonts.roboto(
                      fontSize: proportionalSizes.scaleHeight(18),
                      color: ColorPalette.secondaryText,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: proportionalSizes.scaleWidth(10)),
            Center(
              child: IconMaker(
                assetPath: 'assets/icons/search.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}