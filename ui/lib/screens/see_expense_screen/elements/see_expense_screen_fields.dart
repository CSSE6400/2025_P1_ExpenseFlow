import 'package:flutter/material.dart';
// Common imports
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/fields/date_field/date_field.dart';
import '../../../common/fields/dropdown_field.dart';
import '../../../common/fields/custom_icon_field.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/snack_bar.dart';

class SeeExpenseScreenFields extends StatefulWidget {
  final bool isReadOnly;
  final void Function(bool isValid)? onNameValidityChanged;
  final void Function(bool isValid)? onAmountValidityChanged;
  final bool isAmountValid;

  const SeeExpenseScreenFields({
    super.key,
    this.isReadOnly = true,
    this.onNameValidityChanged,
    this.onAmountValidityChanged,
    this.isAmountValid = false,
  });

  @override
  State<SeeExpenseScreenFields> createState() => _SeeExpenseScreenFieldsState();
}

class _SeeExpenseScreenFieldsState extends State<SeeExpenseScreenFields> {
  bool isNameValid = true;
  bool isAmountValid = true;
  double? enteredAmount;

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Column(
      children: [
        GeneralField(
          label: 'Name*',
          initialValue: 'Shopping at Coles',
          isEditable: !widget.isReadOnly,
          showStatusIcon: true,
          validationRule: (value) => value.trim().isNotEmpty,
          onValidityChanged: widget.onNameValidityChanged,
          maxLength: 50,
          onChanged: (value) {
            // TODO: Save name field value
          },
        ),
        CustomDivider(),

        DateField(
          label: 'Date',
          initialDate: DateTime.now(),
          isEditable: !widget.isReadOnly,
          onChanged: (selectedDate) {
            // TODO: Save selected date
          },
        ),
        CustomDivider(),

        GeneralField(
          label: 'Amount (\$)*',
          initialValue: '1000',
          isEditable: !widget.isReadOnly,
          showStatusIcon: true,
          inputRules: [InputRuleType.decimalWithTwoPlaces],
          validationRule: (value) {
            final number = double.tryParse(value.trim());
            return number != null && number > 0;
          },
          onValidityChanged: widget.onAmountValidityChanged,
          maxLength: 10,
          onChanged: (value) {
            final number = double.tryParse(value.trim());
            setState(() {
              enteredAmount = (number != null && number > 0) ? number : null;
            });
          },
        ),
        CustomDivider(),

        DropdownField(
          label: 'Category',
          options: ['Groceries', 'Transport', 'Bills', 'Entertainment'], // TODO: Load from DB
          placeholder: 'Select Category',
          addDialogHeading: 'New Category',
          addDialogHintText: 'Enter category name',
          addDialogMaxLength: 20,
          onChanged: (value) {
            // TODO: Save selected category
          },
          isEditable: !widget.isReadOnly,
        ),
        CustomDivider(),

        CustomIconField(
          label: 'Split With',
          // TODO: Fetch actual group/friend names
          value: '',
          hintText: 'Select Group or Friends',
          trailingIconPath: 'assets/icons/search.png',
          inactive: widget.isReadOnly || !widget.isAmountValid,
          onTap: () {
            if (widget.isReadOnly) return;

            if (!widget.isAmountValid) {
              showCustomSnackBar(
                context,
                normalText: 'Please enter a valid amount.',
              );
            } else {
              Navigator.pushNamed(context, '/split_with');
            }
          },
        ),
        CustomDivider(),

        CustomIconField(
          label: 'Items',
          // TODO: Show added items from DB
          value: '',
          hintText: 'Specify Items',
          trailingIconPath: 'assets/icons/add.png',
          inactive: widget.isReadOnly || !widget.isAmountValid,
          onTap: () {
            if (widget.isReadOnly) return;

            if (!widget.isAmountValid || enteredAmount == null) {
              showCustomSnackBar(
                context,
                normalText: 'Please enter a valid amount.',
              );
            } else {
              Navigator.pushNamed(
                context,
                '/add_items',
                arguments: {
                  'amount': enteredAmount,
                },
              );
            }
          },
        ),
        CustomDivider(),

        CustomIconField(
          label: 'Receipt',
          // TODO: Show saved receipt name
          value: '',
          hintText: 'Save your Receipt here',
          trailingIconPath: 'assets/icons/clip.png',
          inactive: widget.isReadOnly,
          onTap: () {
            if (widget.isReadOnly) return;

            // TODO: View receipt full screen
          },
        ),
        CustomDivider(),

        GeneralField(
          label: 'Notes',
          initialValue: 'Enter any notes here',
          isEditable: !widget.isReadOnly,
          showStatusIcon: false,
          maxLength: 200,
          onChanged: (value) {
            // TODO: Save notes field value
          },
        ),
        SizedBox(height: proportionalSizes.scaleHeight(24)),
      ],
    );
  }
}