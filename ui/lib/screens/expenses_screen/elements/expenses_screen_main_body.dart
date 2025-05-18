import 'package:flutter/material.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import 'expenses_screen_segment_control.dart';

class ExpensesScreenMainBody extends StatefulWidget {
  const ExpensesScreenMainBody({super.key});

  @override
  State<ExpensesScreenMainBody> createState() => _ExpensesScreenMainBodyState();
}

class _ExpensesScreenMainBodyState extends State<ExpensesScreenMainBody> {
  String selectedSegment = 'Active';

  void handleSegmentChange(String newSegment) {
    setState(() {
      selectedSegment = newSegment;
    });
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Segment Control
              ExpensesScreenSegmentControl(
                selectedSegment: selectedSegment,
                onSegmentChanged: handleSegmentChange,
              ),
              SizedBox(height: proportionalSizes.scaleHeight(20)),
            ],
          ),
        ),
      ),
    );
  }
}