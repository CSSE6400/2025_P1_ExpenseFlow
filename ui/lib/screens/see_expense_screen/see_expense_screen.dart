// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/see_expense_screen/elements/see_expense_screen_main_body.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';

class SeeExpenseScreen extends StatefulWidget {
  final String transactionId;

  const SeeExpenseScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<SeeExpenseScreen> createState() => _SeeExpenseScreenState();
}

class _SeeExpenseScreenState extends State<SeeExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    final String transactionId = 'TXN456'; // TODO: Replace with actual transaction ID
    return Scaffold(
      backgroundColor: ColorPalette.background,

      appBar: AppBarWidget(
        screenName: 'See Expense',
        showBackButton: true,
      ),

      body: SeeExpenseScreenMainBody(transactionId: transactionId),

      bottomNavigationBar: const BottomNavBar(
        currentScreen: 'See',
        inactive: false,
      ),
    );
  }
}