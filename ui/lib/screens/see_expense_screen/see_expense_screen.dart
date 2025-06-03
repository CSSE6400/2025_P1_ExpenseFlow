import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart'
    show SnackBarType, showCustomSnackBar;
import 'package:flutter_frontend/models/enums.dart';
import 'package:flutter_frontend/models/expense.dart'
    show ExpenseCreate, ExpenseRead, SplitStatusInfo;
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/screens/see_expense_screen/elements/see_expense_approvals.dart';
import 'package:flutter_frontend/screens/see_expense_screen/elements/see_expense_view.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:flutter_frontend/screens/see_expense_screen/elements/expense_view_segment_control.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;
import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';

class SeeExpenseScreen extends StatefulWidget {
  final String expenseId;

  const SeeExpenseScreen({super.key, required this.expenseId});

  @override
  State<SeeExpenseScreen> createState() => _SeeExpenseScreenState();
}

class _SeeExpenseScreenState extends State<SeeExpenseScreen> {
  final Logger _logger = Logger("SeeExpenseScreen");
  ExpenseRead? expense;
  UserRead? me;
  List<SplitStatusInfo> splitStatuses = [];
  ExpenseViewSegment selectedSegment = ExpenseViewSegment.information;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool isEditable() {
    if (expense == null || me == null) return false;

    return expense!.uploader.userId == me!.userId && isEditMode;
  }

  bool isItemsAndSplitsEditable() {
    return isEditable() &&
        (expense!.status == ExpenseStatus.requested ||
            (splitStatuses.length == 1 &&
                splitStatuses[0].userId == me!.userId));
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      me = await apiService.userApi.mustGetCurrentUser();
      if (me == null) {
        _logger.warning('Current user not found');
        if (!mounted) return;

        showCustomSnackBar(context, normalText: 'Unable to find current user');
        setState(() => isLoading = false);

        Navigator.of(context).pushNamed('/');
        return;
      }
      setState(() {
        me = me;
      });
      final fetchedExpense = await apiService.expenseApi.getExpense(
        widget.expenseId,
      );

      if (fetchedExpense == null) {
        _logger.warning('Expense with ID ${widget.expenseId} not found');
        if (!mounted) return;

        showCustomSnackBar(context, normalText: 'Unable to find expense');
        setState(() => isLoading = false);
        Navigator.of(context).pop();
        return;
      }

      setState(() {
        expense = fetchedExpense;
        _currentExpense = ExpenseCreate.fromExpenseRead(expense!);
        isLoading = false;
      });

      _logger.info('Expense fetched successfully: ${expense!.expenseId}');

      final fetchedStatuses = await apiService.expenseApi.getAllExpenseStatuses(
        widget.expenseId,
      );

      setState(() => splitStatuses = fetchedStatuses);
    } catch (e) {
      if (!mounted) return;
      _logger.severe('Error fetching expense: $e');
      showCustomSnackBar(context, normalText: 'Failed to fetch expense');
      setState(() => isLoading = false);
    }
  }

  bool isEditMode = false;

  bool isFormValid = true;
  void updateFormValid(bool isValid) {
    setState(() => isFormValid = isValid);
  }

  ExpenseCreate? _currentExpense;
  void updateExpense(ExpenseCreate expense) {
    _currentExpense = expense;
  }

  Future<void> saveExpense() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (_currentExpense == null) {
      showCustomSnackBar(context, normalText: "Please fill in all fields");
      return;
    }

    try {
      final newExpense = await apiService.expenseApi.updateExpense(
        expense!.expenseId,
        _currentExpense!,
      );

      setState(() {
        isEditMode = false;
        expense = newExpense;
        _currentExpense = ExpenseCreate.fromExpenseRead(newExpense);
      });
      if (!mounted) return;
      showCustomSnackBar(
        context,
        type: SnackBarType.success,
        normalText: "Successfully updated expense",
      );
    } catch (e) {
      _logger.severe("Failed to update expense", e);
      if (!mounted) return;
      showCustomSnackBar(context, normalText: "Failed to update expense");
    }
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

    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBarWidget(screenName: 'View Expense', showBackButton: true),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              ExpenseViewSegmentControl(
                selectedSegment: selectedSegment,
                onSegmentChanged: (segment) {
                  setState(() => selectedSegment = segment);
                },
              ),

              Expanded(
                child:
                    selectedSegment == ExpenseViewSegment.information
                        ? SeeExpenseView(
                          expense: expense!,
                          currentExpense: _currentExpense,
                          isEditMode: isEditMode,
                          isEditable: isEditable(),
                          isItemsAndSplitsEditable: isItemsAndSplitsEditable(),
                          isFormValid: isFormValid,
                          onValidityChanged: updateFormValid,
                          onExpenseChanged: updateExpense,
                          onSave: saveExpense,
                          onEdit: () => setState(() => isEditMode = true),
                          onCancel: () {
                            setState(() {
                              isEditMode = false;
                              _currentExpense = null;
                            });
                          },
                        )
                        : SeeExpenseApprovals(
                          expense: expense!,
                          splitStatuses: splitStatuses,
                          currentUser: me!,
                          onApprovePressed: () => {},
                        ),
              ),
            ],
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
