import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
// Elements
import 'elements/manage_groups_main_body.dart';

class ManageGroupsScreen extends StatefulWidget {
  const ManageGroupsScreen({super.key});

  @override
  State<ManageGroupsScreen> createState() => _ManageGroupsScreenState();
}

class _ManageGroupsScreenState extends State<ManageGroupsScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: 'Manage Groups',
        showBackButton: true,
      ),

      body: ManageGroupsMainBody(),
      
      bottomNavigationBar: BottomNavBar(
        currentScreen: 'ManageGroups',
        inactive: false,
      ),
    );
  }
}