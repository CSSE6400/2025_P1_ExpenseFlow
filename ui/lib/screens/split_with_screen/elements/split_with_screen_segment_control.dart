import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../common/proportional_sizes.dart';

class SplitWithScreenSegmentControl extends StatefulWidget {
  const SplitWithScreenSegmentControl({super.key});

  @override
  State<SplitWithScreenSegmentControl> createState() =>
      _SplitWithScreenSegmentControlState();
}

class _SplitWithScreenSegmentControlState
    extends State<SplitWithScreenSegmentControl> {
  String selectedSegment = 'Friend';

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Container(
      height: proportionalSizes.scaleHeight(40),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: CupertinoSlidingSegmentedControl<String>(
        groupValue: selectedSegment,
        thumbColor: Colors.white,
        backgroundColor: const Color(0xFFF2F2F2),
        padding: const EdgeInsets.all(4),
        children: const {
          'Friend': Text(
            'Friend',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          'Group': Text(
            'Group',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        },
        onValueChanged: (String? value) {
          if (value != null) {
            setState(() {
              selectedSegment = value;
            });
          }
        },
      ),
    );
  }
}