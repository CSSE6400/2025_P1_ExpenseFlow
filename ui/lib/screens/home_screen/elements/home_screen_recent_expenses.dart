// Flutter imports
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class RecentExpenseItem {
  final String name;
  final String price;

  RecentExpenseItem({
    required this.name,
    required this.price,
  });
}

class HomeScreenRecentExpenses extends StatefulWidget {
  const HomeScreenRecentExpenses({super.key});

  @override
  State<HomeScreenRecentExpenses> createState() => _HomeScreenRecentExpensesState();
}

class _HomeScreenRecentExpensesState extends State<HomeScreenRecentExpenses> {
  late final List<RecentExpenseItem> recentExpenses;

  @override
  void initState() {
    super.initState();
    // Sample data for recent expenses
    // TODO: Replace with actual data from your database. Fetch 6 most recent expenses.
    recentExpenses = [
      RecentExpenseItem(name: 'Shopping at Coles', price: '78.9'),
      RecentExpenseItem(name: 'Uber Ride', price: '25.5'),
      RecentExpenseItem(name: 'Dinner at Sushi Train', price: '60.2'),
      RecentExpenseItem(name: 'Movie Tickets', price: '34'),
      RecentExpenseItem(name: 'Fuel BP Station', price: '89.9'),
      RecentExpenseItem(name: 'Haircut', price: '45'),
    ];
  }

  formatPrice(String price) {
    return '\$${double.parse(price).toStringAsFixed(2)}';
  }


  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/expenses');
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            proportionalSizes.scaleWidth(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(proportionalSizes.scaleWidth(16)),
              child: Text(
                'Recent Expenses',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(24),
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryText,
                ),
              ),
            ),

            ...recentExpenses.map(
              (expense) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: proportionalSizes.scaleWidth(16),
                  vertical: proportionalSizes.scaleHeight(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      expense.name,
                      style: TextStyle(
                        fontSize: proportionalSizes.scaleText(18),
                        color: ColorPalette.primaryText,
                      ),
                    ),
                    Text(
                      formatPrice(expense.price),
                      style: TextStyle(
                        fontSize: proportionalSizes.scaleText(18),
                        color: ColorPalette.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}