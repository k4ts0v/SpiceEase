import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends ConsumerWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    return Material(
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2099, 12, 31),
        focusedDay: selectedDate,
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          ref.read(selectedDateProvider.notifier).state = selectedDay;
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarFormat: CalendarFormat.month,
        headerStyle:
            const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
          weekendStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration:
              BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: Colors.blue, width: 2.0)),
          todayTextStyle: const TextStyle(color: Colors.black),
          selectedDecoration:
              const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
          selectedTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
