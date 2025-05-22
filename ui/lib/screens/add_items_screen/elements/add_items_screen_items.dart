import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/custom_divider.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;
import '../../../common/icon_maker.dart';

// Item class
// TODO: Consider adding userId, transactionId or unique identifier for backend syncing
class Item {
  String amount;
  final String defaultName;
  final TextEditingController nameController;
  final TextEditingController amountController;

  Item({
    required String name,
    required this.amount,
  })  : defaultName = name,
        nameController = TextEditingController(text: ''),
        amountController = TextEditingController(text: amount);
}

class AddItemsScreenItems extends StatefulWidget {
  final double totalAmount;
  final void Function(bool isValid)? onValidityChanged;
  final String? transactionId;
  final bool isReadOnly;

  const AddItemsScreenItems({
    super.key,
    required this.totalAmount,
    this.onValidityChanged,
    this.transactionId,
    this.isReadOnly = false,
  });

  @override
  State<AddItemsScreenItems> createState() => AddItemsScreenItemsState();
}

class AddItemsScreenItemsState extends State<AddItemsScreenItems> {
  List<Item> allItems = [];
  List<Item> filteredItems = [];

  // Initialize items
  @override
  void initState() {
    super.initState();

    // Dummy starting items.
    // TODO: Replace with actual data from the backend and add lazy loading if items are numerous.
    // TODO: If transactionId is provided, fetch split-with data from backend.
    // Pre-fill the screen for editing or read-only display.
    allItems = List.generate(
      1,
      (index) => Item(name: 'Item Name #${index + 1}', amount: '10'),
    );
    filteredItems = List.from(allItems);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidityChanged?.call(isFormValid());
    });
  }

  // Filter items based on search query
  void _filterItems(String query) {
    setState(() {
      filteredItems = allItems.where((item) {
        return item.nameController.text.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  bool isFormValid() {
    final isAmountValid = allItems.fold<double>(
          0,
          (sum, item) => sum + (double.tryParse(item.amount) ?? 0),
        ) ==
        widget.totalAmount;

    final areNamesValid = allItems.every(
      (item) =>
          item.nameController.text.trim().isNotEmpty &&
          item.nameController.text.trim() != item.defaultName,
    );

    return isAmountValid && areNamesValid;
  }

  void saveAndExit(BuildContext context) {
    // TODO: Persist item list if needed
    Navigator.pop(context);
  }

  // Add a new item
  void _addNewItem() {
    setState(() {
      final newItem = Item(
        name: 'Item Name #${allItems.length + 1}',
        amount: '0',
      );
      allItems.add(newItem);
      filteredItems = List.from(allItems);
      widget.onValidityChanged?.call(isFormValid());
    });
  }

  // Remove an item
  void _removeItem(Item item) {
    setState(() {
      allItems.remove(item);
      filteredItems = List.from(allItems);
      widget.onValidityChanged?.call(isFormValid());
    });
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(
          hintText: 'Search items',
          onChanged: _filterItems,
        ),
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
        CustomDivider(),

        ...filteredItems.map((item) => _buildItemRow(item, proportionalSizes)),

        const SizedBox(height: 16),
        if (!widget.isReadOnly)
          GestureDetector(
            onTap: _addNewItem,
            child: Row(
              children: [
                IconMaker(
                  assetPath: 'assets/icons/add.png',
                ),
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
  Widget _buildItemRow(Item item, ProportionalSizes proportionalSizes) {
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
                if (!widget.isReadOnly)
                  GestureDetector(
                    onTap: () => _removeItem(item),
                    child: Padding(
                      padding: EdgeInsets.only(right: proportionalSizes.scaleWidth(8)),
                      child: IconMaker(
                        assetPath: 'assets/icons/minus.png',
                      ),
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: item.nameController,
                    enabled: !widget.isReadOnly,
                    maxLength: 30,
                    onChanged: (value) {
                      // Format input to Title Case
                      String formatted = value
                          .toLowerCase()
                          .split(' ')
                          .where((w) => w.isNotEmpty)
                          .map((word) => word[0].toUpperCase() + word.substring(1))
                          .join(' ');

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

                      setState(() {
                        widget.onValidityChanged?.call(isFormValid());
                      });
                    },
                    style: GoogleFonts.roboto(
                      fontSize: proportionalSizes.scaleHeight(18),
                      color: item.nameController.text.isEmpty
                          ? hintColor
                          : textColor,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: item.defaultName,
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
              controller: item.amountController,
              enabled: !widget.isReadOnly,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}$'),
                ),
              ],
              textAlign: TextAlign.center,
              onChanged: widget.isReadOnly
                ? null
                : (value) {
                    setState(() {
                      item.amount = value;
                      widget.onValidityChanged?.call(isFormValid());
                    });
                  },
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
}