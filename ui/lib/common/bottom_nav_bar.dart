// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import 'color_palette.dart';
import 'proportional_sizes.dart';

/// A custom bottom navigation bar widget for navigating between Groups, Add, and Expenses.
class BottomNavBar extends StatelessWidget {
  /// The name of the currently active screen.
  final String currentScreen;

  /// If `true`, disables navigation and turns all icons grey.
  final bool inactive;

  const BottomNavBar({
    super.key,
    required this.currentScreen,
    this.inactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final iconColor =
        inactive
            ? ColorPalette.primaryAction.withValues(alpha: 0.5)
            : ColorPalette.primaryAction;
    final backgroundColor = ColorPalette.buttonText;

    final double iconSize = proportionalSizes.scaleWidth(36);

    final List<Map<String, dynamic>> navItems = [
      {
        'screen': 'Home',
        'icon': 'assets/icons/home.png',
        'onTap': () {
          if (!inactive && currentScreen != 'Home') {
            Navigator.pushNamed(context, '/');
          }
        },
      },
      {
        'screen': 'Add',
        'icon': 'assets/icons/add.png',
        'onTap': () {
          if (!inactive && currentScreen != 'Add') {
            Navigator.pushNamed(context, '/add_expense');
          }
        },
      },
      {
        'screen': 'Groups',
        'icon': 'assets/icons/group.png',
        'onTap': () {
          if (!inactive && currentScreen != 'Groups') {
            Navigator.pushNamed(context, '/groups_and_friends');
          }
        },
      },
      {
        'screen': 'Expenses',
        'icon': 'assets/icons/expenses.png',
        'onTap': () {
          if (!inactive && currentScreen != 'Expenses') {
            Navigator.pushNamed(context, '/expenses');
          }
        },
      },
    ];

    return BottomAppBar(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: proportionalSizes.scaleHeight(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              navItems.map((item) {
                bool isSelected = item['screen'] == currentScreen;

                return GestureDetector(
                  onTap: inactive ? null : item['onTap'],
                  child: Opacity(
                    opacity:
                        inactive
                            ? (isSelected ? 0.6 : 0.3)
                            : (isSelected ? 1.0 : 0.25),
                    child: Image.asset(
                      item['icon'],
                      width: iconSize,
                      height: iconSize,
                      color: iconColor,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
