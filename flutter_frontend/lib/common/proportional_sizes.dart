// Flutter imports
import 'package:flutter/widgets.dart';

/// A utility class to proportionally scale width, height, and text
/// based on the actual screen size of the device.
/// 
/// This is useful for maintaining consistent UI layout and readability
/// across different screen sizes and orientations.
///
/// Design reference dimensions default to:
/// - Width: 402
/// - Height: 874
class ProportionalSizes {
  /// BuildContext from the widget using this class
  final BuildContext context;

  /// The width used in the original UI design (e.g., Figma)
  final double designWidth;

  /// The height used in the original UI design
  final double designHeight;

  /// Actual screen width of the current device
  late final double screenWidth;

  /// Actual screen height of the current device
  late final double screenHeight;

  /// Orientation of the device (portrait or landscape)
  late final Orientation orientation;

  /// Constructor: initializes screen size and orientation using MediaQuery
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

  /// Scales a width value proportionally to the current screen size
  double scaleWidth(double input) {
    final safeWidth = screenWidth < screenHeight ? screenWidth : screenHeight;
    return input * safeWidth / designWidth;
  }

  /// Scales a height value proportionally to the current screen size
  double scaleHeight(double input) {
    final safeHeight = screenWidth > screenHeight ? screenWidth : screenHeight;
    return input * safeHeight / designHeight;
  }

  /// Scales a font size value proportionally using screen width
  double scaleText(double input) {
    final safeWidth = screenWidth < screenHeight ? screenWidth : screenHeight;
    return input * safeWidth / designWidth;
  }
}