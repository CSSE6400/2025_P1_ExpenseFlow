// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
import '../add_items_screen/elements/add_items_screen_main_body.dart';

class AddItemsScreen extends StatefulWidget {
  final double? amount;

  const AddItemsScreen({
    super.key,
    this.amount,
  });

  @override
  State<AddItemsScreen> createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: 'Add Items',
        showBackButton: true,
      ),

      body: AddItemsScreenMainBody(
        amount: widget.amount,
      ),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Add',
        inactive: true,
      ),
    );
  }
}