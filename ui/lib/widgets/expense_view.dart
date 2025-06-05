import 'package:flutter/material.dart';
import 'package:expenseflow/models/expense.dart';
import 'package:expenseflow/widgets/expense_list_view.dart'
    show ExpenseViewType;
import 'package:google_fonts/google_fonts.dart';
import 'package:expenseflow/common/color_palette.dart';
import 'package:expenseflow/common/icon_maker.dart';
import 'package:expenseflow/common/proportional_sizes.dart';
import 'package:intl/intl.dart';

class ExpenseView extends StatefulWidget {
  final ExpenseRead expense;
  final ExpenseViewType type;

  // button press
  final VoidCallback? onButtonPressed;

  const ExpenseView({
    super.key,
    required this.expense,
    required this.onButtonPressed,
    this.type = ExpenseViewType.mine,
  });

  @override
  State<ExpenseView> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseView> {
  bool isExpanded = false;

  void _toggleExpansion() {
    setState(() => isExpanded = !isExpanded);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;
    final expense = widget.expense;

    Widget typeIcon() {
      IconData iconData;
      Color backgroundColor;

      switch (widget.type) {
        case ExpenseViewType.friend:
          iconData = Icons.person;
          backgroundColor = Colors.blueAccent;
          break;
        case ExpenseViewType.group:
          iconData = Icons.group;
          backgroundColor = Colors.deepPurple;
          break;
        case ExpenseViewType.mine:
          iconData = Icons.account_circle;
          backgroundColor = Colors.green;
          break;
      }

      return Container(
        width: proportionalSizes.scaleWidth(28),
        height: proportionalSizes.scaleWidth(28),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          size: proportionalSizes.scaleWidth(18),
          color: backgroundColor,
        ),
      );
    }

    String expandedLabel() {
      switch (widget.type) {
        case ExpenseViewType.friend:
          return "Split with Friend";
        case ExpenseViewType.group:
          return "Split with Group";
        case ExpenseViewType.mine:
          return "My expense";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleExpansion,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: proportionalSizes.scaleHeight(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: isExpanded ? 4.71 : 0,
                  child: IconMaker(
                    assetPath: 'assets/icons/angle_small_right.png',
                  ),
                ),
                SizedBox(width: proportionalSizes.scaleWidth(8)),

                typeIcon(),
                SizedBox(width: proportionalSizes.scaleWidth(4)),

                Expanded(
                  child: Text(
                    expense.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.roboto(
                      fontSize: proportionalSizes.scaleText(18),
                      color: textColor,
                    ),
                  ),
                ),

                SizedBox(width: proportionalSizes.scaleWidth(6)),

                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: proportionalSizes.scaleHeight(4),
                    horizontal: proportionalSizes.scaleWidth(8),
                  ),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(
                      proportionalSizes.scaleWidth(8),
                    ),
                  ),
                  child: Text(
                    expense.expenseTotal.toString(),
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
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(
              left: proportionalSizes.scaleWidth(32),
              bottom: proportionalSizes.scaleHeight(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: proportionalSizes.scaleWidth(8),
                        vertical: proportionalSizes.scaleHeight(4),
                      ),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(
                          proportionalSizes.scaleWidth(8),
                        ),
                      ),
                      child: Text(
                        _formatDate(expense.expenseDate),
                        style: GoogleFonts.roboto(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: proportionalSizes.scaleText(14),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onButtonPressed,
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
                          const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: proportionalSizes.scaleHeight(4)),
                Text(
                  expandedLabel(),
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(14),
                    fontStyle: FontStyle.italic,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
