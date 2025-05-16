import 'package:flutter/material.dart';
// Common
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/fields/date_field/date_field.dart';

class AddExpenseScreenFields extends StatelessWidget {
  final bool isDarkMode;

  const AddExpenseScreenFields({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GeneralField(
          label: 'Name',
          initialValue: 'Shopping at Coles',
          isDarkMode: isDarkMode,
          isEditable: true,
          showStatusIcon: true,
          validationRule: (value) => value.trim().isNotEmpty, // not empty rule
        ),
        CustomDivider(isDarkMode: isDarkMode),

        DateField(
          isDarkMode: isDarkMode,
          label: 'Date',
          initialDate: DateTime.now(), // optional
          onDateSelected: (selectedDate) {
            // TODO: handle selected date (e.g., save it to a controller or variable)
          },
        ),
        CustomDivider(isDarkMode: isDarkMode),
      ],
    );
  }
}