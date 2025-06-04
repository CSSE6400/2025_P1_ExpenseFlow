import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'proportional_sizes.dart';
import 'color_palette.dart';
import 'icon_maker.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String screenName;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppBarWidget({
    super.key,
    required this.screenName,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = ProportionalSizes(context: context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: showBackButton ? 0 : 16,
      automaticallyImplyLeading: false,
      leading:
          showBackButton
              ? IconButton(
                icon: IconMaker(assetPath: 'assets/icons/back_button.png'),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
              : null,
      title: Text(
        screenName,
        style: GoogleFonts.roboto(
          fontSize: sizes.scaleText(24),
          fontWeight: FontWeight.w700,
          color: ColorPalette.primaryAction,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
