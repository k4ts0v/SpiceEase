// lib/features/tracker/presentation/modals.dart

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
                    ? 'Edit ${getTitle()}'
                    : 'New ${getTitle()}',
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
                            title: Text('Delete ${getTitle()}?'),
                            content: Text(
                                'Are you sure you want to delete "${getDeleteLabel()}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel',
                                    style: TextStyle(color: Colors.blueAccent)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onDelete();
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blueAccent)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    // style: ModalStyles.buttonStyle,
                    onPressed: onSave,
                    child: const Text('Save'),
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
    final predefinedCategories = ['Physical', 'Psychological', 'Custom'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameC,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Category:'),
            const SizedBox(width: 16),
            if (_isCustomCategory)
              Expanded(
                child: TextFormField(
                  controller: _customCatC,
                  decoration:
                      const InputDecoration(labelText: 'Custom Category'),
                  onChanged: (value) => setState(() => _category = value),
                ),
              )
            else
              DropdownButton<String>(
                value: _category,
                items: predefinedCategories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() {
                  if (v == 'Custom') {
                    _isCustomCategory = true;
                    _customCatC.text = _category == 'Custom' ? '' : _category;
                  } else {
                    _isCustomCategory = false;
                    _category = v!;
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Severity:'),
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
        const SnackBar(content: Text('Name is required')),
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
  String getDeleteLabel() => widget.existing?.name ?? 'this symptom';

  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteSymptom(widget.existing!.id, super.widget.ref);
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
  bool _markAsCompleted = false; // Checkbox for marking as completed
  final _freqOpts = ['Daily', 'Weekly', 'Monthly'];
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
    if (label == 'Daily') return 1;
    if (label == 'Weekly') return 7;
    if (label == 'Monthly') return -1;
    return 1; // Default to Daily
  }

  @override
  Widget buildForm() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(
        controller: _titleC,
        decoration: const InputDecoration(labelText: 'Title'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _descC,
        decoration: const InputDecoration(labelText: 'Description'),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _freqLabel,
        decoration: const InputDecoration(labelText: 'Frequency'),
        items: _freqOpts
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) => setState(() {
          _freqLabel = v!;
          _selectedDays.clear(); // Reset selected days when frequency changes
        }),
      ),
      if (_freqLabel == 'Weekly') ...[
        const SizedBox(height: 16),
        // ChipTheme(
        // data: ModalStyles.chipTheme,
        Wrap(
          spacing: 8,
          children: List.generate(7, (i) {
            final weekday = i + 1;
            return FilterChip(
              label:
                  Text(DateFormat('EEEE').format(DateTime(2024, 1, weekday))),
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
          decoration: const InputDecoration(
            labelText: 'Enter Day of Month (1-31)',
            hintText: 'e.g., 1, 15, 31',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _selectedDay = value;
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          // style: ModalStyles.buttonStyle,
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
          child: const Text('Add Day of Month'),
        ),
      ],
      const SizedBox(height: 12),
      //     ChipTheme(
      // data: ModalStyles.chipTheme,
      Wrap(
        spacing: 8,
        children: _selectedDays
            .map((day) => Chip(
                  label: Text(
                      _freqLabel == 'Weekly' ? _weekdays[day - 1] : 'Day $day'),
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
          title: const Text('Mark as Completed'),
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
    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    if ((_freqLabel == 'Weekly' || _freqLabel == 'Monthly') &&
        _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please select at least one ${_freqLabel == 'Weekly' ? 'weekday' : 'day of the month'}')),
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
  String getDeleteLabel() => widget.existing?.title ?? 'this habit';

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
    Key? key,
    required WidgetRef ref,
    this.existing,
    this.initialStatus,
    this.initialValue,
  }) : super(key: key, ref: ref);

  @override
  _TaskEditorModalState createState() => _TaskEditorModalState();
}

class _TaskEditorModalState extends TrackingEditorModalState<TaskEditorModal> {
  late TextEditingController _titleC, _descC;
  String _status = 'Pending';
  DateTime? _dueDate;
  DateTime? _completedAt;
  int? _estimatedTime;
  String? _estimatedUnit;
  late int _priority;
  List<SubtaskModel> _subtasks = [];
  bool _isLoadingSubtasks = false;

  final List<String> _statusOptions = ['Pending', 'In Progress', 'Done'];

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
    _estimatedTime = (widget.existing?.estimatedTime ?? 0) as int?;
    _estimatedUnit = widget.existing?.estimatedUnit;
    _priority = widget.existing?.priority ?? 1;
    if (widget.initialStatus != null) {
      _status = widget.initialStatus!;
    }
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
    print('Generating subtasks...');
    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Title is required for generating subtasks')),
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
          // Update main task estimated time based on subtasks
          _estimatedTime = subtasks.fold(
              0,
              (sum, subtask) =>
                  sum! + (int.parse(subtask.rawTimeValue ?? '0') ~/ 60));
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
            _estimatedUnit,
            widget.existing!.priority,
            subtasks,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No subtasks were generated')),
        );
        return;
      }

      Navigator.pop(context);
    } catch (e) {
      print('Error generating subtasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate subtasks: $e')),
      );
    } finally {
      setState(() => _isLoadingSubtasks = false);
    }
  }

  @override
  Widget buildForm() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleC,
              decoration: const InputDecoration(labelText: 'Title*'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descC,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: _statusOptions
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'No due date set'
                        : 'Due: ${DateFormat.yMd().format(_dueDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: () => _pickDate(context, true),
                  child: const Text('Set Due Date'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _completedAt == null
                        ? 'Not completed'
                        : 'Completed: ${DateFormat.yMd().format(_completedAt!)}',
                  ),
                ),
                TextButton(
                  onPressed: () => _pickDate(context, false),
                  child: const Text('Set Completed'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Priority:'),
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
            // Update the EstimatorWidget implementation in _TaskEditorModalState:

            Row(
              children: [
                Expanded(
                  child: EstimatorWidget(
                    title: _titleC.text,
                    description: _descC.text,
                    onEstimateUpdated: (time, unit) {
                      setState(() {
                        // Store the original values without conversion
                        _estimatedTime = int.tryParse(time) ?? 0;
                        _estimatedUnit = unit;

                        // No need to convert to minutes anymore
                      });
                    },
                    initialValue: _estimatedTime?.toString(),
                  ),
                ),
              ],
            ),

// Add this to show the estimation with units
            if (_estimatedTime != null &&
                _estimatedUnit != null &&
                _estimatedUnit!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Estimated time: $_estimatedTime $_estimatedUnit'),
              ),
            const SizedBox(height: 16),
// Second row - Subtasks
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Feeling like that's too much? Break it into subtasks!"),
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
                            : const Text('Break it into subtasks'),
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
    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);

    if (widget.existing == null) {
      await ctrl.addTask(
        title: _titleC.text.trim(),
        description: _descC.text.trim(),
        status: _status,
        dueDate: _dueDate,
        completedAt: _completedAt,
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
        _completedAt,
        _estimatedTime,
        _estimatedUnit,
        _priority,
        _subtasks,
      );
    }
  }

  @override
  String getDeleteLabel() => widget.existing?.title ?? 'this task';

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
    _rawTimeUnit = widget.subtask.rawTimeUnit ?? '';
  }

  @override
  Widget buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Subtask for: ${widget.parentTask.title}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: _titleC,
          decoration: const InputDecoration(labelText: 'Title*'),
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

        // Show the current estimate with raw values
        if (_rawTimeValue.isNotEmpty)
          Text('Current estimate: $_rawTimeValue $_rawTimeUnit'),
        const SizedBox(height: 12),

        CheckboxListTile(
          title: const Text('Completed'),
          value: _completed,
          onChanged: (value) => setState(() => _completed = value ?? false),
        ),
      ],
    );
  }

  @override
  void onSave() async {
    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);

    await ctrl.updateSubtask(
      widget.parentTask.id,
      widget.subtask,
      _titleC.text.trim(),
      _completed,
      rawTimeValue: _rawTimeValue,
      rawTimeUnit: _rawTimeUnit,
    );
  }
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
        decoration: const InputDecoration(
            labelText: 'Notes', border: OutlineInputBorder()),
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
        decoration: const InputDecoration(
            labelText: 'Notes', border: OutlineInputBorder()),
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

      // Check if the unit is one of the predefined ones
      final predefinedUnits = ['ml', 'mg', 'g', 'pills', 'tablets'];
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
    switch (label) {
      case 'Daily':
        return 'daily';
      case 'Weekly':
        return 'weekly';
      case 'Monthly':
        return 'monthly';
      default:
        return 'daily';
    }
  }

  @override
  Widget buildForm() {
    final predefinedUnits = ['ml', 'mg', 'g', 'tablets', 'custom'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _nameC,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _doseC,
                decoration: const InputDecoration(labelText: 'Dose'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            if (_isCustomUnit)
              Expanded(
                child: TextFormField(
                  controller: _customUnitC,
                  decoration: const InputDecoration(labelText: 'Custom Unit'),
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
        ),
        const SizedBox(height: 16),
        DropdownButton<String>(
          value: _freqLabel,
          items: ['Daily', 'Weekly', 'Monthly']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() {
            _freqLabel = v!;
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
                label:
                    Text(DateFormat('EEEE').format(DateTime(2024, 1, weekday))),
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
                  decoration: const InputDecoration(
                    labelText: 'Day of Month (1-31)',
                    hintText: 'Enter a number and press Add',
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
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: (_selectedDays.toList()..sort())
                .map((day) => Chip(
                      label: Text('Day $day'),
                      onDeleted: () =>
                          setState(() => _selectedDays.remove(day)),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Times per day:'),
            const SizedBox(width: 16),
            if (_isCustomTimes)
              Expanded(
                child: TextFormField(
                  controller: _customTimesC,
                  decoration: const InputDecoration(labelText: 'Custom Times'),
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
                value: _timesPerDay > 5 ? 'custom' : _timesPerDay,
                items: [
                  ...List.generate(
                    5,
                    (i) =>
                        DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                  ),
                  const DropdownMenuItem(
                      value: 'custom', child: Text('Custom')),
                ],
                onChanged: (v) => setState(() {
                  if (v == 'custom') {
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
          CheckboxListTile(
            title: const Text('Mark as taken'),
            value: _markAsTaken,
            onChanged: (v) => setState(() => _markAsTaken = v!),
          ),
        ],
      ],
    );
  }

  @override
  void onSave() async {
    if (_nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    if (_doseC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dose is required')),
      );
      return;
    }

    if ((_freqLabel == 'Weekly' || _freqLabel == 'Monthly') &&
        _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
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
        frequency,
        customDays,
        _timesPerDay,
        _markAsTaken ? DateTime.now() : null,
      );
    }
  }
}

// Replace the EstimatorModal class with this:
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
  String _estimatedTime = 'Estimated time';
  String _estimatedUnit = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial value if provided
    if (widget.initialValue != null) {
      _estimatedTime = widget.initialValue!;

      // FIXED: Use addPostFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onEstimateUpdated(_estimatedTime, _estimatedUnit);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Estimated time',
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(
                text: "${_estimatedTime} ${_estimatedUnit}"),
          ),
        ),
        const SizedBox(width: 6),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  try {
                    final estimatorService = ref.read(estimatorServiceProvider);
                    final result = await estimatorService.estimateTask(
                      widget.title,
                      widget.description,
                      "Give the estimate in numbers",
                    );
                    if (result is String) {
                      final parsed =
                          await estimatorService.parseResponse(result);
                      setState(() {
                        _estimatedTime = parsed['estimate'].toString();
                        _estimatedUnit = parsed['unit'];
                      });
                      widget.onEstimateUpdated(_estimatedTime, _estimatedUnit);
                    }
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
              : const Text('Estimate'),
        ),
      ],
    );
  }
}

class SubtaskList extends StatelessWidget {
  final List<SubtaskModel> subtasks;
  final Function(SubtaskModel) onToggle;

  const SubtaskList({
    Key? key,
    required this.subtasks,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subtasks
          .map((subtask) => Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    Checkbox(
                      value: subtask.completed,
                      onChanged: (_) => onToggle(subtask),
                    ),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: TextStyle(
                          decoration: subtask.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Text('${subtask.rawTimeValue} min'),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
