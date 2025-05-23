import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import '../../expenses_screen/elements/expenses_screen_segment_control.dart';
import '../../expenses_screen/elements/expenses_screen_list.dart';

class ExpenseItem {
  final String name;
  final String price;
  final String date; // ISO 8601 format
  final bool active;

  ExpenseItem({
    required this.name,
    required this.price,
    required this.date,
    required this.active,
  });
}

class IndFriendExpenseScreenMainBody extends StatefulWidget {
  final String username;

  const IndFriendExpenseScreenMainBody({super.key, required this.username});

  @override
  State<IndFriendExpenseScreenMainBody> createState() =>
      _IndFriendExpenseScreenMainBodyState();
}

class _IndFriendExpenseScreenMainBodyState
    extends State<IndFriendExpenseScreenMainBody> {
  String selectedSegment = 'Active';
  String selectedPeriod = 'Last 30 Days';
  late final List<ExpenseItem> allExpenses;

  @override
  void initState() {
    super.initState();
    // Sample data for expenses
    // TODO: Replace with actual data from your database
    allExpenses = [
      ExpenseItem(name: 'Uber Ride', price: '\$25.5', date: '2024-05-30T09:30:00Z', active: true),
      ExpenseItem(name: 'Dinner at Sushi Train', price: '\$60.2', date: '2024-04-22T19:45:00Z', active: false),
      ExpenseItem(name: 'Movie Tickets', price: '\$34.0', date: '2023-12-12T20:00:00Z', active: true),
      ExpenseItem(name: 'Amazon Order', price: '\$140.75', date: '2024-05-15T13:10:00Z', active: true),
      ExpenseItem(name: 'New Shoes', price: '\$130.0', date: '2024-03-20T16:30:00Z', active: true),
    ];
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

  List<ExpenseItem> getFilteredExpenses() {
    List<ExpenseItem> result = allExpenses;

    // Time filtering
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

    // Segment filtering
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
              // Segment Control
              ExpensesScreenSegmentControl(
                selectedSegment: selectedSegment,
                onSegmentChanged: handleSegmentChange,
              ),

              // Time Period Dropdown
              Align(
                alignment: Alignment.centerRight,
                child: TimePeriodDropdown(
                  selectedPeriod: selectedPeriod,
                  onChanged: handleTimePeriodChange,
                ),
              ),
              SizedBox(height: proportionalSizes.scaleHeight(20)),

              // Expense List
              ExpensesScreenList(expenses: getFilteredExpenses()),
            ],
          ),
        ),
      ),
    );
  }
}