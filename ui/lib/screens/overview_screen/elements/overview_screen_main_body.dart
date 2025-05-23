import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
// Common imports
import '../../../common/proportional_sizes.dart';

class OverviewScreenMainBody extends StatefulWidget {
  const OverviewScreenMainBody({super.key});

  @override
  State<OverviewScreenMainBody> createState() => _OverviewScreenMainBodyState();
}

class _OverviewScreenMainBodyState extends State<OverviewScreenMainBody> {
  String selectedPeriod = 'Last 30 Days';

  void handleTimePeriodChange(String? newPeriod) {
    if (newPeriod != null) {
      setState(() {
        selectedPeriod = newPeriod;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TimePeriodDropdown(
                  selectedPeriod: selectedPeriod,
                  onChanged: handleTimePeriodChange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}