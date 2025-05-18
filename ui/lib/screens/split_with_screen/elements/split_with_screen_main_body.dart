import 'package:flutter/material.dart';
import '../../../common/proportional_sizes.dart';
import 'split_with_screen_segment_control.dart';

class SplitWithScreenMainBody extends StatelessWidget {
  const SplitWithScreenMainBody({super.key});

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
              SplitWithScreenSegmentControl(),
            ],
          ),
        ),
      ),
    );
  }
}