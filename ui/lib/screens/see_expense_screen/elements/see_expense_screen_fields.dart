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
  final String transactionId;
  final void Function(bool isValid)? onNameValidityChanged;
  final void Function(bool isValid)? onAmountValidityChanged;
  final bool isAmountValid;

  const SeeExpenseScreenFields({
    super.key,
    required this.transactionId,
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

  // Dummy data store
  final Map<String, Map<String, dynamic>> dummyData = {
    'TXN456': {
      'name': 'Bus Recharge',
      'amount': '20',
      'date': '2024-06-10T14:20:00Z',
      'category': 'Transport',
      'splitWith': 'Group - Family',
      'items': 'Item 1, Item 2',
      'receipt': 'coles_receipt.png',
      'notes': 'Go-Card recharge',
    },
  };

  // Field values to populate
  late String name;
  late String amount;
  DateTime? date;
  late String category;
  late String splitWith;
  late String items;
  late String receipt;
  late String notes;

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // TODO: Replace this with backend API/database fetch using transactionId

    final data = dummyData[widget.transactionId];

    name = data?['name'] ?? '';
    amount = data?['amount'] ?? '';
    final rawDate = data?['date'];
    final parsedDate = (rawDate is String && rawDate.isNotEmpty) // Expects an ISO 8601 string and converts it to DateTime
        ? DateTime.tryParse(rawDate)
        : null;
    date = parsedDate;
    category = data?['category'] ?? '';
    splitWith = data?['splitWith'] ?? '';
    items = data?['items'] ?? '';
    receipt = data?['receipt'] ?? '';
    notes = data?['notes'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Column(
      children: [
        GeneralField(
          label: 'Name*',
          initialValue: 'Shopping at Coles',
          filledValue: name.isNotEmpty ? name : null,
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
          initialDate: date,
          isEditable: !widget.isReadOnly,
          onChanged: (selectedDate) {
            // TODO: Save selected date
          },
        ),
        CustomDivider(),

        GeneralField(
          label: 'Amount (\$)*',
          initialValue: '1000',
          filledValue: amount.isNotEmpty ? amount : null,
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
          selectedValue: category,
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
          value: splitWith,
          hintText: 'Select Group or Friends',
          trailingIconPath: 'assets/icons/search.png',
          inactive: widget.isReadOnly && splitWith.isEmpty,
          onTap: () {
            if (widget.isReadOnly && splitWith.isEmpty) return;

            if (!widget.isReadOnly || splitWith.isNotEmpty) {
              Navigator.pushNamed(context, '/split_with');
            }
          },
        ),
        CustomDivider(),

        CustomIconField(
          label: 'Items',
          value: items,
          hintText: 'Specify Items',
          trailingIconPath: 'assets/icons/add.png',
          inactive: widget.isReadOnly && items.isEmpty,
          onTap: () {
            if (widget.isReadOnly && items.isEmpty) return;

            if (!widget.isReadOnly || items.isNotEmpty) {
              Navigator.pushNamed(
                context,
                '/add_items',
                arguments: {
                  'amount': enteredAmount ?? 0,
                },
              );
            }
          },
        ),
        CustomDivider(),

        CustomIconField(
          label: 'Receipt',
          // TODO: Show saved receipt name
          value: receipt,
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
          filledValue: notes.isNotEmpty ? notes : null,
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