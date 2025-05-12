//// filepath: /home/k4ts0v/DAM/spiceease/lib/features/time_management/flowmodoro/flowmodoro_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/state_notifiers/task_state_notifier.dart';
import 'package:spiceease/features/time_management/flowmodoro/flowmodoro_controller.dart';
import 'package:spiceease/features/tracker/presentation/modals.dart';
import 'package:spiceease/l10n/app_localizations.dart';

//TODO: add subtask support.
// TODO: if a task has got an estimated time, make the total durationof all pomos be that one (if it's less than x hours.)
class FlowmodoroPage extends ConsumerStatefulWidget {
  const FlowmodoroPage({Key? key}) : super(key: key);

  @override
  _FlowmodoroPageState createState() => _FlowmodoroPageState();
}

class _FlowmodoroPageState extends ConsumerState<FlowmodoroPage> {
  TaskModel? _selectedTask;
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
      _selectedTask = task;
      _remainingSeconds = _focusMinutes * 60;
    });
  }

  void _startFlowmodoro() {
    setState(() {
      _isRunning = true;
      _remainingSeconds = _isBreak ? _breakMinutes * 60 : _focusMinutes * 60;
    });

    // Add to the _startFlowmodoro method's timer callback where transitions happen
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();

          // If we were in focus mode, switch to break or ask for completion
          if (!_isBreak) {
            if (_currentCycle < _cycleCount) {
              // Show focus completed popup
              _showTransitionPopup(isBreakFinished: false);

              // Switch to break mode
              _isBreak = true;
              _remainingSeconds = _breakMinutes * 60;
              _startFlowmodoro(); // Start break timer
            } else {
              // We finished all cycles, ask if completed
              _isRunning = false;
              _showCompletionDialog();
            }
          } else {
            // Show break completed popup
            _showTransitionPopup(isBreakFinished: true);

            // We finished a break, start next focus cycle
            _isBreak = false;
            _currentCycle++;
            _remainingSeconds = _focusMinutes * 60;
            if (_currentCycle <= _cycleCount) {
              _startFlowmodoro(); // Start next focus timer
            } else {
              // We finished all cycles, ask if completed
              _isRunning = false;
              _showCompletionDialog();
            }
          }
        }
      });
    });
  }

  void _showTransitionPopup({required bool isBreakFinished}) {
    final localizations = AppLocalizations.of(context)!;

    // Create a popup that auto-dismisses after a few seconds
    showDialog(
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
                  ? Theme.of(context).colorScheme.primary
                  : Colors.greenAccent[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            isBreakFinished
                ? localizations.timeToFocusAgain
                : localizations.timeToTakeABreak,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.gotIt),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.flowmodoroCompleted),
          content: Text(AppLocalizations.of(context)!.markTaskAsCompleted),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetFlowmodoro();
              },
              child: Text(AppLocalizations.of(context)!.notYet),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeTask();
              },
              child: Text(AppLocalizations.of(context)!.markAsDone),
            ),
          ],
        );
      },
    );
  }

  void _completeTask() async {
    if (_selectedTask == null) return;

    final localizations = AppLocalizations.of(context)!;
    final controller = ref.read(flowmodoroControllerProvider.notifier);

    // First save the completed flowmodoro data
    await controller.saveCompletedFlowmodoro(
      taskId: _selectedTask!.id,
      focusMinutes: _focusMinutes,
      breakMinutes: _breakMinutes,
      cycles: _currentCycle,
    );

    // Then mark the task as completed
    final success = await controller.completeTask(_selectedTask!.id);

    if (success) {
      // Reset the flowmodoro and clear the selected task
      setState(() {
        _selectedTask = null;
        _resetFlowmodoro();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.taskMarkedAsCompleted)),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                localizations.errorMarkingTaskComplete(_selectedTask!.title))),
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
    final taskState = ref.watch(taskStateNotifierProvider(selectedDate));
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    final availableTasks =
        taskState.where((task) => task.status != "Done").toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.flowmodoro,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.refresh(taskStateNotifierProvider(selectedDate)),
            tooltip: localizations.refresh,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date display
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
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

            // Task selection area (shown only when no task is selected)
            if (_selectedTask == null) ...[
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
                        Icons.assignment_outlined,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      localizations.selectTaskForFlowmodoro,
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
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: availableTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.task_alt,
                                color: Colors.grey[400], size: 24),
                            const SizedBox(height: 8),
                            Text(
                              localizations.noTasksAvailable,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        itemCount: availableTasks.length,
                        itemBuilder: (context, index) {
                          final task = availableTasks[index];
                          return _buildTaskCard(context, task);
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoTaskSelectedView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timelapse_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectATaskToStart,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.flowmodoroExplanation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedTask!.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _selectedTask!.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
            foregroundColor: Colors.white,
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
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > minValue ? () => onChanged(value - 1) : null,
        ),
        Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < maxValue ? () => onChanged(value + 1) : null,
        ),
        Expanded(
          flex: 1,
          child: Text(
            unit ?? AppLocalizations.of(context)!.minutes,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey[600],
            ),
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
            color: Colors.grey[600],
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
                backgroundColor: Colors.grey[200],
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
                    color: Colors.grey[600],
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

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    final taskPriorityColor = _getTaskPriorityColor(task.priority);
    final pastelColor = _getPastelColor(task.priority);

    return GestureDetector(
      onTap: () => _selectTask(task),
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: pastelColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: taskPriorityColor.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: taskPriorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.flag_outlined, size: 12, color: taskPriorityColor),
                  const SizedBox(width: 4),
                  Text(
                    _getPriorityLabel(context, task.priority),
                    style: TextStyle(
                      fontSize: 10,
                      color: taskPriorityColor,
                      fontWeight: FontWeight.w500,
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

  Color _getPastelColor(int priority) {
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
        return const Color(0xFFF5F5F5); // Pastel grey
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
