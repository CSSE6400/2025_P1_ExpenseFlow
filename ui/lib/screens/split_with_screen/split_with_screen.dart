// Flutter imports
import 'package:flutter/material.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
// Elements
import '../split_with_screen/elements/split_with_screen_main_body.dart';

class SplitWithScreen extends StatefulWidget {
  final String? transactionId;
  final bool isReadOnly;

  const SplitWithScreen({
    super.key,
    this.transactionId,
    this.isReadOnly = false,
  });

  @override
  State<SplitWithScreen> createState() => _SplitWithScreenState();
}

class _SplitWithScreenState extends State<SplitWithScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(
        screenName: 'Split With',
        showBackButton: true,
      ),

      body: SplitWithScreenMainBody(
        transactionId: widget.transactionId,
        isReadOnly: widget.isReadOnly,
      ),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Add',
        inactive: true,
      ),
    );
  }
}