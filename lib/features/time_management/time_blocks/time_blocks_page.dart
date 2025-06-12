import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/components/calendar_week_selector.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart'; // Keep for getTaskById

import 'package:spiceease/features/time_management/time_blocks/time_block_controller.dart';
import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';
import 'package:spiceease/l10n/app_localizations.dart';

final weekOffsetProvider = StateProvider<int>((ref) => 0);

class TimeBlocksPage extends ConsumerWidget {
  const TimeBlocksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedDateProvider);
    final timeBlockState = ref.watch(timeBlockControllerProvider);
    final theme = Theme.of(context);

    final weekOffset = ref.watch(weekOffsetProvider);

    final selectedDayOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final currentLoadedDayOnly = timeBlockState.currentSelectedDate == null
        ? null
        : DateTime(
            timeBlockState.currentSelectedDate!.year,
            timeBlockState.currentSelectedDate!.month,
            timeBlockState.currentSelectedDate!.day);

    if (selectedDayOnly != currentLoadedDayOnly && !timeBlockState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(timeBlockControllerProvider.notifier).loadTasks(context);
      });
    }

    if (timeBlockState.error != null && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${timeBlockState.error}")),
        );
        // Clear error after showing
        // ref.read(timeBlockControllerProvider.notifier).state = ref.read(timeBlockControllerProvider.notifier).state.copyWith(error: null);
      });
    }

    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: weekOffset * 7));

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.timeBlocks,
            style: const TextStyle(
                fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () =>
                  _showItemModal(context, ref, null), // null for new Task
              icon: const Icon(Icons.add, size: 18),
              label: Text(localizations.newTask),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 2,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(timeBlockControllerProvider.notifier)
                .loadTasks(context),
            tooltip: localizations.refresh,
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CalendarWeekSelector(
                selectedDate: selectedDate,
                locale: Localizations.localeOf(context),
              ),
            ),
            Expanded(
              child: timeBlockState.isLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(
                                  theme.colorScheme.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(localizations.loading,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.event,
                                    size: 20, color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  DateFormat.yMMMMd(locale)
                                      .format(selectedDate),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: theme.colorScheme.onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: theme
                                  .colorScheme.surface, // Was surfaceVariant
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: 60.0 * 24 +
                                      36, // Hour height * 24 hours + header
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildTimeColumn(context),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildScheduleArea(context, ref,
                                            timeBlockState.scheduledItems),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(
                              12, 0, 12, 16), // Adjusted margin
                          child: _buildUnscheduledItemsSection(
                            context,
                            ref,
                            theme,
                            localizations,
                            timeBlockState.unscheduledItems,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context) {
    final theme = Theme.of(context);
    const startHour = 0;
    const endHour = 23;
    const hourHeight = 60.0;

    return SizedBox(
      width: 55, // Adjusted width for better AM/PM display
      child: Column(
        children: [
          Container(
            // Header for the time column
            width: double.infinity,
            height: 35, // Match schedule area header spacer
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Icon(Icons.access_time,
                size: 18, color: theme.colorScheme.primary),
          ),
          Column(
            children: List.generate(endHour - startHour + 1, (i) {
              final hour = startHour + i;
              return Container(
                height: hourHeight,
                width: double.infinity,
                padding:
                    const EdgeInsets.only(left: 6, top: 10), // Adjusted padding
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                          width: 1)),
                ),
                child: Text(
                  DateFormat.j().format(DateTime(
                      2000, 1, 1, hour)), // Using DateFormat for localization
                  style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  int _calculateMaxConcurrentItems(List<dynamic> items) {
    if (items.isEmpty) return 1;

    final validItems = items.where((item) {
      if (item is TaskModel) {
        return item.startTime != null && item.endTime != null;
      }
      if (item is SubtaskModel) {
        return item.startTime != null && item.endTime != null;
      }
      return false;
    }).toList();

    if (validItems.isEmpty) return 1;

    validItems.sort((a, b) {
      DateTime aStart =
          (a is TaskModel) ? a.startTime! : (a as SubtaskModel).startTime!;
      DateTime bStart =
          (b is TaskModel) ? b.startTime! : (b as SubtaskModel).startTime!;
      return aStart.compareTo(bStart);
    });

    int maxConcurrent = 0;
    List<DateTime> endTimes = [];

    for (final item in validItems) {
      DateTime currentItemStartTime = (item is TaskModel)
          ? item.startTime!
          : (item as SubtaskModel).startTime!;
      DateTime currentItemEndTime =
          (item is TaskModel) ? item.endTime! : (item as SubtaskModel).endTime!;

      endTimes.removeWhere((end) => !end.isAfter(currentItemStartTime));
      endTimes.add(currentItemEndTime);
      if (endTimes.length > maxConcurrent) {
        maxConcurrent = endTimes.length;
      }
    }
    return maxConcurrent > 0 ? maxConcurrent : 1;
  }

  Widget _buildScheduleArea(
      BuildContext context, WidgetRef ref, List<dynamic> items) {
    const hourHeight = 60.0;
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxConcurrent = _calculateMaxConcurrentItems(items);
        final double totalWidth = maxConcurrent <= 1
            ? constraints.maxWidth
            : constraints.maxWidth * 1.5; // Allow horizontal scroll if needed

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: maxConcurrent > 1
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: totalWidth,
            child: Stack(
              children: [
                Column(children: [
                  SizedBox(height: 35, width: totalWidth), // Header spacer
                  ...List.generate(24, (i) {
                    return Container(
                      height: hourHeight,
                      width: totalWidth,
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: theme.dividerColor.withValues(alpha: 0.5),
                                width: 1)),
                      ),
                    );
                  }),
                ]),
                _buildCurrentTimeIndicator(hourHeight, ref),
                ..._buildSideBySideItemWidgets(
                    items, hourHeight, totalWidth, maxConcurrent, ref, context),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSideBySideItemWidgets(
    List<dynamic> items,
    double hourHeight,
    double containerWidth,
    int maxConcurrent,
    WidgetRef ref,
    BuildContext context,
  ) {
    final widgets = <Widget>[];
    if (items.isEmpty) return widgets;

    final sortedValidItems = items.where((item) {
      if (item is TaskModel) {
        return item.startTime != null && item.endTime != null;
      }
      if (item is SubtaskModel) {
        return item.startTime != null && item.endTime != null;
      }
      return false;
    }).toList()
      ..sort((a, b) {
        DateTime aStart =
            (a is TaskModel) ? a.startTime! : (a as SubtaskModel).startTime!;
        DateTime bStart =
            (b is TaskModel) ? b.startTime! : (b as SubtaskModel).startTime!;
        return aStart.compareTo(bStart);
      });

    if (sortedValidItems.isEmpty) return widgets;

    final columns = <dynamic, int>{};
    for (final item in sortedValidItems) {
      int assignedColumn = 0;
      bool foundColumn = false;
      while (!foundColumn) {
        bool overlap = false;
        for (final other in sortedValidItems) {
          if (other == item) continue;
          final otherColumn = columns[other] ?? -1;
          if (otherColumn != assignedColumn) continue;
          if (_itemsOverlap(item, other)) {
            overlap = true;
            break;
          }
        }
        if (overlap) {
          assignedColumn++;
        } else {
          foundColumn = true;
        }
      }
      columns[item] = assignedColumn;
    }

    final maxColumn =
        columns.values.fold(0, (max, col) => col > max ? col : max);
    final double itemWidth = maxColumn > 0
        ? (containerWidth / (maxColumn + 1)).clamp(100, containerWidth / 2)
        : containerWidth - 16; // -16 for padding

    for (final item in sortedValidItems) {
      DateTime itemStartTime = (item is TaskModel)
          ? item.startTime!
          : (item as SubtaskModel).startTime!;
      DateTime itemEndTime =
          (item is TaskModel) ? item.endTime! : (item as SubtaskModel).endTime!;

      final startTotalMinutes = itemStartTime.hour * 60 + itemStartTime.minute;
      final endTotalMinutes = itemEndTime.hour * 60 + itemEndTime.minute;
      final durationMinutes = endTotalMinutes - startTotalMinutes;

      final top = startTotalMinutes * (hourHeight / 60);
      final double height =
          max((durationMinutes * (hourHeight / 60)), 60.0); // Min height 60

      final columnIndex = columns[item] ?? 0;
      final leftOffset = columnIndex * itemWidth;

      widgets.add(
        Positioned(
          top: top,
          left: leftOffset,
          width: itemWidth,
          height: height,
          child: _buildItemCardWithoutDrag(item, ref, context),
        ),
      );
    }
    return widgets;
  }

  bool _itemsOverlap(dynamic a, dynamic b) {
    DateTime startA =
        (a is TaskModel) ? a.startTime! : (a as SubtaskModel).startTime!;
    DateTime endA =
        (a is TaskModel) ? a.endTime! : (a as SubtaskModel).endTime!;
    DateTime startB =
        (b is TaskModel) ? b.startTime! : (b as SubtaskModel).startTime!;
    DateTime endB =
        (b is TaskModel) ? b.endTime! : (b as SubtaskModel).endTime!;
    return startA.isBefore(endB) && startB.isBefore(endA);
  }

  Widget _buildCurrentTimeIndicator(double hourHeight, WidgetRef ref) {
    final now = DateTime.now();
    // Only show indicator if 'now' is on the selectedDate
    final selectedDate = ref.read(selectedDateProvider);
    if (now.year != selectedDate.year ||
        now.month != selectedDate.month ||
        now.day != selectedDate.day) {
      return const SizedBox.shrink();
    }

    final minutesSinceMidnight = now.hour * 60 + now.minute;
    final topPosition = minutesSinceMidnight * (hourHeight / 60);

    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        color: Colors.red.withValues(alpha: 0.7),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle)),
        ),
      ),
    );
  }

  Widget _buildItemCardWithoutDrag(
      dynamic item, WidgetRef ref, BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    String title;
    String? description;
    int priority = 3; // Default priority for color
    bool isSubtask = false;

    if (item is TaskModel) {
      title = item.title;
      description = item.description;
      priority = item.priority;
    } else if (item is SubtaskModel) {
      title = item.title;
      isSubtask = true;
      // Get priority from controller instead of async lookup
      priority = ref
          .read(timeBlockControllerProvider.notifier)
          .getPriorityForSubtask(item.id);
      // Don't show time estimate in description area - it will be shown in bottom section
      description = null;
    } else {
      return const SizedBox.shrink(); // Should not happen
    }

    final Color itemColor, borderColor;
    if (isSubtask) {
      // Use priority-based colors for subtasks, but with reduced opacity
      itemColor = getPastelColor(priority, theme.brightness).withValues(alpha: 0.7);
      borderColor = getTaskPriorityColor(priority, theme.brightness);
    } else {
      itemColor = getPastelColor(priority, theme.brightness);
      borderColor = getTaskPriorityColor(priority, theme.brightness);
    }

    return _buildCard(context, ref, item, title, description, priority,
        isSubtask, itemColor, borderColor, theme, localizations);
  }
// ...existing code...

  Widget _buildCard(
      BuildContext context,
      WidgetRef ref,
      dynamic item,
      String title,
      String? description,
      int priority,
      bool isSubtask,
      Color itemColor,
      Color borderColor,
      ThemeData theme,
      AppLocalizations localizations) {
    // Get the same colors as Kanban cards
    final taskPriorityColor = getTaskPriorityColor(priority, theme.brightness);
    final pastelColor = getPastelColor(priority, theme.brightness);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
          vertical: 4, horizontal: 2), // Match Kanban margins
      color: pastelColor, // Use Kanban-style pastel background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Match Kanban border radius
        side: BorderSide(
            color: taskPriorityColor.withAlpha(153),
            width: 1), // Match Kanban border
      ),
      child: InkWell(
        onTap: () => _showItemModal(context, ref, item),
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  12, 6, 12, 6), // Slightly increased padding
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority color bar with dynamic height based on title length - match Kanban formula
                  Container(
                    width: 4, // Match Kanban width
                    height: min(
                        60,
                        12.0 *
                            (title.length / 10).ceil()), // Use Kanban formula
                    decoration: BoxDecoration(
                      color: taskPriorityColor, // Use Kanban-style color
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8), // Match Kanban spacing

                  // Main content area
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtask indicator for subtasks - minimal height
                        if (isSubtask) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.subdirectory_arrow_right,
                                size: 8, // Slightly bigger icon
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  localizations.subtask,
                                  style: TextStyle(
                                    fontSize: 7, // Slightly bigger font
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2), // Small spacing
                        ],

                        // Title - Use Expanded to take available space
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate how many full lines of text can fit
                              final fontSize =
                                  isSubtask ? 10.0 : 11.0; // Bigger fonts
                              const lineHeight =
                                  1.2; // More line height for readability
                              final lineHeightPx = fontSize * lineHeight;
                              final availableHeight = constraints.maxHeight;
                              final maxLines = (availableHeight / lineHeightPx)
                                  .floor()
                                  .clamp(1, 3);

                              return Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                  height: lineHeight,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: maxLines, // Only show complete lines
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),

                        // Description (only for tasks) - Fixed single line
                        if (description != null &&
                            description.isNotEmpty &&
                            !isSubtask) ...[
                          const SizedBox(height: 2), // Small spacing
                          Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9, // Bigger font
                              height: 1.1,
                              color:
                                  theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],

                        const SizedBox(
                            height: 3), // Small spacing before bottom row

                        // Bottom content - Priority and Time/Estimate on same row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Priority section
                            Icon(Icons.flag_outlined,
                                size: 8, // Bigger icon
                                color: taskPriorityColor),
                            const SizedBox(width: 2), // More spacing
                            Flexible(
                              child: Text(
                                _getPriorityLabel(context, priority),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 7, // Bigger font
                                  color: taskPriorityColor,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                ),
                              ),
                            ),

                            // Time or estimate section - close spacing
                            if ((item is TaskModel &&
                                    item.startTime != null &&
                                    item.endTime != null) ||
                                (item is SubtaskModel &&
                                    item.startTime != null &&
                                    item.endTime != null) ||
                                (isSubtask &&
                                    item is SubtaskModel &&
                                    item.rawTimeValue?.isNotEmpty == true)) ...[
                              const SizedBox(width: 4), // More spacing
                              Icon(Icons.timer_outlined,
                                  size: 8, // Bigger icon
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6)),
                              const SizedBox(width: 2), // More spacing
                              Flexible(
                                child: Text(
                                  // Show scheduled time if available, otherwise show estimate for subtasks
                                  ((item is TaskModel &&
                                              item.startTime != null &&
                                              item.endTime != null) ||
                                          (item is SubtaskModel &&
                                              item.startTime != null &&
                                              item.endTime != null))
                                      ? DateFormat.jm().format((item
                                              is TaskModel)
                                          ? item.startTime!
                                          : (item as SubtaskModel).startTime!)
                                      : (isSubtask &&
                                              item is SubtaskModel &&
                                              item.rawTimeValue?.isNotEmpty ==
                                                  true)
                                          ? item.rawTimeValue!
                                          : '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 7, // Bigger font
                                    height: 1.1,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 2, // Slightly more space from top
              right: 2, // Slightly more space from right
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmUnschedule(context, ref, item),
                  borderRadius:
                      BorderRadius.circular(3), // Slightly bigger radius
                  child: Container(
                    padding: const EdgeInsets.all(1), // Slightly more padding
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Icon(Icons.close,
                        size: 10, // Bigger icon
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ...existing code...

  void _confirmUnschedule(BuildContext context, WidgetRef ref, dynamic item) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.unschedule),
        content: Text(localizations.unscheduleTaskConfirmation),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(timeBlockControllerProvider.notifier)
                  .unscheduleTask(item, context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white),
            child: Text(localizations.unschedule),
          ),
        ],
      ),
    );
  }

  Widget _buildUnscheduledItemsSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations localizations,
    List<dynamic> unscheduledItems,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: unscheduledItems.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                localizations.noTasks,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(128),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final item in unscheduledItems)
                      _buildUnscheduledItemCard(
                          context, ref, item, theme, localizations),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUnscheduledItemCard(BuildContext context, WidgetRef ref,
      dynamic item, ThemeData theme, AppLocalizations localizations) {
    String title;
    String? description;
    int priority = 3; // Default
    bool isSubtask = false;

    if (item is TaskModel) {
      title = item.title;
      description = item.description;
      priority = item.priority;
    } else if (item is SubtaskModel) {
      title = item.title;
      isSubtask = true;
      description = null;

      // Get priority from controller instead of FutureBuilder
      priority = ref
          .read(timeBlockControllerProvider.notifier)
          .getPriorityForSubtask(item.id);
    } else {
      return const SizedBox.shrink();
    }

    // Use Kanban-style colors consistently
    final taskPriorityColor = getTaskPriorityColor(priority, theme.brightness);
    final itemColor =
        getPastelColor(priority, theme.brightness).withValues(alpha: 0.3);

    return _buildUnscheduledCard(
        context,
        ref,
        item,
        title,
        description,
        priority,
        isSubtask,
        itemColor,
        taskPriorityColor,
        theme,
        localizations);
  }

  Widget _buildUnscheduledCard(
      BuildContext context,
      WidgetRef ref,
      dynamic item,
      String title,
      String? description,
      int priority,
      bool isSubtask,
      Color itemColor,
      Color borderColor,
      ThemeData theme,
      AppLocalizations localizations) {
    return GestureDetector(
      onTap: () => _showItemModal(context, ref, item),
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: itemColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor.withAlpha(153)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showItemModal(context, ref, item),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top content - Title section with priority color bar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use Kanban-style dynamic height formula
                    Container(
                      width: 4,
                      height: min(60,
                          12.0 * (title.length / 10).ceil()), // Kanban formula
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Subtask indicator for subtasks
                          if (isSubtask)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.subdirectory_arrow_right,
                                    size: 10,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    localizations.subtask,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontStyle: FontStyle.italic,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Title
                          Text(
                            title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Description (only for tasks - subtasks don't show description here)
                          if (!isSubtask &&
                              description != null &&
                              description.isNotEmpty) ...[
                            Text(
                              description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                                height: 1.0,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Spacer to push bottom content down
                const Spacer(),

                // Bottom content - Priority (for both tasks and subtasks now)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flag_outlined, size: 10, color: borderColor),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        _getPriorityLabel(context, priority),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: borderColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                // Time estimate for subtasks (separate from priority)
                if (isSubtask &&
                    item is SubtaskModel &&
                    item.rawTimeValue?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 10,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            item.rawTimeValue!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.1,
                              color:
                                  theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getPastelColor(int? priority, Brightness brightness) {
    // For dark mode, use darker pastel colors that work well with dark backgrounds
    if (brightness == Brightness.dark) {
      switch (priority) {
        case 1:
          return const Color(0xFF0D47A1).withValues(alpha: 0.3); // Dark blue pastel
        case 2:
          return const Color(0xFF1B5E20).withValues(alpha: 0.3); // Dark green pastel
        case 3:
          return const Color(0xFFF57F17).withValues(alpha: 0.3); // Dark yellow pastel
        case 4:
          return const Color(0xFFE65100).withValues(alpha: 0.3); // Dark orange pastel
        case 5:
          return const Color(0xFFB71C1C).withValues(alpha: 0.3); // Dark red pastel
        default:
          return const Color(0xFF424242).withValues(alpha: 0.3); // Dark grey pastel
      }
    }

    // Light, subtle pastel colors for light mode
    switch (priority) {
      case 1:
        return const Color(0xFFE3F2FD); // Pastel blue
      case 2:
        return const Color(0xFFE8F5E9); // Pastel green
      case 3:
        return const Color(0xFFFFF8E1); // Pastel yellow
      case 4:
        return const Color(0xFFFFE0B2); // Pastel orange
      case 5:
        return const Color(0xFFFFF0F0); // Pastel red
      default:
        return const Color(0xFFF5F5F5); // Default pastel color
    }
  }

  Color getTaskPriorityColor(int? priority, Brightness brightness) {
    // For dark mode, use slightly lighter colors for better visibility
    if (brightness == Brightness.dark) {
      switch (priority) {
        case 1:
          return const Color(0xFF42A5F5); // Light blue for dark mode
        case 2:
          return const Color(0xFF66BB6A); // Light green for dark mode
        case 3:
          return const Color(0xFFFFD54F); // Light yellow for dark mode
        case 4:
          return const Color(0xFFFFB74D); // Light orange for dark mode
        case 5:
          return const Color(0xFFEF5350); // Light red for dark mode
        default:
          return const Color(0xFFBDBDBD); // Light grey for dark mode
      }
    }

    // Standard colors for light mode
    switch (priority) {
      case 1:
        return const Color(0xFF2196F3); // Blue
      case 2:
        return const Color(0xFF4CAF50); // Green
      case 3:
        return const Color(0xFFFFC107); // Yellow
      case 4:
        return const Color(0xFFFF9800); // Orange
      case 5:
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  Future<void> _showItemModal(
      BuildContext context, WidgetRef ref, dynamic item) async {
    Widget modalContent;

    if (item is TaskModel || item == null) {
      // item == null means new Task
      modalContent = TaskEditorModal(
        ref: ref,
        existing: item as TaskModel?,
        selectedDate: ref.read(selectedDateProvider),
      );
    } else if (item is SubtaskModel) {
      // For SubtaskEditorModal, we need the parent TaskModel.
      // Fetch it using the taskId from the SubtaskModel.
      final parentTask =
          await ref.read(taskServiceProvider).getTaskById(item.taskId);
      if (parentTask != null) {
        modalContent = SubtaskEditorModal(
          ref: ref,
          parentTask: parentTask,
          subtask: item, // 'existing' is the subtask itself
        );
      } else {
        // Handle error: parent task not found
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            // SnackBar(content: Text(AppLocalizations.of(context)!.parentTaskNotFound)),
            SnackBar(content: Text('Parent task not found')),
          );
        }
        return;
      }
    } else {
      return; // Should not happen
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => modalContent,
    ).then((result) {
      // If modal was popped with 'true' (e.g. after save/delete), refresh.
      if (result == true) {
        ref.read(timeBlockControllerProvider.notifier).loadTasks(context);
      } else if (item == null && result == null) {
        // New task modal was cancelled
        // Potentially do nothing or a light refresh if needed
      } else {
        // Fallback refresh for other cases if state might be stale
        ref.read(timeBlockControllerProvider.notifier).loadTasks(context);
      }
    });
  }

  String _getPriorityLabel(BuildContext context, int priority) {
    final localizations = AppLocalizations.of(context)!;
    switch (priority) {
      case 1:
        return localizations.lowestPriority;
      case 2:
        return localizations.lowPriority;
      case 3:
        return localizations.mediumPriority;
      case 4:
        return localizations.highPriority;
      case 5:
        return localizations.highestPriority;
      default:
        return "";
    }
  }
}
