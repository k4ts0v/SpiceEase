// ...existing code...

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/components/calendar_week_selector.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';

import 'package:spiceease/features/time_management/time_blocks/time_block_controller.dart';
import 'package:spiceease/features/tracker/presentation/modals.dart';
import 'package:spiceease/l10n/app_localizations.dart';

final weekOffsetProvider = StateProvider<int>((ref) => 0);

class TimeBlocksPage extends ConsumerWidget {
  const TimeBlocksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedDateProvider);
    final timeBlockState = ref.watch(timeBlockControllerProvider);
    final theme = Theme.of(context);

    // Add this line to access the week offset
    final weekOffset = ref.watch(weekOffsetProvider);

    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final currentDay = timeBlockState.currentSelectedDate == null
        ? null
        : DateTime(
            timeBlockState.currentSelectedDate!.year,
            timeBlockState.currentSelectedDate!.month,
            timeBlockState.currentSelectedDate!.day,
          );

    // Automatically load tasks if date changed
    if (selectedDay != currentDay && !timeBlockState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(timeBlockControllerProvider.notifier).loadTasks(context);
      });
    }

    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();

    // To account for week offset
    final firstDayOfWeek = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: weekOffset * 7));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.timeBlocks ?? 'Time Blocks',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showTaskModal(context, ref, null),
              icon: const Icon(Icons.add, size: 18),
              label: Text(localizations.newTask ?? 'New Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
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
      backgroundColor: const Color(0xFFF8F9FA),
    body: SafeArea(
      child: Column(
        children: [
          // Calendar Week Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CalendarWeekSelector(
              selectedDate: selectedDate,
              locale: Localizations.localeOf(context),
              theme: theme,
            ),
          ),

            // —— Main content ——
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
                          Text(
                            localizations.loading ?? 'Loading...',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // —— Display for the selected date ——
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.event,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  DateFormat.yMMMMd(locale)
                                      .format(selectedDate),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // —— The schedule area ——
                        Expanded(
                          flex: 5,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
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
                                  height: 60.0 * 24 + 36,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildTimeColumn(context),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildScheduleArea(
                                          context,
                                          ref,
                                          timeBlockState.scheduledTasks,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // —— Unscheduled tasks (no dragging) ——
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.list_alt,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                localizations.unscheduledTasks ??
                                    'Unscheduled Tasks',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFF5F6F8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          // Just show a list of unscheduled tasks (no Draggable)
                          child: timeBlockState.unscheduledTasks.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inbox,
                                        color: Colors.grey[400],
                                        size: 24,
                                      ),
                                      Text(
                                        localizations.noTasks ?? 'No tasks',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  itemCount:
                                      timeBlockState.unscheduledTasks.length,
                                  itemBuilder: (context, index) {
                                    final task =
                                        timeBlockState.unscheduledTasks[index];
                                    return SizedBox(
                                      width: 180,
                                      height: 100,
                                      child: _buildTaskCard(context, ref, task),
                                    );
                                  },
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

  // Add this helper method to format the week range display
  String _formatWeekRange(DateTime firstDay, String locale) {
    final lastDay = firstDay.add(const Duration(days: 6));

    // If first and last day are in the same month
    if (firstDay.month == lastDay.month) {
      return '${DateFormat.MMMd(locale).format(firstDay)} - ${DateFormat.d(locale).format(lastDay)}, ${lastDay.year}';
    }

    // If first and last day are in different months but same year
    if (firstDay.year == lastDay.year) {
      return '${DateFormat.MMMd(locale).format(firstDay)} - ${DateFormat.MMMd(locale).format(lastDay)}';
    }

    // If first and last day are in different years
    return '${DateFormat.MMMd(locale).format(firstDay)}, ${firstDay.year} - ${DateFormat.MMMd(locale).format(lastDay)}, ${lastDay.year}';
  }

  Widget _buildTimeColumn(BuildContext context) {
    final theme = Theme.of(context);
    const startHour = 0;
    const endHour = 23;
    final hourHeight = 60.0;

    return SizedBox(
      width: 55,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Icon(
              Icons.access_time,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          Column(
            children: List.generate(endHour - startHour + 1, (i) {
              final hour = startHour + i;
              return Container(
                height: hourHeight,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 6, top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  '${hour % 12 == 0 ? 12 : hour % 12}${hour < 12 ? 'AM' : 'PM'}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  int _calculateMaxConcurrentTasks(List<TaskModel> tasks) {
    if (tasks.isEmpty) return 1;

    // Filter valid tasks
    final validTasks =
        tasks.where((t) => t.startTime != null && t.endTime != null).toList();
    if (validTasks.isEmpty) return 1;

    // Sort by start time
    validTasks.sort((a, b) => a.startTime!.compareTo(b.startTime!));

    // Calculate max concurrent tasks
    int maxConcurrent = 0;
    List<DateTime> endTimes = [];

    for (final task in validTasks) {
      // Remove ended tasks
      endTimes.removeWhere((end) => !end.isAfter(task.startTime!));
      // Add this task's end time
      endTimes.add(task.endTime!);
      // Update max
      if (endTimes.length > maxConcurrent) {
        maxConcurrent = endTimes.length;
      }
    }

    return maxConcurrent > 0 ? maxConcurrent : 1;
  }

  Widget _buildScheduleArea(
    BuildContext context,
    WidgetRef ref,
    List<TaskModel> tasks,
  ) {
    final hourHeight = 60.0;

    // Debug - print tasks with times to check if they're being received
    print('Scheduled tasks: ${tasks.length}');
    for (final task in tasks) {
      print(
          'Task: ${task.title}, Start: ${task.startTime}, End: ${task.endTime}');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate maximum concurrent tasks
        final maxConcurrent = _calculateMaxConcurrentTasks(tasks);
        print("Max concurrent tasks: $maxConcurrent");

        // Calculate the total width needed based on max concurrency
        final double totalWidth = maxConcurrent <= 1
            ? constraints.maxWidth // Use full width if only one concurrent task
            : constraints.maxWidth *
                1.5; // Use more than screen width if multiple tasks

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: maxConcurrent > 1
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: totalWidth,
            child: Stack(
              children: [
                Column(
                  children: List.generate(24, (i) {
                    return Container(
                      height: hourHeight,
                      width: totalWidth,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.black.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                _buildCurrentTimeIndicator(hourHeight),
                // Instead of drag/drop, simply lay out tasks by calculating top offset
                ..._buildSideBySideTaskWidgets(
                    tasks, hourHeight, totalWidth, maxConcurrent, ref),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSideBySideTaskWidgets(
    List<TaskModel> tasks,
    double hourHeight,
    double containerWidth,
    int maxConcurrent,
    WidgetRef ref,
  ) {
    final widgets = <Widget>[];

    if (tasks.isEmpty) {
      print("No scheduled tasks to display");
      return widgets;
    }

    // Sort tasks by startTime to process them in order
    final sorted = List<TaskModel>.from(tasks)
      ..removeWhere((task) => task.startTime == null || task.endTime == null)
      ..sort((a, b) => a.startTime!.compareTo(b.startTime!));

    if (sorted.isEmpty) {
      print("No tasks with both start and end times");
      return widgets;
    }

    // We'll assign each overlapping block a "column" index.
    final columns = <TaskModel, int>{};

    for (final task in sorted) {
      int assignedColumn = 0;
      bool foundColumn = false;
      // Check existing assignments
      while (!foundColumn) {
        bool overlap = false;
        for (final other in sorted) {
          if (other == task) continue;

          final otherColumn = columns[other] ?? -1;
          if (otherColumn != assignedColumn) continue;

          // Check overlap
          if (_tasksOverlap(task, other)) {
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
      columns[task] = assignedColumn;
    }

    // Calculate the maximum column index
    final maxColumn =
        columns.values.fold(0, (max, col) => col > max ? col : max);

    // Calculate task width based on container width and concurrent tasks
    final bool hasConcurrent = maxColumn > 0;

    // Width calculation: if there are concurrent tasks, make each task
    // take up 50% of the available width (or less), otherwise full width
    final double taskWidth = hasConcurrent
        ? (containerWidth / (maxColumn + 1)).clamp(100, containerWidth / 2)
        : containerWidth - 16; // Full width minus padding

    // Calculate position & size for each scheduled task
    for (final task in sorted) {
      final startTotal = task.startTime!.hour * 60 + task.startTime!.minute;
      final endTotal = task.endTime!.hour * 60 + task.endTime!.minute;
      final duration = endTotal - startTotal;
      final top = startTotal * (hourHeight / 60);

      // Calculate height based on duration, with minimum
      final double height = max(
        (duration * (hourHeight / 60)),
        // Set minimum height based on content
        task.description.isEmpty ? 60.0 : 70.0,
      );

      final columnIndex = columns[task] ?? 0;
      final leftOffset = columnIndex * taskWidth;

      print(
          "Positioning task: ${task.title} at top: $top, left: $leftOffset, width: $taskWidth, height: $height");

      widgets.add(
        Positioned(
          top: top,
          left: leftOffset,
          width: taskWidth,
          height: height,
          child: _buildTaskCardWithoutDrag(task, ref),
        ),
      );
    }

    return widgets;
  }

  bool _tasksOverlap(TaskModel a, TaskModel b) {
    final startA = a.startTime!;
    final endA = a.endTime!;
    final startB = b.startTime!;
    final endB = b.endTime!;
    return startA.isBefore(endB) && startB.isBefore(endA);
  }

  Widget _buildCurrentTimeIndicator(double hourHeight) {
    final now = DateTime.now();
    final minutesSinceMidnight = now.hour * 60 + now.minute;
    final topPosition = minutesSinceMidnight * (hourHeight / 60);

    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        color: Colors.red.withOpacity(0.7),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCardWithoutDrag(TaskModel task, WidgetRef ref) {
    final pastel = getPastelColor(task.priority);
    final border = getTaskPriorityColor(task.priority);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      color: pastel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: border.withOpacity(0.6), width: 1),
      ),
      child: InkWell(
        onTap: () => _showTaskModal(ref.context, ref, task),
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.1,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  _buildCompactPriorityRow(task),
                  if (task.startTime != null && task.endTime != null)
                    _buildCompactTimeRow(task),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmUnschedule(ref.context, ref, task),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(9),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmUnschedule(BuildContext context, WidgetRef ref, TaskModel task) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unschedule Task'),
        content: Text(
            'Remove this task from the schedule? It will remain in your task list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Use the controller method instead of direct service
              await ref
                  .read(timeBlockControllerProvider.notifier)
                  .unscheduleTask(task, context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Unschedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, TaskModel task,
      {bool isDragging = false}) {
    final pastel = getPastelColor(task.priority);
    final border = getTaskPriorityColor(task.priority);
    return Card(
      elevation: isDragging ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      color: pastel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: border.withOpacity(0.6), width: 1),
      ),
      child: InkWell(
        onTap: () => _showTaskModal(context, ref, task),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 50, maxHeight: 100),
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.1,
                ),
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  task.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.0,
                  ),
                ),
              ],
              const Spacer(),
              _buildCompactPriorityRow(task),
              if (task.startTime != null && task.endTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _buildCompactTimeRow(task),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPriorityRow(TaskModel task) {
    final priorityColor = getTaskPriorityColor(task.priority);
    String label = '';
    switch (task.priority) {
      case 1:
        label = 'Lowest Priority';
        break;
      case 2:
        label = 'Low Priority';
        break;
      case 3:
        label = 'Medium Priority';
        break;
      case 4:
        label = 'High Priority';
        break;
      case 5:
        label = 'Highest Priority';
        break;
      default:
        label = '';
    }
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 8, color: priorityColor),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                color: priorityColor,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTimeRow(TaskModel task) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 8, color: Colors.grey[600]),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              '${DateFormat.jm().format(task.startTime!)} - '
              '${DateFormat.jm().format(task.endTime!)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getPastelColor(int? priority) {
    switch (priority) {
      case 1:
        return const Color(0xFFE3F2FD);
      case 2:
        return const Color(0xFFE8F5E9);
      case 3:
        return const Color(0xFFFFF8E1);
      case 4:
        return const Color(0xFFFFE0B2);
      case 5:
        return const Color(0xFFFFF0F0);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color getTaskPriorityColor(int? priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF2196F3);
      case 2:
        return const Color(0xFF4CAF50);
      case 3:
        return const Color(0xFFFFC107);
      case 4:
        return const Color(0xFFFF9800);
      case 5:
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  void _showTaskModal(BuildContext context, WidgetRef? ref, TaskModel? task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskEditorModal(
        ref: ref!,
        existing: task,
        selectedDate: ref.read(selectedDateProvider),
      ),
    ).then((_) {
      if (ref != null) {
        ref.read(timeBlockControllerProvider.notifier).loadTasks(context);
      }
    });
  }
}
