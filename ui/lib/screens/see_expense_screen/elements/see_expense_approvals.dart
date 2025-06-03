import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/models/enums.dart' show ExpenseStatus;
import 'package:flutter_frontend/models/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/utils/colors.dart';
import 'package:flutter_frontend/utils/string_utils.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/icon_maker.dart';

class SeeExpenseApprovals extends StatelessWidget {
  final ExpenseRead expense;
  final UserRead currentUser;
  final List<SplitStatusInfo> splitStatuses;
  final ExpenseStatus? myStatus;
  final VoidCallback? onApprovePressed;

  SeeExpenseApprovals({
    super.key,
    required this.expense,
    required this.currentUser,
    required this.splitStatuses,
    this.onApprovePressed,
  }) : myStatus = _getMyStatus(currentUser.userId, splitStatuses);

  static ExpenseStatus? _getMyStatus(
    String userId,
    List<SplitStatusInfo> splits,
  ) {
    final match = splits.where((s) => s.userId == userId).toList();
    return match.isNotEmpty ? match.first.status : null;
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    // Determine if we should show the button and with which label
    String? buttonText;
    late final ExpenseStatus buttonStatus;
    if (expense.status == ExpenseStatus.requested &&
        myStatus == ExpenseStatus.requested) {
      buttonText = "Accept";
      buttonStatus = ExpenseStatus.accepted;
    } else if (expense.status == ExpenseStatus.accepted &&
        myStatus == ExpenseStatus.accepted) {
      buttonText = "Pay";
      buttonStatus = ExpenseStatus.paid;
    } else {
      buttonText = null;
      buttonStatus = expense.status;
    }

    final buttonBgColor = statusBackgroundColor(buttonStatus);
    final buttonTxtColor = statusIconAndTextColor(buttonStatus);

    return Scaffold(
      backgroundColor: ColorPalette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
        ),
      ),

      // Show button only if buttonText is not null
      bottomNavigationBar:
          buttonText != null
              ? Padding(
                padding: EdgeInsets.all(proportionalSizes.scaleHeight(12)),
                child: ElevatedButton(
                  onPressed: onApprovePressed ?? () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBgColor,
                    minimumSize: Size(
                      double.infinity,
                      proportionalSizes.scaleHeight(50),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.roboto(
                      fontSize: proportionalSizes.scaleText(16),
                      fontWeight: FontWeight.bold,
                      color: buttonTxtColor,
                    ),
                  ),
                ),
              )
              : null,
    );
  }
}
