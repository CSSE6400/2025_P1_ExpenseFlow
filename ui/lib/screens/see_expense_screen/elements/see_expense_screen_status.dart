import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/enums.dart' show ExpenseStatus;
import 'package:flutter_frontend/utils/colors.dart';
import 'package:flutter_frontend/utils/string_utils.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';

class SeeExpenseScreenActiveStatus extends StatelessWidget {
  final ExpenseStatus status;

  const SeeExpenseScreenActiveStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: proportionalSizes.scaleHeight(6),
        horizontal: proportionalSizes.scaleWidth(12),
      ),
      decoration: BoxDecoration(
        color: statusBackgroundColor(status),
        borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconMaker(
            assetPath: 'assets/icons/check.png',
            color: statusIconAndTextColor(status),
          ),
          SizedBox(width: proportionalSizes.scaleWidth(8)),
          Text(
            titleCaseString(status.label),
            style: GoogleFonts.roboto(
              color: statusIconAndTextColor(status),
              fontSize: proportionalSizes.scaleText(16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
