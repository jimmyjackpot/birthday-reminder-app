import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/birthday.dart';
import '../theme/app_theme.dart';
import '../widgets/minimal_card.dart';

class CalendarViewScreen extends StatefulWidget {
  final List<Birthday> birthdays;
  final Function(Birthday) onBirthdayTap;

  const CalendarViewScreen({
    super.key,
    required this.birthdays,
    required this.onBirthdayTap,
  });

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<Birthday> _getBirthdaysForDay(DateTime day) {
    return widget.birthdays.where((birthday) {
      return birthday.birthdate.month == day.month &&
          birthday.birthdate.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthBirthdays = _getBirthdaysForMonth(_focusedDay.month);
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Month birthdays at top
            if (monthBirthdays.isNotEmpty) ...[
              Text(
                'This Month',
                style: AppTheme.heading3(isDark),
              ),
              const SizedBox(height: AppTheme.spacingSM),
              ...monthBirthdays.map((birthday) {
                return MinimalCard(
                  elevation: 1,
                  padding: const EdgeInsets.all(AppTheme.spacingSM),
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingSM),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        '${birthday.birthdate.day}',
                        style: AppTheme.labelLarge(isDark).copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    title: Text(
                      birthday.name,
                      style: AppTheme.labelLarge(isDark),
                    ),
                    subtitle: Text(
                      'Turns ${birthday.age}',
                      style: AppTheme.bodySmall(isDark),
                    ),
                    onTap: () => widget.onBirthdayTap(birthday),
                  ),
                );
              }),
              const SizedBox(height: AppTheme.spacingLG),
            ],
            // Calendar
            MinimalCard(
              elevation: 2,
              padding: EdgeInsets.zero,
              child: TableCalendar<Birthday>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getBirthdaysForDay,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: AppTheme.bodyMedium(isDark),
                  weekendTextStyle: AppTheme.bodyMedium(isDark).copyWith(
                    color: AppTheme.getTextSecondaryColor(isDark),
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: AppTheme.heading3(isDark),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: AppTheme.getTextSecondaryColor(isDark),
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: AppTheme.getTextSecondaryColor(isDark),
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  
                  final birthdays = _getBirthdaysForDay(selectedDay);
                  if (birthdays.length == 1) {
                    widget.onBirthdayTap(birthdays.first);
                  }
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedDay = focusedDay;
                  });
                },
              ),
            ),
            // Empty state if no birthdays
            if (monthBirthdays.isEmpty && widget.birthdays.isEmpty) ...[
              const SizedBox(height: AppTheme.spacingXL),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXL),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: AppTheme.getTextTertiaryColor(isDark),
                      ),
                      const SizedBox(height: AppTheme.spacingMD),
                      Text(
                        'No birthdays this month',
                        style: AppTheme.heading3(isDark).copyWith(
                          color: AppTheme.getTextSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }

  List<Birthday> _getBirthdaysForMonth(int month) {
    return widget.birthdays
        .where((b) => b.birthdate.month == month)
        .toList()
      ..sort((a, b) => a.birthdate.day.compareTo(b.birthdate.day));
  }
}

