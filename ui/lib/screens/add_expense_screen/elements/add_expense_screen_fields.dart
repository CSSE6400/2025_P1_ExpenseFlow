import 'package:flutter/material.dart';
// Common imports
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/fields/date_field/date_field.dart';
import '../../../common/fields/dropdown_field.dart';
import '../../../common/fields/custom_icon_field.dart';
import '../../../common/proportional_sizes.dart';
// import '../../../common/show_image.dart';
import '../../../common/snack_bar.dart';

class AddExpenseScreenFields extends StatefulWidget {
  final void Function(bool isValid)? onNameValidityChanged;
  final void Function(bool isValid)? onAmountValidityChanged;
  final bool isAmountValid;

  const AddExpenseScreenFields({
    super.key,
    this.onNameValidityChanged,
    this.onAmountValidityChanged,
    this.isAmountValid = false,
  });

  @override
  State<AddExpenseScreenFields> createState() => _AddExpenseScreenFieldsState();
}

class _AddExpenseScreenFieldsState extends State<AddExpenseScreenFields> {
  bool isNameValid = false;
  bool isAmountValid = false;

  void updateNameValidity(bool isValid) {
    setState(() {
      isNameValid = isValid;
    });
  }
  
  void updateAmountValidity(bool isValid) {
    setState(() {
      isAmountValid = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Column(
      children: [
        GeneralField(
          label: 'Name*',
          initialValue: 'Shopping at Coles',
          isEditable: true,
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
          onChanged: (selectedDate) {
            // TODO: Save selected date (e.g., save it to a controller or variable)
          },
        ),
        CustomDivider(),

        GeneralField(
          label: 'Amount (\$)*',
          initialValue: '1000',
          isEditable: true,
          showStatusIcon: true,
          inputRules: [InputRuleType.decimalWithTwoPlaces],
          validationRule: (value) {
            final number = double.tryParse(value.trim());
            return number != null && number > 0;
          },
          onValidityChanged: widget.onAmountValidityChanged,
          maxLength: 10,
          onChanged: (value) {
            // TODO: Save amount field value
          },
        ),
        CustomDivider(),

        DropdownField(
          label: 'Category',
          options: ['Groceries', 'Transport', 'Bills', 'Entertainment'], // TODO: Fetch categories from the database
          placeholder: 'Select Category',
          addDialogHeading: 'New Category',
          addDialogHintText: 'Enter category name',
          addDialogMaxLength: 20,
          onChanged: (value) {
            // TODO: Save selected category
          },
        ),
        CustomDivider(),

        CustomIconField(
          label: 'Split With',
          // TODO: Fetch the group or friends names from the database & set the value.
          // For group, the value should be of the form 'Group - Group Name'
          // For friends, the value should be of the form 'Friend - Friend Name'
          value: '',
          hintText: 'Select Group',
          trailingIconPath: 'assets/icons/search.png',
          inactive: !widget.isAmountValid,
          onTap: () {
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
          // TODO: Fetch the enetered items from the database & set the value.
          // Items should be of the form 'Item 1, Item 2, Item 3'
          // like 'Milk, Eggs, Bread'
          value: '',
          hintText: 'Specify Items',
          trailingIconPath: 'assets/icons/add.png',
          inactive: !widget.isAmountValid,
          onTap: !widget.isAmountValid
            ? null
            : () {
                // TODO: Navigate to the Add Items screen
              },
              ),
        CustomDivider(),

        CustomIconField(
          label: 'Receipt',
          // TODO: Fetch the name of saved receipt from the database.
          value: '',
          hintText: 'Save your Receipt here',
          trailingIconPath: 'assets/icons/clip.png',
          onTap: () {
            // TODO: Expand to show the receipt
            // For example, like "showFullScreenImage(context, imageUrl: 'https://example.com/image.png');"
          },
        ),
        CustomDivider(),

        GeneralField(
          label: 'Notes',
          initialValue: 'Enter any notes here',
          isEditable: true,
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