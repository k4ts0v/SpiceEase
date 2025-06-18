// Standard Flutter imports for UI components and mathematical calculations
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Custom components and data models
import 'package:spiceease/components/calendar_week_selector.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';

// Data providers for state management
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart'; // Keep for getTaskById

// Feature-specific imports for time management and modals
import 'package:spiceease/features/time_management/time_blocks/time_block_controller.dart';
import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// ===== PROVIDERS =====
/// Provider for managing week offset in calendar navigation
/// Allows users to navigate between different weeks in the time blocks view
final weekOffsetProvider = StateProvider<int>((ref) => 0);

// ===== TIME BLOCKS PAGE =====
/// Main page widget for the time blocks feature
/// Displays scheduled and unscheduled tasks/subtasks in a visual time-based layout
/// Allows users to view, edit, schedule, and unschedule tasks for a selected date
class TimeBlocksPage extends ConsumerWidget {
  const TimeBlocksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ===== LOCALIZATION AND THEME SETUP =====
    final localizations = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedDateProvider);
    final timeBlockState = ref.watch(timeBlockControllerProvider);
    final theme = Theme.of(context);
    final weekOffset = ref.watch(weekOffsetProvider);

    // ===== DATE COMPARISON FOR REFRESH LOGIC =====
    // Compare currently selected date with the date loaded in the state
    // This ensures we reload data when the user changes the selected date
    final selectedDayOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final currentLoadedDayOnly = timeBlockState.currentSelectedDate == null
        ? null
        : DateTime(
            timeBlockState.currentSelectedDate!.year,
            timeBlockState.currentSelectedDate!.month,
            timeBlockState.currentSelectedDate!.day);

    // ===== AUTO-REFRESH LOGIC =====
    // Automatically reload tasks when the selected date changes
    if (selectedDayOnly != currentLoadedDayOnly && !timeBlockState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(timeBlockControllerProvider.notifier).loadTasks(context);
      });
    }

    // ===== ERROR HANDLING =====
    // Show error messages to user if any operations fail
    if (timeBlockState.error != null && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${timeBlockState.error}")),
        );
        // Note: Error clearing is handled in the controller
      });
    }

    // ===== LOCALE SETUP =====
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    // Calculate week start based on current date and week offset
    now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: weekOffset * 7));

    return Scaffold(
      // ===== APP BAR SECTION =====
      appBar: AppBar(
        title: Text(localizations.timeBlocks,
            style: const TextStyle(
                fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          // New Task button
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
          // Refresh button
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
      // ===== MAIN BODY SECTION =====
      body: SafeArea(
        child: Column(
          children: [
            // ===== CALENDAR WEEK SELECTOR =====
            // Top section with week navigation and date selection
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
            // ===== MAIN CONTENT AREA =====
            Expanded(
              child: timeBlockState.isLoading
                  ? // ===== LOADING STATE =====
                  Center(
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
                  : // ===== MAIN CONTENT LAYOUT =====
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ===== DATE HEADER SECTION =====
                        // Shows the currently selected date with an icon
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
                        // ===== SCHEDULED ITEMS SECTION =====
                        // Main time blocks view with hourly grid and scheduled items
                        Expanded(
                          flex: 5,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: theme.colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      theme.shadowColor.withValues(alpha: 0.1),
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
                                      // Time column showing hours 0-23
                                      _buildTimeColumn(context),
                                      const SizedBox(width: 12),
                                      // Schedule area with positioned items
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
                        // ===== UNSCHEDULED ITEMS SECTION =====
                        // Bottom section showing tasks/subtasks without specific times
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
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

  // ===== TIME COLUMN BUILDER =====
  /// Builds the left column showing hour markers from 0:00 to 23:00
  /// Uses localized time format and provides visual separation between hours
  Widget _buildTimeColumn(BuildContext context) {
    final theme = Theme.of(context);
    const startHour = 0;
    const endHour = 23;
    const hourHeight = 60.0;

    return SizedBox(
      width: 55, // Adjusted width for better AM/PM display
      child: Column(
        children: [
          // ===== TIME COLUMN HEADER =====
          // Header section with clock icon to match the schedule area
          Container(
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
          // ===== HOUR MARKERS =====
          // Generate hour markers from 0 to 23 with proper formatting
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

  // ===== CONCURRENT ITEMS CALCULATOR =====
  /// Calculates the maximum number of items that overlap at any given time
  /// This determines the layout width needed for side-by-side display
  /// Used to prevent overlapping scheduled items and enable horizontal scrolling when needed
  int _calculateMaxConcurrentItems(List<dynamic> items) {
    if (items.isEmpty) return 1;

    // Filter out items without valid start/end times
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

    // Sort by start time for processing
    validItems.sort((a, b) {
      DateTime aStart =
          (a is TaskModel) ? a.startTime! : (a as SubtaskModel).startTime!;
      DateTime bStart =
          (b is TaskModel) ? b.startTime! : (b as SubtaskModel).startTime!;
      return aStart.compareTo(bStart);
    });

    // Calculate maximum concurrent items using sweep line algorithm
    int maxConcurrent = 0;
    List<DateTime> endTimes = [];

    for (final item in validItems) {
      DateTime currentItemStartTime = (item is TaskModel)
          ? item.startTime!
          : (item as SubtaskModel).startTime!;
      DateTime currentItemEndTime =
          (item is TaskModel) ? item.endTime! : (item as SubtaskModel).endTime!;

      // Remove ended items before current item starts
      endTimes.removeWhere((end) => !end.isAfter(currentItemStartTime));
      // Add current item's end time
      endTimes.add(currentItemEndTime);

      // Update maximum if current count is higher
      if (endTimes.length > maxConcurrent) {
        maxConcurrent = endTimes.length;
      }
    }
    return maxConcurrent > 0 ? maxConcurrent : 1;
  }

  // ===== SCHEDULE AREA BUILDER =====
  /// Builds the main schedule area where timed items are positioned
  /// Handles horizontal scrolling when multiple items overlap
  /// Contains the time grid, current time indicator, and positioned item cards
  Widget _buildScheduleArea(
      BuildContext context, WidgetRef ref, List<dynamic> items) {
    const hourHeight = 60.0;
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxConcurrent = _calculateMaxConcurrentItems(items);
        // Expand width if items need to be displayed side-by-side
        final double totalWidth = maxConcurrent <= 1
            ? constraints.maxWidth
            : constraints.maxWidth * 1.5; // Allow horizontal scroll if needed

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          // Only allow horizontal scrolling if there are overlapping items
          physics: maxConcurrent > 1
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: totalWidth,
            child: Stack(
              children: [
                // ===== BACKGROUND HOUR GRID =====
                // Creates the visual grid lines for each hour
                Column(children: [
                  SizedBox(height: 35, width: totalWidth), // Header spacer
                  ...List.generate(24, (i) {
                    return Container(
                      height: hourHeight,
                      width: totalWidth,
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color:
                                    theme.dividerColor.withValues(alpha: 0.5),
                                width: 1)),
                      ),
                    );
                  }),
                ]),
                // ===== CURRENT TIME INDICATOR =====
                // Red line showing current time if viewing today
                _buildCurrentTimeIndicator(hourHeight, ref),
                // ===== POSITIONED ITEMS =====
                // All scheduled items positioned based on their start/end times
                ..._buildSideBySideItemWidgets(
                    items, hourHeight, totalWidth, maxConcurrent, ref, context),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== SIDE-BY-SIDE ITEM WIDGETS BUILDER =====
  /// Positions scheduled items side-by-side when they overlap in time
  /// Uses a column assignment algorithm to prevent visual conflicts
  /// Calculates precise positioning based on start/end times
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

    // ===== FILTER AND SORT ITEMS =====
    // Only process items with valid start and end times
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

    // ===== COLUMN ASSIGNMENT ALGORITHM =====
    // Assign each item to a column to prevent overlaps
    final columns = <dynamic, int>{};
    for (final item in sortedValidItems) {
      int assignedColumn = 0;
      bool foundColumn = false;

      // Find the first available column where this item doesn't overlap
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

    // ===== CALCULATE ITEM DIMENSIONS =====
    final maxColumn =
        columns.values.fold(0, (max, col) => col > max ? col : max);
    final double itemWidth = maxColumn > 0
        ? (containerWidth / (maxColumn + 1)).clamp(100, containerWidth / 2)
        : containerWidth - 16; // -16 for padding

    // ===== POSITION EACH ITEM =====
    for (final item in sortedValidItems) {
      DateTime itemStartTime = (item is TaskModel)
          ? item.startTime!
          : (item as SubtaskModel).startTime!;
      DateTime itemEndTime =
          (item is TaskModel) ? item.endTime! : (item as SubtaskModel).endTime!;

      // Calculate position and size based on time
      final startTotalMinutes = itemStartTime.hour * 60 + itemStartTime.minute;
      final endTotalMinutes = itemEndTime.hour * 60 + itemEndTime.minute;
      final durationMinutes = endTotalMinutes - startTotalMinutes;

      final top = startTotalMinutes * (hourHeight / 60);
      final double height =
          max((durationMinutes * (hourHeight / 60)), 60.0); // Min height 60

      final columnIndex = columns[item] ?? 0;
      final leftOffset = columnIndex * itemWidth;

      // Create positioned widget for this item
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

  // ===== OVERLAP DETECTION =====
  /// Determines if two items overlap in time
  /// Used by the column assignment algorithm to prevent visual conflicts
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

  // ===== CURRENT TIME INDICATOR =====
  /// Builds a red line indicator showing the current time
  /// Only visible when viewing today's schedule
  /// Positioned based on current hour and minute
  Widget _buildCurrentTimeIndicator(double hourHeight, WidgetRef ref) {
    final now = DateTime.now();
    // Only show indicator if 'now' is on the selectedDate
    final selectedDate = ref.read(selectedDateProvider);
    if (now.year != selectedDate.year ||
        now.month != selectedDate.month ||
        now.day != selectedDate.day) {
      return const SizedBox.shrink();
    }

    // Calculate position based on current time
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

  // ===== SCHEDULED ITEM CARD BUILDER =====
  /// Builds the visual card for a scheduled item (task or subtask)
  /// Extracts item properties and applies appropriate styling
  /// Handles both TaskModel and SubtaskModel types
  Widget _buildItemCardWithoutDrag(
      dynamic item, WidgetRef ref, BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    // ===== EXTRACT ITEM PROPERTIES =====
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
      // Get priority from controller's cached map instead of async lookup
      priority = ref
          .read(timeBlockControllerProvider.notifier)
          .getPriorityForSubtask(item.id);
      // Don't show time estimate in description area for scheduled items
      description = null;
    } else {
      return const SizedBox.shrink(); // Should not happen
    }

    // ===== CALCULATE COLORS =====
    final Color itemColor, borderColor;
    if (isSubtask) {
      // Use priority-based colors for subtasks, but with reduced opacity
      itemColor =
          getPastelColor(priority, theme.brightness).withValues(alpha: 0.7);
      borderColor = getTaskPriorityColor(priority, theme.brightness);
    } else {
      itemColor = getPastelColor(priority, theme.brightness);
      borderColor = getTaskPriorityColor(priority, theme.brightness);
    }

    return _buildCard(context, ref, item, title, description, priority,
        isSubtask, itemColor, borderColor, theme, localizations);
  }

  // ===== SCHEDULED ITEM CARD BUILDER =====
  /// Builds the actual card widget for scheduled items
  /// Uses Kanban-style design with priority colors and proper layout
  /// Includes tap to edit and close button to unschedule
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
    // Get the same colors as Kanban cards for consistency
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
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== PRIORITY COLOR BAR =====
                  // Dynamic height based on title length - match Kanban formula
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

                  // ===== MAIN CONTENT AREA =====
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== SUBTASK INDICATOR =====
                        // Shows subtask icon and label for subtasks
                        if (isSubtask) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.subdirectory_arrow_right,
                                size: 8,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  localizations.subtask,
                                  style: TextStyle(
                                    fontSize: 7,
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
                          const SizedBox(height: 2),
                        ],

                        // ===== TITLE SECTION =====
                        // Dynamic title display with smart line calculation
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate how many full lines of text can fit
                              final fontSize = isSubtask ? 10.0 : 11.0;
                              const lineHeight = 1.2;
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

                        // ===== DESCRIPTION SECTION =====
                        // Only shown for tasks, not subtasks
                        if (description != null &&
                            description.isNotEmpty &&
                            !isSubtask) ...[
                          const SizedBox(height: 2),
                          Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.1,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],

                        const SizedBox(height: 3),

                        // ===== BOTTOM CONTENT ROW =====
                        // Priority and time information in a single row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ===== PRIORITY SECTION =====
                            Icon(Icons.flag_outlined,
                                size: 8, color: taskPriorityColor),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                _getPriorityLabel(context, priority),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 7,
                                  color: taskPriorityColor,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                ),
                              ),
                            ),

                            // ===== TIME/ESTIMATE SECTION =====
                            // Shows scheduled time or estimate for subtasks
                            if ((item is TaskModel &&
                                    item.startTime != null &&
                                    item.endTime != null) ||
                                (item is SubtaskModel &&
                                    item.startTime != null &&
                                    item.endTime != null) ||
                                (isSubtask &&
                                    item is SubtaskModel &&
                                    item.rawTimeValue?.isNotEmpty == true)) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.timer_outlined,
                                  size: 8,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6)),
                              const SizedBox(width: 2),
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
                                    fontSize: 7,
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
            // ===== UNSCHEDULE BUTTON =====
            // Small close button in top-right corner to unschedule the item
            Positioned(
              top: 2,
              right: 2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmUnschedule(context, ref, item),
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Icon(Icons.close,
                        size: 10, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== UNSCHEDULE CONFIRMATION DIALOG =====
  /// Shows a confirmation dialog before unscheduling an item
  /// Prevents accidental unscheduling and provides clear user feedback
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

  // ===== UNSCHEDULED ITEMS SECTION BUILDER =====
  /// Builds the bottom section containing items without specific scheduled times
  /// Shows as horizontal scrollable cards when items exist, or empty state message
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
          ? // ===== EMPTY STATE =====
          Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                localizations.noTasks,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(128),
                ),
              ),
            )
          : // ===== HORIZONTAL SCROLLABLE LIST =====
          SingleChildScrollView(
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

  // ===== UNSCHEDULED ITEM CARD BUILDER =====
  /// Builds individual cards for unscheduled items
  /// Extracts properties and applies styling consistent with scheduled items
  Widget _buildUnscheduledItemCard(BuildContext context, WidgetRef ref,
      dynamic item, ThemeData theme, AppLocalizations localizations) {
    // ===== EXTRACT ITEM PROPERTIES =====
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

    // ===== CALCULATE COLORS =====
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

  // ===== UNSCHEDULED CARD WIDGET BUILDER =====
  /// Builds the actual card widget for unscheduled items
  /// Uses vertical layout optimized for the horizontal scroll area
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
                // ===== TOP CONTENT SECTION =====
                // Title section with priority color bar
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
                          // ===== SUBTASK INDICATOR =====
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

                          // ===== TITLE =====
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

                          // ===== DESCRIPTION =====
                          // Only for tasks - subtasks don't show description here
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

                // ===== SPACER =====
                // Push bottom content to the bottom of the card
                const Spacer(),

                // ===== BOTTOM CONTENT =====
                // Priority information for both tasks and subtasks
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

                // ===== TIME ESTIMATE FOR SUBTASKS =====
                // Separate from priority section for better layout
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
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
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
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
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

  // ===== COLOR UTILITY METHODS =====

  /// Returns pastel background colors based on priority and theme brightness
  /// Used for card backgrounds with appropriate opacity for readability
  Color getPastelColor(int? priority, Brightness brightness) {
    // For dark mode, use darker pastel colors that work well with dark backgrounds
    if (brightness == Brightness.dark) {
      switch (priority) {
        case 1:
          return const Color(0xFF0D47A1)
              .withValues(alpha: 0.3); // Dark blue pastel
        case 2:
          return const Color(0xFF1B5E20)
              .withValues(alpha: 0.3); // Dark green pastel
        case 3:
          return const Color(0xFFF57F17)
              .withValues(alpha: 0.3); // Dark yellow pastel
        case 4:
          return const Color(0xFFE65100)
              .withValues(alpha: 0.3); // Dark orange pastel
        case 5:
          return const Color(0xFFB71C1C)
              .withValues(alpha: 0.3); // Dark red pastel
        default:
          return const Color(0xFF424242)
              .withValues(alpha: 0.3); // Dark grey pastel
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

  /// Returns accent colors for borders, icons, and text based on priority
  /// Provides strong contrast while being theme-appropriate
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

  // ===== MODAL MANAGEMENT =====
  /// Shows the appropriate modal for creating/editing items
  /// Handles both new item creation and existing item editing
  /// Refreshes the view after modal operations complete
  Future<void> _showItemModal(
      BuildContext context, WidgetRef ref, dynamic item) async {
    Widget modalContent;

    if (item is TaskModel || item == null) {
      // item == null means new Task creation
      modalContent = TaskEditorModal(
        ref: ref,
        existing: item as TaskModel?,
        selectedDate: ref.read(selectedDateProvider),
      );
    } else if (item is SubtaskModel) {
      // For SubtaskEditorModal, we need the parent TaskModel
      // Fetch it using the taskId from the SubtaskModel
      final parentTask =
          await ref.read(taskServiceProvider).getTaskById(item.taskId);
      if (parentTask != null) {
        modalContent = SubtaskEditorModal(
          ref: ref,
          parentTask: parentTask,
          subtask: item, // existing subtask for editing
        );
      } else {
        // Handle error: parent task not found
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Parent task not found')),
          );
        }
        return;
      }
    } else {
      return; // Should not happen - unknown item type
    }

    // Show the modal and handle the result
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => modalContent,
    ).then((result) {
      // ===== POST-MODAL REFRESH LOGIC =====
      // Refresh data after modal operations to ensure UI stays in sync
      if (result == true) {
        // Modal was completed with save/delete action
        ref.read(timeBlockControllerProvider.notifier).loadTasks(context);
      } else if (item == null && result == null) {
        // New task modal was cancelled - no refresh needed
      } else {
        // Fallback refresh for other cases to ensure state consistency
        ref.read(timeBlockControllerProvider.notifier).loadTasks(context);
      }
    });
  }

  // ===== PRIORITY LABEL HELPER =====
  /// Converts numeric priority values to localized text labels
  /// Used throughout the UI for consistent priority display
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
