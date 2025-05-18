import 'package:flutter/material.dart';
import '../../../common/proportional_sizes.dart';

class SplitWithScreenGroup extends StatelessWidget {
  const SplitWithScreenGroup({super.key});

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
            children: const [
              // Elements
              Text('Group'),
            ],
          ),
        ),
      ),
    );
  }
}