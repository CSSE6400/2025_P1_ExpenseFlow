import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/enums.dart' show ExpenseStatus;
import 'package:flutter_frontend/utils/string_utils.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';

class SeeExpenseScreenActiveStatus extends StatelessWidget {
  final ExpenseStatus status;

  const SeeExpenseScreenActiveStatus({super.key, required this.status});

  Color get backgroundColor {
    switch (status) {
      case ExpenseStatus.paid:
        return Colors.green.withOpacity(0.2);
      case ExpenseStatus.accepted:
        return Colors.yellow.withOpacity(0.2);
      case ExpenseStatus.requested:
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color get iconAndTextColor {
    switch (status) {
      case ExpenseStatus.paid:
        return Colors.green;
      case ExpenseStatus.accepted:
        return Colors.yellow[800]!; // Darker yellow for better contrast
      case ExpenseStatus.requested:
      default:
        return Colors.grey;
    }
  }

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
        color: backgroundColor,
        borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            color: iconAndTextColor,
          ),
          SizedBox(width: proportionalSizes.scaleWidth(8)),
          Text(
            titleCaseString(status.label),
            style: GoogleFonts.roboto(
              color: iconAndTextColor,
              fontSize: proportionalSizes.scaleText(16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
