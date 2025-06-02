import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/common/icon_maker.dart';
import 'package:flutter_frontend/common/proportional_sizes.dart';
import 'package:flutter_frontend/common/search_bar.dart' as search;
import 'package:intl/intl.dart';

class ExpensesScreenList extends StatefulWidget {
  final List<dynamic> expenses;

  const ExpensesScreenList({
    super.key,
    required this.expenses,
  });

  @override
  State<ExpensesScreenList> createState() => _ExpensesScreenListState();
}

class _ExpensesScreenListState extends State<ExpensesScreenList> {
  late List<dynamic> filteredExpenses;
  late List<bool> expansionStates;

  @override
  void initState() {
    super.initState();
    filteredExpenses = widget.expenses;
    expansionStates = List<bool>.filled(widget.expenses.length, false);
  }

  void _toggleExpansion(int index) {
    setState(() {
      expansionStates[index] = !expansionStates[index];
    });
  }

  void _filterExpenses(String query) {
    final lowerQuery = query.toLowerCase();
    final result = widget.expenses
        .asMap()
        .entries
        .where((entry) =>
            entry.value.name.toLowerCase().contains(lowerQuery))
        .toList();

    setState(() {
      filteredExpenses = result.map((e) => e.value).toList();
      expansionStates = List<bool>.filled(filteredExpenses.length, false);
    });
  }

  // format the date from AWS timestamp to a readable format
  String _formatDate(String awsTimestamp) {
    try {
      final dateTime = DateTime.parse(awsTimestamp).toLocal();
      return DateFormat('MMM d, yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // update the filtered expenses and expansion states when the widget updates
  @override
  void didUpdateWidget(covariant ExpensesScreenList oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredExpenses = widget.expenses;
    expansionStates = List<bool>.filled(widget.expenses.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(
          hintText: 'Search expenses',
          onChanged: _filterExpenses,
        ),
        const SizedBox(height: 16),

        ...filteredExpenses.asMap().entries.map((entry) {
          final index = entry.key;
          final expense = entry.value;
          final isExpanded = expansionStates[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _toggleExpansion(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: proportionalSizes.scaleHeight(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // expand arrow
                      Transform.rotate(
                        angle: isExpanded ? 4.71 : 0,
                        child: IconMaker(
                          assetPath: 'assets/icons/angle_small_right.png',
                        ),
                      ),
                      SizedBox(width: proportionalSizes.scaleWidth(8)),

                      // expense name
                      SizedBox(
                        width: proportionalSizes.scaleWidth(180),
                        child: Text(
                          expense.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: false,
                          style: GoogleFonts.roboto(
                            fontSize: proportionalSizes.scaleText(18),
                            color: textColor,
                          ),
                        ),
                      ),

                      // right-aligned price + tag
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // "Active" Tag
                              if (expense.active) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: proportionalSizes.scaleHeight(2),
                                    horizontal: proportionalSizes.scaleWidth(6),
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.accent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(
                                      proportionalSizes.scaleWidth(6)
                                    ),
                                  ),
                                  child: Text(
                                    'Active',
                                    style: GoogleFonts.roboto(
                                      color: ColorPalette.accent,
                                      fontSize: proportionalSizes.scaleText(14),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: proportionalSizes.scaleWidth(6)),
                              ],

                              // price tag
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: proportionalSizes.scaleHeight(4),
                                  horizontal: proportionalSizes.scaleWidth(8),
                                ),
                                decoration: BoxDecoration(
                                  color: textColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    proportionalSizes.scaleWidth(8),
                                  ),
                                ),
                                child: Text(
                                  expense.price,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontSize: proportionalSizes.scaleText(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isExpanded)
                Padding(
                  padding: EdgeInsets.only(
                    left: proportionalSizes.scaleWidth(32),
                    bottom: proportionalSizes.scaleHeight(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: proportionalSizes.scaleWidth(8),
                          vertical: proportionalSizes.scaleHeight(4),
                        ),
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            proportionalSizes.scaleWidth(8),
                          ),
                        ),
                        child: Text(
                          _formatDate(expense.date),
                          style: GoogleFonts.roboto(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: proportionalSizes.scaleText(14),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/see_expenses',
                            arguments: {
                              'transactionId': expense.transactionId, // TODO: Update with actual transaction ID
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'See Expense',
                              style: GoogleFonts.roboto(
                                color: textColor,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                fontSize: proportionalSizes.scaleText(18),
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                size: 20, color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}