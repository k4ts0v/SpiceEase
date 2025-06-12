import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/components/calendar_week_selector.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/features/time_management/kanban/kanban_controller.dart';
import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';
import 'package:spiceease/l10n/app_localizations.dart';

/// A Kanban board page for managing tasks in a visual workflow.
///
/// This widget displays tasks in a traditional Kanban board layout with three columns:
/// todo, in progress, and done. It supports drag-and-drop functionality for moving
/// tasks between columns and automatically updates task statuses.
///
/// The page is divided into two main sections:
/// - Date-specific tasks shown in the main Kanban board
/// - Tasks without due dates shown in a separate horizontal scrollable section
class KanbanPage extends ConsumerWidget {
  /// Creates a new [KanbanPage].
  const KanbanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedDateProvider);
    final controller = ref.watch(kanbanControllerProvider);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    // Check if date changed since last build and reload tasks if needed
    if (selectedDate != controller.currentSelectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(kanbanControllerProvider).loadTasks(context);
      });
    }

    // Extract task and subtask lists from the controller for easier access
    final todoTasks = controller.todoTasks;
    final inProgressTasks = controller.inProgressTasks;
    final doneTasks = controller.doneTasks;
    final todoSubtasks = controller.todoSubtasks;
    final inProgressSubtasks = controller.inProgressSubtasks;
    final doneSubtasks = controller.doneSubtasks;
    final noDueDateTasks = controller.noDueDateTasks;
    final isLoading = controller.isLoading;

    // Get subtasks that belong to tasks without due dates
    final noDueDateSubtasks = _getNoDueDateSubtasks(controller);

    final locale = Localizations.localeOf(context).languageCode;

    // Get the first day of current week (Monday) for calendar context
    final now = DateTime.now();
    now.subtract(Duration(days: now.weekday - 1));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.kanban,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          // Add New Task button in the app bar for easy access
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showTaskModal(context, ref, null),
              icon: const Icon(Icons.add, size: 18),
              label: Text(localizations.newTask),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                elevation: 2,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
              ),
            ),
          ),
          // Refresh button to manually reload tasks
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(kanbanControllerProvider).loadTasks(context),
            tooltip: localizations.refresh,
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Calendar week selector for date navigation
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
                locale: Locale(locale),
              ),
            ),

            // Main content area with loading state or Kanban board
            Expanded(
              child: isLoading
                  ? _buildLoadingIndicator(theme, localizations)
                  : _buildKanbanBoard(
                      context,
                      ref,
                      theme,
                      brightness,
                      localizations,
                      selectedDate,
                      locale,
                      todoTasks,
                      inProgressTasks,
                      doneTasks,
                      todoSubtasks,
                      inProgressSubtasks,
                      doneSubtasks,
                      noDueDateTasks,
                      noDueDateSubtasks,
                      controller,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets subtasks that belong to tasks without due dates
  List<SubtaskModel> _getNoDueDateSubtasks(KanbanController controller) {
    final allSubtasks = [
      ...controller.todoSubtasks,
      ...controller.inProgressSubtasks,
      ...controller.doneSubtasks,
    ];

    return allSubtasks.where((subtask) {
      final parentTask = controller.getParentTask(subtask);
      // Include subtask if parent task has no due date
      return parentTask?.dueDate == null;
    }).toList();
  }

  /// Builds a centered loading indicator with message.
  ///
  /// The [theme] parameter provides color scheme information.
  /// The [localizations] parameter provides localized text.
  Widget _buildLoadingIndicator(
      ThemeData theme, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.loading,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the complete Kanban board layout with all sections.
  ///
  /// This method creates the main board structure including:
  /// - Date header section
  /// - Three-column Kanban board for date-specific tasks
  /// - Horizontal section for tasks without due dates
  Widget _buildKanbanBoard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Brightness brightness,
    AppLocalizations localizations,
    DateTime selectedDate,
    String locale,
    List<TaskModel> todoTasks,
    List<TaskModel> inProgressTasks,
    List<TaskModel> doneTasks,
    List<SubtaskModel> todoSubtasks,
    List<SubtaskModel> inProgressSubtasks,
    List<SubtaskModel> doneSubtasks,
    List<TaskModel> noDueDateTasks,
    List<SubtaskModel> noDueDateSubtasks,
    KanbanController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date-specific tasks section header with improved styling
        _buildDateHeader(theme, localizations, selectedDate, locale),

        // Enhanced Kanban board for date-specific tasks
        Expanded(
          flex: 5,
          child: _buildMainKanbanBoard(
            context,
            ref,
            theme,
            brightness,
            todoTasks,
            inProgressTasks,
            doneTasks,
            todoSubtasks,
            inProgressSubtasks,
            doneSubtasks,
            controller,
          ),
        ),

        // Section header for tasks without due dates
        _buildNoDueDateHeader(theme, localizations),

        // Enhanced section for tasks without due date
        _buildNoDueDateSection(
          context,
          ref,
          theme,
          brightness,
          localizations,
          noDueDateTasks,
          noDueDateSubtasks,
          controller,
        ),
      ],
    );
  }

  /// Builds the date header section showing the currently selected date.
  ///
  /// The [theme] parameter provides styling information.
  /// The [localizations] parameter provides localized text.
  /// The [selectedDate] parameter is the currently selected date to display.
  /// The [locale] parameter is used for date formatting.
  Widget _buildDateHeader(
    ThemeData theme,
    AppLocalizations localizations,
    DateTime selectedDate,
    String locale,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.event_note,
              size: 20,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DateFormat.yMMMMd(locale).format(selectedDate),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main three-column Kanban board for date-specific tasks.
  ///
  /// This creates the core Kanban functionality with drag-and-drop support
  /// between todo, in progress, and done columns.
  Widget _buildMainKanbanBoard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Brightness brightness,
    List<TaskModel> todoTasks,
    List<TaskModel> inProgressTasks,
    List<TaskModel> doneTasks,
    List<SubtaskModel> todoSubtasks,
    List<SubtaskModel> inProgressSubtasks,
    List<SubtaskModel> doneSubtasks,
    KanbanController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: theme.colorScheme.surface,
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
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Todo column
            _buildColumn(
              context,
              ref,
              'todo',
              todoTasks,
              todoSubtasks,
              theme.colorScheme.surfaceContainerLowest,
              theme.colorScheme.onSurface,
              Icons.playlist_add_check_outlined,
              controller,
            ),
            const SizedBox(width: 12),
            // In Progress column
            _buildColumn(
              context,
              ref,
              'in_progress',
              inProgressTasks,
              inProgressSubtasks,
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.onSurface,
              Icons.timelapse_rounded,
              controller,
            ),
            const SizedBox(width: 12),
            // Done column
            _buildColumn(
              context,
              ref,
              'done',
              doneTasks,
              doneSubtasks,
              brightness == Brightness.dark
                  ? theme.colorScheme.surfaceContainerLow
                  : const Color(0xFFEDF7ED),
              theme.colorScheme.tertiary,
              Icons.check_circle_outline,
              controller,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header section for tasks without due dates.
  ///
  /// This provides a visual separator and label for the no-due-date tasks section.
  Widget _buildNoDueDateHeader(
      ThemeData theme, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            localizations.tasksWithoutDueDate,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.0,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the horizontal scrollable section for tasks without due dates.
  ///
  /// This section displays tasks that don't have specific due dates in a
  /// horizontally scrollable list of compact cards.
  Widget _buildNoDueDateSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Brightness brightness,
    AppLocalizations localizations,
    List<TaskModel> noDueDateTasks,
    List<SubtaskModel> noDueDateSubtasks,
    KanbanController controller,
  ) {
    // Combine tasks and subtasks for the no-due-date section
    final hasItems = noDueDateTasks.isNotEmpty || noDueDateSubtasks.isNotEmpty;

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
      child: !hasItems
          ? Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                localizations.noTasksWithoutDueDate,
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
                    // Show tasks without due dates
                    for (final task in noDueDateTasks)
                      _buildNoDueDateTaskCard(context, ref, task, theme),
                    // Show subtasks without due dates
                    for (final subtask in noDueDateSubtasks)
                      _buildNoDueDateSubtaskCard(
                          context, ref, subtask, theme, controller),
                  ],
                ),
              ),
            ),
    );
  }

  /// Builds a task card for the no-due-date section.
  ///
  /// This card is styled similarly to the Flowmodoro task selection cards.
  Widget _buildNoDueDateTaskCard(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
    ThemeData theme,
  ) {
    final taskPriorityColor =
        getTaskPriorityColor(task.priority, theme.brightness);
    final pastelColor = getPastelColor(task.priority, theme.brightness);

    return GestureDetector(
      onTap: () => _showTaskModal(context, ref, task),
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: pastelColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: taskPriorityColor.withAlpha(153)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: taskPriorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description section
              if (task.description.isNotEmpty) ...[
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withAlpha(153),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Spacer to push priority to bottom
              const Spacer(),

              // Priority row
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 12,
                    color: taskPriorityColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getPriorityLabel(context, task.priority),
                      style: TextStyle(
                        fontSize: 10,
                        color: taskPriorityColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a subtask card for the no-due-date section.
  Widget _buildNoDueDateSubtaskCard(
    BuildContext context,
    WidgetRef ref,
    SubtaskModel subtask,
    ThemeData theme,
    KanbanController controller,
  ) {
    final parentTask = controller.getParentTask(subtask);
    final priority = parentTask?.priority ?? 3;
    final taskPriorityColor = getTaskPriorityColor(priority, theme.brightness);
    final pastelColor = getPastelColor(priority, theme.brightness);
    final localizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        if (parentTask != null) {
          _showTaskModal(context, ref, parentTask);
        }
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: pastelColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: taskPriorityColor.withAlpha(102)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtask indicator
              _buildSubtaskIndicator(theme, localizations),
              const SizedBox(height: 6),

              // Title section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 30,
                    decoration: BoxDecoration(
                      color: taskPriorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtask.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Parent task reference
              if (parentTask != null) ...[
                Text(
                  parentTask.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Spacer to push priority to bottom
              const Spacer(),

              // Priority row (inherited from parent)
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 12,
                    color: taskPriorityColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getPriorityLabel(context, priority),
                      style: TextStyle(
                        fontSize: 10,
                        color: taskPriorityColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a modal dialog for creating or editing a task.
  ///
  /// The [context] parameter provides the widget context for showing the modal.
  /// The [ref] parameter is used to access providers and refresh data.
  /// The [task] parameter is the existing task to edit, or null for creating a new task.
  void _showTaskModal(BuildContext context, WidgetRef ref, TaskModel? task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TaskEditorModal(
          ref: ref,
          existing: task,
          selectedDate: ref.read(selectedDateProvider),
        );
      },
    ).then((_) {
      // Refresh tasks after modal is closed to reflect any changes
      ref.read(kanbanControllerProvider).loadTasks(context);
    });
  }

  /// Builds a single column of the Kanban board with drag-and-drop functionality.
  ///
  /// Each column represents a task status (todo, in progress, done) and accepts
  /// dragged tasks to update their status.
  ///
  /// The [context] parameter provides the widget context.
  /// The [ref] parameter is used to access providers for task updates.
  /// The [code] parameter is the internal status code ('todo', 'in_progress', 'done').
  /// The [tasks] parameter is the list of tasks to display in this column.
  /// The [subtasks] parameter is the list of subtasks to display in this column.
  /// The [color] parameter is the background color for the column.
  /// The [textColor] parameter is the text color for the column header.
  /// The [headerIcon] parameter is the icon to display in the column header.
  /// The [controller] parameter provides access to parent task information.
  Widget _buildColumn(
    BuildContext context,
    WidgetRef ref,
    String code, // Internal status code: 'todo', 'in_progress', 'done'
    List<TaskModel> tasks,
    List<SubtaskModel> subtasks,
    Color color,
    Color textColor,
    IconData headerIcon,
    KanbanController controller,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Show all subtasks in the Kanban columns regardless of due date
    final filteredSubtasks = subtasks;

    // Map internal status code to localized display title
    String title;
    switch (code) {
      case 'in_progress':
        title = localizations.inProgress;
        break;
      case 'done':
        title = localizations.done;
        break;
      default:
        title = localizations.todo;
    }

    // Calculate total items (tasks + filtered subtasks)
    final totalItems = tasks.length + filteredSubtasks.length;

    return Expanded(
      child: Column(
        children: [
          // Column header with consistent height and task count badge
          _buildColumnHeader(theme, title, headerIcon, textColor, totalItems),

          // Task list area with drag-and-drop functionality
          Expanded(
            child: _buildColumnContent(context, ref, theme, localizations,
                tasks, filteredSubtasks, code, color, controller),
          ),
        ],
      ),
    );
  }

  /// Builds the header section of a Kanban column.
  ///
  /// Displays the column title, icon, and task count in a styled container.
  Widget _buildColumnHeader(
    ThemeData theme,
    String title,
    IconData headerIcon,
    Color textColor,
    int taskCount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(headerIcon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2, // Allow up to 2 lines for long translations
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: textColor,
                  letterSpacing: 0.2,
                  height: 1.1, // Tighter line height for better spacing
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Task count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '$taskCount',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the content area of a Kanban column with drag-and-drop functionality.
  ///
  /// Creates a drop target that accepts dragged tasks and updates their status.
  /// Displays either a list of tasks or an empty state message.
  Widget _buildColumnContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations localizations,
    List<TaskModel> tasks,
    List<SubtaskModel> subtasks,
    String code,
    Color color,
    KanbanController controller,
  ) {
    return DragTarget<Object>(
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? color.withValues(alpha: 0.8)
                : color.withValues(alpha: 0.7),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalItems = tasks.length + subtasks.length;
              if (totalItems == 0) {
                return _buildEmptyColumnState(
                    theme, localizations, constraints);
              }
              // Build list of tasks and subtasks for this column
              return ListView.builder(
                padding: const EdgeInsets.all(6),
                itemCount: totalItems,
                itemBuilder: (context, index) {
                  // Show tasks first, then subtasks
                  if (index < tasks.length) {
                    return _buildDraggableTaskCard(
                      context,
                      ref,
                      tasks[index],
                      code,
                      false,
                    );
                  } else {
                    final subtaskIndex = index - tasks.length;
                    return _buildDraggableSubtaskCard(
                      context,
                      ref,
                      subtasks[subtaskIndex],
                      code,
                      controller,
                    );
                  }
                },
              );
            },
          ),
        );
      },
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        // Handle dropping a task or subtask into this column
        final item = details.data;
        String newStatus = code; // Use the internal status code

        if (item is TaskModel) {
          ref
              .read(kanbanControllerProvider)
              .updateTaskStatus(item, newStatus, context);
        } else if (item is SubtaskModel) {
          ref
              .read(kanbanControllerProvider)
              .updateSubtaskStatus(item, newStatus, context);
        }
      },
    );
  }

  /// Builds an empty state display for a Kanban column with no tasks.
  ///
  /// Adapts the display based on available space - shows a minimal version
  /// for very constrained spaces and a full version with text for larger areas.
  Widget _buildEmptyColumnState(
    ThemeData theme,
    AppLocalizations localizations,
    BoxConstraints constraints,
  ) {
    // Check if we have enough space for the full empty state
    final hasEnoughSpace = constraints.maxHeight > 60;

    if (!hasEnoughSpace) {
      // Minimal empty state for very constrained spaces
      return Center(
        child: Icon(Icons.inbox_outlined,
            size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
      );
    }

    // Full empty state with text and instructions
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                localizations.noTasks,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                localizations.dragTasksHere,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a visual task card displaying task information.
  ///
  /// Creates a styled card showing task details including title, description,
  /// priority, estimated time, and special indicators for subtasks or no-due-date tasks.
  ///
  /// The [context] parameter provides the widget context.
  /// The [ref] parameter is used to access providers.
  /// The [task] parameter contains the task data to display.
  /// The [isNoDueDate] parameter indicates if this task should show a no-due-date badge.
  Widget _buildTaskCard(BuildContext context, WidgetRef ref, TaskModel task,
      [bool isNoDueDate = false]) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final taskPriorityColor = getTaskPriorityColor(task.priority, brightness);
    final pastelColor = getPastelColor(task.priority, brightness);

    // Get localized priority label
    String priorityLabel;
    final localizations = AppLocalizations.of(context)!;

    switch (task.priority) {
      case 1:
        priorityLabel = localizations.lowestPriority;
        break;
      case 2:
        priorityLabel = localizations.lowPriority;
        break;
      case 3:
        priorityLabel = localizations.mediumPriority;
        break;
      case 4:
        priorityLabel = localizations.highPriority;
        break;
      case 5:
        priorityLabel = localizations.highestPriority;
        break;
      default:
        priorityLabel = "";
    }

    // Build the main card content with dynamic height based on content
    Widget cardContent = InkWell(
      onTap: () => _showTaskModal(context, ref, task),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority color bar with dynamic height based on title length
            Container(
              width: 4,
              height: min(60, 12.0 * (task.title.length / 10).ceil()),
              decoration: BoxDecoration(
                color: taskPriorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),

            // Main content area using Expanded to handle overflow gracefully
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task indicator for tasks with subtasks
                  if (task.hasSubtasks)
                    _buildTaskWithSubtasksIndicator(
                        Theme.of(context), AppLocalizations.of(context)!),

                  // Task title allowing up to 3 lines with ellipsis overflow
                  Text(
                    task.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: 13,
                      height: 1.1, // Tighter line height for better spacing
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Task description (single line with ellipsis)
                  if (task.description.isNotEmpty)
                    Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.0,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Priority information with icon and label
                  _buildPriorityRow(taskPriorityColor, priorityLabel),

                  // Time estimate information if available
                  if (task.estimatedTime != null)
                    _buildTimeEstimateRow(theme, task.estimatedTime!),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Create the styled card container
    Widget card = Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      color: pastelColor.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: taskPriorityColor.withAlpha(153), width: 1),
      ),
      child: cardContent,
    );

    // Add no-due-date badge if this task doesn't have a due date
    if (isNoDueDate) {
      return _addNoDueDateBadge(card, theme);
    }

    return card;
  }

  /// Builds a visual subtask card displaying subtask information.
  ///
  /// Creates a styled card showing task details including title, description,
  /// priority, estimated time, and special indicators for subtasks or no-due-date tasks.
  ///
  /// The [context] parameter provides the widget context.
  /// The [ref] parameter is used to access providers.
  /// The [subtask] parameter contains the subtask data to display.
  /// The [controller] parameter provides access to parent task information.
  ///
  Widget _buildSubtaskCard(BuildContext context, WidgetRef ref,
      SubtaskModel subtask, KanbanController controller) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    // Get parent task for context
    final parentTask = controller.getParentTask(subtask);

    // Use parent task priority for color, fallback to medium priority
    final priority = parentTask?.priority ?? 3;
    final brightness = theme.brightness;
    final taskPriorityColor = getTaskPriorityColor(priority, brightness);
    final pastelColor = getPastelColor(priority, brightness);

    // Build the main card content
    Widget cardContent = InkWell(
      onTap: () {
        // Show subtask edit modal if needed
        // For now, just show parent task modal
        if (parentTask != null) {
          _showTaskModal(context, ref, parentTask);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority color bar (thinner for subtasks)
            Container(
              width: 3,
              height: min(50, 10.0 * (subtask.title.length / 10).ceil()),
              decoration: BoxDecoration(
                color: taskPriorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),

            // Main content area
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtask indicator
                  _buildSubtaskIndicator(theme, localizations),

                  // Subtask title
                  Text(
                    subtask.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontSize: 12,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Parent task reference
                  if (parentTask != null)
                    Text(
                      parentTask.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: 6),

                  // Time estimate if available
                  if (subtask.rawTimeValue != null)
                    _buildTimeEstimateRow(theme, subtask.rawTimeValue!),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Create the styled card container (slightly smaller for subtasks)
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      color: pastelColor.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: taskPriorityColor.withAlpha(102), width: 1),
      ),
      child: cardContent,
    );
  }

  /// Builds a subtle indicator showing that this task has subtasks.
  Widget _buildTaskWithSubtasksIndicator(
      ThemeData theme, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              localizations.subtasks,
              style: TextStyle(
                fontSize: 9,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a subtle indicator showing that this task is actually a subtask.
  ///
  /// Displays a small arrow icon and "Subtask" label to provide context.
  Widget _buildSubtaskIndicator(
      ThemeData theme, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.subdirectory_arrow_right,
            size: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              localizations.subtask,
              style: TextStyle(
                fontSize: 9,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a row displaying task priority with icon and label.
  ///
  /// Shows a flag icon with the priority level in the appropriate color.
  Widget _buildPriorityRow(Color taskPriorityColor, String priorityLabel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.flag_outlined, size: 10, color: taskPriorityColor),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            priorityLabel,
            maxLines: 2, // Allow priority label to wrap to 2 lines
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: taskPriorityColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a row displaying the estimated time for the task.
  ///
  /// Shows a timer icon with the time estimate, allowing text to wrap.
  Widget _buildTimeEstimateRow(ThemeData theme, String estimatedTime) {
    return Padding(
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
              estimatedTime,
              maxLines: 2, // Allow time display to wrap to 2 lines
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                height: 1.1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Adds a visual badge to indicate that a task has no due date.
  ///
  /// Places a small calendar icon in the top-right corner of the card.
  Widget _addNoDueDateBadge(Widget card, ThemeData theme) {
    return Stack(
      children: [
        card,
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(Icons.calendar_today_outlined,
                size: 10, color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  /// Builds a draggable task card that can be moved between Kanban columns.
  ///
  /// Wraps a regular task card with drag functionality and provides visual
  /// feedback during drag operations.
  ///
  /// The [context] parameter provides the widget context.
  /// The [ref] parameter is used to access providers.
  /// The [task] parameter contains the task data.
  /// The [columnId] parameter identifies the current column (for internal tracking).
  /// The [isNoDueDate] parameter indicates if this is a no-due-date task.
  Widget _buildDraggableTaskCard(
      BuildContext context, WidgetRef ref, TaskModel task, String columnId,
      [bool isNoDueDate = false]) {
    final theme = Theme.of(context);
    final taskPriorityColor =
        getTaskPriorityColor(task.priority, theme.brightness);
    final pastelColor = getPastelColor(task.priority, theme.brightness);

    return Draggable<TaskModel>(
      data: task,
      // Visual feedback shown while dragging
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: pastelColor,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: taskPriorityColor, width: 1.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simplified priority color bar for drag feedback
              Container(
                width: 4,
                height: min(60, 12.0 * (task.title.length / 10).ceil()),
                decoration: BoxDecoration(
                  color: taskPriorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Card appearance while being dragged (semi-transparent)
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTaskCard(context, ref, task, isNoDueDate),
      ),
      // Normal card appearance
      child: _buildTaskCard(context, ref, task, isNoDueDate),
    );
  }

  /// Builds a draggable subtask card that can be moved between Kanban columns.
  Widget _buildDraggableSubtaskCard(BuildContext context, WidgetRef ref,
      SubtaskModel subtask, String columnId, KanbanController controller) {
    final theme = Theme.of(context);

    // Get parent task for context
    final parentTask = controller.getParentTask(subtask);
    final priority = parentTask?.priority ?? 3;
    final taskPriorityColor = getTaskPriorityColor(priority, theme.brightness);
    final pastelColor = getPastelColor(priority, theme.brightness);

    return Draggable<SubtaskModel>(
      data: subtask,
      // Visual feedback shown while dragging
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: pastelColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: taskPriorityColor, width: 1.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simplified priority color bar for drag feedback
              Container(
                width: 3,
                height: min(40, 8.0 * (subtask.title.length / 10).ceil()),
                decoration: BoxDecoration(
                  color: taskPriorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  subtask.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Card appearance while being dragged (semi-transparent)
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildSubtaskCard(context, ref, subtask, controller),
      ),
      // Normal card appearance
      child: _buildSubtaskCard(context, ref, subtask, controller),
    );
  }

  /// Returns the appropriate color for a task based on its priority level.
  ///
  /// Uses different color palettes for light and dark themes to ensure
  /// proper contrast and visibility.
  ///
  /// The [priority] parameter should be an integer from 1-5.
  /// The [brightness] parameter indicates the current theme brightness.
  Color getTaskPriorityColor(int priority, Brightness brightness) {
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

  /// Returns a subtle pastel background color for task cards based on priority.
  ///
  /// Provides gentle background colors that complement the priority border colors
  /// while maintaining readability in both light and dark themes.
  ///
  /// The [priority] parameter should be an integer from 1-5.
  /// The [brightness] parameter indicates the current theme brightness.
  Color getPastelColor(int priority, Brightness brightness) {
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

  /// Returns a localized priority label for the given priority level.
  ///
  /// The [context] parameter provides access to localizations.
  /// The [priority] parameter should be an integer from 1-5.
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
