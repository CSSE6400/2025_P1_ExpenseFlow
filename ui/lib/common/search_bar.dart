import 'package:flutter/material.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';
import 'package:google_fonts/google_fonts.dart';

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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleHeight(18),
                  color: ColorPalette.primaryText, // typed input
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleHeight(18),
                    color: ColorPalette.secondaryText, // placeholder text
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(width: proportionalSizes.scaleWidth(10)),
            IconMaker(
              assetPath: 'assets/icons/search.png',
            ),
          ],
        ),
      ),
    );
  }
}