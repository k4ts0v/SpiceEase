import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';

final weekOffsetProvider = StateProvider<int>((ref) => 0);

class CalendarWeekSelector extends ConsumerWidget {
  final DateTime selectedDate;
  final Locale locale;

  const CalendarWeekSelector({
    super.key,
    required this.selectedDate,
    required this.locale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weekOffset = ref.watch(weekOffsetProvider);
    final now = DateTime.now();
    final firstDayOfWeek = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: weekOffset * 7));

    // Unified background color for the whole component
    final backgroundColor = theme.colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header section with proper flex constraints
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Row(
              children: [
                // Left arrow button with fixed width
                SizedBox(
                  width: 40,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () =>
                        ref.read(weekOffsetProvider.notifier).state--,
                    color: theme.colorScheme.secondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),

                // Center content with flexible width
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: theme.colorScheme.secondary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _formatWeekRange(firstDayOfWeek, locale.languageCode),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right arrow button with fixed width
                SizedBox(
                  width: 40,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () =>
                        ref.read(weekOffsetProvider.notifier).state++,
                    color: theme.colorScheme.secondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thin divider
          Divider(
            height: 1,
            thickness: 0.5,
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),

          // Weekdays section
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                ref.read(weekOffsetProvider.notifier).state++;
              } else if (details.primaryVelocity! > 0) {
                ref.read(weekOffsetProvider.notifier).state--;
              }
            },
            child: _buildWeekDays(firstDayOfWeek, ref, context),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays(
      DateTime firstDayOfWeek, WidgetRef ref, BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final date = firstDayOfWeek.add(Duration(days: index));
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 70,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : isToday
                          ? theme.colorScheme.secondary.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.secondary.withOpacity(
                                theme.brightness == Brightness.dark
                                    ? 0.5
                                    : 0.3),
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
                    onTap: () =>
                        ref.read(selectedDateProvider.notifier).state = date,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E(locale.languageCode)
                              .format(date)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? theme.colorScheme.onSecondary
                                : theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                          strutStyle: const StrutStyle(
                            fontSize: 12,
                            height: 1.1,
                            forceStrutHeight: true,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? theme.colorScheme.onSecondary.withOpacity(0.3)
                                : isToday
                                    ? theme.colorScheme.secondary
                                        .withOpacity(0.2)
                                    : Colors.transparent,
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? theme.colorScheme.onSecondary
                                  : isToday
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
                            strutStyle: const StrutStyle(
                              fontSize: 14,
                              height: 1.1,
                              forceStrutHeight: true,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
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

    // For very small screens, use a more compact format
    if (firstDay.month == lastDay.month) {
      // Same month: "Mar 1-7, 2024"
      return '${DateFormat.MMM(locale).format(firstDay)} ${firstDay.day}-${lastDay.day}, ${lastDay.year}';
    }
    if (firstDay.year == lastDay.year) {
      // Same year: "Mar 30 - Apr 5"
      return '${DateFormat.MMMd(locale).format(firstDay)} - ${DateFormat.MMMd(locale).format(lastDay)}';
    }
    // Different years: "Dec 30, 2023 - Jan 5, 2024"
    return '${DateFormat.MMMd(locale).format(firstDay)}, ${firstDay.year} - ${DateFormat.MMMd(locale).format(lastDay)}, ${lastDay.year}';
  }
}
