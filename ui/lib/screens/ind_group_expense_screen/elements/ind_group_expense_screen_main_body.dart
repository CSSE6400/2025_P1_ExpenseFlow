import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import '../../expenses_screen/elements/expenses_screen_segment_control.dart';
import '../elements/ind_group_expense_screen_list.dart';

class GroupMember {
  final String name;
  final String? status; // null for 'You', else: 'Needs Approval', 'Approved', 'Needs Payment', 'Paid'
  final String amount;

  GroupMember({required this.name, this.status, required this.amount});
}

class ExpenseItem {
  final String name;
  final String price;
  final String date; // ISO 8601 format
  final bool active;
  final List<GroupMember> members;

  ExpenseItem({
    required this.name,
    required this.price,
    required this.date,
    required this.active,
    required this.members,
  });
}

class IndGroupExpenseScreenMainBody extends StatefulWidget {
  final String groupName;

  const IndGroupExpenseScreenMainBody({super.key, required this.groupName});

  @override
  State<IndGroupExpenseScreenMainBody> createState() =>
      _IndGroupExpenseScreenMainBodyState();
}

class _IndGroupExpenseScreenMainBodyState
    extends State<IndGroupExpenseScreenMainBody> {
  String selectedSegment = 'Active';
  String selectedPeriod = 'Last 30 Days';
  late final List<ExpenseItem> allExpenses;
  late final List<String> groupMembers;

  @override
  void initState() {
    super.initState();

    // TODO: Fetch group members from backend using widget.groupName
    groupMembers = ['@abc123', '@xyz987', '@pqr456', '@mno789', 'You'];

    // TODO: Replace with actual data from your database
    // Shouldn't "paid" as active status turn "active" to false?
    allExpenses = [
      ExpenseItem(
        name: 'Uber Ride',
        price: '\$427.28',
        date: '2025-05-09T00:00:00',
        active: true,
        members: [
          GroupMember(name: 'You', amount: '\$150.00'),
          GroupMember(name: '@abc123', status: 'Needs Approval', amount: '\$100.00'),
          GroupMember(name: '@xyz987', status: 'Approved', amount: '\$90.00'),
          GroupMember(name: '@pqr456', status: 'Needs Payment', amount: '\$87.28'),
        ],
      ),
      ExpenseItem(
        name: 'Dinner at Sushi Train',
        price: '\$78.38',
        date: '2024-12-26T00:00:00',
        active: true,
        members: [
          GroupMember(name: 'You', amount: '\$28.38'),
          GroupMember(name: '@mno789', status: 'Needs Payment', amount: '\$50.00'),
        ],
      ),
      ExpenseItem(
        name: 'Movie Tickets',
        price: '\$373.11',
        date: '2025-01-04T00:00:00',
        active: true,
        members: [
          GroupMember(name: 'You', amount: '\$123.11'),
          GroupMember(name: '@xyz987', status: 'Needs Payment', amount: '\$100.00'),
          GroupMember(name: '@abc123', status: 'Approved', amount: '\$100.00'),
          GroupMember(name: '@pqr456', status: 'Needs Approval', amount: '\$50.00'),
        ],
      ),
      ExpenseItem(
        name: 'Taxi Split',
        price: '\$210.00',
        date: '2025-04-01T00:00:00',
        active: false,
        members: [
          GroupMember(name: 'You', amount: '\$70.00'),
          GroupMember(name: '@abc123', status: 'Paid', amount: '\$70.00'),
          GroupMember(name: '@xyz987', status: 'Paid', amount: '\$70.00'),
        ],
      ),
      ExpenseItem(
        name: 'Team Coffee',
        price: '\$95.00',
        date: '2025-02-12T00:00:00',
        active: false,
        members: [
          GroupMember(name: '@mno789', status: 'Paid', amount: '\$65.00'),
          GroupMember(name: '@pqr456', status: 'Paid', amount: '\$30.00'),
        ],
      ),
      ExpenseItem(
        name: 'Board Game Night',
        price: '\$120.00',
        date: '2025-03-15T00:00:00',
        active: false,
        members: [
          GroupMember(name: '@abc123', status: 'Paid', amount: '\$60.00'),
          GroupMember(name: 'You', amount: '\$60.00'),
        ],
      ),
      ExpenseItem(
        name: 'Flight Booking',
        price: '\$393.95',
        date: '2024-11-30T00:00:00',
        active: true,
        members: [
          GroupMember(name: '@xyz987', status: 'Needs Payment', amount: '\$100.00'),
          GroupMember(name: 'You', amount: '\$143.95'),
          GroupMember(name: '@mno789', status: 'Needs Approval', amount: '\$150.00'),
        ],
      ),
      ExpenseItem(
        name: 'Haircut Subscription',
        price: '\$100.00',
        date: '2025-04-26T00:00:00',
        active: true,
        members: [
          GroupMember(name: 'You', amount: '\$50.00'),
          GroupMember(name: '@xyz987', status: 'Needs Payment', amount: '\$50.00'),
        ],
      ),
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
              IndGroupExpenseScreenList(expenses: getFilteredExpenses()),
            ],
          ),
        ),
      ),
    );
  }
}