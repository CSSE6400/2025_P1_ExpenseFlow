import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
import 'package:flutter_frontend/screens/overview_screen/elements/overview_screen_stat_widget.dart';
import 'package:flutter_frontend/screens/overview_screen/elements/overview_screen_amount_widget.dart';
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
                // TODO: Made the dropdown non-interactive, as I think it would complicate the calculation of the overview.
                // For MVP, we may not need to change the time period.
                child: IgnorePointer(
                  child: TimePeriodDropdown(
                    selectedPeriod: selectedPeriod,
                    onChanged: handleTimePeriodChange, // will never be called
                  ),
                ),
              ),
              SizedBox(
                height: proportionalSizes.scaleHeight(20),
              ),

              const OverviewScreenStatWidget(),
              SizedBox(
                height: proportionalSizes.scaleHeight(20),
              ),

              const OverviewScreenAmountWidget(),
              SizedBox(
                height: proportionalSizes.scaleHeight(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
