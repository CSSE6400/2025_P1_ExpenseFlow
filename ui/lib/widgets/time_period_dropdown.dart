import 'package:flutter/material.dart';
import '../common/custom_dropdown.dart';

class TimePeriodDropdown extends StatelessWidget {
  final String selectedPeriod;
  final void Function(String) onChanged;

  const TimePeriodDropdown({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  static const List<String> options = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 60 Days',
    'Last 90 Days',
    'Last 120 Days',
    'Last 180 Days',
    'Last 365 Days',
    'From Start',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      selected: selectedPeriod,
      options: options,
      onChanged: onChanged,
      labelBuilder: (val) => val,
    );
  }
}
