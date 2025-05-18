import 'package:flutter/material.dart';
import '../../../common/proportional_sizes.dart';
import 'split_with_screen_segment_control.dart';
import 'split_with_screen_friend.dart';
import 'split_with_screen_group.dart';

class SplitWithScreenMainBody extends StatefulWidget {
  const SplitWithScreenMainBody({super.key});

  @override
  State<SplitWithScreenMainBody> createState() => _SplitWithScreenMainBodyState();
}

class _SplitWithScreenMainBodyState extends State<SplitWithScreenMainBody> {
  String selectedSegment = 'Friend';

  void updateSegment(String newSegment) {
    setState(() {
      selectedSegment = newSegment;
    });
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
              // Segment Control with Callback
              SplitWithScreenSegmentControl(
                selectedSegment: selectedSegment,
                onSegmentChanged: updateSegment,
              ),
              // Switch based on selected segment
              if (selectedSegment == 'Friend')
                const SplitWithScreenFriend()
              else
                const SplitWithScreenGroup(),
            ],
          ),
        ),
      ),
    );
  }
}