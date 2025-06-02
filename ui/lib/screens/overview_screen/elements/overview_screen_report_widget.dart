import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/snack_bar.dart';

class OverviewScreenReportWidget extends StatefulWidget {
  const OverviewScreenReportWidget({super.key});

  @override
  State<OverviewScreenReportWidget> createState() =>
      _OverviewScreenReportWidgetState();
}

class _OverviewScreenReportWidgetState
    extends State<OverviewScreenReportWidget> {
  List<String> reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    // TODO: Replace this with the names of the reports already generated from the backend
    reports = [
      'January 20, 2025 Report',
      'February 20, 2025 Report',
      'March 10, 2025 Report',
      'March 31, 2025 Report',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(proportionalSizes.scaleWidth(16)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Report',
            style: GoogleFonts.roboto(
              fontSize: proportionalSizes.scaleText(20),
              fontWeight: FontWeight.bold,
              color: ColorPalette.primaryText,
            ),
          ),
          SizedBox(height: proportionalSizes.scaleHeight(10)),

          // List of generated reports
          ...reports.map(
            (report) => Padding(
              padding: EdgeInsets.only(
                bottom: proportionalSizes.scaleHeight(6),
              ),
              child: GestureDetector(
                onTap: () {
                  // TODO: Trigger report download
                },
                child: Text(
                  report,
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(16),
                    fontWeight: FontWeight.w500,
                    color: ColorPalette.primaryText,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: proportionalSizes.scaleHeight(10)),

          // Generate new report
          GestureDetector(
            onTap: () {
              showCustomSnackBar(
                context,
                boldText: 'Info:',
                normalText: 'Please wait 5 minutes and then return.',
                type: SnackBarType.failed,
              );
              // TODO: Trigger actual report generation request to backend here.
            },
            child: Text(
              '+ Generate a New Report',
              style: GoogleFonts.roboto(
                fontSize: proportionalSizes.scaleText(16),
                fontWeight: FontWeight.bold,
                color: ColorPalette.primaryText,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
