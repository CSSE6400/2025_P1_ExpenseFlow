import 'package:flutter/material.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import '../../../common/custom_button.dart';
// Elements
import 'see_expense_screen_fields.dart';
import 'see_expense_screen_active_status.dart';

class SeeExpenseScreenMainBody extends StatefulWidget {
  final String expenseId;

  const SeeExpenseScreenMainBody({super.key, required this.expenseId});

  @override
  State<SeeExpenseScreenMainBody> createState() =>
      _SeeExpenseScreenMainBodyState();
}

class _SeeExpenseScreenMainBodyState extends State<SeeExpenseScreenMainBody> {
  bool isNameValid = true;
  bool isAmountValid = true;
  bool isEditMode = false;

  bool get isFormValid => isNameValid && isAmountValid;

  void updateNameValidity(bool isValid) {
    setState(() => isNameValid = isValid);
  }

  void updateAmountValidity(bool isValid) {
    setState(() => isAmountValid = isValid);
  }

  Future<void> _onSave() async {
    // TODO: Save updated fields to backend using widget.transactionId

    setState(() => isEditMode = false);
  }

  void _onEdit() {
    setState(() => isEditMode = true);
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
              SeeExpenseScreenActiveStatus(
                isActive: true,
              ), // TODO: Fetch active status from backend
              SizedBox(height: proportionalSizes.scaleHeight(20)),

              SeeExpenseScreenFields(
                onNameValidityChanged: updateNameValidity,
                onAmountValidityChanged: updateAmountValidity,
                isAmountValid: isAmountValid,
                isReadOnly: !isEditMode,
                transactionId: widget.expenseId,
              ),
              SizedBox(height: proportionalSizes.scaleHeight(24)),

              CustomButton(
                label: isEditMode ? 'Save' : 'Edit',
                onPressed:
                    isEditMode ? (isFormValid ? _onSave : () {}) : _onEdit,
                sizeType: ButtonSizeType.full,
                state:
                    isEditMode
                        ? (isFormValid
                            ? ButtonState.enabled
                            : ButtonState.disabled)
                        : ButtonState.enabled,
              ),
              SizedBox(height: proportionalSizes.scaleHeight(96)),
            ],
          ),
        ),
      ),
    );
  }
}
