import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
import 'package:logging/logging.dart';
import '../../../common/proportional_sizes.dart';
import 'expenses_screen_segment_control.dart';
import 'expenses_screen_list.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;

class ExpenseItem {
  final String name;
  final String price;
  final String date; // iso 8601 format
  final bool active;

  ExpenseItem({
    required this.name,
    required this.price,
    required this.date,
    required this.active,
  });
}

class ExpensesScreenMainBody extends StatefulWidget {
  const ExpensesScreenMainBody({super.key});

  @override
  State<ExpensesScreenMainBody> createState() => _ExpensesScreenMainBodyState();
}

class _ExpensesScreenMainBodyState extends State<ExpensesScreenMainBody> {
  String selectedSegment = 'Active';
  String selectedPeriod = 'Last 30 Days';
  late List<ExpenseItem> allExpenses = [];
  final Logger _logger = Logger("ExpenseScreenMainBody");

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await _fetchUserExpenses();
    setState(() {
      allExpenses = expenses;
    });
}

  Future<List<ExpenseItem>> _fetchUserExpenses() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.expenseApi.getExpensesUploadedByMe(); //TODO: make appropriate end point

      final rawCategories = userReads.map((expense) {
        return ExpenseItem(
          name:expense.name,
          price: "100", // TODO: change to better fitting end point with a price.
          date: expense.expenseDate.toIso8601String(),
          active: true  // Active if not completed
        );
      }).toList();
      _logger.info("number of recent categories: ${rawCategories.length}");
      return rawCategories;
    } catch (e) {
      _logger.warning("Failed to get recent categories: $e");
      return [];
    }
  }

  void handleSegmentChange(String newSegment) {
    setState(() {
      selectedSegment = newSegment;
    });
  }

  void handleTimePeriodChange(String? newPeriod) {
    if (newPeriod != null) {
      setState(() {
        selectedPeriod = newPeriod;
      });
    }
  }

  // filter based on selected time period and segment
  List<ExpenseItem> getFilteredExpenses() {
    List<ExpenseItem> result = allExpenses;

    if (selectedPeriod != 'From Start') {
      final match = RegExp(r'Last (\d+) Days').firstMatch(selectedPeriod);
      if (match != null) {
        final int days = int.parse(match.group(1)!);
        final DateTime cutoff = DateTime.now().subtract(Duration(days: days));
        result = result.where((e) {
          try {
            return DateTime.parse(e.date).isAfter(cutoff);
          } catch (_) {
            return false;
          }
        }).toList();
      }
    }

    // filter by segment active or all
    if (selectedSegment == 'Active') {
      result = result.where((e) => e.active).toList();
    }

    return result;
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
              ExpensesScreenSegmentControl(
                selectedSegment: selectedSegment,
                onSegmentChanged: handleSegmentChange,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TimePeriodDropdown(
                  selectedPeriod: selectedPeriod,
                  onChanged: handleTimePeriodChange,
                ),
              ),
              SizedBox(height: proportionalSizes.scaleHeight(20)),

              ExpensesScreenList(expenses: getFilteredExpenses()),
            ],
          ),
        ),
      ),
    );
  }
}