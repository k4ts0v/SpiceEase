import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/components/calendar_week_selector.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/features/time_management/kanban/kanban_controller.dart';
import 'package:spiceease/features/tracker/presentation/modals.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class KanbanPage extends ConsumerWidget {
  const KanbanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedDateProvider);
    final controller = ref.watch(kanbanControllerProvider);
    final theme = Theme.of(context);

    // Check if date changed since last build, reload tasks if needed
    if (selectedDate != controller.currentSelectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(kanbanControllerProvider).loadTasks(context);
      });
    }

    // The UI stays exactly the same, we just pull data from controller instead of state
    final todoTasks = controller.todoTasks;
    final inProgressTasks = controller.inProgressTasks;
    final doneTasks = controller.doneTasks;
    final noDueDateTasks = controller.noDueDateTasks;
    final isLoading = controller.isLoading;

    final locale = Localizations.localeOf(context).languageCode;

    // Get the first day of current week (Monday)
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          // Add New Task button here in the app bar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showTaskModal(context, ref, null),
              icon: const Icon(Icons.add, size: 18),
              label: Text(localizations.newTask),
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
            onPressed: () =>
                ref.read(kanbanControllerProvider).loadTasks(context),
            tooltip: localizations.refresh,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Replace calendar with CalendarWeekSelector
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CalendarWeekSelector(
                selectedDate: selectedDate,
                locale: Locale(locale),
                theme: theme,
              ),
            ),

            // Kanban board with improved visuals
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            localizations.loading,
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
                        // Date-specific tasks section with improved styling
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withAlpha(26), // 0.1 opacity = ~26/255
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.event_note,
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
                                    fontSize: 18.0,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Enhanced Kanban board for date-specific tasks
                        Expanded(
                          flex: 5,
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
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
                                  _buildColumn(
                                    context,
                                    ref,
                                    localizations.todo,
                                    todoTasks,
                                    const Color(0xFFF9FAFC),
                                    Colors.grey[800]!,
                                    Icons.playlist_add_check_outlined,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildColumn(
                                    context,
                                    ref,
                                    localizations.inProgress,
                                    inProgressTasks,
                                    const Color(0xFFEDF6FF),
                                    Colors.blue[700]!,
                                    Icons.timelapse_rounded,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildColumn(
                                    context,
                                    ref,
                                    localizations.done,
                                    doneTasks,
                                    const Color(0xFFEDF7ED),
                                    Colors.green[700]!,
                                    Icons.check_circle_outline,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // No due date section with improved styling
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                localizations.tasksWithoutDueDate,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.0,
                                  color: Colors.grey[800],
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Enhanced section for tasks without due date
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 16.0),
                          height: 103,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: const Color(0xFFF5F6F8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: noDueDateTasks.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.event_busy_outlined,
                                        color: Colors.grey[400],
                                        size: 24,
                                      ),
                                      Text(
                                        localizations.noTasksWithoutDueDate,
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
                                      horizontal: 12.0, vertical: 8.0),
                                  itemCount: noDueDateTasks.length,
                                  itemBuilder: (context, index) {
                                    return SizedBox(
                                      width: 180,
                                      child: _buildDraggableTaskCard(
                                        context,
                                        ref,
                                        noDueDateTasks[index],
                                        '',
                                        true, // Mark as no due date
                                      ),
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
      // Refresh tasks after modal is closed
      ref.read(kanbanControllerProvider).loadTasks(context);
    });
  }

  // The UI helper functions remain the same, just adding ref parameter and using the controller
  Widget _buildColumn(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<TaskModel> tasks,
    Color color,
    Color textColor,
    IconData headerIcon,
  ) {
    final localizations = AppLocalizations.of(context)!;

    return Expanded(
      child: Column(
        children: [
          // Column header with consistent height
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
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
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: textColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withAlpha(204), // ~0.8 opacity (204/255)
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      '${tasks.length}',
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
          ),

          // Task list / drag target
          Expanded(
            child: DragTarget<TaskModel>(
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? color.withAlpha(204) // ~0.8 opacity (204/255)
                        : color.withAlpha(128), // ~0.5 opacity (128/255)
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 24, color: Colors.grey[400]),
                              const SizedBox(height: 6),
                              Text(
                                localizations.noTasks,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                localizations.dragTasksHere,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(6),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          // Remove ConstrainedBox to let cards take their natural height
                          return _buildDraggableTaskCard(
                            context,
                            ref,
                            tasks[index],
                            title,
                          );
                        },
                      );
                    },
                  ),
                );
              },
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) {
                TaskModel task = details.data;
                String newStatus = localizations.pending;
                if (title == localizations.todo) {
                  newStatus = localizations.pending;
                } else if (title == localizations.inProgress) {
                  newStatus = localizations.inProgress;
                } else if (title == localizations.done) {
                  newStatus = localizations.done;
                }
                ref
                    .read(kanbanControllerProvider)
                    .updateTaskStatus(task, newStatus, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTaskCard(
      BuildContext context, WidgetRef ref, TaskModel task, String columnId,
      [bool isNoDueDate = false]) {
    final taskPriorityColor = getTaskPriorityColor(task.priority);
    final pastelColor = getPastelColor(task.priority);

    return Draggable<TaskModel>(
      data: task,
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: pastelColor,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: taskPriorityColor, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: taskPriorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTaskCard(context, ref, task, isNoDueDate),
      ),
      child: _buildTaskCard(context, ref, task, isNoDueDate),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, TaskModel task,
      [bool isNoDueDate = false]) {
    final pastelColor = getPastelColor(task.priority);
    final taskPriorityColor = getTaskPriorityColor(task.priority);

    // Get priority label
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

    // Build the card content - same for all cards
    Widget cardContent = IntrinsicHeight(
      child: InkWell(
        onTap: () => _showTaskModal(context, ref, task),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: taskPriorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),

              // Content - use Expanded to prevent overflow
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add subtask indicator if this is a subtask
                    if (task.parentTaskId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.subdirectory_arrow_right,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                localizations.subtask,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Title - always present
                    Text(
                      task.title,
                      maxLines: isNoDueDate ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[850],
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),

                    // Description - only if not empty
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        task.description,
                        maxLines: isNoDueDate ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          height: 1.1,
                        ),
                      ),
                    ],

                    // Priority - always present
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.flag_outlined,
                            size: 10, color: taskPriorityColor),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            priorityLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8,
                              color: taskPriorityColor,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Estimated time - only if it exists
                    if (task.estimatedTime != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 10, color: Colors.grey[600]),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${task.estimatedTime}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Create the card with appropriate styling
    Widget card = Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      color: pastelColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: taskPriorityColor.withAlpha(153), width: 1),
      ),
      // For no-due-date cards, wrap content in a fixed height container
      child:
          isNoDueDate ? SizedBox(height: 100, child: cardContent) : cardContent,
    );

    // Add no-due-date badge if needed
    if (isNoDueDate) {
      return Stack(
        children: [
          card,
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(Icons.calendar_today_outlined,
                  size: 10, color: Colors.grey[700]),
            ),
          ),
        ],
      );
    }
    return card;
  }

  Color getTaskPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF2196F3); // Darker blue
      case 2:
        return const Color(0xFF4CAF50); // Darker green
      case 3:
        return const Color(0xFFFFC107); // Darker yellow
      case 4:
        return const Color(0xFFFF9800); // Darker orange
      case 5:
        return const Color(0xFFF44336); // Darker red
      default:
        return const Color(0xFF9E9E9E); // Darker default color
    }
  }

  Color getPastelColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFFE3F2FD); // Pastel blue
      case 2:
        return const Color(0xFFE8F5E9); // Pastel green
      case 3:
        return const Color(0xFFFFF8E1); // Pastel orange
      case 4:
        return const Color(0xFFFFE0B2); // Pastel yellow
      case 5:
        return const Color(0xFFFFF0F0); // Pastel red
      default:
        return const Color(0xFFF5F5F5); // Default pastel color
    }
  }
}
