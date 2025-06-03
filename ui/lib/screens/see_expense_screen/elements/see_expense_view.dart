import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/widgets/expense_form.dart';
import '../../../common/custom_button.dart';
import '../../../common/proportional_sizes.dart';
import '../elements/see_expense_screen_status.dart';

class SeeExpenseView extends StatelessWidget {
  final ExpenseRead expense;
  final ExpenseCreate? currentExpense;
  final bool isEditMode;
  final bool isEditable;
  final bool isItemsAndSplitsEditable;
  final bool isFormValid;
  final void Function(bool) onValidityChanged;
  final void Function(ExpenseCreate) onExpenseChanged;
  final VoidCallback onSave;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const SeeExpenseView({
    super.key,
    required this.expense,
    required this.currentExpense,
    required this.isEditMode,
    required this.isEditable,
    required this.isItemsAndSplitsEditable,
    required this.isFormValid,
    required this.onValidityChanged,
    required this.onExpenseChanged,
    required this.onSave,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: proportionalSizes.scaleWidth(20),
        vertical: proportionalSizes.scaleHeight(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ExpenseForm(
            initialExpense: currentExpense,
            canEdit: isEditable,
            canEditItems: isItemsAndSplitsEditable,
            canEditSplits: isItemsAndSplitsEditable,
            onValidityChanged: onValidityChanged,
            onExpenseChanged: onExpenseChanged,
          ),
          SizedBox(height: proportionalSizes.scaleHeight(24)),
          CustomButton(
            label: isEditMode ? 'Save' : 'Edit',
            onPressed: isEditMode ? (isFormValid ? onSave : () {}) : onEdit,
            sizeType: ButtonSizeType.full,
            state:
                isEditMode
                    ? (isFormValid ? ButtonState.enabled : ButtonState.disabled)
                    : ButtonState.enabled,
          ),
          SizedBox(height: proportionalSizes.scaleHeight(16)),
          if (isEditMode)
            CustomButton(
              label: 'Cancel',
              onPressed: onCancel,
              sizeType: ButtonSizeType.full,
              state: ButtonState.enabled,
            ),
          SizedBox(height: proportionalSizes.scaleHeight(96)),
        ],
      ),
    );
  }
}
