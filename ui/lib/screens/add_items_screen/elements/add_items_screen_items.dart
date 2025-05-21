import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/utils/string_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/custom_divider.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;
import '../../../common/icon_maker.dart';

class ExpenseItem {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  bool isModified;

  ExpenseItem({
    required String name,
    required double price,
    required int quantity,
    this.isModified = false,
  }) : nameController = TextEditingController(text: name),
       priceController = TextEditingController(text: price.toString()),
       quantityController = TextEditingController(text: quantity.toString());

  String get name => nameController.text;

  double get price => double.tryParse(priceController.text) ?? 0.0;

  int get quantity => int.tryParse(quantityController.text) ?? 1;

  double get totalCost => price * quantity;

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }
}

class AddItemsScreenItems extends StatefulWidget {
  final List<ExpenseItem> items;

  final Function(List<ExpenseItem> items, bool hasChanges) onItemsChanged;

  const AddItemsScreenItems({
    super.key,
    required this.items,
    required this.onItemsChanged,
  });

  @override
  State<AddItemsScreenItems> createState() => AddItemsScreenItemsState();
}

class AddItemsScreenItemsState extends State<AddItemsScreenItems> {
  List<ExpenseItem> _items = [];
  List<ExpenseItem> filteredItems = [];
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();

    // clone the items
    _items = widget.items;

    filteredItems = List.from(_items);

    // set up listeners
    _setupItemListeners();
  }

  // parent updates items
  @override
  void didUpdateWidget(AddItemsScreenItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      // Update items if the parent passes new ones
      setState(() {
        _items = widget.items;
        filteredItems = List.from(_items);
        hasChanges = false;
      });
      _setupItemListeners();
    }
  }

  void _setupItemListeners() {
    for (final item in _items) {
      item.nameController.addListener(() => _onItemChanged(item));
      item.priceController.addListener(() => _onItemChanged(item));
      item.quantityController.addListener(() => _onItemChanged(item));
    }
  }

  // callback when any item prop changes
  void _onItemChanged(ExpenseItem item) {
    item.isModified = true;
    setState(() {
      hasChanges = true;
    });
    _notifyParent();
  }

  void _notifyParent() {
    widget.onItemsChanged(_items, hasChanges);
  }

  // filter items
  void _filterItems(String query) {
    setState(() {
      filteredItems =
          _items.where((item) {
            final nameText =
                item.nameController.text.isEmpty
                    ? ""
                    : item.nameController.text;
            return nameText.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  // add new item
  void _addNewItem() {
    final newItem = ExpenseItem(
      name: 'Item Name #${_items.length + 1}',
      price: 0.0,
      quantity: 1,
      isModified: true,
    );

    setState(() {
      _items.add(newItem);
      filteredItems = List.from(_items);
      hasChanges = true;
    });

    // set up listeners
    newItem.nameController.addListener(() => _onItemChanged(newItem));
    newItem.priceController.addListener(() => _onItemChanged(newItem));
    newItem.quantityController.addListener(() => _onItemChanged(newItem));

    _notifyParent();
  }

  // remove item
  void _removeItem(ExpenseItem item) {
    setState(() {
      _items.remove(item);
      filteredItems = List.from(_items);
      hasChanges = true;
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(hintText: 'Search items', onChanged: _filterItems),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Item Name',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: proportionalSizes.scaleHeight(18),
                color: textColor,
              ),
            ),
            Row(
              children: [
                Text(
                  'Qty',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: proportionalSizes.scaleHeight(18),
                    color: textColor,
                  ),
                ),
                SizedBox(width: proportionalSizes.scaleWidth(20)),
                Text(
                  'Price',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: proportionalSizes.scaleHeight(18),
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        CustomDivider(),

        ...filteredItems.map((item) => _buildItemRow(item, proportionalSizes)),

        if (filteredItems.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(proportionalSizes.scaleHeight(20)),
              child: Text('No items found'),
            ),
          ),

        const SizedBox(height: 16),
        GestureDetector(
          onTap: _addNewItem,
          child: Row(
            children: [
              IconMaker(assetPath: 'assets/icons/add.png'),
              const SizedBox(width: 6),
              Text(
                'Add Item',
                style: GoogleFonts.roboto(
                  color: ColorPalette.primaryText,
                  fontSize: proportionalSizes.scaleHeight(16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build each item row
  Widget _buildItemRow(ExpenseItem item, ProportionalSizes proportionalSizes) {
    final textColor = ColorPalette.primaryText;
    final hintColor = ColorPalette.secondaryText;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: proportionalSizes.scaleHeight(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Editable Name Field with Remove Icon
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _removeItem(item),
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: proportionalSizes.scaleWidth(8),
                    ),
                    child: IconMaker(assetPath: 'assets/icons/minus.png'),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: item.nameController,
                    maxLength: 30,
                    onChanged: (value) {
                      String formatted = titleCaseString(value);

                      // Update only if formatting changes it
                      if (formatted != value) {
                        // Avoid invalid cursor position
                        final newLength = formatted.length;
                        item.nameController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: newLength.clamp(0, newLength),
                          ),
                        );
                      }
                    },
                    style: GoogleFonts.roboto(
                      fontSize: proportionalSizes.scaleHeight(18),
                      color:
                          item.nameController.text.isEmpty
                              ? hintColor
                              : textColor,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "",
                      counterText: '', // Hides counter below
                      hintStyle: GoogleFonts.roboto(
                        fontSize: proportionalSizes.scaleHeight(18),
                        color: hintColor,
                      ),
                      isCollapsed: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quantity Input Box
          Container(
            width: proportionalSizes.scaleWidth(40),
            padding: EdgeInsets.symmetric(
              horizontal: proportionalSizes.scaleWidth(8),
              vertical: proportionalSizes.scaleHeight(4),
            ),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                proportionalSizes.scaleWidth(6),
              ),
            ),
            child: TextField(
              controller: item.quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: proportionalSizes.scaleHeight(14),
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
              ),
            ),
          ),

          SizedBox(width: proportionalSizes.scaleWidth(10)),

          // Price Input Box
          Container(
            width: proportionalSizes.scaleWidth(70),
            padding: EdgeInsets.symmetric(
              horizontal: proportionalSizes.scaleWidth(8),
              vertical: proportionalSizes.scaleHeight(4),
            ),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                proportionalSizes.scaleWidth(6),
              ),
            ),
            child: TextField(
              controller: item.priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
              ],
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: proportionalSizes.scaleHeight(14),
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: ColorPalette.primaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Supposedly this is a good idea?
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }
}
