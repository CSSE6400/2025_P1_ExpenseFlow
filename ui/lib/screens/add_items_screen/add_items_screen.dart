import 'package:flutter/material.dart';
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/custom_button.dart';
import '../../models/expense.dart';
import 'elements/add_items_screen_items.dart';

class AddItemsScreen extends StatefulWidget {
  final double? amount;
  final String? transactionId;
  final bool isReadOnly;
  final List<ExpenseItemCreate> existingItems;

  const AddItemsScreen({
    super.key, 
    this.existingItems = const [],
    this.transactionId,
    this.isReadOnly = false,
    this.amount,
  });

  @override
  State<AddItemsScreen> createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  List<ExpenseItem> items = [];

  @override
  void initState() {
    super.initState();
    // convert expense item creates to expense items
    items =
        widget.existingItems.map((expenseItem) {
          return ExpenseItem(
            name: expenseItem.name,
            price: expenseItem.price,
            quantity: expenseItem.quantity,
          );
        }).toList();
  }

  // callback on items change
  void _onItemsChanged(List<ExpenseItem> updatedItems, bool hasChanges) {
    setState(() {
      items = updatedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBarWidget(screenName: 'Add Items', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: AddItemsScreenItems(
                    items: items,
                    onItemsChanged: _onItemsChanged,
                    isReadOnly: widget.isReadOnly,
                    transactionId: widget.transactionId,
                  ),
                ),
              ),
              if (!widget.isReadOnly)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CustomButton(
                    label: 'Confirm Items',
                    onPressed: _saveAndReturn,
                    state: ButtonState.enabled,
                    sizeType: ButtonSizeType.full,
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentScreen: 'Add',
        inactive: true,
      ),
    );
  }

  // return items to calling screen
  void _saveAndReturn() {
    final expenseItems =
        items
            .map(
              (item) => ExpenseItemCreate(
                name:
                    item.nameController.text.isNotEmpty
                        ? item.nameController.text
                        : "",
                quantity: item.quantity,
                price: item.price,
              ),
            )
            .toList();

    // return the items list to the previous screen
    Navigator.pop(context, expenseItems);
  }
}
