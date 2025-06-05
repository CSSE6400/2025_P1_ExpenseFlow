import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/user.dart' show UserRead;
import 'package:flutter_frontend/widgets/expense_form.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import '../../../common/custom_button.dart';
import '../../../common/proportional_sizes.dart';

class SeeExpenseView extends StatelessWidget {
  final ExpenseRead expense;
  final ExpenseCreate? currentExpense;
  final bool isEditMode;
  final bool isEditable;
  final bool isItemsAndSplitsEditable;
  final bool isFormValid;
  final void Function(bool) onValidityChanged;
  final void Function(ExpenseCreate, String?) onExpenseChanged;
  final VoidCallback onSave;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final UserRead currentUser;

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
    required this.currentUser,
  });

  // Sorry in advance for this this

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: proportionalSizes.scaleWidth(20),
        vertical: proportionalSizes.scaleHeight(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Expense Details",
            style: GoogleFonts.roboto(
              fontSize: proportionalSizes.scaleText(18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: proportionalSizes.scaleHeight(10)),

          ExpenseForm(
            initialExpense: currentExpense,
            canEdit: false,
            canEditItems: isItemsAndSplitsEditable,
            canEditSplits: isItemsAndSplitsEditable,
            onValidityChanged: onValidityChanged,
            onExpenseChanged: onExpenseChanged,
          ),
          SizedBox(height: proportionalSizes.scaleHeight(12)),
          CustomButton(
            label: isEditMode ? 'Save' : 'Edit',
            onPressed: isEditMode ? (isFormValid ? onSave : () {}) : onEdit,
            sizeType: ButtonSizeType.full,
            state:
                isEditMode
                    ? (isFormValid ? ButtonState.enabled : ButtonState.disabled)
                    : ButtonState.enabled,
          ),
          SizedBox(height: proportionalSizes.scaleHeight(12)),
          if (isEditMode)
            CustomButton(
              label: 'Cancel',
              onPressed: onCancel,
              sizeType: ButtonSizeType.full,
              state: ButtonState.enabled,
            ),
        ],
      ),
    );
  }
}
