// Flutter imports
import 'package:flutter/material.dart';
// // Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common
import '../common/proportional_sizes.dart';
import '../common/color_palette.dart';
import '../common/icon_maker.dart';

/// A customizable AppBar used across screens in the app.
/// Supports optional back navigation and dynamic styling based on screen size.
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  /// Title displayed on the AppBar.
  final String screenName;

  /// Determines if the back button should be shown.
  final bool showBackButton;

  /// Optional custom back button handler. Defaults to Navigator.pop().
  final VoidCallback? onBackPressed;

  /// Dark mode toggle passed from screen.
  final bool isDarkMode;

  const AppBarWidget({
    super.key,
    required this.screenName,
    this.showBackButton = false,
    this.onBackPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    // Set colors according to dark mode status
    final textColor = isDarkMode
        ? ColorPalette.primaryActionDark
        : ColorPalette.primaryAction;

    return AppBar(
      backgroundColor: Colors.transparent, // Flat look
      elevation: 0, // No shadow
      titleSpacing: 0, // Title aligns closer to the left edge

      // Back button if enabled
      leading: showBackButton
          ? IconButton(
              icon: IconMaker(
                assetPath: 'assets/icons/back_button.png',
                isDarkMode: isDarkMode,
              ),
              onPressed: onBackPressed ?? () {
                Navigator.pop(context);
              },
            )
          : null,

      // Title text
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          screenName,
          style: GoogleFonts.roboto(
            fontSize: proportionalSizes.scaleText(24),
            fontWeight: FontWeight.w700,
            color: textColor, // Text uses primaryAction or primaryActionDark
          ),
        ),
      ),
    );
  }

  /// Preferred height for the AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}