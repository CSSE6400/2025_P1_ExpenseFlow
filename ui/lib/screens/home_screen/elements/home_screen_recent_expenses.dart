import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;

class RecentExpense {
  final String name;
  final String price;
  final String expenseId;

  RecentExpense({
    required this.name,
    required this.price,
    required this.expenseId,
  });
}

class HomeScreenRecentExpenses extends StatefulWidget {
  const HomeScreenRecentExpenses({super.key});

  @override
  State<HomeScreenRecentExpenses> createState() => _HomeScreenRecentExpensesState();
}

class _HomeScreenRecentExpensesState extends State<HomeScreenRecentExpenses> {
  List<RecentExpense> recentExpenses = [];
  bool isLoading = true;
  final Logger _logger = Logger("HomeRecentExpensesScreen");

  @override
  void initState() {
    super.initState();
    _loadRecentExpenses();
  }

  Future<void> _loadRecentExpenses() async {
  await _fetchUserExpenses(); // ✅ Wait for this
  //await Future.delayed(const Duration(milliseconds: 800));

  if (mounted) {
    setState(() {
      isLoading = false; // ✅ Mark loading as done
    });
  }
}


  Future<void> _fetchUserExpenses() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.expenseApi.getExpensesUploadedByMe(); //TODO: this should be all expenses the user is apart of

      setState(() {
        recentExpenses = userReads.map((expense) {
          return RecentExpense(
            name:expense.name,
            price: "100000", // TODO: change to better fitting end point with a price.
            expenseId: expense.expenseId,
          );
        }).toList();
      });
      _logger.info("number of recent expenses: ${recentExpenses.length}");
    } catch (e) {
      _logger.warning("Failed to get recent expenses: $e");
    }
  }

  String formatPrice(String price) {
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

            // loading state
            if (isLoading)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: proportionalSizes.scaleHeight(20),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorPalette.primaryAction,
                  ),
                ),
              )
            else
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
          ],
        ),
      ),
    );
  }
}