import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/common/icon_maker.dart';
import 'package:flutter_frontend/common/proportional_sizes.dart';
import 'package:intl/intl.dart';

class ExpenseView extends StatefulWidget {
  final ExpenseRead expense;
  // Callback for button press
  final VoidCallback? onButtonPressed;

  const ExpenseView({
    super.key,
    required this.expense,
    required this.onButtonPressed,
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
                    color: textColor.withOpacity(0.1),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: proportionalSizes.scaleWidth(8),
                    vertical: proportionalSizes.scaleHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.1),
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
          ),
      ],
    );
  }
}
