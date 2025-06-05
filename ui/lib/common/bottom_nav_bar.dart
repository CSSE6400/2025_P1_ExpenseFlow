import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'proportional_sizes.dart';

enum BottomNavBarScreen { home, add, groupsAndFriends, expenses }

class BottomNavBar extends StatelessWidget {
  final BottomNavBarScreen? currentScreen;
  final bool inactive;

  const BottomNavBar({super.key, this.currentScreen, this.inactive = false});

  @override
  Widget build(BuildContext context) {
    final sizes = ProportionalSizes(context: context);
    final iconSize = sizes.scaleWidth(36);
    final iconColor =
        inactive
            ? ColorPalette.primaryAction.withAlpha(128)
            : ColorPalette.primaryAction;

    final navItems = <_NavItem>[
      _NavItem(
        screen: BottomNavBarScreen.home,
        iconPath: 'assets/icons/home.png',
        route: '/',
      ),
      _NavItem(
        screen: BottomNavBarScreen.add,
        iconPath: 'assets/icons/add.png',
        route: '/add_expense',
      ),
      _NavItem(
        screen: BottomNavBarScreen.groupsAndFriends,
        iconPath: 'assets/icons/group.png',
        route: '/groups_and_friends',
      ),
      _NavItem(
        screen: BottomNavBarScreen.expenses,
        iconPath: 'assets/icons/expenses.png',
        route: '/expenses',
      ),
    ];

    return BottomAppBar(
      color: ColorPalette.buttonText,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sizes.scaleHeight(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              navItems.map((item) {
                final isSelected = item.screen == currentScreen;
                final opacity =
                    inactive
                        ? (isSelected ? 0.6 : 0.3)
                        : (isSelected ? 1.0 : 0.25);

                return GestureDetector(
                  onTap:
                      inactive || isSelected
                          ? null
                          : () => Navigator.pushNamed(context, item.route),
                  child: Opacity(
                    opacity: opacity,
                    child: Image.asset(
                      item.iconPath,
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

class _NavItem {
  final BottomNavBarScreen screen;
  final String iconPath;
  final String route;

  const _NavItem({
    required this.screen,
    required this.iconPath,
    required this.route,
  });
}
