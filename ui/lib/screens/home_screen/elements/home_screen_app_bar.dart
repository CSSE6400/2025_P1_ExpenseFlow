// Flutter imports
import 'package:flutter/material.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../../../common/proportional_sizes.dart';
import '../../../common/color_palette.dart';
import '../../../common/icon_maker.dart';

/// A customized HomeScreenAppBar specifically styled for the Home Screen.
class HomeScreenAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const HomeScreenAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    final logoColor = ColorPalette.logoColor;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: App icon and name
          Row(
            children: [
              Image.asset(
                'assets/logo/expenseflow_logo.png',
                width: proportionalSizes.scaleWidth(36),
                height: proportionalSizes.scaleHeight(36),
                color: logoColor,
              ),
              SizedBox(width: proportionalSizes.scaleWidth(8)),
              Text(
                'ExpenseFlow',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(22),
                  fontWeight: FontWeight.w700,
                  color: logoColor,
                ),
              ),
            ],
          ),

          // Right side: User icon
          IconButton(
            icon: IconMaker(
              assetPath: 'assets/icons/user.png',
            ),
            onPressed: () {
              // TODO: Navigate to General Screen
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}