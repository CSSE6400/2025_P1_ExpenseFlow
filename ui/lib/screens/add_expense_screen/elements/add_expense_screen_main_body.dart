import 'package:flutter/material.dart';
// Common
import '../../../common/proportional_sizes.dart';
// Elements
import 'add_expense_screen_scan_receipt.dart';

class AddExpenseScreenMainBody extends StatelessWidget {
  final bool isDarkMode;

  const AddExpenseScreenMainBody({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scan receipt
              AddExpenseScreenScanReceipt(isDarkMode: isDarkMode)
            ],
          ),
        ),
      ),
    );
  }
}