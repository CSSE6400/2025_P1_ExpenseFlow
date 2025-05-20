import 'package:flutter/material.dart';
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

  void updateFormValid(bool isValid) {
    setState(() => isFormValid = isValid);
  }

  Future<void> onAdd() async {
    // TODO: Handle save logic
    Navigator.pushNamed(context, '/');
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
              AddExpenseScreenFields(onValidityChanged: updateFormValid),
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
