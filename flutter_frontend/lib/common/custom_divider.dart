import 'package:flutter/material.dart';

import '../../../../../common/proportional_sizes.dart';

/// A reusable divider widget for separating profile fields.
/// - Thin grey line
/// - Proportional thickness and spacing
class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Divider(
      color: const Color(0xFF898989),
      thickness: proportionalSizes.scaleHeight(0.5),
      height: proportionalSizes.scaleHeight(0),
    );
  }
}
