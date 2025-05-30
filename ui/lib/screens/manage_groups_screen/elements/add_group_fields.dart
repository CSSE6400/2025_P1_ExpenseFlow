import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/enums.dart' show ExpenseCategory;
import 'package:flutter_frontend/utils/string_utils.dart';
// Common imports
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/fields/date_field/date_field.dart';
import '../../../common/fields/dropdown_field.dart';
import '../../../models/expense.dart';
import '../../../common/fields/custom_icon_field.dart';
import '../../../common/proportional_sizes.dart';
// import '../../../common/show_image.dart';
import '../../../common/snack_bar.dart';
import '../../add_items_screen/add_items_screen.dart';

class AddGroupScreenFields extends StatefulWidget {
  final void Function(bool isValid) onValidityChanged;
  final void Function(ExpenseCreate expense)? onExpenseChanged;

  const AddGroupScreenFields({
    super.key,
    required this.onValidityChanged,
    required this.onExpenseChanged,
  });

  @override
  State<AddGroupScreenFields> createState() => _AddGroupScreenFieldsState();
}

class _AddGroupScreenFieldsState extends State<AddGroupScreenFields> {
  bool isNameValid = false;
  bool isDescriptionValid = false;

  void _updateField<T>(void Function() updateState) {
    setState(updateState);
    _notifyExpenseChanged();
  }

  void _updateFormValidity() {
    final isFormValid =
        isNameValid && isDescriptionValid && _expenseItems.isNotEmpty;
    widget.onValidityChanged.call(isFormValid);
  }

  void _notifyExpenseChanged() {
    final expense = getExpenseData();
    widget.onExpenseChanged?.call(expense);
  }

  String _name = "";
  String _description = "";
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  List<ExpenseItemCreate> _expenseItems = [];
  final TextEditingController _amountController = TextEditingController(
    text: '0.00',
  );

  void updateNameValidity(bool isValid) {
    setState(() {
      isNameValid = isValid;
    });
  }

  // Calculate amount based on expense items
  void _updateCalculatedAmount() {
    double total = 0;
    for (var item in _expenseItems) {
      total += item.price * item.quantity;
    }
    setState(() {
      _amountController.text = total.toStringAsFixed(2);
    });
  }

  // get overview of items for display
  String get formattedItemsString {
    final count = _expenseItems.length;
    if (count == 0) return '';
    return '$count ${count == 1 ? 'Item' : 'Items'}';
  }

  // go to items screen
  void _navigateToItemsScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemsScreen(existingItems: _expenseItems),
      ),
    );

    // check for non-null result - I spent so long figuring out this, rip
    if (result != null) {
      final List<ExpenseItemCreate> updatedItems = result;
      setState(() {
        _expenseItems = updatedItems;
        _updateCalculatedAmount();
      });
      _notifyExpenseChanged();
      _updateFormValidity(); // check whether items is empty
    }
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Column(
      children: [
        GeneralField(
          label: 'Name*',
          initialValue: '',
          isEditable: true,
          showStatusIcon: true,
          validationRule: (value) => value.trim().isNotEmpty,
          onValidityChanged: (isValid) {
            setState(() {
              isNameValid = isValid;
            });
            _updateFormValidity();
          },
          maxLength: 50,
          onChanged: (value) => _updateField(() => _name = value),
        ),
        CustomDivider(),

        GeneralField(
          label: 'Description*',
          initialValue: '',
          isEditable: true,
          showStatusIcon: true,
          validationRule: (value) => value.trim().isNotEmpty,
          onValidityChanged: (isValid) {
            setState(() {
              isDescriptionValid = isValid;
            });
            _updateFormValidity();
          },
          maxLength: 50,
          onChanged: (value) => _updateField(() => _description = value),
        ),
        CustomDivider(),

        DateField(
          label: 'Date',
          initialDate: _selectedDate,
          onChanged: (value) => _updateField(() => _selectedDate = value),
        ),
        CustomDivider(),

        GeneralField(
          label: 'Amount (\$)',
          controller: _amountController,
          isEditable: false,
          showStatusIcon: false,
          validationRule: (value) => true,
          maxLength: 10,
        ),
        CustomDivider(),

        CustomIconField(
          label: 'Items',
          value: formattedItemsString,
          hintText: 'No items',
          trailingIconPath: 'assets/icons/add.png',
          onTap: () => _navigateToItemsScreen(context),
        ),
        CustomDivider(),

        DropdownField(
          label: 'Category',
          options:
              ExpenseCategory.values
                  .map((e) => capitalizeString(e.label))
                  .toList(),
          placeholder: 'Select Category',
          addDialogHeading: 'New Category',
          addDialogHintText: 'Enter category name',
          addDialogMaxLength: 20,
          onChanged:
              (value) => _updateField(() {
                final selectedCategory = ExpenseCategory.values.firstWhere(
                  (e) => capitalizeString(e.label) == value,
                  orElse: () => ExpenseCategory.other,
                );
                _selectedCategory = selectedCategory;
              }),
        ),

        CustomDivider(),

        CustomIconField(
          label: 'Split With',
          // TODO: Fetch the group or friends names from the database & set the value.
          // For group, the value should be of the form 'Group - Group Name'
          // For friends, the value should be of the form 'Friend - Friend Name'
          value: '',
          hintText: 'Select Group or Friends',
          trailingIconPath: 'assets/icons/search.png',
          inactive: _expenseItems.isEmpty,
          onTap: () {
            if (_expenseItems.isEmpty) {
              showCustomSnackBar(
                context,
                normalText: 'Please add at least one item before splitting.',
              );
            } else {
              Navigator.pushNamed(context, '/split_with');
            }
          },
        ),
        CustomDivider(),

        CustomIconField(
          label: 'Receipt',
          // TODO: Fetch the attachments with the image
          value: '',
          hintText: 'Save your Receipt here',
          trailingIconPath: 'assets/icons/clip.png',
          onTap: () {
            // TODO: Expand to show the receipt
            // For example, like "showFullScreenImage(context, imageUrl: 'https://example.com/image.png');"
          },
        ),
        CustomDivider(),

        SizedBox(height: proportionalSizes.scaleHeight(24)),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose(); // Prevents memory leaks
    super.dispose();
  }

  // Method to get the current expense data
  ExpenseCreate getExpenseData() {
    return ExpenseCreate(
      name: _name,
      description: _description,
      category: _selectedCategory,
      items: _expenseItems,
      expenseDate: _selectedDate,
    );
  }
}
