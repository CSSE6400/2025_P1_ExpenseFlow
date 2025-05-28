import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/models/expense.dart' show ExpenseCreate;
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;
// Third-party imports
// Common imports
import '../../../common/proportional_sizes.dart';
import '../../../common/custom_button.dart';
// Elements
import 'add_expense_screen_scan_receipt.dart';
import 'add_expense_screen_fields.dart';

class AddExpenseScreenMainBody extends StatefulWidget {
  const AddExpenseScreenMainBody({super.key});

  @override
  State<AddExpenseScreenMainBody> createState() =>
      _AddExpenseScreenMainBodyState();
}

class _AddExpenseScreenMainBodyState extends State<AddExpenseScreenMainBody> {
  bool isFormValid = false;
  ExpenseCreate? _currentExpense;
  final Logger _logger = Logger("AddExpenseScreenMainBody");

  void updateFormValid(bool isValid) {
    setState(() => isFormValid = isValid);
  }

  void updateExpense(ExpenseCreate expense) {
    _currentExpense = expense;
  }

  Future<void> onAdd() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (_currentExpense == null) {
      showCustomSnackBar(context, normalText: "Please fill in all fields");
      return;
    }

    try {
      await apiService.expenseApi.createExpense(_currentExpense!);
      if (!mounted) return;
      showCustomSnackBar(
        context,
        normalText: "Successfully added expense",
        backgroundColor: Colors.green,
      );
      Navigator.pushNamed(context, '/');
    } catch (e) {
      _logger.severe("Failed to add expense", e);
      if (!mounted) return;
      showCustomSnackBar(context, normalText: "Failed to add expense");
    }
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AddExpenseScreenScanReceipt(),
              SizedBox(height: proportionalSizes.scaleHeight(20)),

              // Pass validity up from fields
              AddExpenseScreenFields(
                onValidityChanged: updateFormValid,
                onExpenseChanged: updateExpense, // <-- pass callback here
              ),
              SizedBox(height: proportionalSizes.scaleHeight(24)),

              CustomButton(
                label: 'Add Expense',
                onPressed: isFormValid ? onAdd : () {},
                sizeType: ButtonSizeType.full,
                state: isFormValid ? ButtonState.enabled : ButtonState.disabled,
              ),
              SizedBox(height: proportionalSizes.scaleHeight(96)),
            ],
          ),
        ),
      ),
    );
  }
}
