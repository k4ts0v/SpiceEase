import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends ConsumerWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final locale = Localizations.localeOf(ctx).languageCode;
    final theme = Theme.of(ctx);

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2099, 12, 31),
      focusedDay: selectedDate,
      locale: locale, // Set the calendar locale
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        ref.read(selectedDateProvider.notifier).state = selectedDay;
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextFormatter: (date, locale) {
          // Format month name according to the locale
          return DateFormat.yMMMM(locale).format(date);
        },
        // Add theme-based styling for the header
        titleTextStyle: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: theme.colorScheme.primary,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.primary,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        // Theme-based weekday styling - matching day number font size
        weekdayStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
          fontSize: 16.0, // Same as day numbers
        ),
        weekendStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          fontSize: 16.0, // Same as day numbers
        ),
      ),
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          // Custom day of week labels using localized strings
          final weekdayString = DateFormat.E(locale).format(day).substring(0, 3);
          final bool isWeekend = day.weekday == DateTime.saturday ||
              day.weekday == DateTime.sunday;

          return Container(
            width: double.infinity,
            height: 20.0, // Increased height to accommodate larger font
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                weekdayString.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0, // Same as day numbers
                  color: isWeekend
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
      calendarStyle: CalendarStyle(
        // Today's date styling
        todayDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.primary, width: 2.0),
        ),
        todayTextStyle: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 16.0, // Standard calendar day font size
        ),

        // Selected date styling
        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 16.0, // Standard calendar day font size
        ),

        // Default day styling
        defaultTextStyle: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 16.0, // Standard calendar day font size
        ),

        // Weekend styling
        weekendTextStyle: TextStyle(
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
          fontSize: 16.0, // Standard calendar day font size
        ),

        // Outside days styling (days from other months)
        outsideTextStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          fontSize: 16.0, // Standard calendar day font size
        ),

        // Markers styling
        markersMaxCount: 3,
        markerDecoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}