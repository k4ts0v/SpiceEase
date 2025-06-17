import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/services/magic_todo_service.dart';
import 'package:spiceease/features/time_management/time_blocks/time_block_controller.dart';
import 'package:spiceease/features/tracker/presentation/widgets/estimator_widget.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import '../tracker_controller.dart';

// —— Base Editor Modal —— //

abstract class TrackingEditorModal<T> extends StatefulWidget {
  const TrackingEditorModal({super.key, required this.ref, this.existing});
  final WidgetRef ref;
  final T? existing;
  @override
  TrackingEditorModalState createState();
}

// Update the base TrackingEditorModal build method
abstract class TrackingEditorModalState<T extends TrackingEditorModal>
    extends State<T> {
  Widget buildForm();
  void onSave();
  void onDelete();

  // Base editor modal build method
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.maxFinite, // Ensure dialog uses available width
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fix title text overflow
              Flexible(
                child: Text(
                  getTitle(),
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 20),
              buildForm(),
              const SizedBox(height: 24),
              // Fix button row overflow
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.existing != null)
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (alertDialogContext) => AlertDialog(
                            title: Text(localizations.confirmDelete),
                            content: Text(localizations
                                .deleteConfirmationMessage(getDeleteLabel())),
                            actions: [
                              TextButton(
                                child: Text(localizations.cancel),
                                onPressed: () =>
                                    Navigator.of(alertDialogContext).pop(),
                              ),
                              TextButton(
                                child: Text(
                                  localizations.delete,
                                  style:
                                      TextStyle(color: theme.colorScheme.error),
                                ),
                                onPressed: () {
                                  Navigator.of(alertDialogContext).pop();
                                  onDelete();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        localizations.delete,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(localizations.cancel),
                  ),
                  ElevatedButton(
                    onPressed: onSave,
                    child: Text(localizations.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getDeleteLabel() => AppLocalizations.of(context)!.thisItem('item');
  String getTitle() => AppLocalizations.of(context)!.item('item');
}

// —— Symptom Editor —— //

class SymptomEditorModal extends TrackingEditorModal {
  final SymptomModel? existing;
  const SymptomEditorModal({
    super.key,
    required super.ref,
    this.existing,
  });
  @override
  SymptomEditorModalState createState() => SymptomEditorModalState();
}

class SymptomEditorModalState
    extends TrackingEditorModalState<SymptomEditorModal> {
  late TextEditingController _nameC;
  final _customCatC = TextEditingController();
  String _category = 'Physical';
  bool _isCustomCategory = false;
  int _severity = 0;
  late TextEditingController _notesC;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.existing?.name ?? '');
    _notesC = TextEditingController(text: widget.existing?.notes ?? '');

    // Handle category initialization
    if (widget.existing != null) {
      final predefinedCategories = ['Physical', 'Psychological'];
      if (predefinedCategories.contains(widget.existing!.category)) {
        _category = widget.existing!.category;
      } else {
        _isCustomCategory = true;
        _customCatC.text = widget.existing!.category;
        _category = 'Custom';
      }
      _severity = widget.existing?.severity ?? 0;
    }
  }

  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;

    // Map English category names to localized ones
    final Map<String, String> categoryMap = {
      'Physical': localizations.physical,
      'Psychological': localizations.psychological,
      'Custom': localizations.custom
    };

    // Get the localized version of the current category
    final localizedCategory = categoryMap[_category] ?? localizations.physical;

    final predefinedCategories = [
      localizations.physical,
      localizations.psychological,
      localizations.custom
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameC,
          decoration: InputDecoration(labelText: localizations.name),
        ),
        const SizedBox(height: 12),
        // Fix: Replace overflowing Row with responsive Column layout
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations.category}:'),
            const SizedBox(height: 8),
            if (_isCustomCategory)
              TextFormField(
                controller: _customCatC,
                decoration:
                    InputDecoration(labelText: localizations.customCategory),
                onChanged: (value) => setState(() => _category = value),
              )
            else
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  value: localizedCategory,
                  decoration:
                      InputDecoration(labelText: localizations.category),
                  items: predefinedCategories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    if (v == localizations.custom) {
                      _isCustomCategory = true;
                      _customCatC.text = _category == 'Custom' ? '' : _category;
                      _category = 'Custom';
                    } else if (v == localizations.physical) {
                      _isCustomCategory = false;
                      _category = 'Physical';
                    } else if (v == localizations.psychological) {
                      _isCustomCategory = false;
                      _category = 'Psychological';
                    }
                  }),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Fix: Make severity row responsive
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations.severity}:'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 10,
                    divisions: 10,
                    value: _severity.toDouble(),
                    label: '$_severity',
                    onChanged: (v) => setState(() => _severity = v.round()),
                  ),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text('$_severity'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesC,
          decoration: InputDecoration(
            labelText: localizations.notes,
            hintText: localizations.symptomNotesHint,
          ),
          maxLines: null,
        ),
      ],
    );
  }

  @override
  void onSave() async {
    if (_nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.nameRequired)),
      );
      return;
    }

    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);

    final categoryToSave = _isCustomCategory ? _customCatC.text : _category;

    if (widget.existing == null) {
      await ctrl.addSymptom(
        _nameC.text.trim(),
        categoryToSave,
        _severity,
        _notesC.text.trim(),
      );
    } else {
      await ctrl.updateSymptom(
        widget.existing!.id,
        _nameC.text.trim(),
        categoryToSave,
        _severity,
        _notesC.text.trim(),
      );
    }
  }

  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteSymptom(widget.existing!.id, widget.ref);
  }
}
// —— Habit Editor —— //

class HabitEditorModal extends TrackingEditorModal {
  final HabitModel? existing;
  const HabitEditorModal({
    super.key,
    required super.ref,
    this.existing,
  });

  @override
  HabitEditorModalState createState() => HabitEditorModalState();
}

class HabitEditorModalState extends TrackingEditorModalState<HabitEditorModal> {
  late TextEditingController _titleC, _descC;
  late String _freqLabel;
  List<int> _selectedDays = [];
  bool _markAsCompleted = false;
  List<String>? _freqOpts;
  final List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  String? _selectedDay;

  // Map to translate between internal and UI values
  Map<String, String> _freqMapToDisplay = {};
  Map<String, String> _freqMapToInternal = {};

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.existing?.title ?? '');
    _descC = TextEditingController(text: widget.existing?.description ?? '');
    _freqLabel = widget.existing != null
        ? _mapFrequencyToLabel(widget.existing!.frequency)
        : 'Daily';
    _selectedDays = widget.existing?.customDays ?? [];

    if (widget.existing?.lastCompleted != null) {
      final today = DateTime.now();
      _markAsCompleted = widget.existing!.lastCompleted!.year == today.year &&
          widget.existing!.lastCompleted!.month == today.month &&
          widget.existing!.lastCompleted!.day == today.day;
    }
  }

  /// Maps frequency integer to a human-readable label.
  String _mapFrequencyToLabel(int frequency) {
    if (frequency == 1) return 'Daily';
    if (frequency == 7) return 'Weekly';
    if (frequency == -1) return 'Monthly';
    return 'Daily'; // Default to Daily
  }

  /// Maps a human-readable label to a frequency integer.
  int _mapLabelToFrequency(String label) {
    if (label == 'Daily' || label == _freqMapToInternal['Daily']) return 1;
    if (label == 'Weekly' || label == _freqMapToInternal['Weekly']) return 7;
    if (label == 'Monthly' || label == _freqMapToInternal['Monthly']) return -1;
    return 1; // Default to Daily
  }

  // Fix 1: Missing closing bracket in buildForm method around line 410
  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;

    // Setup mapping between internal and UI values
    _freqMapToDisplay = {
      'Daily': localizations.daily,
      'Weekly': localizations.weekly,
      'Monthly': localizations.monthly
    };
    _freqMapToInternal = {
      'Daily': localizations.daily,
      'Weekly': localizations.weekly,
      'Monthly': localizations.monthly
    };

    // Get localized options
    _freqOpts = [
      localizations.daily,
      localizations.weekly,
      localizations.monthly
    ];

    // Get the localized version of current frequency
    final localizedFreq = _freqMapToDisplay[_freqLabel] ?? localizations.daily;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(
        controller: _titleC,
        decoration: InputDecoration(labelText: localizations.title),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _descC,
        decoration: InputDecoration(labelText: localizations.description),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: localizedFreq,
        decoration: InputDecoration(labelText: localizations.frequency),
        items: _freqOpts
            ?.map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) => setState(() {
          // Map back to internal representation
          if (v == localizations.daily) {
            _freqLabel = 'Daily';
          } else if (v == localizations.weekly) {
            _freqLabel = 'Weekly';
          } else if (v == localizations.monthly) {
            _freqLabel = 'Monthly';
          }
          _selectedDays.clear(); // Reset selected days when frequency changes
        }),
      ),
      if (_freqLabel == 'Weekly') ...[
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: List.generate(7, (i) {
            final weekday = i + 1;
            return FilterChip(
              label: Text(DateFormat('EEEE', localizations.localeName)
                  .format(DateTime(2024, 1, weekday))),
              selected: _selectedDays.contains(weekday),
              onSelected: (selected) => setState(() {
                if (selected) {
                  _selectedDays.add(weekday);
                } else {
                  _selectedDays.remove(weekday);
                }
              }),
            );
          }),
        ),
      ],
      if (_freqLabel == 'Monthly') ...[
        const SizedBox(height: 12),
        TextField(
          controller: TextEditingController(text: _selectedDay ?? ''),
          decoration: InputDecoration(
            labelText: localizations.enterDayOfMonth,
            hintText: localizations.dayOfMonthHint,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _selectedDay = value;
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            if (_selectedDay != null) {
              final day = int.tryParse(_selectedDay!);
              if (day != null && day >= 1 && day <= 31) {
                if (!_selectedDays.contains(day)) {
                  setState(() {
                    _selectedDays.add(day); // Add the day to the list
                  });
                }
              }
            }
          },
          child: Text(localizations.addDayOfMonth),
        ),
      ],
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: _selectedDays
            .map((day) => Chip(
                  label: Text(_freqLabel == 'Weekly'
                      ? DateFormat('EEEE', localizations.localeName)
                          .format(DateTime(2024, 1, day))
                      : localizations.dayNumber(day.toString())),
                  onDeleted: () {
                    setState(() {
                      _selectedDays.remove(day);
                    });
                  },
                ))
            .toList(),
      ),
      // Fix 2: Add the missing code for existing habits
      if (widget.existing != null) ...[
        const SizedBox(height: 12),
        CheckboxListTile(
          title: Text(localizations.markAsCompleted),
          value: _markAsCompleted,
          onChanged: (value) {
            // Only update the UI state immediately
            setState(() => _markAsCompleted = value ?? false);

            // Capture controller reference before async operation
            final ctrl = widget.ref.read(trackerControllerProvider);

            // Then trigger the save operation asynchronously
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                await ctrl.updateHabit(
                  widget.existing!.id,
                  widget.existing!.title,
                  widget.existing!.description,
                  widget.existing!.frequency,
                  widget.existing!.customDays,
                  value ?? false,
                );
              } catch (e) {
                debugPrint('Error updating habit completion: $e');
                // Revert the UI state if the operation failed
                if (mounted) {
                  setState(() => _markAsCompleted = !_markAsCompleted);
                }
              }
            });
          },
        )
      ],
    ]);
  }

  @override
  void onSave() async {
    final localizations = AppLocalizations.of(context)!;

    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.titleRequired)),
      );
      return;
    }

    if ((_freqLabel == 'Weekly' || _freqLabel == 'Monthly') &&
        _selectedDays.isEmpty) {
      String message = _freqLabel == 'Weekly'
          ? localizations.selectWeekday
          : localizations.selectDayOfMonth;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);

    final frequency = _mapLabelToFrequency(_freqLabel);
    final customDays =
        (frequency == 7 || frequency == -1) ? _selectedDays : null;

    if (widget.existing == null) {
      // Adding a new habit
      await ctrl.addHabit(
        title: _titleC.text.trim(),
        description: _descC.text.trim(),
        frequency: frequency,
        customDays: customDays,
      );
    } else {
      // Updating an existing habit
      await ctrl.updateHabit(
        widget.existing!.id,
        _titleC.text.trim(),
        _descC.text.trim(),
        frequency,
        customDays,
        _markAsCompleted,
      );
    }
  }

  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteHabit(widget.existing!.id);
  }
}

// —— Task Editor —— //

class TaskEditorModal extends TrackingEditorModal {
  final TaskModel? existing;
  final String? initialStatus;
  final String? initialValue;
  const TaskEditorModal({
    super.key,
    required super.ref,
    this.existing,
    this.initialStatus,
    this.initialValue,
    DateTime? selectedDate,
  });

  @override
  TaskEditorModalState createState() => TaskEditorModalState();
}

class TaskEditorModalState extends TrackingEditorModalState<TaskEditorModal> {
  late TextEditingController _titleC, _descC;
  String _status = 'Pending';
  DateTime? _dueDate;
  DateTime? _completedAt;
  String? _estimatedTime;
  late int _priority;
  final List<SubtaskModel> _subtasks = [];
  bool _isLoadingSubtasks = false;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.existing?.title ?? '');
    _descC = TextEditingController(text: widget.existing?.description ?? '');
    _status = widget.existing?.status ?? 'Pending';
    _dueDate = widget.existing?.dueDate;
    _completedAt = widget.existing?.completedAt;
    _estimatedTime = widget.existing?.estimatedTime;
    _priority = widget.existing?.priority ?? 1;
    if (widget.initialStatus != null) {
      _status = widget.initialStatus!;
    }
    _startTime = widget.existing?.startTime;
    _endTime = widget.existing?.endTime;
  }

  // Helper method to get localized version of the status
  String _getLocalizedStatus(String status, AppLocalizations localizations) {
    switch (status) {
      case 'Pending':
        return localizations.pending;
      case 'In Progress':
        return localizations.inProgress;
      case 'Done':
        return localizations.done;
      default:
        return localizations.pending;
    }
  }

  // Helper method to convert localized status back to internal format
  String _getInternalStatus(
      String localizedStatus, AppLocalizations localizations) {
    if (localizedStatus == localizations.pending) return 'Pending';
    if (localizedStatus == localizations.inProgress) return 'In Progress';
    if (localizedStatus == localizations.done) return 'Done';
    return 'Pending';
  }

  Future<void> _pickDate(BuildContext context, bool isDueDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? _dueDate ?? now : _completedAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _completedAt = picked;
          // When setting a completion date, also update status to Done
          if (_status != 'Done') {
            _status = 'Done';
          }
        }
      });
    }
  }

  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    final now = TimeOfDay.now();
    final initialTime = isStartTime
        ? (_startTime != null ? TimeOfDay.fromDateTime(_startTime!) : now)
        : (_endTime != null ? TimeOfDay.fromDateTime(_endTime!) : now);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      // Convert TimeOfDay to DateTime preserving the date part
      final today = DateTime.now();
      final dateTime = DateTime(
          today.year, today.month, today.day, picked.hour, picked.minute);

      setState(() {
        if (isStartTime) {
          _startTime = dateTime;
        } else {
          _endTime = dateTime;
        }
      });
    }
  }

  Future<void> _generateSubtasks() async {
    final localizations = AppLocalizations.of(context)!;
    debugPrint('Generating subtasks...');
    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.titleRequiredForSubtasks)),
      );
      return;
    }

    setState(() => _isLoadingSubtasks = true);
    try {
      // First, create the parent task if it doesn't exist yet
      final ctrl = widget.ref.read(trackerControllerProvider);
      String taskId;

      if (widget.existing == null) {
        // Create a new task first, so we can attach subtasks to it
        taskId = ctrl.generateId();
        await ctrl.addTask(
          title: _titleC.text.trim(),
          description: _descC.text.trim(),
          status: 'Pending',
          dueDate: _dueDate,
          completedAt: _completedAt,
          estimatedTime: _estimatedTime,
          priority: _priority,
          subtasks: [], // No subtasks in the task model anymore
          startTime: _startTime,
          endTime: _endTime,
        );
      } else {
        // Update the existing task
        taskId = widget.existing!.id;
        await ctrl.updateTask(
          taskId,
          _titleC.text.trim(),
          _descC.text.trim(),
          _status,
          _dueDate,
          _completedAt,
          _estimatedTime,
          _priority,
          null, // No subtasks in the task model anymore
          _startTime,
          _endTime,
        );
      }

      // Get existing subtasks to determine the next order number
      final subtaskService = widget.ref.read(subtaskServiceProvider);
      final existingSubtasks = await subtaskService.getSubtasksForTask(taskId);
      int nextOrder = 0;

      if (existingSubtasks.isNotEmpty) {
        // Find the highest order number and add 1
        final maxOrder = existingSubtasks
            .map((subtask) => subtask.order)
            .where((order) => order != null)
            .fold<int>(0, (max, order) => order! > max ? order : max);
        nextOrder = maxOrder + 1;
      }

      // Now generate and add subtasks
      final magicTodo = widget.ref.read(magicTodoServiceProvider);
      final subtaskSuggestions = await magicTodo.divideTask(
        title: _titleC.text.trim(),
        description: _descC.text.trim(),
      );

      if (subtaskSuggestions.isNotEmpty) {
        // Mark the parent task as having subtasks
        final taskService = widget.ref.read(taskServiceProvider);
        final parentTask = await taskService.getTaskById(taskId);
        if (parentTask != null) {
          await taskService.updateTask(
              taskId, parentTask.copyWith(hasSubtasks: true));
        }

        // Create each subtask using the createSubtask method
        int totalMinutes = 0;
        for (int i = 0; i < subtaskSuggestions.length; i++) {
          final suggestion = subtaskSuggestions[i];

          // Create the subtask with proper order numbering
          await ctrl.createSubtask(
            taskId,
            suggestion.title,
            suggestion.rawTimeValue,
            nextOrder + i, // Start from nextOrder and increment
          );

          // Calculate time estimate if available
          if (suggestion.rawTimeValue != null &&
              suggestion.rawTimeValue!.isNotEmpty) {
            final String timeStr = suggestion.rawTimeValue!.toLowerCase();
            final RegExp numRegex = RegExp(r'(\d+)');
            final match = numRegex.firstMatch(timeStr);
            if (match != null) {
              int value = int.parse(match.group(1)!);
              if (timeStr.contains('second')) {
                value = (value / 60).ceil();
              } else if (timeStr.contains('hour')) {
                value *= 60;
              }
              totalMinutes += value;
            }
          }
        }

        // Refresh the subtask list for the parent task
        // widget.ref.refresh(subtaskStateNotifierProvider(taskId));

        // Update the parent task with the calculated total time
        if (totalMinutes > 0) {
          _estimatedTime = totalMinutes.toString();
          await ctrl.updateTask(
            taskId,
            _titleC.text.trim(),
            _descC.text.trim(),
            _status,
            _dueDate,
            _completedAt,
            _estimatedTime,
            _priority,
            null,
            _startTime,
            _endTime,
          );
        }

        // Close the modal
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.noSubtasksGenerated)),
        );
        return;
      }
    } catch (e) {
      debugPrint('Error generating subtasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(localizations.failedToGenerateSubtasks(e.toString()))),
      );
    } finally {
      setState(() => _isLoadingSubtasks = false);
    }
  }

  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;

    // Get localized status options
    final List<String> localizedStatusOptions = [
      localizations.pending,
      localizations.inProgress,
      localizations.done
    ];

    // Get localized version of current status
    final String localizedStatus = _getLocalizedStatus(_status, localizations);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleC,
              decoration: InputDecoration(labelText: '${localizations.title}*'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descC,
              decoration: InputDecoration(labelText: localizations.description),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: localizedStatus,
              decoration: InputDecoration(labelText: localizations.status),
              items: localizedStatusOptions
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    // Convert back to internal status representation
                    _status = _getInternalStatus(value, localizations);

                    // Automatically sync completion date with status
                    if (_status == 'Done') {
                      _completedAt ??= DateTime.now();
                    } else {
                      // Clear completion date when moving out of Done status
                      _completedAt = null;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? localizations.noDueDateSet
                        : '${localizations.due}: ${DateFormat.yMd().format(_dueDate!)}',
                  ),
                ),
                if (_dueDate != null)
                  TextButton(
                    onPressed: () => setState(() => _dueDate = null),
                    child: Text(localizations.clear),
                  ),
                TextButton(
                  onPressed: () => _pickDate(context, true),
                  child: Text(localizations.setDueDate),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Replace the existing completion status Row with this Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First show the completion status text
                Text(
                  _completedAt == null
                      ? localizations.notCompleted
                      : '${localizations.completed}: ${DateFormat.yMd().format(_completedAt!)}',
                ),
                const SizedBox(
                    height: 8), // Add spacing between text and buttons

                // Then show the buttons underneath
                Row(
                  children: [
                    if (_completedAt != null)
                      // Clear button when completed
                      Expanded(
                        child: TextButton(
                          onPressed: () => setState(() {
                            _completedAt = null;
                            // Also update status if it's "Done"
                            if (_status == 'Done') {
                              _status = 'In Progress';
                            }
                          }),
                          child: Text(localizations.clearCompletion),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _pickDate(context, false),
                        child: Text(localizations.setCompleted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${localizations.priority}:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _priority.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_priority',
                    onChanged: (value) =>
                        setState(() => _priority = value.toInt()),
                  ),
                ),
                Text('$_priority'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _startTime == null
                        ? localizations.noStartTime
                        : '${localizations.startTime} ${DateFormat.jm().format(_startTime!)}',
                  ),
                ),
                if (_startTime != null)
                  TextButton(
                    onPressed: () => setState(() => _startTime = null),
                    child: Text(localizations.clear),
                  ),
                TextButton(
                  onPressed: () => _pickTime(context, true),
                  child: Text(localizations.setStartTime),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _endTime == null
                        ? localizations.noEndTime
                        : '${localizations.endTime}: ${DateFormat.jm().format(_endTime!)}',
                  ),
                ),
                if (_endTime != null)
                  TextButton(
                    onPressed: () => setState(() => _endTime = null),
                    child: Text(localizations.clear),
                  ),
                TextButton(
                  onPressed: () => _pickTime(context, false),
                  child: Text(localizations.setEndTime),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: EstimatorWidget(
                    title: _titleC.text,
                    description: _descC.text,
                    onEstimateUpdated: (time, unit) {
                      setState(() {
                        // Store the original values without conversion
                        _estimatedTime = time;
                      });
                    },
                    initialValue: _estimatedTime?.toString(),
                  ),
                ),
              ],
            ),

            // Add this to show the estimation with units
            if (_estimatedTime != null && _estimatedTime!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                    '${localizations.estimatedTimeLabel}: $_estimatedTime!.'),
              ),
            const SizedBox(height: 16),

            // Second row - Subtasks
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localizations.breakIntoSubtasksPrompt),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isLoadingSubtasks
                            ? null
                            : () {
                                debugPrint("Generating subtasks");
                                _generateSubtasks();
                              },
                        child: _isLoadingSubtasks
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(localizations.breakIntoSubtasks),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onSave() async {
    final localizations = AppLocalizations.of(context)!;

    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.titleRequired)),
      );
      return;
    }

    // Capture all needed references before async operations
    final ctrl = widget.ref.read(trackerControllerProvider);

    // Fix completion logic: Ensure status and completedAt are synchronized
    DateTime? finalCompletedAt = _completedAt;
    String finalStatus = _status;

    if (_status == 'Done') {
      finalCompletedAt ??= DateTime.now();
    } else {
      finalCompletedAt = null;
    }

    if (finalCompletedAt != null && _status != 'Done') {
      finalStatus = 'Done';
    }

    try {
      // Pop the modal first to avoid disposal issues
      Navigator.of(context).pop();

      if (widget.existing == null) {
        await ctrl.addTask(
          title: _titleC.text.trim(),
          description: _descC.text.trim(),
          status: finalStatus,
          dueDate: _dueDate,
          completedAt: finalCompletedAt,
          estimatedTime: _estimatedTime,
          priority: _priority,
          subtasks: [],
          startTime: _startTime,
          endTime: _endTime,
        );
      } else {
        await ctrl.updateTask(
          widget.existing!.id,
          _titleC.text.trim(),
          _descC.text.trim(),
          finalStatus,
          _dueDate,
          finalCompletedAt,
          _estimatedTime,
          _priority,
          _subtasks,
          _startTime,
          _endTime,
        );

        // Schedule task if it has a start time
        if (_startTime != null && context.mounted) {
          await _scheduleTaskWithTimes(context);
        }
      }
    } catch (e) {
      debugPrint('Error saving task: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save task: $e')),
        );
      }
    }
  }

  @override
  String getDeleteLabel() =>
      widget.existing?.title ?? AppLocalizations.of(context)!.thisTask;

  @override
  String getTitle() => AppLocalizations.of(context)!.task;

  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteTask(widget.existing!.id);
  }

  Future<void> _scheduleTaskWithTimes(BuildContext context) async {
    if (_startTime != null) {
      final TimeOfDay startTimeOfDay = TimeOfDay(
        hour: _startTime!.hour,
        minute: _startTime!.minute,
      );

      // End time is optional now
      TimeOfDay? endTimeOfDay;
      if (_endTime != null) {
        endTimeOfDay = TimeOfDay(
          hour: _endTime!.hour,
          minute: _endTime!.minute,
        );
      }

      // Use the new method signature with optional end time and await it
      await widget.ref
          .read(timeBlockControllerProvider.notifier)
          .scheduleTask(widget.existing!, startTimeOfDay, endTimeOfDay);
    }
  }
}

// —— Subtask Editor —— //
class SubtaskEditorModal extends TrackingEditorModal<SubtaskModel> {
  // Specify SubtaskModel as the generic type
  final TaskModel parentTask;
  final SubtaskModel subtask; // This is the 'existing' item

  const SubtaskEditorModal({
    super.key,
    required super.ref,
    required this.parentTask,
    required this.subtask,
  }) : super(existing: subtask); // Pass the subtask to 'existing'

  @override
  SubtaskEditorModalState createState() => SubtaskEditorModalState();
}

class SubtaskEditorModalState
    extends TrackingEditorModalState<SubtaskEditorModal> {
  late TextEditingController _titleC;
  late TextEditingController _descC;
  late bool _completed;
  late String _status; // Add status field
  DateTime? _startTime;
  DateTime? _endTime;
  String _rawTimeUnit = '';
  String _rawTimeValue = '';

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.subtask.title);
    _descC = TextEditingController();
    _completed = widget.subtask.completed;
    _status = widget.subtask.status ?? 'todo'; // Initialize status
    _rawTimeValue = widget.subtask.rawTimeValue ?? '';
  }

  // Helper method to get localized version of the status
  String _getLocalizedStatus(String status, AppLocalizations localizations) {
    switch (status.toLowerCase()) {
      case 'done':
        return localizations.done;
      case 'in_progress':
        return localizations.inProgress;
      case 'todo':
      default:
        return localizations.todo;
    }
  }

  // Helper method to convert localized status back to internal format
  String _getInternalStatus(
      String localizedStatus, AppLocalizations localizations) {
    if (localizedStatus == localizations.done) return 'done';
    if (localizedStatus == localizations.inProgress) return 'in_progress';
    if (localizedStatus == localizations.todo) return 'todo';
    return 'todo';
  }

  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;

    // Get localized status options
    final List<String> localizedStatusOptions = [
      localizations.todo,
      localizations.inProgress,
      localizations.done
    ];

    // Get localized version of current status
    final String localizedStatus = _getLocalizedStatus(_status, localizations);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(localizations.subtaskFor(widget.parentTask.title),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: _titleC,
          decoration: InputDecoration(labelText: '${localizations.title}*'),
          maxLines: 5,
          autofocus: true,
        ),
        const SizedBox(height: 12),

        // Add status dropdown with simplified logic
        DropdownButtonFormField<String>(
          value: localizedStatus,
          decoration: InputDecoration(labelText: localizations.status),
          items: localizedStatusOptions
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                // Convert back to internal status representation
                _status = _getInternalStatus(value, localizations);

                // Simplified sync logic: only sync completion when status is done
                if (_status == 'done') {
                  _completed = true;
                } else if (_status == 'todo') {
                  _completed = false;
                }
                // For 'in_progress', leave completion state as is
              });
            }
          },
        ),

        const SizedBox(height: 12),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                _startTime == null
                    ? localizations.noStartTime
                    : '${localizations.startTime} ${DateFormat.jm().format(_startTime!)}',
              ),
            ),
            if (_startTime != null)
              TextButton(
                onPressed: () => setState(() => _startTime = null),
                child: Text(localizations.clear),
              ),
            TextButton(
              onPressed: () => _pickTime(context, true),
              child: Text(localizations.setStartTime),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                _endTime == null
                    ? localizations.noEndTime
                    : '${localizations.endTime}: ${DateFormat.jm().format(_endTime!)}',
              ),
            ),
            if (_endTime != null)
              TextButton(
                onPressed: () => setState(() => _endTime = null),
                child: Text(localizations.clear),
              ),
            TextButton(
              onPressed: () => _pickTime(context, false),
              child: Text(localizations.setEndTime),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // EstimatorWidget with updated callback - no conversion
        Row(
          children: [
            Expanded(
              child: EstimatorWidget(
                title: _titleC.text,
                description: _descC.text,
                onEstimateUpdated: (time, unit) {
                  setState(() {
                    // Store the raw values from API without conversion
                    _rawTimeValue = time;
                    _rawTimeUnit = unit;
                  });
                },
                initialValue: _rawTimeValue.isNotEmpty ? _rawTimeValue : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        CheckboxListTile(
          title: Text(localizations.completed),
          value: _completed,
          onChanged: (value) => setState(() {
            _completed = value ?? false;

            // Simplified sync logic for checkbox
            if (_completed) {
              _status = 'done';
            } else if (_status == 'done') {
              _status = 'todo';
            }
            // If status is 'in_progress', leave it as is when unchecking
          }),
        ),
      ],
    );
  }

  @override
  void onSave() async {
    final localizations = AppLocalizations.of(context)!;
    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(localizations.titleRequired)));
      return;
    }

    // Capture all needed references before async operations
    final ctrl = widget.ref.read(trackerControllerProvider);
    final subtaskService = widget.ref.read(subtaskServiceProvider);
    final taskService = widget.ref.read(taskServiceProvider);

    try {
      // Pop the modal first
      Navigator.of(context).pop();

      await ctrl.updateSubtask(
        widget.subtask.taskId,
        widget.subtask,
        _titleC.text.trim(),
        _completed,
        _status,
        _rawTimeValue,
        _startTime,
        _endTime,
      );

      // Update parent task estimate calculation
      final allSubtasks =
          await subtaskService.getSubtasksForTask(widget.subtask.taskId);

      if (allSubtasks.isNotEmpty &&
          allSubtasks.every((st) => st.rawTimeValue?.isNotEmpty == true)) {
        int totalSeconds = 0;
        final regex = RegExp(r'^(\d+(?:\.\d+)?)\s*(\w+)$');

        for (final st in allSubtasks) {
          final raw = st.rawTimeValue!.trim();
          final match = regex.firstMatch(raw);
          if (match != null) {
            final value = double.parse(match.group(1)!);
            final unit = match.group(2)!.toLowerCase();
            if (unit.startsWith('h')) {
              totalSeconds += (value * 3600).round();
            } else if (unit.startsWith('min')) {
              totalSeconds += (value * 60).round();
            } else {
              totalSeconds += value.round();
            }
          }
        }

        String sumEstimate;
        if (totalSeconds >= 3600) {
          final hours = totalSeconds / 3600;
          sumEstimate =
              '${hours.toStringAsFixed((hours % 1 == 0) ? 0 : 1)} ${localizations.hours}';
        } else if (totalSeconds >= 60) {
          final minutes = totalSeconds / 60;
          sumEstimate =
              '${minutes.toStringAsFixed((minutes % 1 == 0) ? 0 : 1)} ${localizations.minutes}';
        } else {
          sumEstimate = '$totalSeconds ${localizations.seconds}';
        }

        final parentTaskData =
            await taskService.getTaskById(widget.subtask.taskId);

        if (parentTaskData != null) {
          await ctrl.updateTask(
            parentTaskData.id,
            parentTaskData.title,
            parentTaskData.description,
            parentTaskData.status,
            parentTaskData.dueDate,
            parentTaskData.completedAt,
            sumEstimate,
            parentTaskData.priority,
            null,
            parentTaskData.startTime,
            parentTaskData.endTime,
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving subtask: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save subtask: $e')),
        );
      }
    }
  }

  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteSubtask(widget.subtask.id, widget.subtask.taskId);
    // widget.ref.refresh(subtaskStateNotifierProvider(widget.subtask.taskId));
  }

  @override
  String getDeleteLabel() => widget.subtask.title;

  @override
  String getTitle() => AppLocalizations.of(context)!.subtask;

  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    final now = TimeOfDay.now();
    final initialTime = isStartTime
        ? (_startTime != null ? TimeOfDay.fromDateTime(_startTime!) : now)
        : (_endTime != null ? TimeOfDay.fromDateTime(_endTime!) : now);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      // Convert TimeOfDay to DateTime preserving the date part
      final today = DateTime.now();
      final dateTime = DateTime(
          today.year, today.month, today.day, picked.hour, picked.minute);

      setState(() {
        if (isStartTime) {
          _startTime = dateTime;
        } else {
          _endTime = dateTime;
        }
      });
    }
  }
}

// —— Mood Editor —— //

class MoodLevelEditorModal extends TrackingEditorModal {
  final MoodModel? existing;
  const MoodLevelEditorModal({
    super.key,
    required super.ref,
    this.existing,
  });
  @override
  MoodLevelEditorModalState createState() => MoodLevelEditorModalState();
}

class MoodLevelEditorModalState
    extends TrackingEditorModalState<MoodLevelEditorModal> {
  int? _value;
  late TextEditingController _notesC;

  @override
  void initState() {
    super.initState();
    _value = widget.existing?.moodLevel;
    _notesC = TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: List.generate(10, (i) {
          final v = i + 1;
          return InkWell(
            onTap: () => setState(() => _value = v),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _value == v
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Color.alphaBlend(
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(204),
                            Colors.transparent)
                        : Color.alphaBlend(
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(77),
                            Colors.transparent))
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                  child: Text('$v',
                      key: ValueKey('moodValue_$v'))), // Add Key here
            ),
          );
        }),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _notesC,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: localizations.notes,
          hintText: localizations.moodNotesHint,
          border: const OutlineInputBorder(),
        ),
      ),
    ]);
  }

  @override
  void onSave() async {
    final localizations = AppLocalizations.of(context)!;
    debugPrint(
        "[MoodLevelEditorModal.onSave] Entered onSave. Value: $_value. Existing: ${widget.existing != null}");

    if (_value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(localizations.pleaseSelectA(localizations.mood))),
      );
      debugPrint("[MoodLevelEditorModal.onSave] Value is null, returning.");
      return;
    }

    // Capture the controller reference before any async operations
    final ctrl = widget.ref.read(trackerControllerProvider);
    debugPrint(
        "[MoodLevelEditorModal.onSave] Controller obtained. Attempting DB operation.");

    try {
      // Pop the modal first to avoid disposal issues
      Navigator.of(context).pop();

      if (widget.existing == null) {
        debugPrint("[MoodLevelEditorModal.onSave] Adding new mood.");
        await ctrl.addMood(_value!, _notesC.text.trim());
        debugPrint("[MoodLevelEditorModal.onSave] addMood completed.");
      } else {
        debugPrint(
            "[MoodLevelEditorModal.onSave] Updating existing mood ID: ${widget.existing!.id}.");
        await ctrl.updateMood(
          widget.existing!.id,
          _value!,
          _notesC.text.trim(),
        );
        debugPrint(
            "[MoodLevelEditorModal.onSave] updateMood completed for ID: ${widget.existing!.id}.");
      }
    } catch (e, s) {
      debugPrint(
          "[MoodLevelEditorModal.onSave] Caught error during DB operation: $e. Stack: $s");
      // Show error in a different context since modal is already popped
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(localizations.failedToSaveItem(localizations.mood))),
        );
      }
    }
    debugPrint("[MoodLevelEditorModal.onSave] Exiting onSave method.");
  }

  @override
  String getDeleteLabel() {
    final localizations = AppLocalizations.of(context)!;
    return widget.existing?.notes?.isNotEmpty == true
        ? widget.existing!.notes!
        : localizations.thisMoodEntry;
  }

  @override
  String getTitle() {
    final localizations = AppLocalizations.of(context)!;
    return localizations.mood;
  }

  @override
  void onDelete() async {
    // This onDelete is called from the base TrackingEditorModal's delete button.
    // It should handle its own try-catch for the delete operation and pop.
    final localizations = AppLocalizations.of(context)!;
    final ctrl = widget.ref.read(trackerControllerProvider);
    try {
      if (widget.existing != null) {
        await ctrl.deleteMood(widget.existing!.id, widget.ref);
        if (mounted) {
          Navigator.of(context)
              .pop(); // Pop editor modal after successful delete
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(localizations.failedToDeleteItem(localizations.mood))),
        );
      }
    }
  }
}

// —— Energy Editor —— //

class EnergyLevelEditorModal extends TrackingEditorModal {
  final EnergyModel? existing;
  const EnergyLevelEditorModal({
    super.key,
    required super.ref,
    this.existing,
  });
  @override
  EnergyLevelEditorModalState createState() => EnergyLevelEditorModalState();
}

class EnergyLevelEditorModalState
    extends TrackingEditorModalState<EnergyLevelEditorModal> {
  int? _value;
  late TextEditingController _notesC;

  @override
  void initState() {
    super.initState();
    _value = widget.existing?.energyLevel;
    _notesC = TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: List.generate(10, (i) {
          final v = i + 1;
          return InkWell(
            onTap: () => setState(() => _value = v),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _value == v
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Color.alphaBlend(
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(204),
                            Colors.transparent)
                        : Color.alphaBlend(
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(77),
                            Colors.transparent))
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('$v')),
            ),
          );
        }),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _notesC,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: localizations.notes,
          hintText: localizations.energyNotesHint,
          border: const OutlineInputBorder(),
        ),
      ),
    ]);
  }

  @override
  void onSave() async {
    if (_value == null) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(localizations.pleaseSelectA(localizations.energy))),
      );
      return;
    }

    // Capture the controller reference before any async operations
    final ctrl = widget.ref.read(trackerControllerProvider);

    try {
      // Pop the modal first
      Navigator.of(context).pop();

      if (widget.existing == null) {
        await ctrl.addEnergy(_value ?? 1, _notesC.text.trim());
      } else {
        await ctrl.updateEnergy(
          widget.existing!.id,
          _value ?? 1,
          _notesC.text.trim(),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save energy: $e')),
        );
      }
    }
  }

  @override
  String getDeleteLabel() => widget.existing?.notes?.isNotEmpty == true
      ? widget.existing!.notes!
      : AppLocalizations.of(context)!.thisEnergyEntry;

  @override
  String getTitle() => AppLocalizations.of(context)!.energy;

  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteEnergy(widget.existing!.id, widget.ref);
  }
}

// —— Medication Editor —— //
class MedicationEditorModal extends TrackingEditorModal {
  final MedicationModel? existing;
  const MedicationEditorModal({
    super.key,
    required super.ref,
    this.existing,
  });

  @override
  MedicationEditorModalState createState() => MedicationEditorModalState();
}

class MedicationEditorModalState
    extends TrackingEditorModalState<MedicationEditorModal> {
  final _nameC = TextEditingController();
  final _doseC = TextEditingController();
  String _unit = 'mg';
  int _takenTimes = 0;
  final _customUnitC = TextEditingController();
  bool _isCustomUnit = false;
  String _freqLabel = 'Daily';
  final _monthlyDayC = TextEditingController();
  final Set<int> _selectedDays = {};
  int _timesPerDay = 1;
  final _customTimesC = TextEditingController();
  bool _isCustomTimes = false;
  bool _markAsTaken = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameC.text = widget.existing!.name;
      _doseC.text = widget.existing!.dose.toString();
      // Update taken status initialization
      final selectedDate = widget.ref.read(selectedDateProvider);
      _takenTimes = widget.existing!.getTakenCountForDate(selectedDate);
      _markAsTaken = _takenTimes > 0;

      // Check if the medication was taken today
      // Use getTakenCountForDate method instead of lastTaken
      _markAsTaken = widget.existing!.getTakenCountForDate(selectedDate) > 0;

      // Check if the unit is one of the predefined ones
      final predefinedUnits = ['ml', 'mg', 'g', 'tablets'];
      if (predefinedUnits.contains(widget.existing!.unit)) {
        _unit = widget.existing!.unit;
      } else {
        // If it's a custom unit
        _isCustomUnit = true;
        _customUnitC.text = widget.existing!.unit;
        _unit = 'custom';
      }
      _timesPerDay = widget.existing!.timesPerDay;

      // Set frequency and custom days
      switch (widget.existing!.frequency) {
        case 'daily':
          _freqLabel = 'Daily';
          break;
        case 'weekly':
          _freqLabel = 'Weekly';
          if (widget.existing!.customDays != null) {
            _selectedDays.addAll(widget.existing!.customDays!);
          }
          break;
        case 'monthly':
          _freqLabel = 'Monthly';
          if (widget.existing!.customDays != null) {
            _selectedDays.addAll(widget.existing!.customDays!);
          }
          break;
      }
    }
  }

  String _mapLabelToFrequency(String label) {
    final localizations = AppLocalizations.of(context)!;

    if (label == localizations.daily) return 'daily';
    if (label == localizations.weekly) return 'weekly';
    if (label == localizations.monthly) return 'monthly';
    return 'daily';
  }

  // Fix: Add this helper method to map internal frequency to localized string
  String _getLocalizedFrequency() {
    final localizations = AppLocalizations.of(context)!;

    switch (_freqLabel) {
      case 'Daily':
        return localizations.daily;
      case 'Weekly':
        return localizations.weekly;
      case 'Monthly':
        return localizations.monthly;
      default:
        return localizations.daily;
    }
  }

  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;
    final predefinedUnits = ['ml', 'mg', 'g', 'tablets', 'custom'];
    String getLocalizedUnit(String unit, AppLocalizations loc) {
      switch (unit) {
        case 'ml':
          return 'ml';
        case 'mg':
          return 'mg';
        case 'g':
          return 'g';
        case 'tablets':
          return loc.tablets;
        case 'custom':
          return loc.custom;
        default:
          return unit;
      }
    }

    // Fix: Get the correctly localized frequency value
    final localizedFreq = _getLocalizedFrequency();

    // Fix: Define the available frequency options
    final freqOptions = [
      localizations.daily,
      localizations.weekly,
      localizations.monthly
    ];

    return Column(mainAxisSize: MainAxisSize.min, children: [
      TextFormField(
        controller: _nameC,
        decoration: InputDecoration(
            labelText: localizations.name), // Fix: Use expected test label
      ),
      const SizedBox(height: 16),

      // Fix: Replace the overflowing Row with responsive layout
      LayoutBuilder(
        builder: (context, constraints) {
          // Use Column layout for very narrow screens to prevent overflow
          if (constraints.maxWidth < 300) {
            return Column(
              children: [
                TextFormField(
                  controller: _doseC,
                  decoration: InputDecoration(labelText: localizations.dose),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                if (_isCustomUnit)
                  TextFormField(
                    controller: _customUnitC,
                    decoration:
                        InputDecoration(labelText: localizations.customUnit),
                    onChanged: (value) => setState(() {
                      _unit = value;
                    }),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _unit,
                    decoration: InputDecoration(labelText: localizations.unit),
                    items: predefinedUnits
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(getLocalizedUnit(e, localizations)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() {
                      if (v == 'custom') {
                        _isCustomUnit = true;
                        _customUnitC.text = _unit == 'custom' ? '' : _unit;
                      } else {
                        _isCustomUnit = false;
                        _unit = v!;
                      }
                    }),
                  ),
              ],
            );
          } else {
            // Use Row layout for wider screens but with Expanded widgets
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _doseC,
                    decoration: InputDecoration(labelText: localizations.dose),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _isCustomUnit
                      ? TextFormField(
                          controller: _customUnitC,
                          decoration: InputDecoration(
                              labelText: localizations.customUnit),
                          onChanged: (value) => setState(() {
                            _unit = value;
                          }),
                        )
                      : DropdownButtonFormField<String>(
                          value: _unit,
                          decoration:
                              InputDecoration(labelText: localizations.unit),
                          items: predefinedUnits
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                        getLocalizedUnit(e, localizations)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() {
                            if (v == 'custom') {
                              _isCustomUnit = true;
                              _customUnitC.text =
                                  _unit == 'custom' ? '' : _unit;
                            } else {
                              _isCustomUnit = false;
                              _unit = v!;
                            }
                          }),
                        ),
                ),
              ],
            );
          }
        },
      ),
      const SizedBox(height: 16),

      // Fix: Use proper dropdown form field for frequency
      DropdownButtonFormField<String>(
        value: localizedFreq,
        decoration: InputDecoration(labelText: localizations.frequency),
        items: freqOptions
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() {
          // Fix: Map the localized value back to internal representation
          if (v == localizations.daily) {
            _freqLabel = 'Daily';
          } else if (v == localizations.weekly) {
            _freqLabel = 'Weekly';
          } else if (v == localizations.monthly) {
            _freqLabel = 'Monthly';
          }
          _selectedDays.clear();
        }),
      ),

      if (_freqLabel == 'Weekly') ...[
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: List.generate(7, (i) {
            final weekday = i + 1;
            return FilterChip(
              label: Text(DateFormat('EEEE', localizations.localeName)
                  .format(DateTime(2024, 1, weekday))),
              selected: _selectedDays.contains(weekday),
              onSelected: (selected) => setState(() {
                if (selected) {
                  _selectedDays.add(weekday);
                } else {
                  _selectedDays.remove(weekday);
                }
              }),
            );
          }),
        ),
      ] else if (_freqLabel == 'Monthly') ...[
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _monthlyDayC,
                decoration: InputDecoration(
                  labelText: localizations.dayOfMonth,
                  hintText: localizations.enterDayHint,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final day = int.tryParse(_monthlyDayC.text);
                if (day != null && day >= 1 && day <= 31) {
                  setState(() {
                    _selectedDays.add(day);
                    _monthlyDayC.clear();
                  });
                }
              },
              tooltip: localizations.addDay,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: (_selectedDays.toList()..sort())
              .map((day) => Chip(
                    label: Text(localizations.dayNumber(day.toString())),
                    onDeleted: () => setState(() => _selectedDays.remove(day)),
                  ))
              .toList(),
        ),
      ],

      const SizedBox(height: 16),

      // Fix: Make times per day section responsive
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 300) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.timesPerDay),
                const SizedBox(height: 8),
                if (_isCustomTimes)
                  TextFormField(
                    controller: _customTimesC,
                    decoration:
                        InputDecoration(labelText: localizations.customValue),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final times = int.tryParse(value);
                      if (times != null && times > 0) {
                        setState(() => _timesPerDay = times);
                      }
                    },
                  )
                else
                  DropdownButtonFormField<dynamic>(
                    value:
                        _timesPerDay > 5 ? localizations.custom : _timesPerDay,
                    decoration:
                        InputDecoration(labelText: localizations.timesPerDay),
                    items: [
                      ...List.generate(
                        5,
                        (i) => DropdownMenuItem(
                            value: i + 1, child: Text('${i + 1}')),
                      ),
                      DropdownMenuItem(
                          value: localizations.custom,
                          child: Text(localizations.custom)),
                    ],
                    onChanged: (v) => setState(() {
                      if (v == localizations.custom) {
                        _isCustomTimes = true;
                        _customTimesC.text = _timesPerDay.toString();
                      } else {
                        _isCustomTimes = false;
                        _timesPerDay = v as int;
                      }
                    }),
                  ),
              ],
            );
          } else {
            return Row(
              children: [
                Text(localizations.timesPerDay),
                const SizedBox(width: 16),
                Expanded(
                  child: _isCustomTimes
                      ? TextFormField(
                          controller: _customTimesC,
                          decoration: InputDecoration(
                              labelText: localizations.customValue),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final times = int.tryParse(value);
                            if (times != null && times > 0) {
                              setState(() => _timesPerDay = times);
                            }
                          },
                        )
                      : DropdownButtonFormField<dynamic>(
                          value: _timesPerDay > 5
                              ? localizations.custom
                              : _timesPerDay,
                          items: [
                            ...List.generate(
                              5,
                              (i) => DropdownMenuItem(
                                  value: i + 1, child: Text('${i + 1}')),
                            ),
                            DropdownMenuItem(
                                value: localizations.custom,
                                child: Text(localizations.custom)),
                          ],
                          onChanged: (v) => setState(() {
                            if (v == localizations.custom) {
                              _isCustomTimes = true;
                              _customTimesC.text = _timesPerDay.toString();
                            } else {
                              _isCustomTimes = false;
                              _timesPerDay = v as int;
                            }
                          }),
                        ),
                ),
              ],
            );
          }
        },
      ),

      if (widget.existing != null) ...[
        const SizedBox(height: 16),
        if (_timesPerDay <= 1)
          CheckboxListTile(
            title: Text(localizations.markAsTaken),
            value: _markAsTaken,
            onChanged: (v) => setState(() => _markAsTaken = v!),
          )
        else ...[
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.unitsTaken),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: _takenTimes > 0
                        ? () => setState(() => _takenTimes--)
                        : null,
                  ),
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: Text(
                        '$_takenTimes / $_timesPerDay',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _takenTimes < _timesPerDay
                        ? () => setState(() => _takenTimes++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress indicator
              LinearProgressIndicator(
                value: _timesPerDay > 0 ? _takenTimes / _timesPerDay : 0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                    _takenTimes >= _timesPerDay ? Colors.green : Colors.blue),
              ),
            ],
          ),
        ],
      ],
    ]);
  }

  @override
  void onSave() async {
    final localizations = AppLocalizations.of(context)!;

    if (_nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.nameRequired)),
      );
      return;
    }

    if (_doseC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.doseRequired)),
      );
      return;
    }

    if ((_freqLabel == 'Weekly' || _freqLabel == 'Monthly') &&
        _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.selectAtLeastOneDay)),
      );
      return;
    }

    // Guard against async gaps
    if (!mounted) return;
    Navigator.of(context).pop();

    final ctrl = widget.ref.read(trackerControllerProvider);
    final frequency = _mapLabelToFrequency(_freqLabel);
    final customDays = (frequency == 'weekly' || frequency == 'monthly')
        ? _selectedDays.toList()
        : null;
    final unitToSave = _isCustomUnit ? _customUnitC.text : _unit;

    if (widget.existing == null) {
      // Creating new medication
      await ctrl.addMedication(
        name: _nameC.text.trim(),
        dose: double.parse(_doseC.text),
        unit: unitToSave,
        frequency: frequency,
        customDays: customDays,
        timesPerDay: _timesPerDay,
      );
    } else {
      // Updating existing medication details
      // First update the medication details
      await ctrl.updateMedicationDetails(
        id: widget.existing!.id,
        name: _nameC.text.trim(),
        dose: double.parse(_doseC.text),
        unit: unitToSave,
        frequency: frequency,
        customDays: customDays,
        timesPerDay: _timesPerDay,
      );

      // Then update the taken status for today if changed
      final selectedDate = widget.ref.read(selectedDateProvider);
      final currentTakenCount =
          widget.existing!.getTakenCountForDate(selectedDate);

      if (_timesPerDay <= 1) {
        // Simple checkbox case
        final shouldBeTaken = _markAsTaken;
        final isTaken = currentTakenCount > 0;

        if (shouldBeTaken != isTaken) {
          await ctrl.updateMedication(
            id: widget.existing!.id,
            isCompleted: shouldBeTaken,
            forDate: selectedDate,
          );
        }
      } else {
        // Multiple times per day case
        if (_takenTimes != currentTakenCount) {
          final isCompleted = _takenTimes >= _timesPerDay;
          await ctrl.updateMedication(
            id: widget.existing!.id,
            isCompleted: isCompleted,
            forDate: selectedDate,
          );
        }
      }
    }
  }

  @override
  String getDeleteLabel() =>
      widget.existing?.name ?? AppLocalizations.of(context)!.thisMedication;

  @override
  String getTitle() => AppLocalizations.of(context)!.medication;

  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteMedication(widget.existing!.id);
  }
}
