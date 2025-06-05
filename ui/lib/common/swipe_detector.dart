import 'package:flutter/material.dart';

class SwipeDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDragLeft;
  final VoidCallback? onDragRight;
  final double velocityThreshold;

  const SwipeDetector({
    super.key,
    required this.child,
    this.onDragLeft,
    this.onDragRight,
    this.velocityThreshold = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        if (velocity.abs() < velocityThreshold) return;

        if (velocity < 0) {
          onDragLeft?.call();
        } else if (velocity > 0) {
          onDragRight?.call();
        }
      },
      child: child,
    );
  }
}
