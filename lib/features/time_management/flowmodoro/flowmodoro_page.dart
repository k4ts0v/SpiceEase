import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/features/time_management/flowmodoro/flowmodoro_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class FlowmodoroPage extends ConsumerStatefulWidget {
  const FlowmodoroPage({Key? key}) : super(key: key);

  @override
  _FlowmodoroPageState createState() => _FlowmodoroPageState();
}

class _FlowmodoroPageState extends ConsumerState<FlowmodoroPage> {
  TaskModel? _selectedTask;
  bool _selectedIsSubtask = false; // Added to track if we selected a subtask
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _cycleCount = 4;
  bool _isRunning = false;
  bool _isBreak = false;
  int _currentCycle = 1;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectTask(TaskModel task) {
    setState(() {
      _selectedIsSubtask = false;
      _selectedTask = task;
      _remainingSeconds = _focusMinutes * 60;
    });
  }

  /// Treat a subtask as if it were a task, letting it run Flowmodoro.
  /// We create a "dummy" TaskModel using the subtask information.
  void _selectSubtask(SubtaskModel subtask) {
    final controller = ref.read(flowmodoroControllerProvider);
    // Fetch parent to get its priority (or default if not found).
    final parent = controller.availableTasks.firstWhere(
      (t) => t.id == subtask.taskId,
      orElse: () => TaskModel(
        id: '',
        userId: '',
        title: '',
        description: '',
        priority: 3,
        status: '',
        hasSubtasks: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    setState(() {
      _selectedIsSubtask = true;
      _selectedTask = TaskModel(
        id: subtask.id, // Use the subtask ID
        userId: parent.userId,
        title: subtask.title,
        description: subtask.title,
        priority: parent.priority, // Use parent's priority or default
        status: 'To-do',
        hasSubtasks: false,
        createdAt: subtask.createdAt,
        updatedAt: subtask.updatedAt,
      );
      _remainingSeconds = _focusMinutes * 60;
    });
  }

  Future<void> _startFlowmodoro() async {
    setState(() {
      _isRunning = true;
      _remainingSeconds = _isBreak ? _breakMinutes * 60 : _focusMinutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();

          // If focus just ended
          if (!_isBreak) {
            if (_currentCycle < _cycleCount) {
              // Show the popup and wait for it to close before starting break
              _showTransitionPopup(isBreakFinished: false).then((_) {
                setState(() {
                  _isBreak = true;
                  _remainingSeconds = _breakMinutes * 60;
                });
                _startFlowmodoro();
              });
            } else {
              // All cycles finished
              _isRunning = false;
              _showCompletionDialog();
            }
          } else {
            // Break just ended
            _showTransitionPopup(isBreakFinished: true).then((_) {
              setState(() {
                _isBreak = false;
                _currentCycle++;
                _remainingSeconds = _focusMinutes * 60;
              });

              if (_currentCycle <= _cycleCount) {
                _startFlowmodoro();
              } else {
                // All cycles finished
                _isRunning = false;
                _showCompletionDialog();
              }
            });
          }
        }
      });
    });
  }

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

  void _resetFlowmodoro() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _currentCycle = 1;
      _remainingSeconds = _focusMinutes * 60;
    });
  }

  void _showCompletionDialog() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    // Always save the flowmodoro data when completing all cycles
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetFlowmodoro();
              },
              child: Text(localizations.notYet),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeTaskOnly(); // Only complete the task, don't save flowmodoro again
              },
              child: Text(localizations.markAsDone),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Save flowmodoro data without completing the task
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

  /// Complete the task without saving flowmodoro data (already saved)
  void _completeTaskOnly() async {
    if (_selectedTask == null) return;

    final localizations = AppLocalizations.of(context)!;
    final controller = ref.read(flowmodoroControllerProvider.notifier);

    final success = _selectedIsSubtask
        ? await controller.completeSubtask(_selectedTask!.id)
        : await controller.completeTask(_selectedTask!.id);

    if (success) {
      setState(() {
        _selectedIsSubtask = false;
        _selectedTask = null;
        _resetFlowmodoro();
      });

      await controller.loadTasks(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.taskMarkedAsCompleted)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.errorMarkingTaskComplete(_selectedTask!.title),
          ),
        ),
      );
    }
  }

  /// If it's a subtask, mark subtask as complete. Otherwise, mark task.
  /// This method now only saves flowmodoro and completes task together (for backward compatibility)
  void _completeTask() async {
    if (_selectedTask == null) return;

    final localizations = AppLocalizations.of(context)!;
    final controller = ref.read(flowmodoroControllerProvider.notifier);

    // Save the completed flowmodoro data
    await controller.saveCompletedFlowmodoro(
      taskId: _selectedTask!.id,
      focusMinutes: _focusMinutes,
      breakMinutes: _breakMinutes,
      cycles: _currentCycle,
    );

    final success = _selectedIsSubtask
        ? await controller.completeSubtask(_selectedTask!.id)
        : await controller.completeTask(_selectedTask!.id);

    if (success) {
      setState(() {
        _selectedIsSubtask = false;
        _selectedTask = null;
        _resetFlowmodoro();
      });

      await controller.loadTasks(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.taskMarkedAsCompleted)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.errorMarkingTaskComplete(_selectedTask!.title),
          ),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final controller = ref.watch(flowmodoroControllerProvider);
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final brightness = theme.brightness;

    // Load tasks when date changes or on first build
    if (controller.currentSelectedDate != selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadTasks(context);
      });
    }

    final availableTasks = controller.availableTasks;

    return Scaffold(
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadTasks(context),
            tooltip: localizations.refresh,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date display - FIX FOR LINE 369 OVERFLOW
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
                  // Main Flowmodoro area
                  Expanded(
                    child: _selectedTask == null
                        ? _buildNoTaskSelectedView(context)
                        : _buildFlowmodoroView(context),
                  ),
                  // Task selection area
                  if (_selectedTask == null) ...[
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
                    // Flexible container that adapts to content
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
                          ? Padding(
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
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(8),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Show tasks
                                    for (final task
                                        in controller.availableTasks)
                                      _buildTaskCard(context, task, controller),
                                    // Show subtasks
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

  Widget _buildSubtaskCard(
    BuildContext context,
    SubtaskModel subtask,
    FlowmodoroController controller,
  ) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    // Retrieve the parent task's title and priority
    final parentTitle = controller.getParentTaskTitle(subtask.taskId) ?? '';
    final parentPriority = controller.getParentTaskPriority(subtask.taskId) ??
        3; // Default to medium priority

    // Use parent's priority for styling
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
              /// "Subtask of" row
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

              /// Title row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: subtaskPriorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
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

              /// Spacer to push bottom content down
              const Spacer(),

              /// Bottom section with time and priority
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Estimated time (if available)
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

                  /// Priority row
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

  Widget _buildNoTaskSelectedView(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timelapse_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(102),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectATaskToStart,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
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

  Widget _buildFlowmodoroView(BuildContext context) {
    final theme = Theme.of(context);
    final isConfiguring = !_isRunning;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selected task card
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

          // Timer display or configuration
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

  Widget _buildConfigurationView(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

        // Focus time
        _buildTimeConfigRow(
          context,
          localizations.focusTime,
          _focusMinutes,
          (value) => setState(() => _focusMinutes = value),
          minValue: 1,
          maxValue: 60,
        ),

        const SizedBox(height: 16),

        // Break time
        _buildTimeConfigRow(
          context,
          localizations.breakTime,
          _breakMinutes,
          (value) => setState(() => _breakMinutes = value),
          minValue: 1,
          maxValue: 30,
        ),

        const SizedBox(height: 16),

        // Cycle count
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

        // Start button
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

        // Cancel button
        TextButton(
          onPressed: () => setState(() => _selectedTask = null),
          child: Text(localizations.cancel),
        ),
      ],
    );
  }

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
        IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: theme.colorScheme.primary,
          ),
          onPressed: value > minValue ? () => onChanged(value - 1) : null,
        ),
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
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: theme.colorScheme.primary,
          ),
          onPressed: value < maxValue ? () => onChanged(value + 1) : null,
        ),
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

  Widget _buildTimerView(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    final progressValue = _remainingSeconds /
        (_isBreak ? _breakMinutes * 60 : _focusMinutes * 60);
    final timerColor =
        _isBreak ? Colors.greenAccent[700]! : theme.colorScheme.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isBreak ? localizations.breakTime : localizations.focusTime,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: timerColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentCycle} / ${_cycleCount} ${localizations.cycles}',
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
        const SizedBox(height: 40),
        Stack(
          alignment: Alignment.center,
          children: [
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
            Column(
              children: [
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: timerColor,
                  ),
                ),
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
              /// Title section
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

              /// Description section
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

              /// Spacer to push priority to bottom
              const Spacer(),

              /// Priority row
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

  Color _getTaskPriorityColor(int priority) {
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

  Color _getPastelColor(int priority, Brightness brightness) {
    // For dark mode, use darker pastel colors
    if (brightness == Brightness.dark) {
      switch (priority) {
        case 1:
          return const Color(0xFF0D47A1).withOpacity(0.3); // Dark blue pastel
        case 2:
          return const Color(0xFF1B5E20).withOpacity(0.3); // Dark green pastel
        case 3:
          return const Color(0xFFF57F17).withOpacity(0.3); // Dark yellow pastel
        case 4:
          return const Color(0xFFE65100).withOpacity(0.3); // Dark orange pastel
        case 5:
          return const Color(0xFFB71C1C).withOpacity(0.3); // Dark red pastel
        default:
          return const Color(0xFF424242).withOpacity(0.3); // Dark grey pastel
      }
    }

    // Original colors for light mode
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
