import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart' show showCustomSnackBar;
import 'package:flutter_frontend/models/expense.dart' show ExpenseRead;
import 'package:flutter_frontend/screens/see_expense_screen/elements/see_expense_screen_fields.dart'
    show SeeExpenseScreenFields;
import 'package:flutter_frontend/screens/see_expense_screen/elements/see_expense_screen_status.dart'
    show SeeExpenseScreenActiveStatus;
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/custom_button.dart';

class SeeExpenseScreen extends StatefulWidget {
  final String expenseId;

  const SeeExpenseScreen({super.key, required this.expenseId});

  @override
  State<SeeExpenseScreen> createState() => _SeeExpenseScreenState();
}

class _SeeExpenseScreenState extends State<SeeExpenseScreen> {
  final Logger _logger = Logger("SeeExpenseScreen");
  ExpenseRead? expense;

  bool isLoading = true;

  // Validation and editing state variables
  bool isNameValid = true;
  bool isAmountValid = true;
  bool isEditMode = false;

  bool get isFormValid => isNameValid && isAmountValid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final fetchedExpense = await apiService.expenseApi.getExpense(
        widget.expenseId,
      );

      if (fetchedExpense == null) {
        _logger.warning('Expense with ID ${widget.expenseId} not found');
        if (!mounted) return;

        showCustomSnackBar(context, normalText: 'Unable to find expense');
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        expense = fetchedExpense;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _logger.severe('Error fetching expense: $e');
      showCustomSnackBar(context, normalText: 'Failed to fetch expense');
      setState(() => isLoading = false);
    }
  }

  void updateNameValidity(bool isValid) {
    setState(() => isNameValid = isValid);
  }

  void updateAmountValidity(bool isValid) {
    setState(() => isAmountValid = isValid);
  }

  Future<void> _onSave() async {
    // TODO: Save updated fields to backend using expense.expenseId

    setState(() => isEditMode = false);
  }

  void _onEdit() {
    setState(() => isEditMode = true);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (expense == null) {
      _logger.warning("Expense is null");
      return const Scaffold(body: Center(child: Text("Expense not found")));
    }

    final proportionalSizes = ProportionalSizes(context: context);

    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBarWidget(screenName: 'View Expense', showBackButton: true),
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
                SeeExpenseScreenActiveStatus(status: expense!.status),
                SizedBox(height: proportionalSizes.scaleHeight(20)),
                SeeExpenseScreenFields(
                  onNameValidityChanged: updateNameValidity,
                  onAmountValidityChanged: updateAmountValidity,
                  isAmountValid: isAmountValid,
                  isReadOnly: !isEditMode,
                  transactionId: expense!.expenseId,
                ),
                SizedBox(height: proportionalSizes.scaleHeight(24)),
                CustomButton(
                  label: isEditMode ? 'Save' : 'Edit',
                  onPressed:
                      isEditMode ? (isFormValid ? _onSave : () {}) : _onEdit,
                  sizeType: ButtonSizeType.full,
                  state:
                      isEditMode
                          ? (isFormValid
                              ? ButtonState.enabled
                              : ButtonState.disabled)
                          : ButtonState.enabled,
                ),
                SizedBox(height: proportionalSizes.scaleHeight(96)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentScreen: 'See',
        inactive: false,
      ),
    );
  }
}
