import 'package:flutter/widgets.dart';

class ProportionalSizes {
  final BuildContext context;

  final double designWidth;

  final double designHeight;

  late final double screenWidth;

  late final double screenHeight;

  late final Orientation orientation;

  ProportionalSizes({
    required this.context,
    this.designWidth = 402,
    this.designHeight = 874,
  }) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    orientation = mediaQuery.orientation;
  }

  double scaleWidth(double input) {
    final safeWidth = screenWidth < screenHeight ? screenWidth : screenHeight;
    return input * safeWidth / designWidth;
  }

  double scaleHeight(double input) {
    final safeHeight = screenWidth > screenHeight ? screenWidth : screenHeight;
    return input * safeHeight / designHeight;
  }

  double scaleText(double input) {
    final safeWidth = screenWidth < screenHeight ? screenWidth : screenHeight;
    return input * safeWidth / designWidth;
  }
}
