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
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/services/estimator_service.dart';
import 'package:spiceease/data/services/magic_todo_service.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'tracker_controller.dart';

// —— Base Editor Modal —— //

abstract class TrackingEditorModal<T> extends StatefulWidget {
  const TrackingEditorModal({Key? key, required this.ref, this.existing})
      : super(key: key);
  final WidgetRef ref;
  final T? existing;
  @override
  TrackingEditorModalState createState();
}

abstract class TrackingEditorModalState<T extends TrackingEditorModal>
    extends State<T> {
  Widget buildForm();
  void onSave();
  void onDelete() {}

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing != null
                    ? localizations.editTitle(getTitle())
                    : localizations.newTitle(getTitle()),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              buildForm(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.existing != null)
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(localizations
                                .deleteConfirmationTitle(getTitle())),
                            content: Text(localizations
                                .deleteConfirmationMessage(getDeleteLabel())),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(localizations.cancel,
                                    style: TextStyle(color: Colors.blueAccent)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onDelete();
                                },
                                child: Text(
                                  localizations.delete,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        localizations.delete,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(localizations.cancel,
                        style: TextStyle(color: Colors.blueAccent)),
                  ),
                  const SizedBox(width: 12),
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

  String getDeleteLabel() => 'this item'; // Override this in each modal
  String getTitle() => 'Item';
}

// —— Symptom Editor —— //

class SymptomEditorModal extends TrackingEditorModal {
  final SymptomModel? existing;
  const SymptomEditorModal({
    Key? key,
    required WidgetRef ref,
    this.existing,
  }) : super(key: key, ref: ref);
  @override
  _SymptomEditorModalState createState() => _SymptomEditorModalState();
}

class _SymptomEditorModalState
    extends TrackingEditorModalState<SymptomEditorModal> {
  late TextEditingController _nameC;
  final _customCatC = TextEditingController();
  String _category = 'Physical';
  bool _isCustomCategory = false;
  int _severity = 1;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.existing?.name ?? '');

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
      _severity = widget.existing?.severity ?? 1;
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
        Row(
          children: [
            Text('${localizations.category}:'),
            const SizedBox(width: 16),
            if (_isCustomCategory)
              Expanded(
                child: TextFormField(
                  controller: _customCatC,
                  decoration:
                      InputDecoration(labelText: localizations.customCategory),
                  onChanged: (value) => setState(() => _category = value),
                ),
              )
            else
              DropdownButton<String>(
                value: localizedCategory,
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
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('${localizations.severity}:'),
            Expanded(
              child: Slider(
                min: 1,
                max: 10,
                divisions: 9,
                value: _severity.toDouble(),
                label: '$_severity',
                onChanged: (v) => setState(() => _severity = v.round()),
              ),
            ),
            Text('$_severity'),
          ],
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
      );
    } else {
      await ctrl.updateSymptom(
        widget.existing!.id,
        _nameC.text.trim(),
        categoryToSave,
        _severity,
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
    Key? key,
    required WidgetRef ref,
    this.existing,
  }) : super(key: key, ref: ref);

  @override
  _HabitEditorModalState createState() => _HabitEditorModalState();
}

class _HabitEditorModalState
    extends TrackingEditorModalState<HabitEditorModal> {
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
      if (widget.existing != null) ...[
        const SizedBox(height: 12),
        CheckboxListTile(
          title: Text(localizations.markAsCompleted),
          value: _markAsCompleted,
          onChanged: (value) async {
            setState(() {
              _markAsCompleted = value ?? false;
              print('Habit completion changed to: $_markAsCompleted');
            });

            // Update the habit immediately when toggled
            final ctrl = widget.ref.read(trackerControllerProvider);
            final habit = widget.existing!;

            // Toggle completion and recalculate nextDueDate
            habit.toggleCompletion(isCompleted: _markAsCompleted);

            // Update the habit in Firestore
            await ctrl.updateHabit(
              habit.id,
              habit.title,
              habit.description,
              habit.frequency,
              habit.customDays,
              markAsCompleted: _markAsCompleted,
            );

            print("Habit after recalculating nextDueDate:");
            print(habit.toMap());
          },
        ),
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
        markAsCompleted: _markAsCompleted,
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

//TODO: task estimation is not working properly.

class TaskEditorModal extends TrackingEditorModal {
  final TaskModel? existing;
  final String? initialStatus;
  final String? initialValue;
  const TaskEditorModal({
    Key? key,
    required WidgetRef ref,
    this.existing,
    this.initialStatus,
    this.initialValue,
    DateTime? selectedDate,
  }) : super(key: key, ref: ref);

  @override
  _TaskEditorModalState createState() => _TaskEditorModalState();
}

class _TaskEditorModalState extends TrackingEditorModalState<TaskEditorModal> {
  late TextEditingController _titleC, _descC;
  String _status = 'Pending';
  DateTime? _dueDate;
  DateTime? _completedAt;
  String? _estimatedTime;
  late int _priority;
  List<SubtaskModel> _subtasks = [];
  bool _isLoadingSubtasks = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.ref
          .read(
              taskStateNotifierProvider(widget.ref.watch(selectedDateProvider))
                  .notifier)
          .fetchTasks();
    });
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
        }
      });
    }
  }

  Future<void> _generateSubtasks() async {
    final localizations = AppLocalizations.of(context)!;
    print('Generating subtasks...');
    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.titleRequiredForSubtasks)),
      );
      return;
    }

    setState(() => _isLoadingSubtasks = true);
    try {
      final magicTodo = widget.ref.read(magicTodoServiceProvider);
      final subtasks = await magicTodo.divideTask(
        title: _titleC.text.trim(),
        description: _descC.text.trim(),
      );

      print(subtasks);
      if (subtasks.isNotEmpty) {
        setState(() {
          _subtasks = subtasks;

          // Calculate the total estimated time from subtasks
          int totalMinutes = 0;

          for (var subtask in subtasks) {
            if (subtask.rawTimeValue != null &&
                subtask.rawTimeValue!.isNotEmpty) {
              // Parse the human-readable time string
              final String timeStr = subtask.rawTimeValue!.toLowerCase();

              // Extract the numeric value using a regex
              final RegExp numRegex = RegExp(r'(\d+)');
              final match = numRegex.firstMatch(timeStr);
              if (match != null) {
                int value = int.parse(match.group(1)!);

                // Convert to minutes based on the unit
                if (timeStr.contains('second')) {
                  value = (value / 60).ceil(); // Convert seconds to minutes
                } else if (timeStr.contains('hour')) {
                  value *= 60; // Convert hours to minutes
                }

                totalMinutes += value;
              }
            }
          }

          // Update main task estimated time in minutes
          _estimatedTime = totalMinutes.toString();
        });

        final ctrl = widget.ref.read(trackerControllerProvider);
        if (widget.existing == null) {
          // Create a new task (with subtasks)
          await ctrl.addTask(
            title: _titleC.text.trim(),
            description: _descC.text.trim(),
            status: 'Pending',
            dueDate: null,
            completedAt: null,
            estimatedTime: _estimatedTime,
            priority: 1,
            subtasks: subtasks,
          );
        } else {
          // Update existing task to attach newly generated subtasks
          await ctrl.updateTask(
            widget.existing!.id,
            _titleC.text.trim(),
            _descC.text.trim(),
            widget.existing!.status,
            widget.existing!.dueDate,
            widget.existing!.completedAt,
            _estimatedTime,
            widget.existing!.priority,
            subtasks,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.noSubtasksGenerated)),
        );
        return;
      }

      Navigator.pop(context);
    } catch (e) {
      print('Error generating subtasks: $e');
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
                TextButton(
                  onPressed: () => _pickDate(context, true),
                  child: Text(localizations.setDueDate),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _completedAt == null
                        ? localizations.notCompleted
                        : '${localizations.completed}: ${DateFormat.yMd().format(_completedAt!)}',
                  ),
                ),
                Row(
                  children: [
                    if (_completedAt != null)
                      // Add a clear button when completed
                      TextButton(
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
                    TextButton(
                      onPressed: () => _pickDate(context, false),
                      child: Text(localizations.setCompleted),
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
                    '${localizations.estimatedTimeLabel}: ${_estimatedTime}'),
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
                                print("Generating subtasks");
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

    // Fix completion logic: Set completedAt based on status
    if (_status == 'Done') {
      // If status is "Done" but no completion date is set, use current time
      _completedAt ??= DateTime.now();
    } else {
      // If status is not "Done", clear the completion date
      _completedAt = null;
    }

    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);

    if (widget.existing == null) {
      await ctrl.addTask(
        title: _titleC.text.trim(),
        description: _descC.text.trim(),
        status: _status,
        dueDate: _dueDate,
        completedAt: _completedAt, // This will be null if not completed
        estimatedTime: _estimatedTime,
        priority: _priority,
        subtasks: [],
      );
    } else {
      await ctrl.updateTask(
        widget.existing!.id,
        _titleC.text.trim(),
        _descC.text.trim(),
        _status,
        _dueDate,
        _completedAt, // This will be null if not completed
        _estimatedTime,
        _priority,
        _subtasks,
      );
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
}

class SubtaskEditorModal extends TrackingEditorModal {
  final TaskModel parentTask;
  final SubtaskModel subtask;

  const SubtaskEditorModal({
    Key? key,
    required WidgetRef ref,
    required this.parentTask,
    required this.subtask,
  }) : super(key: key, ref: ref);

  @override
  _SubtaskEditorModalState createState() => _SubtaskEditorModalState();
}

class _SubtaskEditorModalState
    extends TrackingEditorModalState<SubtaskEditorModal> {
  late TextEditingController _titleC;
  late TextEditingController _descC;
  late bool _completed;
  String _rawTimeUnit = '';
  String _rawTimeValue = '';

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.subtask.title);
    _descC = TextEditingController(); // Empty description for subtasks
    _completed = widget.subtask.completed;

    // Initialize raw time values if available
    _rawTimeValue = widget.subtask.rawTimeValue ?? '';
  }

  // In _SubtaskEditorModalState class, replace the problematic estimated time display:
  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;

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
          onChanged: (value) => setState(() => _completed = value ?? false),
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

    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);

    // update this subtask
    await ctrl.updateSubtask(
      widget.parentTask.id,
      widget.subtask,
      _titleC.text.trim(),
      _completed,
      rawTimeValue: _rawTimeValue,
    );

     // when *all* subtasks now have an estimate, sum them and update parent
    final all = widget.parentTask.subtasks;
    if (all != null && all.isNotEmpty &&
        all.every((st) => st.rawTimeValue?.isNotEmpty == true)) {
      int totalSeconds = 0;
      final regex = RegExp(r'^(\d+(?:\.\d+)?)\s*(\w+)$');
      for (final st in all) {
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
        sumEstimate = '${hours.toStringAsFixed((hours % 1 == 0) ? 0 : 1)} ${localizations.hours}';
      } else if (totalSeconds >= 60) {
        final minutes = totalSeconds / 60;
        sumEstimate = '${minutes.toStringAsFixed((minutes % 1 == 0) ? 0 : 1)} ${localizations.minutes}';
      } else {
        sumEstimate = '$totalSeconds ${localizations.seconds}';
      }

      await ctrl.updateTask(
        widget.parentTask.id,
        widget.parentTask.title,
        widget.parentTask.description,
        widget.parentTask.status,
        widget.parentTask.dueDate,
        widget.parentTask.completedAt,
        sumEstimate,
        widget.parentTask.priority,
        widget.parentTask.subtasks,
      );
    }
  }

  @override
  String getDeleteLabel() => widget.subtask.title;

  @override
  String getTitle() => AppLocalizations.of(context)!.subtask;
}

// —— Mood Editor —— //

class MoodLevelEditorModal extends TrackingEditorModal {
  final MoodModel? existing;
  const MoodLevelEditorModal({
    Key? key,
    required WidgetRef ref,
    this.existing,
  }) : super(key: key, ref: ref);
  @override
  _MoodLevelEditorModalState createState() => _MoodLevelEditorModalState();
}

class _MoodLevelEditorModalState
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
                color: _value == v ? Colors.blue[200] : Colors.grey[200],
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
          border: const OutlineInputBorder(),
        ),
      ),
    ]);
  }

  @override
  void onSave() async {
    final ctrl = widget.ref.read(trackerControllerProvider);
    Navigator.of(context).pop();
    if (widget.existing == null) {
      await ctrl.addMood(_value ?? 1, _notesC.text.trim());
    } else {
      await ctrl.updateMood(
        widget.existing!.id,
        _value ?? 1,
        _notesC.text.trim(),
      );
    }
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
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteMood(widget.existing!.id, widget.ref);
  }
}

// —— Energy Editor —— //

class EnergyLevelEditorModal extends TrackingEditorModal {
  final EnergyModel? existing;
  const EnergyLevelEditorModal({
    Key? key,
    required WidgetRef ref,
    this.existing,
  }) : super(key: key, ref: ref);
  @override
  _EnergyLevelEditorModalState createState() => _EnergyLevelEditorModalState();
}

class _EnergyLevelEditorModalState
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
                color: _value == v ? Colors.blue[200] : Colors.grey[200],
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
          border: const OutlineInputBorder(),
        ),
      ),
    ]);
  }

  @override
  void onSave() async {
    final ctrl = widget.ref.read(trackerControllerProvider);
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
    Key? key,
    required WidgetRef ref,
    this.existing,
  }) : super(key: key, ref: ref);

  @override
  _MedicationEditorModalState createState() => _MedicationEditorModalState();
}

class _MedicationEditorModalState
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
      _takenTimes = widget.existing!.takenTimes;

      // Check if the medication was taken today
      if (widget.existing!.lastTaken != null) {
        final now = DateTime.now();
        final lastTaken = widget.existing!.lastTaken!;

        // Compare year, month, and day to see if it was taken today
        _markAsTaken = lastTaken.year == now.year &&
            lastTaken.month == now.month &&
            lastTaken.day == now.day;
      } else {
        _markAsTaken = false;
      }

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
    final predefinedUnits = [
      'ml',
      'mg',
      'g',
      localizations.tablets,
      localizations.custom
    ];

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
        decoration: InputDecoration(labelText: localizations.name),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _doseC,
              decoration: InputDecoration(labelText: localizations.dose),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          if (_isCustomUnit)
            Expanded(
              child: TextFormField(
                controller: _customUnitC,
                decoration:
                    InputDecoration(labelText: localizations.customUnit),
                onChanged: (value) => setState(() {
                  _unit = value;
                }),
              ),
            )
          else
            DropdownButton<String>(
              value: _unit,
              items: predefinedUnits
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() {
                if (v == localizations.custom) {
                  _isCustomUnit = true;
                  _customUnitC.text = _unit == 'custom' ? '' : _unit;
                } else {
                  _isCustomUnit = false;
                  _unit = v!;
                }
              }),
            ),
        ],
      ),
      const SizedBox(height: 16),
      // Fix: Use the proper value and update internal representation correctly
      DropdownButton<String>(
        value: localizedFreq,
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
      Row(
        children: [
          Text(localizations.timesPerDay),
          const SizedBox(width: 16),
          if (_isCustomTimes)
            Expanded(
              child: TextFormField(
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
              ),
            )
          else
            DropdownButton<dynamic>(
              value: _timesPerDay > 5 ? localizations.custom : _timesPerDay,
              items: [
                ...List.generate(
                  5,
                  (i) =>
                      DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
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
              Text(localizations.unitsTaken,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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

    if ((_freqLabel == localizations.weekly ||
            _freqLabel == localizations.monthly) &&
        _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.selectAtLeastOneDay)),
      );
      return;
    }

    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);

    final frequency = _mapLabelToFrequency(_freqLabel);
    final customDays = (frequency == 'weekly' || frequency == 'monthly')
        ? _selectedDays.toList()
        : null;

    final unitToSave = _isCustomUnit ? _customUnitC.text : _unit;

    if (widget.existing == null) {
      await ctrl.addMedication(
        name: _nameC.text.trim(),
        dose: double.parse(_doseC.text),
        unit: unitToSave,
        frequency: frequency,
        customDays: customDays,
        timesPerDay: _timesPerDay,
      );
    } else {
      await ctrl.updateMedication(
        widget.existing!.id,
        _nameC.text.trim(),
        double.parse(_doseC.text),
        unitToSave,
        _takenTimes,
        frequency,
        customDays,
        _timesPerDay,
        _markAsTaken ? DateTime.now() : null,
      );
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
    await ctrl.deleteMedication(widget.existing!.id, widget.ref);
  }
}

class EstimatorWidget extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final Function(String, String) onEstimateUpdated;
  final String? initialValue;

  const EstimatorWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.onEstimateUpdated,
    this.initialValue,
  }) : super(key: key);

  @override
  _EstimatorWidgetState createState() => _EstimatorWidgetState();
}

class _EstimatorWidgetState extends ConsumerState<EstimatorWidget> {
  String _rawEstimate = '';
  String _estimatedTime = '';
  String _estimatedUnit = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial value if provided
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _rawEstimate = widget.initialValue!;

      // Only notify parent if we have a valid initial value
      if (_rawEstimate.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onEstimateUpdated(_rawEstimate, '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Display the parsed values if available, otherwise show the label
    final String displayText = (_estimatedTime.isNotEmpty)
        ? "$_estimatedTime $_estimatedUnit"
        : (_rawEstimate.isNotEmpty)
            ? _rawEstimate
            : localizations.estimatedTimeLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: localizations.estimatedTimeLabel,
                  border: const OutlineInputBorder(),
                ),
                controller: TextEditingController(text: displayText),
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      try {
                        final estimatorService =
                            ref.read(estimatorServiceProvider);
                        print("Estimating task with title: ${widget.title}");

                        // First get the raw API response
                        final result = await estimatorService.estimateTask(
                          widget.title,
                          widget.description,
                          localizations.estimateInstructions,
                        );

                        print("API estimation result: $result");

                        if (result is String && result.isNotEmpty) {
                          // Then parse the response to extract time and unit
                          final parsed = await estimatorService
                              .parseResponseWithLocale(result, context);
                          print("Parsed estimation: $parsed");

                          if (parsed != null) {
                            setState(() {
                              _rawEstimate = parsed['estimate'] + ' ' +  parsed['unit'];
                            });
                          }

                          // Pass the raw estimate to parent
                          widget.onEstimateUpdated(_rawEstimate, '');
                          print(_rawEstimate);
                        }
                      } catch (e) {
                        print("Error estimating task: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(localizations.estimate),
            ),
          ],
        ),
      ],
    );
  }
}

class SubtaskList extends StatelessWidget {
  final List<SubtaskModel> subtasks;
  final Function(SubtaskModel) onToggle;
  final TaskModel parentTask;
  final WidgetRef ref; // Add this parameter

  const SubtaskList({
    Key? key,
    required this.subtasks,
    required this.onToggle,
    required this.parentTask,
    required this.ref, // Add this required parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subtasks.map((subtask) {
        return Container(
          margin: const EdgeInsets.only(left: 15.0),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 0, right: 16.0),
            leading: const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.task_alt, size: 20),
            ),
            title: Text(
              subtask.title,
              style: TextStyle(
                decoration:
                    subtask.completed ? TextDecoration.lineThrough : null,
                color: subtask.completed ? Colors.grey : Colors.black,
                fontSize: 14.0, // Slightly smaller than parent task
              ),
            ),
            subtitle: Text(
              subtask.rawTimeValue != null && subtask.rawTimeValue!.isNotEmpty
                ? '${localizations.estimatedTimeLabel}: ${subtask.rawTimeValue}'
                : '${localizations.estimatedTimeLabel}: ${localizations.noTimeEstimate}',
              style: const TextStyle(fontSize: 12.0),
            ),
            // Make the entire ListTile tappable to open the edit modal
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SubtaskEditorModal(
                  ref: ref, // Use the passed ref
                  parentTask: parentTask,
                  subtask: subtask,
                ),
              );
            },
            // Align the checkbox with the parent task's checkbox
            trailing: SizedBox(
              width: 24, // Same width as parent task's checkbox
              child: Checkbox(
                value: subtask.completed,
                onChanged: (_) => onToggle(subtask),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
