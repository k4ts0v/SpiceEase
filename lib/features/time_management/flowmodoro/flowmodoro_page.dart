// ===== CORE DART/FLUTTER IMPORTS =====
// Standard library and framework imports for async operations, UI components, and state management
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ===== APPLICATION IMPORTS =====
// Data models for tasks and subtasks
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';

// State providers for date selection and localization
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/features/time_management/flowmodoro/flowmodoro_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// ===== FLOWMODORO PAGE =====
/// Main page for the Flowmodoro technique implementation
///
/// Flowmodoro is a productivity technique that combines focused work sessions
/// with break periods, similar to Pomodoro but with customizable timings.
/// This page allows users to:
/// - Select tasks or subtasks to work on
/// - Configure focus/break durations and cycle counts
/// - Run timed sessions with visual progress indicators
/// - Track completed sessions and mark tasks as done
class FlowmodoroPage extends ConsumerStatefulWidget {
  const FlowmodoroPage({super.key});

  @override
  FlowmodoroPageState createState() => FlowmodoroPageState();
}

/// State class managing all Flowmodoro session logic and UI state
/// Handles timer operations, configuration, and user interactions
class FlowmodoroPageState extends ConsumerState<FlowmodoroPage> {
  // ===== TASK SELECTION STATE =====
  /// Currently selected task for the Flowmodoro session
  /// Can be either a TaskModel or a "dummy" TaskModel created from a SubtaskModel
  TaskModel? _selectedTask;

  /// Tracks whether the selected item is actually a subtask
  /// Used to determine completion behavior and data handling
  bool _selectedIsSubtask = false;

  // ===== TIMER CONFIGURATION STATE =====
  /// Duration of each focus session in minutes
  /// User-configurable, default 25 minutes (traditional Pomodoro length)
  int _focusMinutes = 25;

  /// Duration of each break session in minutes
  /// User-configurable, default 5 minutes
  int _breakMinutes = 5;

  /// Number of focus/break cycles to complete in a full session
  /// User-configurable, default 4 cycles
  int _cycleCount = 4;

  // ===== TIMER EXECUTION STATE =====
  /// Whether a Flowmodoro session is currently running
  bool _isRunning = false;

  /// Whether currently in a break period (true) or focus period (false)
  bool _isBreak = false;

  /// Current cycle number (1-based counting)
  int _currentCycle = 1;

  /// Remaining seconds in the current timer period
  int _remainingSeconds = 0;

  /// Timer instance for countdown functionality
  Timer? _timer;

  @override
  void dispose() {
    // ===== CLEANUP =====
    // Cancel any active timer to prevent memory leaks
    _timer?.cancel();
    super.dispose();
  }

  // ===== TASK SELECTION METHODS =====

  /// Selects a regular task for Flowmodoro session
  /// Resets timer state and prepares for configuration
  void _selectTask(TaskModel task) {
    setState(() {
      _selectedIsSubtask = false;
      _selectedTask = task;
      _remainingSeconds = _focusMinutes * 60;
    });
  }

  /// Selects a subtask for Flowmodoro session
  /// Creates a "dummy" TaskModel using subtask data and parent task priority
  /// This allows subtasks to be treated as regular tasks for timing purposes
  void _selectSubtask(SubtaskModel subtask) {
    final controller = ref.read(flowmodoroControllerProvider);

    // ===== PARENT TASK LOOKUP =====
    // Find the parent task to inherit its priority and user ID
    final parent = controller.availableTasks.firstWhere(
      (t) => t.id == subtask.taskId,
      orElse: () => TaskModel(
        id: '',
        userId: '',
        title: '',
        description: '',
        priority: 3, // Default medium priority if parent not found
        status: '',
        hasSubtasks: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // ===== CREATE DUMMY TASK MODEL =====
    // Convert subtask to TaskModel format for consistent handling
    setState(() {
      _selectedIsSubtask = true;
      _selectedTask = TaskModel(
        id: subtask.id, // Use the subtask ID for completion tracking
        userId: parent.userId,
        title: subtask.title,
        description: subtask.title, // Use title as description for subtasks
        priority: parent.priority, // Inherit parent's priority
        status: 'To-do',
        hasSubtasks: false,
        createdAt: subtask.createdAt,
        updatedAt: subtask.updatedAt,
      );
      _remainingSeconds = _focusMinutes * 60;
    });
  }

  // ===== TIMER MANAGEMENT METHODS =====

  /// Starts the Flowmodoro timer for the current period (focus or break)
  /// Handles countdown logic and automatic transitions between periods
  Future<void> _startFlowmodoro() async {
    setState(() {
      _isRunning = true;
      _remainingSeconds = _isBreak ? _breakMinutes * 60 : _focusMinutes * 60;
    });

    // ===== COUNTDOWN TIMER LOGIC =====
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          // ===== DECREMENT TIMER =====
          _remainingSeconds--;
        } else {
          // ===== TIMER COMPLETED =====
          _timer?.cancel();

          if (!_isBreak) {
            // ===== FOCUS SESSION ENDED =====
            if (_currentCycle < _cycleCount) {
              // More cycles remaining - transition to break
              _showTransitionPopup(isBreakFinished: false).then((_) {
                setState(() {
                  _isBreak = true;
                  _remainingSeconds = _breakMinutes * 60;
                });
                _startFlowmodoro();
              });
            } else {
              // ===== ALL CYCLES COMPLETED =====
              _isRunning = false;
              _showCompletionDialog();
            }
          } else {
            // ===== BREAK SESSION ENDED =====
            _showTransitionPopup(isBreakFinished: true).then((_) {
              setState(() {
                _isBreak = false;
                _currentCycle++;
                _remainingSeconds = _focusMinutes * 60;
              });

              if (_currentCycle <= _cycleCount) {
                // Continue to next focus session
                _startFlowmodoro();
              } else {
                // ===== ALL CYCLES COMPLETED =====
                _isRunning = false;
                _showCompletionDialog();
              }
            });
          }
        }
      });
    });
  }

  /// Shows transition popup between focus and break periods
  /// Provides clear visual feedback and user acknowledgment before proceeding
  Future<void> _showTransitionPopup({required bool isBreakFinished}) async {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isBreakFinished
                ? localizations.breakTimeEnded
                : localizations.focusTimeEnded,
            style: TextStyle(
              color: isBreakFinished
                  ? theme.colorScheme.primary
                  : Colors.greenAccent[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            isBreakFinished
                ? localizations.timeToFocusAgain
                : localizations.timeToTakeABreak,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.gotIt,
                style: TextStyle(
                  color: isBreakFinished
                      ? theme.colorScheme.primary
                      : Colors.greenAccent[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          backgroundColor: theme.colorScheme.surface,
        );
      },
    );
  }

  /// Resets the Flowmodoro session to initial state
  /// Cancels any running timer and restores default values
  void _resetFlowmodoro() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _currentCycle = 1;
      _remainingSeconds = _focusMinutes * 60;
    });
  }

  // ===== SESSION COMPLETION METHODS =====

  /// Shows completion dialog when all Flowmodoro cycles are finished
  /// Automatically saves session data and offers task completion option
  void _showCompletionDialog() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    // ===== AUTO-SAVE SESSION DATA =====
    // Always save the completed Flowmodoro session for tracking
    _saveFlowmodoroData();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            localizations.flowmodoroCompleted,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            localizations.markTaskAsCompleted,
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          backgroundColor: theme.colorScheme.surface,
          actions: [
            // ===== OPTION: CONTINUE WITHOUT COMPLETING TASK =====
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetFlowmodoro();
              },
              child: Text(localizations.notYet),
            ),
            // ===== OPTION: MARK TASK AS COMPLETE =====
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeTaskOnly(); // Session already saved, just complete task
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text(localizations.markAsDone),
            ),
          ],
        );
      },
    );
  }

  /// Saves completed Flowmodoro session data to the database
  /// Records timing configuration and completion for analytics/tracking
  Future<void> _saveFlowmodoroData() async {
    if (_selectedTask == null) return;

    final controller = ref.read(flowmodoroControllerProvider.notifier);

    await controller.saveCompletedFlowmodoro(
      taskId: _selectedTask!.id,
      focusMinutes: _focusMinutes,
      breakMinutes: _breakMinutes,
      cycles: _currentCycle,
    );
  }

  /// Completes the selected task without saving Flowmodoro data again
  /// Handles both regular tasks and subtasks with appropriate completion methods
  void _completeTaskOnly() async {
    if (_selectedTask == null) return;

    final localizations = AppLocalizations.of(context)!;
    final controller = ref.read(flowmodoroControllerProvider.notifier);

    // ===== TASK VS SUBTASK COMPLETION =====
    final success = _selectedIsSubtask
        ? await controller.completeSubtask(_selectedTask!.id)
        : await controller.completeTask(_selectedTask!.id);

    if (success) {
      // ===== SUCCESS: RESET UI STATE =====
      setState(() {
        _selectedIsSubtask = false;
        _selectedTask = null;
        _resetFlowmodoro();
      });

      // ===== REFRESH TASK LIST =====
      await controller.loadTasks(context);

      // ===== SUCCESS FEEDBACK =====
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.taskMarkedAsCompleted)),
      );
    } else {
      // ===== ERROR FEEDBACK =====
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.errorMarkingTaskComplete(_selectedTask!.title),
          ),
        ),
      );
    }
  }

  // ===== UTILITY METHODS =====

  /// Formats seconds into MM:SS display format
  /// Used for timer display and countdown visualization
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ===== MAIN BUILD METHOD =====

  @override
  Widget build(BuildContext context) {
    // ===== STATE AND THEME SETUP =====
    final selectedDate = ref.watch(selectedDateProvider);
    final controller = ref.watch(flowmodoroControllerProvider);
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final brightness = theme.brightness;

    // ===== AUTO-LOAD TASKS =====
    // Load tasks when date changes or on first build
    if (controller.currentSelectedDate != selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadTasks(context);
      });
    }

    return Scaffold(
      // ===== APP BAR =====
      appBar: AppBar(
        title: Text(
          localizations.flowmodoro,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: brightness == Brightness.light ? Colors.black : Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(
          color: brightness == Brightness.light ? Colors.black87 : Colors.white,
        ),
        actions: [
          // ===== REFRESH BUTTON =====
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadTasks(context),
            tooltip: localizations.refresh,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,

      // ===== MAIN BODY =====
      body: controller.isLoading
          ? // ===== LOADING STATE =====
          const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== DATE DISPLAY SECTION =====
                  // Shows current selected date with timer icon
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.timer,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            DateFormat.yMMMMd().format(selectedDate),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== MAIN CONTENT AREA =====
                  // Shows either task selection or active Flowmodoro session
                  Expanded(
                    child: _selectedTask == null
                        ? _buildNoTaskSelectedView(context)
                        : _buildFlowmodoroView(context),
                  ),

                  // ===== TASK SELECTION AREA =====
                  // Only shown when no task is selected
                  if (_selectedTask == null) ...[
                    // ===== SECTION HEADER =====
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.assignment_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              localizations.selectTaskForFlowmodoro,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.0,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ===== TASK CARDS CONTAINER =====
                    // Horizontal scrollable list of available tasks and subtasks
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withAlpha(13),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: (controller.availableTasks.isEmpty &&
                              controller.availableSubtasks.isEmpty)
                          ? // ===== EMPTY STATE =====
                          Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                localizations.noTasksAvailable,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(128),
                                ),
                              ),
                            )
                          : // ===== TASK/SUBTASK CARDS =====
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(8),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // ===== TASK CARDS =====
                                    for (final task
                                        in controller.availableTasks)
                                      _buildTaskCard(context, task, controller),
                                    // ===== SUBTASK CARDS =====
                                    for (final sub
                                        in controller.availableSubtasks)
                                      _buildSubtaskCard(
                                          context, sub, controller),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  // ===== SUBTASK CARD BUILDER =====

  /// Builds a card widget for subtask selection
  /// Shows subtask information with parent task context and priority styling
  Widget _buildSubtaskCard(
    BuildContext context,
    SubtaskModel subtask,
    FlowmodoroController controller,
  ) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    // ===== PARENT TASK INFORMATION LOOKUP =====
    // Retrieve parent task details for context and styling
    final parentTitle = controller.getParentTaskTitle(subtask.taskId) ?? '';
    final parentPriority = controller.getParentTaskPriority(subtask.taskId) ??
        3; // Default medium priority

    // ===== COLOR CALCULATION =====
    // Use parent task's priority for consistent styling
    final subtaskPriorityColor = _getTaskPriorityColor(parentPriority);
    final pastelColor = _getPastelColor(parentPriority, brightness);

    return GestureDetector(
      onTap: () => _selectSubtask(subtask),
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: pastelColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: subtaskPriorityColor.withAlpha(153)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== PARENT TASK CONTEXT =====
              // Shows which task this subtask belongs to
              if (parentTitle.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      size: 10,
                      color: subtaskPriorityColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Subtask of: $parentTitle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: subtaskPriorityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              // ===== SUBTASK TITLE SECTION =====
              // Main title with priority color bar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== PRIORITY COLOR BAR =====
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: subtaskPriorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ===== TITLE TEXT =====
                  Expanded(
                    child: Text(
                      subtask.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ===== SPACER =====
              // Push bottom content to the bottom of the card
              const Spacer(),

              // ===== BOTTOM INFORMATION SECTION =====
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== TIME ESTIMATE =====
                  // Show estimated time if available
                  if (subtask.rawTimeValue != null) ...[
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 10,
                            color: subtaskPriorityColor.withAlpha(153)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            subtask.rawTimeValue!,
                            style: TextStyle(
                              fontSize: 9,
                              color: subtaskPriorityColor.withAlpha(153),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  // ===== PRIORITY INFORMATION =====
                  // Show parent task's priority level
                  Row(children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 10,
                      color: subtaskPriorityColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getPriorityLabel(context, parentPriority),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: subtaskPriorityColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== NO TASK SELECTED VIEW =====

  /// Builds the central view shown when no task is selected
  /// Provides explanation of Flowmodoro technique and encourages task selection
  Widget _buildNoTaskSelectedView(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== ICON =====
          Icon(
            Icons.timelapse_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(102),
          ),
          const SizedBox(height: 16),

          // ===== MAIN MESSAGE =====
          Text(
            AppLocalizations.of(context)!.selectATaskToStart,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // ===== EXPLANATION =====
          Text(
            AppLocalizations.of(context)!.flowmodoroExplanation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }

  // ===== FLOWMODORO SESSION VIEW =====

  /// Builds the main view when a task is selected
  /// Shows task details and either configuration or active timer interface
  Widget _buildFlowmodoroView(BuildContext context) {
    final theme = Theme.of(context);
    final isConfiguring = !_isRunning;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===== SELECTED TASK CARD =====
          // Shows details of the currently selected task/subtask
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== TASK HEADER =====
                Row(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedTask!.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // ===== TASK DESCRIPTION =====
                // Show description if available and not empty
                if (_selectedTask!.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _selectedTask!.description,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withAlpha(179),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===== TIMER/CONFIGURATION AREA =====
          // Shows either configuration controls or active timer display
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isConfiguring
                  ? _buildConfigurationView(context)
                  : _buildTimerView(context),
            ),
          ),
        ],
      ),
    );
  }

  // ===== CONFIGURATION VIEW =====

  /// Builds the configuration interface for setting up Flowmodoro parameters
  /// Allows users to adjust focus time, break time, and cycle count
  Widget _buildConfigurationView(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ===== HEADER =====
        Text(
          localizations.configureFlowmodoro,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // ===== FOCUS TIME CONFIGURATION =====
        _buildTimeConfigRow(
          context,
          localizations.focusTime,
          _focusMinutes,
          (value) => setState(() => _focusMinutes = value),
          minValue: 1,
          maxValue: 60,
        ),

        const SizedBox(height: 16),

        // ===== BREAK TIME CONFIGURATION =====
        _buildTimeConfigRow(
          context,
          localizations.breakTime,
          _breakMinutes,
          (value) => setState(() => _breakMinutes = value),
          minValue: 1,
          maxValue: 30,
        ),

        const SizedBox(height: 16),

        // ===== CYCLE COUNT CONFIGURATION =====
        _buildTimeConfigRow(
          context,
          localizations.cyclesToComplete,
          _cycleCount,
          (value) => setState(() => _cycleCount = value),
          minValue: 1,
          maxValue: 10,
          unit: localizations.cycles,
        ),

        const Spacer(),

        // ===== START BUTTON =====
        ElevatedButton.icon(
          onPressed: _startFlowmodoro,
          icon: const Icon(Icons.play_arrow),
          label: Text(localizations.startFlowmodoro),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),

        const SizedBox(height: 12),

        // ===== CANCEL BUTTON =====
        TextButton(
          onPressed: () => setState(() => _selectedTask = null),
          child: Text(localizations.cancel),
        ),
      ],
    );
  }

  // ===== TIME CONFIGURATION ROW =====

  /// Builds a configuration row with increment/decrement controls
  /// Used for adjusting focus time, break time, and cycle count
  Widget _buildTimeConfigRow(
    BuildContext context,
    String label,
    int value,
    Function(int) onChanged, {
    required int minValue,
    required int maxValue,
    String? unit,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // ===== LABEL =====
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // ===== DECREMENT BUTTON =====
        IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: theme.colorScheme.primary,
          ),
          onPressed: value > minValue ? () => onChanged(value - 1) : null,
        ),

        // ===== VALUE DISPLAY =====
        Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        // ===== INCREMENT BUTTON =====
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: theme.colorScheme.primary,
          ),
          onPressed: value < maxValue ? () => onChanged(value + 1) : null,
        ),

        // ===== UNIT LABEL =====
        Expanded(
          flex: 1,
          child: Text(
            unit ?? AppLocalizations.of(context)!.minutes,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ===== ACTIVE TIMER VIEW =====

  /// Builds the active timer interface during Flowmodoro sessions
  /// Shows circular progress, remaining time, and session controls
  Widget _buildTimerView(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    // ===== PROGRESS CALCULATION =====
    final progressValue = _remainingSeconds /
        (_isBreak ? _breakMinutes * 60 : _focusMinutes * 60);

    // ===== COLOR CODING =====
    // Different colors for focus (primary) vs break (green) periods
    final timerColor =
        _isBreak ? Colors.greenAccent[700]! : theme.colorScheme.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ===== SESSION TYPE INDICATOR =====
        Text(
          _isBreak ? localizations.breakTime : localizations.focusTime,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: timerColor,
          ),
        ),
        const SizedBox(height: 8),

        // ===== CYCLE PROGRESS =====
        Text(
          '$_currentCycle / $_cycleCount ${localizations.cycles}',
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
        const SizedBox(height: 40),

        // ===== CIRCULAR TIMER DISPLAY =====
        Stack(
          alignment: Alignment.center,
          children: [
            // ===== PROGRESS CIRCLE =====
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: progressValue,
                strokeWidth: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
            ),
            // ===== TIMER TEXT OVERLAY =====
            Column(
              children: [
                // ===== REMAINING TIME =====
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: timerColor,
                  ),
                ),
                // ===== MODE INDICATOR =====
                Text(
                  _isBreak ? localizations.relax : localizations.focus,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),

        // ===== STOP BUTTON =====
        ElevatedButton.icon(
          onPressed: _resetFlowmodoro,
          icon: const Icon(Icons.stop),
          label: Text(localizations.stopFlowmodoro),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            backgroundColor: Colors.red[400],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // ===== TASK CARD BUILDER =====

  /// Builds a card widget for regular task selection
  /// Shows task information with priority-based styling
  Widget _buildTaskCard(
    BuildContext context,
    TaskModel task,
    FlowmodoroController controller,
  ) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final taskPriorityColor = _getTaskPriorityColor(task.priority);
    final pastelColor = _getPastelColor(task.priority, brightness);

    return GestureDetector(
      onTap: () => _selectTask(task),
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: pastelColor,
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
              // ===== TITLE SECTION =====
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== PRIORITY COLOR BAR =====
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: taskPriorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ===== TITLE TEXT =====
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

              // ===== DESCRIPTION SECTION =====
              // Show description if available and not empty
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

              // ===== SPACER =====
              // Push priority section to bottom of card
              const Spacer(),

              // ===== PRIORITY SECTION =====
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

  // ===== COLOR UTILITY METHODS =====

  /// Returns accent colors for borders, icons, and text based on priority
  /// Provides consistent color coding across the interface
  Color _getTaskPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF2196F3); // Blue - Lowest priority
      case 2:
        return const Color(0xFF4CAF50); // Green - Low priority
      case 3:
        return const Color(0xFFFFC107); // Yellow - Medium priority
      case 4:
        return const Color(0xFFFF9800); // Orange - High priority
      case 5:
        return const Color(0xFFF44336); // Red - Highest priority
      default:
        return const Color(0xFF9E9E9E); // Grey - Default/unknown
    }
  }

  /// Returns pastel background colors based on priority and theme brightness
  /// Used for card backgrounds with appropriate opacity for readability
  Color _getPastelColor(int priority, Brightness brightness) {
    // ===== DARK MODE COLORS =====
    // Use darker pastel colors that work well with dark backgrounds
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

    // ===== LIGHT MODE COLORS =====
    // Light, subtle pastel colors for light mode backgrounds
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
