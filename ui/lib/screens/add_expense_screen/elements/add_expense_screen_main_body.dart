import 'package:flutter/material.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
// Elements
import 'add_expense_screen_scan_receipt.dart';
import 'add_expense_screen_fields.dart';

class AddExpenseScreenMainBody extends StatelessWidget {
  const AddExpenseScreenMainBody({super.key});

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
              AddExpenseScreenScanReceipt(),
              SizedBox(height: proportionalSizes.scaleHeight(20)),
              
              AddExpenseScreenFields(),
            ],
          ),
        ),
      ),
    );
  }
}