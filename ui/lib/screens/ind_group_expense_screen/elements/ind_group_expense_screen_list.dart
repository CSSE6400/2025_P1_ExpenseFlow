import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/custom_divider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/common/icon_maker.dart';
import 'package:flutter_frontend/common/proportional_sizes.dart';
import 'package:flutter_frontend/common/search_bar.dart' as search;
import 'package:intl/intl.dart';

class IndGroupExpenseScreenList extends StatefulWidget {
  final List<dynamic> expenses;

  const IndGroupExpenseScreenList({
    super.key,
    required this.expenses,
  });

  @override
  State<IndGroupExpenseScreenList> createState() => _IndGroupExpenseScreenListState();
}

class _IndGroupExpenseScreenListState extends State<IndGroupExpenseScreenList> {
  late List<dynamic> filteredExpenses;
  late List<bool> expansionStates;

  // initialise the list of expenses and expansion states
  @override
  void initState() {
    super.initState();
    filteredExpenses = widget.expenses;
    // initialise expansion states to false for all items
    expansionStates = List<bool>.filled(widget.expenses.length, false);
  }

  @override
  void didUpdateWidget(covariant IndGroupExpenseScreenList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expenses != oldWidget.expenses) {
      filteredExpenses = widget.expenses;
      expansionStates = List<bool>.filled(widget.expenses.length, false);
    }
  }

  void _toggleExpansion(int index) {
    setState(() {
      expansionStates[index] = !expansionStates[index];
    });
  }

  // filter the expenses based on the search
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

  // Format the date from AWS timestamp to a readable format
  // Example: "2024-06-10T14:20:00Z" to "Jun 10, 2024"
  String _formatDate(String awsTimestamp) {
    try {
      final dateTime = DateTime.parse(awsTimestamp).toLocal();
      return DateFormat('MMM d, yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _titleCase(String input) {
    return input
        .split(' ')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
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
                      // Expand/collapse arrow
                      Transform.rotate(
                        angle: isExpanded ? 4.71 : 0,
                        child: IconMaker(
                          assetPath: 'assets/icons/angle_small_right.png',
                        ),
                      ),
                      SizedBox(width: proportionalSizes.scaleWidth(8)),

                      Expanded(
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
                      if (expense.active) ...[
                        SizedBox(width: proportionalSizes.scaleWidth(6)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: proportionalSizes.scaleHeight(2),
                            horizontal: proportionalSizes.scaleWidth(6),
                          ),
                          decoration: BoxDecoration(
                            color: ColorPalette.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              proportionalSizes.scaleWidth(6),
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
                      ],

                      SizedBox(width: proportionalSizes.scaleWidth(6)),

                      // Price tag
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

              if (isExpanded) ...[
                Padding(
                  padding: EdgeInsets.only(
                    left: proportionalSizes.scaleWidth(32),
                    bottom: proportionalSizes.scaleHeight(8),
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
                              'transactionId': expense.name,
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
                CustomDivider(),
                ...(() {
                  final members = [...expense.members];
                  members.sort((a, b) => a.name == 'You' ? -1 : b.name == 'You' ? 1 : 0);
                  return members.map((member) => Padding(
                    padding: EdgeInsets.only(
                      left: proportionalSizes.scaleWidth(32),
                      top: proportionalSizes.scaleHeight(6),
                      right: proportionalSizes.scaleWidth(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: member.name == 'You'
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      '/friend_expense',
                                      arguments: {'username': member.name},
                                    );
                                  },
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    member.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      fontSize: proportionalSizes.scaleText(16),
                                      color: textColor,
                                      decoration: member.name == 'You'
                                          ? TextDecoration.none
                                          : TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                if (member.name != 'You') ...[
                                  IconMaker(
                                    assetPath: 'assets/icons/angle_small_right.png',
                                    width: proportionalSizes.scaleWidth(16),
                                    height: proportionalSizes.scaleHeight(16),
                                  ),
                                  SizedBox(width: proportionalSizes.scaleWidth(6)),
                                ],
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (member.status != null) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: proportionalSizes.scaleHeight(2),
                                  horizontal: proportionalSizes.scaleWidth(6),
                                ),
                                decoration: BoxDecoration(
                                  color: ColorPalette.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    proportionalSizes.scaleWidth(6),
                                  ),
                                ),
                                child: Text(
                                  _titleCase(member.status!),
                                  style: GoogleFonts.roboto(
                                    color: ColorPalette.accent,
                                    fontSize: proportionalSizes.scaleText(12),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: proportionalSizes.scaleWidth(8)),
                            ],
                            Text(
                              member.amount,
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: proportionalSizes.scaleText(14),
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
                })(),
              ]
            ],
          );
        }),
      ],
    );
  }
}