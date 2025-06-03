import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
import '../../common/bottom_nav_bar.dart';
import '../ind_friend_expense_screen/elements/ind_friend_expense_screen_main_body.dart';

class IndFriendExpenseScreen extends StatefulWidget {
  final String userId;

  const IndFriendExpenseScreen({super.key, required this.userId});

  @override
  State<IndFriendExpenseScreen> createState() => _IndFriendExpenseScreenState();
}

class _IndFriendExpenseScreenState extends State<IndFriendExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(screenName: widget.userId, showBackButton: true),

      body: IndFriendExpenseScreenMainBody(username: widget.userId),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Individual Friend',
        inactive: false,
      ),
    );
  }
}
