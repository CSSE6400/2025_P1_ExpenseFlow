import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/enums.dart' show ExpenseCategory;
import 'package:flutter_frontend/screens/add_items_screen/add_items_screen.dart'
    show AddItemsScreen;
import 'package:flutter_frontend/utils/string_utils.dart';
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/fields/date_field/date_field.dart';
import '../../../common/fields/dropdown_field.dart';
import '../../../models/expense.dart';
import '../../../common/fields/custom_icon_field.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/snack_bar.dart';

class ExpenseForm extends StatefulWidget {
  final ExpenseCreate? initialExpense; // optional for editing

  final void Function(bool isValid) onValidityChanged;
  final void Function(ExpenseCreate expense)? onExpenseChanged;

  final bool canEdit;
  final bool canEditItems;
  final bool canEditSplits;

  const ExpenseForm({
    super.key,
    this.initialExpense,
    required this.onValidityChanged,
    required this.onExpenseChanged,
    required this.canEdit,
    required this.canEditItems,
    required this.canEditSplits,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  bool isNameValid = false;
  bool isDescriptionValid = false;

  late String _name;
  late String _description;
  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;
  late List<ExpenseItemCreate> _expenseItems;

  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();

    // populate fields
    _name = widget.initialExpense?.name ?? '';
    _description = widget.initialExpense?.description ?? '';
    _selectedDate = widget.initialExpense?.expenseDate ?? DateTime.now();
    _selectedCategory =
        widget.initialExpense?.category ?? ExpenseCategory.other;
    _expenseItems = widget.initialExpense?.items ?? [];

    _amountController = TextEditingController(text: '0.00');

    // update total amount
    _updateCalculatedAmount();

    // validate initial name and description
    isNameValid = _name.trim().isNotEmpty;
    isDescriptionValid = _description.trim().isNotEmpty;

    // notify initial validity and expense data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFormValidity();
      _notifyExpenseChanged();
    });
  }

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

  void updateNameValidity(bool isValid) {
    setState(() {
      isNameValid = isValid;
    });
  }

  void _updateCalculatedAmount() {
    double total = 0;
    for (var item in _expenseItems) {
      total += item.price * item.quantity;
    }
    _amountController.text = total.toStringAsFixed(2);
  }

  String get formattedItemsString {
    final count = _expenseItems.length;
    if (count == 0) return '';
    return '$count ${count == 1 ? 'Item' : 'Items'}';
  }

  void _navigateToItemsScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemsScreen(existingItems: _expenseItems),
      ),
    );

    if (result != null) {
      final List<ExpenseItemCreate> updatedItems = result;
      setState(() {
        _expenseItems = updatedItems;
        _updateCalculatedAmount();
      });
      _notifyExpenseChanged();
      _updateFormValidity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Column(
      children: [
        GeneralField(
          label: 'Name*',
          initialValue: _name,
          isEditable: widget.canEdit,
          showStatusIcon: widget.canEdit,
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
          initialValue: _description,
          isEditable: widget.canEdit,
          showStatusIcon: widget.canEdit,
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
          isEnabled: widget.canEditItems && widget.canEdit,
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
          isEditable: widget.canEdit,
          placeholder: 'Select Category',
          addDialogHeading: 'New Category',
          addDialogHintText: 'Enter category name',
          addDialogMaxLength: 20,
          onChanged:
              (value) => _updateField(() {
                final selectedCategory = ExpenseCategory.values.firstWhere(
                  (e) => titleCaseString(e.label) == value,
                  orElse: () => ExpenseCategory.other,
                );
                _selectedCategory = selectedCategory;
              }),
          selectedValue: titleCaseString(_selectedCategory.label),
        ),
        CustomDivider(),
        CustomIconField(
          label: 'Split With',
          value: '',
          isEnabled: widget.canEditSplits && widget.canEdit,
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
          value: '',
          isEnabled: widget.canEdit,
          hintText: 'Save your Receipt here',
          trailingIconPath: 'assets/icons/clip.png',
          onTap: () {
            // TODO: Show receipt or attachment viewer
          },
        ),
        CustomDivider(),
        SizedBox(height: proportionalSizes.scaleHeight(24)),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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
