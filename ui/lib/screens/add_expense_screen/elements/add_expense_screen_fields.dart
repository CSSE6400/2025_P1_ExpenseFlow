import 'package:flutter/material.dart';
// Common imports
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/fields/date_field/date_field.dart';
import '../../../common/fields/dropdown_field.dart';

class AddExpenseScreenFields extends StatefulWidget {
  const AddExpenseScreenFields({super.key});

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
    return Column(
      children: [
        GeneralField(
          label: 'Name*',
          initialValue: 'Shopping at Coles',
          isEditable: true,
          showStatusIcon: true,
          validationRule: (value) => value.trim().isNotEmpty,
          onValidityChanged: updateNameValidity,
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
          onValidityChanged: updateAmountValidity,
          onChanged: (value) {
            // TODO: Save amount field value
          },
        ),
        CustomDivider(),

        DropdownField(
          label: 'Category',
          options: ['Groceries', 'Transport', 'Bills', 'Entertainment'],
          placeholder: 'Select Category',
          onChanged: (value) {
            // TODO: Save selected category
          },
        ),
      ],
    );
  }
}