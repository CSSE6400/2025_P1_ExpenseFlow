import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';

class SeeExpenseScreenActiveStatus extends StatelessWidget {
  final bool isActive;

  const SeeExpenseScreenActiveStatus({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    if (!isActive) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: proportionalSizes.scaleHeight(6),
        horizontal: proportionalSizes.scaleWidth(12),
      ),
      decoration: BoxDecoration(
        color: ColorPalette.accent.withValues(alpha: 0.2),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          IconMaker(
            assetPath: 'assets/icons/check.png',
            color: ColorPalette.accent,
            ),
          SizedBox(width: proportionalSizes.scaleWidth(8)),
          Text(
            'Active',
            style: GoogleFonts.roboto(
              color: ColorPalette.accent,
              fontSize: proportionalSizes.scaleText(16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}