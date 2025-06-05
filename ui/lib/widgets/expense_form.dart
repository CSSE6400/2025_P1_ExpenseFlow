import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/enums.dart' show ExpenseCategory;
import 'package:flutter_frontend/models/group.dart' show GroupReadWithMembers;
import 'package:flutter_frontend/models/user.dart' show UserRead;
import 'package:flutter_frontend/screens/add_items_screen/add_items_screen.dart'
    show AddItemsScreen;
import 'package:flutter_frontend/screens/split_with_screen/split_with_screen.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:flutter_frontend/services/auth_guard_provider.dart'
    show AuthGuardProvider;
import 'package:flutter_frontend/utils/string_utils.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/fields/date_field/date_field.dart';
import '../../../common/fields/dropdown_field.dart';
import '../../../models/expense.dart';
import '../../../common/fields/custom_icon_field.dart';
import '../../../common/snack_bar.dart';

class ExpenseForm extends StatefulWidget {
  final ExpenseCreate? initialExpense; // optional for editing

  final void Function(bool isValid) onValidityChanged;
  final void Function(ExpenseCreate expense, String? parentId)?
  onExpenseChanged;

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
  List<ExpenseItemSplitCreate> _expenseSplits = [];

  String? _selectedGroupId;

  UserRead? user;
  List<UserRead> friends = [];
  List<GroupReadWithMembers> groups = [];
  bool isLoading = true;

  late TextEditingController _amountController;
  late TextEditingController _splitAmountController;

  final _logger = Logger('ExpenseForm');

  @override
  void initState() {
    super.initState();

    final authGuard = Provider.of<AuthGuardProvider>(context, listen: false);
    user = authGuard.mustGetUser(context);

    _loadData();

    // populate fields
    _name = widget.initialExpense?.name ?? '';
    _description = widget.initialExpense?.description ?? '';
    _selectedDate = widget.initialExpense?.expenseDate ?? DateTime.now();
    _selectedCategory =
        widget.initialExpense?.category ?? ExpenseCategory.other;
    _expenseItems = widget.initialExpense?.items ?? [];
    _expenseSplits = widget.initialExpense?.splits ?? [];

    _amountController = TextEditingController(text: '0.00');
    _splitAmountController = TextEditingController(text: '0.00');

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

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final fetchedFriends = await apiService.friendApi.getFriends();

      setState(() {
        friends = fetchedFriends;
      });

      final fetchedGroups =
          await apiService.groupApi.getUsersGroupsWithMembers();

      setState(() {
        groups = fetchedGroups;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _logger.severe('Error fetching data: $e');
      showCustomSnackBar(context, normalText: 'Failed to fetch expense data');
      setState(() => isLoading = false);
    }
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
    widget.onExpenseChanged?.call(expense, _selectedGroupId);
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
    _logger.info('Total amount calculated: $total');
    _logger.info('Total number of splits : ${_expenseSplits.length}');
    _splitAmountController.text = (total /
            (_expenseSplits.isNotEmpty ? _expenseSplits.length : 1))
        .toStringAsFixed(2);
    _logger.info(
      'Your split amount calculated: ${_splitAmountController.text}',
    );
  }

  String get formattedItemsString {
    final count = _expenseItems.length;
    if (count == 0) return '';
    return '$count ${count == 1 ? 'Item' : 'Items'}';
  }

  void _navigateToItemsScreen(BuildContext context, bool isReadOnly) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddItemsScreen(
              existingItems: _expenseItems,
              isReadOnly: isReadOnly,
            ),
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

  void _navigateToSplitsScreen(BuildContext context, bool isReadyOnly) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SplitWithScreen(
              splits: _expenseSplits,
              isReadOnly: isReadyOnly,
              groups: groups,
              friends: friends,
              currentUser: user!,
              selectedGroupId: _selectedGroupId,
            ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final updatedItems = result['splits'] as List<ExpenseItemSplitCreate>;
      final groupId = result['groupId'] as String?;

      setState(() {
        _expenseSplits = updatedItems;
        _selectedGroupId = groupId;
        _updateCalculatedAmount();
      });
      _notifyExpenseChanged();
      _updateFormValidity();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || user == null) {
      return Center(child: CircularProgressIndicator());
    }

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
          label: 'Total (\$)',
          controller: _amountController,
          isEditable: false,
          showStatusIcon: false,
          validationRule: (value) => true,
          maxLength: 10,
        ),
        GeneralField(
          label: 'Your Split (\$)',
          controller: _splitAmountController,
          isEditable: false,
          showStatusIcon: false,
          validationRule: (value) => true,
          maxLength: 10,
        ),
        CustomDivider(),
        CustomIconField(
          label: 'Items',
          isEnabled: true,
          value: formattedItemsString,
          hintText: 'No items',
          trailingIconPath: 'assets/icons/add.png',
          onTap: () => _navigateToItemsScreen(context, !widget.canEditItems),
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
          isEnabled: true,
          hintText:
              _expenseSplits.isEmpty
                  ? 'Select Group or Friends'
                  : 'Split between ${_expenseSplits.length} people',
          trailingIconPath: 'assets/icons/search.png',
          inactive: _expenseItems.isEmpty,
          onTap: () {
            _logger.info('Navigating to splits screen');
            if (_expenseItems.isEmpty) {
              showCustomSnackBar(
                context,
                normalText: 'Please add at least one item before splitting.',
              );
            } else {
              _navigateToSplitsScreen(
                context,
                !(widget.canEditSplits && widget.canEdit),
              );
            }
          },
        ),
        CustomDivider(),
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
      splits: _expenseSplits,
    );
  }
}
