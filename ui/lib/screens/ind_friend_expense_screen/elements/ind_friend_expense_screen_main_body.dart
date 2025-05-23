import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import '../../expenses_screen/elements/expenses_screen_segment_control.dart';
import '../elements/ind_friend_expense_screen_list.dart';

class ExpenseItem {
  final String name;
  final String price;
  final String date; // ISO 8601 format
  final bool active;
  final String? activeStatus;

  ExpenseItem({
    required this.name,
    required this.price,
    required this.date,
    required this.active,
    this.activeStatus,
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
      ExpenseItem(name: 'Uber Ride', price: '\$427.28', date: '2025-05-09T00:00:00', active: true, activeStatus: 'paid'),
      ExpenseItem(name: 'Dinner at Sushi Train', price: '\$78.38', date: '2024-12-26T00:00:00', active: true, activeStatus: 'approved'),
      ExpenseItem(name: 'Movie Tickets', price: '\$373.11', date: '2025-01-04T00:00:00', active: true, activeStatus: 'paid'),
      ExpenseItem(name: 'Amazon Order', price: '\$69.37', date: '2025-01-07T00:00:00', active: false),
      ExpenseItem(name: 'New Shoes', price: '\$204.72', date: '2024-12-09T00:00:00', active: true, activeStatus: 'needs payment'),
      ExpenseItem(name: 'Flight Booking', price: '\$393.95', date: '2024-11-30T00:00:00', active: true, activeStatus: 'needs payment'),
      ExpenseItem(name: 'Spotify Subscription', price: '\$28.34', date: '2025-02-07T00:00:00', active: false),
      ExpenseItem(name: 'Netflix', price: '\$406.20', date: '2025-03-27T00:00:00', active: false),
      ExpenseItem(name: 'Phone Bill', price: '\$374.85', date: '2025-03-24T00:00:00', active: true, activeStatus: 'needs approval'),
      ExpenseItem(name: 'Laptop Charger', price: '\$56.64', date: '2025-01-28T00:00:00', active: true, activeStatus: 'needs payment'),
      ExpenseItem(name: 'Haircut', price: '\$146.23', date: '2025-04-26T00:00:00', active: true, activeStatus: 'needs approval'),
      ExpenseItem(name: 'Fuel BP Station', price: '\$301.01', date: '2024-12-21T00:00:00', active: true, activeStatus: 'approved'),
      ExpenseItem(name: 'Gym Anytime Fitness', price: '\$139.55', date: '2025-04-05T00:00:00', active: true, activeStatus: 'needs approval'),
      ExpenseItem(name: 'Grocery at Aldi', price: '\$243.17', date: '2025-04-12T00:00:00', active: true, activeStatus: 'needs approval'),
      ExpenseItem(name: 'Streaming Bundle', price: '\$478.10', date: '2025-02-16T00:00:00', active: true, activeStatus: 'needs payment'),
      ExpenseItem(name: 'Taxi to Airport', price: '\$202.50', date: '2025-02-12T00:00:00', active: false),
      ExpenseItem(name: 'Team Lunch', price: '\$280.35', date: '2025-04-19T00:00:00', active: false),
      ExpenseItem(name: 'Coffee Machine', price: '\$64.57', date: '2025-03-25T00:00:00', active: false),
      ExpenseItem(name: 'Earpods Purchase', price: '\$340.95', date: '2024-11-24T00:00:00', active: false),
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
              IndFriendExpenseScreenList(expenses: getFilteredExpenses()),
            ],
          ),
        ),
      ),
    );
  }
}