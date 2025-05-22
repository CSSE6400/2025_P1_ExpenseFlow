import 'package:flutter/material.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/snack_bar.dart';
import '../../../common/custom_button.dart';
import 'add_items_screen_items.dart';

class AddItemsScreenMainBody extends StatefulWidget {
  final double? amount;
  final String? transactionId;
  final bool isReadOnly;

  const AddItemsScreenMainBody({
    super.key,
    this.amount,
    this.transactionId,
    this.isReadOnly = false,
  });

  @override
  State<AddItemsScreenMainBody> createState() => _AddItemsScreenMainBodyState();
}

class _AddItemsScreenMainBodyState extends State<AddItemsScreenMainBody> {
  final GlobalKey<AddItemsScreenItemsState> itemsKey =
      GlobalKey<AddItemsScreenItemsState>();

  bool isItemTotalValid = false;

  void updateItemTotalValidity(bool isValid) {
    setState(() {
      isItemTotalValid = isValid;
    });
  }

  void _handleContinue(BuildContext context) {
    final itemsState = itemsKey.currentState;
    if (itemsState == null) return;

    if (itemsState.isFormValid()) {
      // TODO: Save the items and navigate to the next screen
      itemsState.saveAndExit(context);
    } else {
      showCustomSnackBar(
        context,
        boldText: 'Error:',
        normalText: 'Item totals must exactly match \$${widget.amount?.toStringAsFixed(2) ?? "0.00"}.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Items input section
              AddItemsScreenItems(
                key: itemsKey,
                totalAmount: widget.amount ?? 0,
                onValidityChanged: updateItemTotalValidity,
                isReadOnly: widget.isReadOnly,
                transactionId: widget.transactionId,
              ),

              const SizedBox(height: 24),

              // Continue Button (only in edit mode)
              if (!widget.isReadOnly)
                GestureDetector(
                  onTap: () {
                    if (isItemTotalValid) {
                      _handleContinue(context);
                    } else {
                      showCustomSnackBar(
                        context,
                        boldText: 'Error:',
                        normalText: 'Item totals must total ${widget.amount}.',
                      );
                    }
                  },
                  child: AbsorbPointer(
                    absorbing: !isItemTotalValid,
                    child: CustomButton(
                      label: 'Continue',
                      onPressed: () => _handleContinue(context),
                      state: isItemTotalValid
                          ? ButtonState.enabled
                          : ButtonState.disabled,
                      sizeType: ButtonSizeType.full,
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}