import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/utils/colors.dart';
import 'package:flutter_frontend/utils/string_utils.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';
import '../elements/see_expense_screen_status.dart';

class SeeExpenseApprovals extends StatelessWidget {
  final ExpenseRead expense;
  final List<SplitStatusInfo> splitStatuses;

  const SeeExpenseApprovals({
    super.key,
    required this.expense,
    required this.splitStatuses,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: proportionalSizes.scaleWidth(20),
        vertical: proportionalSizes.scaleHeight(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SeeExpenseScreenActiveStatus(status: expense.status),
          SizedBox(height: proportionalSizes.scaleHeight(20)),
          Text(
            "Approvals",
            style: GoogleFonts.roboto(
              fontSize: proportionalSizes.scaleText(18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: proportionalSizes.scaleHeight(10)),
          ...splitStatuses.map((split) {
            final statusColor = statusIconAndTextColor(split.status);
            final backgroundColor = statusBackgroundColor(split.status);

            return Container(
              margin: EdgeInsets.only(
                bottom: proportionalSizes.scaleHeight(12),
              ),
              padding: EdgeInsets.symmetric(
                vertical: proportionalSizes.scaleHeight(10),
                horizontal: proportionalSizes.scaleWidth(12),
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(
                  proportionalSizes.scaleWidth(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconMaker(
                    assetPath: 'assets/icons/check.png',
                    color: statusColor,
                  ),
                  SizedBox(width: proportionalSizes.scaleWidth(8)),
                  Expanded(
                    child: Text(
                      split.nickname,
                      style: GoogleFonts.roboto(
                        fontSize: proportionalSizes.scaleText(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    titleCaseString(split.status.name),
                    style: GoogleFonts.roboto(
                      fontSize: proportionalSizes.scaleText(14),
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
