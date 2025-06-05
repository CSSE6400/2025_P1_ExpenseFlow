import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/models/expense.dart' show ExpenseCreate;
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:flutter_frontend/widgets/expense_form.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
import '../../common/proportional_sizes.dart';
import '../../common/custom_button.dart';
import '../add_expense_screen/elements/add_expense_screen_scan_receipt.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  bool isFormValid = false;
  ExpenseCreate? _currentExpense;
  String? _parentId;
  final Logger _logger = Logger("AddExpenseScreen");

  @override
  void initState() {
    super.initState();
  }

  void updateFormValid(bool isValid) {
    setState(() => isFormValid = isValid);
  }

  // optional parentId is used when adding a group expense
  void updateExpense(ExpenseCreate expense, String? parentId) {
    _currentExpense = expense;
    _parentId = parentId;
  }

  Future<void> onAdd() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (_currentExpense == null) {
      showCustomSnackBar(context, normalText: "Please fill in all fields");
      return;
    }

    _logger.info("Adding expense: ${_currentExpense?.toJson()}");
    _logger.info(
      "Splits are ${_currentExpense?.splits?.map((e) => e.toJson()).toList()}",
    );

    try {
      await apiService.expenseApi.createExpense(_currentExpense!, _parentId);
      if (!mounted) return;
      showCustomSnackBar(
        context,
        type: SnackBarType.success,
        normalText: "Successfully added expense",
      );
      Navigator.pushNamed(context, '/');
    } catch (e) {
      _logger.severe("Failed to add expense", e);
      if (!mounted) return;
      showCustomSnackBar(context, normalText: "Failed to add expense");
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;
    final proportionalSizes = ProportionalSizes(context: context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(screenName: 'Add Expense', showBackButton: false),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: proportionalSizes.scaleWidth(20),
              vertical: proportionalSizes.scaleHeight(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AddExpenseScreenScanReceipt(),
                SizedBox(height: proportionalSizes.scaleHeight(20)),

                ExpenseForm(
                  onValidityChanged: updateFormValid,
                  onExpenseChanged: updateExpense,
                  canEdit: true,
                  canEditItems: true,
                  canEditSplits: true,
                ),
                SizedBox(height: proportionalSizes.scaleHeight(24)),

                CustomButton(
                  label: 'Add Expense',
                  onPressed: isFormValid ? onAdd : () {},
                  sizeType: ButtonSizeType.full,
                  state:
                      isFormValid ? ButtonState.enabled : ButtonState.disabled,
                ),
                SizedBox(height: proportionalSizes.scaleHeight(96)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentScreen: BottomNavBarScreen.add,
        inactive: false,
      ),
    );
  }
}
