import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
import '../../../common/proportional_sizes.dart';
import 'expenses_screen_segment_control.dart';
import 'expenses_screen_list.dart';

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
  late final List<ExpenseItem> allExpenses;

  @override
  void initState() {
    super.initState();
    // TODO: Replace with actual data from your database
    allExpenses = [
      ExpenseItem(name: 'Shopping at Coles', price: '\$78.9', date: '2024-06-10T14:20:00Z', active: false),
      ExpenseItem(name: 'Uber Ride', price: '\$25.5', date: '2024-05-30T09:30:00Z', active: true),
      ExpenseItem(name: 'Dinner at Sushi Train', price: '\$60.2', date: '2024-04-22T19:45:00Z', active: false),
      ExpenseItem(name: 'Movie Tickets', price: '\$34.0', date: '2023-12-12T20:00:00Z', active: true),
      ExpenseItem(name: 'Fuel BP Station', price: '\$89.9', date: '2024-06-01T16:00:00Z', active: false),
      ExpenseItem(name: 'Haircut', price: '\$45.0', date: '2024-03-15T11:15:00Z', active: true),
      ExpenseItem(name: 'Gym Anytime Fitness', price: '\$99.0', date: '2024-01-05T08:00:00Z', active: false),
      ExpenseItem(name: 'Grocery at Aldi', price: '\$62.3', date: '2023-11-27T17:00:00Z', active: false),
      ExpenseItem(name: 'Flight Booking', price: '\$450.0', date: '2024-02-18T12:00:00Z', active: true),
      ExpenseItem(name: 'Laptop Charger', price: '\$120.0', date: '2024-05-10T14:00:00Z', active: true),
      ExpenseItem(name: 'Spotify Subscription', price: '\$11.99', date: '2024-06-02T00:00:00Z', active: true),
      ExpenseItem(name: 'Netflix', price: '\$15.99', date: '2024-05-02T00:00:00Z', active: false),
      ExpenseItem(name: 'Phone Bill', price: '\$65.0', date: '2024-04-01T00:00:00Z', active: false),
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