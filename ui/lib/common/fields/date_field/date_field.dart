import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../proportional_sizes.dart';
import 'open_calender_popup.dart';

class DateField extends StatefulWidget {
  final bool isDarkMode;

  /// Label shown to the left of the date (e.g., "Date of Birth", "Expense Date")
  final String label;

  /// Optional initial date to pre-fill the field
  final DateTime? initialDate;

  /// Callback when a new date is selected
  final ValueChanged<DateTime>? onDateSelected;

  const DateField({
    super.key,
    required this.isDarkMode,
    required this.label,
    this.initialDate,
    this.onDateSelected,
  });

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  String _formatDate(DateTime date) {
    return "${_monthName(date.month)} ${date.day}, ${date.year}";
  }

  String _monthName(int month) {
    const List<String> monthNames = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: proportionalSizes.scaleHeight(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: proportionalSizes.scaleWidth(100),
            child: Text(
              widget.label,
              style: GoogleFonts.roboto(
                color: const Color(0xFF007AFF),
                fontSize: proportionalSizes.scaleText(16),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
          SizedBox(width: proportionalSizes.scaleWidth(8)),

          GestureDetector(
            onTap: () {
              openCalendarPopup(
                context: context,
                initialDate: _selectedDate,
                isDarkMode: widget.isDarkMode,
                onDateSelected: (selectedDate) {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                  if (widget.onDateSelected != null) {
                    widget.onDateSelected!(selectedDate);
                  }
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: proportionalSizes.scaleWidth(10),
                vertical: proportionalSizes.scaleHeight(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withAlpha(25),
                borderRadius: BorderRadius.circular(
                  proportionalSizes.scaleWidth(10),
                ),
              ),
              child: Text(
                _formatDate(_selectedDate),
                style: GoogleFonts.roboto(
                  color: const Color(0xFF007AFF),
                  fontSize: proportionalSizes.scaleText(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}