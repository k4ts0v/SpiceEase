import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';

final weekOffsetProvider = StateProvider<int>((ref) => 0);

class CalendarWeekSelector extends ConsumerWidget {
  final DateTime selectedDate;
  final Locale locale;
  final ThemeData theme;

  const CalendarWeekSelector({
    super.key,
    required this.selectedDate,
    required this.locale,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekOffset = ref.watch(weekOffsetProvider);
    final now = DateTime.now();
    final firstDayOfWeek = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: weekOffset * 7));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => ref.read(weekOffsetProvider.notifier).state--,
                color: theme.colorScheme.primary,
              ),
              const Spacer(),
              Icon(
                Icons.calendar_month,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _formatWeekRange(firstDayOfWeek, locale.languageCode),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => ref.read(weekOffsetProvider.notifier).state++,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              ref.read(weekOffsetProvider.notifier).state++;
            } else if (details.primaryVelocity! > 0) {
              ref.read(weekOffsetProvider.notifier).state--;
            }
          },
          child: _buildWeekDays(firstDayOfWeek, ref),
        ),
      ],
    );
  }

  Widget _buildWeekDays(DateTime firstDayOfWeek, WidgetRef ref) {
    return SizedBox(
      height: 85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = firstDayOfWeek.add(Duration(days: index));
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 45,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isToday
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => ref.read(selectedDateProvider.notifier).state = date,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.E(locale.languageCode)
                          .format(date)
                          .substring(0, 1)
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? Colors.white
                            : theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.white.withOpacity(0.3)
                            : isToday
                                ? theme.colorScheme.primary.withOpacity(0.2)
                                : Colors.transparent,
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _formatWeekRange(DateTime firstDay, String locale) {
    final lastDay = firstDay.add(const Duration(days: 6));
    if (firstDay.month == lastDay.month) {
      return '${DateFormat.MMMd(locale).format(firstDay)} - ${DateFormat.d(locale).format(lastDay)}, ${lastDay.year}';
    }
    if (firstDay.year == lastDay.year) {
      return '${DateFormat.MMMd(locale).format(firstDay)} - ${DateFormat.MMMd(locale).format(lastDay)}';
    }
    return '${DateFormat.MMMd(locale).format(firstDay)}, ${firstDay.year} - ${DateFormat.MMMd(locale).format(lastDay)}, ${lastDay.year}';
  }
}