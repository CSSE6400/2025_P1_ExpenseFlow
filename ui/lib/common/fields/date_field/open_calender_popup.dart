import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'custom_pop_menu.dart';
import '../../proportional_sizes.dart';
import '../../color_palette.dart';

void openCalendarPopup({
  required BuildContext context,
  required DateTime initialDate,
  required ValueChanged<DateTime> onChanged,
}) {
  DateTime focusedDate = initialDate;
  DateTime selectedDate = initialDate;
  final DateTime currentDate = DateTime.now();
  final DateTime lastViewableDate = DateTime(currentDate.year, 12, 31);
  final DateTime firstViewableDate = DateTime(1905, 1, 1);
  final proportionalSizes = ProportionalSizes(context: context);
  final primaryColor = ColorPalette.primaryText;

  bool isFirstMonth(DateTime date) {
    return date.year == firstViewableDate.year &&
        date.month == firstViewableDate.month;
  }

  bool isLastMonth(DateTime date) {
    return date.year == lastViewableDate.year &&
        date.month == lastViewableDate.month;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
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
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(
                  proportionalSizes.scaleWidth(20),
                ),
              ),
              padding: EdgeInsets.all(proportionalSizes.scaleWidth(20)),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dialog Title
                      Text(
                        'Select Date',
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: proportionalSizes.scaleText(18),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: proportionalSizes.scaleHeight(20)),

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
                              ),
                              SizedBox(width: proportionalSizes.scaleWidth(10)),
                              CustomPopupMenu<int>(
                                initialValue: focusedDate.year,
                                items: List.generate(
                                  lastViewableDate.year -
                                      firstViewableDate.year +
                                      1,
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
                              ),
                            ],
                          ),

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
                                  padding: EdgeInsets.all(
                                    proportionalSizes.scaleWidth(8.0),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.1),
                                  ),
                                  child: Image.asset(
                                    'assets/icons/back_button.png',
                                    width: proportionalSizes.scaleWidth(12),
                                    height: proportionalSizes.scaleHeight(12),
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

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
                                  padding: EdgeInsets.all(
                                    proportionalSizes.scaleWidth(8.0),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.1),
                                  ),
                                  child: Transform.rotate(
                                    angle:
                                        3.14159, // Flip the back button horizontally
                                    child: Image.asset(
                                      'assets/icons/back_button.png',
                                      width: proportionalSizes.scaleWidth(12),
                                      height: proportionalSizes.scaleHeight(12),
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: proportionalSizes.scaleHeight(10)),

                      TableCalendar(
                        firstDay: firstViewableDate,
                        lastDay: lastViewableDate,
                        focusedDay: focusedDate,
                        currentDay: currentDate,
                        selectedDayPredicate:
                            (day) => isSameDay(selectedDate, day),
                        enabledDayPredicate: (day) => !day.isAfter(currentDate),
                        onDaySelected: (selectedDay, focusedDay) {
                          // Allow selection only if the day is not after today
                          if (!selectedDay.isAfter(currentDate)) {
                            setState(() {
                              selectedDate = selectedDay;
                            });
                            onChanged(selectedDay);
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
                            color: primaryColor.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          defaultTextStyle: GoogleFonts.roboto(
                            color: Colors.black,
                          ),
                          weekendTextStyle: GoogleFonts.roboto(
                            color: Colors.black54,
                          ),
                          disabledTextStyle: GoogleFonts.roboto(
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                          outsideTextStyle: GoogleFonts.roboto(
                            color: Colors.black.withValues(alpha: 0.3),
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
