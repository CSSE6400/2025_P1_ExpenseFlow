import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
// Elements
import 'elements/groups_and_friends_main_body.dart';

class GroupsAndFriendsScreen extends StatefulWidget {
  const GroupsAndFriendsScreen({super.key});

  @override
  State<GroupsAndFriendsScreen> createState() =>
      _GroupsAndFriendsScreenState();
}

class _GroupsAndFriendsScreenState extends State<GroupsAndFriendsScreen> {
  String selectedSegment = 'Friends';

  void _onSegmentChanged(String newSegment) {
    setState(() {
      selectedSegment = newSegment;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: selectedSegment, // Dynamic title
        showBackButton: true,
      ),
      body: GroupsAndFriendsMainBody(
        selectedSegment: selectedSegment,
        onSegmentChanged: _onSegmentChanged,
      ),
      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Groups',
        inactive: false,
      ),
    );
  }
}