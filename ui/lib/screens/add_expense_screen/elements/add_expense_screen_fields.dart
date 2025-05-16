import 'package:flutter/material.dart';
// Common
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/fields/date_field/date_field.dart';

class AddExpenseScreenFields extends StatefulWidget {
  final bool isDarkMode;

  const AddExpenseScreenFields({super.key, required this.isDarkMode});

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
          label: 'Name',
          initialValue: 'Shopping at Coles',
          isDarkMode: widget.isDarkMode,
          isEditable: true,
          showStatusIcon: true,
          validationRule: (value) => value.trim().isNotEmpty,
          onValidityChanged: updateNameValidity,
        ),
        CustomDivider(isDarkMode: widget.isDarkMode),

        DateField(
          isDarkMode: widget.isDarkMode,
          label: 'Date',
          initialDate: DateTime.now(),
        ),
        CustomDivider(isDarkMode: widget.isDarkMode),

        GeneralField(
          label: 'Amount (\$)*',
          initialValue: '1000',
          isDarkMode: widget.isDarkMode,
          isEditable: true,
          showStatusIcon: true,
          inputRules: [InputRuleType.decimalWithTwoPlaces],
          validationRule: (value) {
            final number = double.tryParse(value.trim());
            return number != null && number > 0;
          },
          onValidityChanged: updateAmountValidity,
        ),
        CustomDivider(isDarkMode: widget.isDarkMode),
      ],
    );
  }
}