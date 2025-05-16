import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
// Elements
import 'custom_pop_menu.dart';
// Common Files
import '../../proportional_sizes.dart';

/// Opens a dialog-based calendar for selecting dates, restricted to between 1905 and the current year.
///
/// Features:
/// - Dark mode styling.
/// - Arrows and a custom year/month dropdown for navigation.
/// - Disables future dates beyond the current day.
void openCalendarPopup({
  required BuildContext context,
  required DateTime initialDate,
  required bool isDarkMode,
  required ValueChanged<DateTime> onDateSelected,
}) {
  DateTime focusedDate = initialDate;
  DateTime selectedDate = initialDate;
  final DateTime currentDate = DateTime.now();
  final DateTime lastViewableDate = DateTime(currentDate.year, 12, 31);
  final DateTime firstViewableDate = DateTime(1905, 1, 1);
  final proportionalSizes = ProportionalSizes(context: context);

  // Checks if the focused date is the earliest allowed month.
  bool isFirstMonth(DateTime date) {
    return date.year == firstViewableDate.year && date.month == firstViewableDate.month;
  }

  // Checks if the focused date is the latest allowed month.
  bool isLastMonth(DateTime date) {
    return date.year == lastViewableDate.year && date.month == lastViewableDate.month;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        // Rounded corners for the calendar dialog.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(20)),
        ),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: proportionalSizes.scaleWidth(15.0),
              sigmaY: proportionalSizes.scaleWidth(15.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(20)),
              ),
              padding: EdgeInsets.all(proportionalSizes.scaleWidth(20)),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dialog Title
                      Text(
                        'Select Date of Birth',
                        style: GoogleFonts.roboto(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: proportionalSizes.scaleText(18),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: proportionalSizes.scaleHeight(20)),

                      // Navigation Row (Month & Year Dropdowns + Left/Right Arrows)
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomPopupMenu<int>(
                                initialValue: focusedDate.month,
                                items: List.generate(12, (index) => index + 1),
                                itemBuilder: (month) => monthName(month),
                                onSelected: (newMonth) {
                                  setState(() {
                                    focusedDate = DateTime(
                                      focusedDate.year,
                                      newMonth,
                                      focusedDate.day,
                                    );
                                  });
                                },
                                isDarkMode: isDarkMode,
                              ),
                              SizedBox(width: proportionalSizes.scaleWidth(10)),
                              CustomPopupMenu<int>(
                                initialValue: focusedDate.year,
                                items: List.generate(
                                  lastViewableDate.year - firstViewableDate.year + 1,
                                  (index) => lastViewableDate.year - index,
                                ),
                                itemBuilder: (year) => year.toString(),
                                onSelected: (newYear) {
                                  setState(() {
                                    focusedDate = DateTime(
                                      newYear,
                                      focusedDate.month,
                                      focusedDate.day,
                                    );
                                  });
                                },
                                isDarkMode: isDarkMode,
                              ),
                            ],
                          ),

                          // Left arrow button to go back one month (if not at earliest month)
                          if (!isFirstMonth(focusedDate))
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    focusedDate = DateTime(
                                      focusedDate.year,
                                      focusedDate.month - 1,
                                      focusedDate.day,
                                    );
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(proportionalSizes.scaleWidth(8.0)),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.1),
                                  ),
                                  child: Image.asset(
                                    'assets/icons/back_button.png',
                                    width: proportionalSizes.scaleWidth(12),
                                    height: proportionalSizes.scaleHeight(12),
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),

                          // Right arrow button to go forward one month (if not at latest month)
                          if (!isLastMonth(focusedDate))
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    focusedDate = DateTime(
                                      focusedDate.year,
                                      focusedDate.month + 1,
                                      focusedDate.day,
                                    );
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(proportionalSizes.scaleWidth(8.0)),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.1),
                                  ),
                                  child: Transform.rotate(
                                    angle: 3.14159, // Flip the back button horizontally
                                    child: Image.asset(
                                      'assets/icons/back_button.png',
                                      width: proportionalSizes.scaleWidth(12),
                                      height: proportionalSizes.scaleHeight(12),
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: proportionalSizes.scaleHeight(10)),

                      // Calendar widget from table_calendar package
                      TableCalendar(
                        firstDay: firstViewableDate,
                        lastDay: lastViewableDate,
                        focusedDay: focusedDate,
                        currentDay: currentDate,
                        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                        enabledDayPredicate: (day) => !day.isAfter(currentDate),
                        onDaySelected: (selectedDay, focusedDay) {
                          // Allow selection only if the day is not after today
                          if (!selectedDay.isAfter(currentDate)) {
                            setState(() {
                              selectedDate = selectedDay;
                            });
                            onDateSelected(selectedDay);
                            Navigator.pop(context);
                          }
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            focusedDate = focusedDay;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: GoogleFonts.roboto(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF007AFF),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          defaultTextStyle: GoogleFonts.roboto(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          weekendTextStyle: GoogleFonts.roboto(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          disabledTextStyle: GoogleFonts.roboto(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.3),
                          ),
                          outsideTextStyle: GoogleFonts.roboto(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.3),
                          ),
                        ),
                        headerVisible: false, // Hide default calendar header
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}