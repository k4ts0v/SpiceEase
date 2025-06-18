// Standard Flutter imports for UI components and state management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Date/time formatting utilities
import 'package:intl/intl.dart';

// Data models that define the structure of different tracking entities
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/models/medication_model.dart';

// Providers that manage state for different tracking entities
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

// External services for AI-powered features
import 'package:spiceease/data/services/magic_todo_service.dart';

// Time management features
import 'package:spiceease/features/time_management/time_blocks/time_block_controller.dart';

// Custom widgets for AI task estimation
import 'package:spiceease/features/tracker/presentation/widgets/estimator_widget.dart';

// Internationalization for multi-language support
import 'package:spiceease/l10n/app_localizations.dart';

// Controller that handles business logic
import '../controllers/tracker_controller.dart';

// ===== BASE EDITOR MODAL ARCHITECTURE =====
// This section defines the common structure for all tracking modals

/// Abstract base class for all tracking editor modals
/// This provides a consistent interface and shared functionality across different tracking types
///
/// Why use an abstract class here?
/// - Enforces a consistent interface for all editor modals
/// - Provides shared UI structure (buttons, layout, etc.)
/// - Reduces code duplication across different tracking types
/// - Makes it easier to add new tracking types in the future
abstract class TrackingEditorModal<T> extends StatefulWidget {
  const TrackingEditorModal({super.key, required this.ref, this.existing});

  /// Reference to Riverpod's dependency injection system
  final WidgetRef ref;

  /// Existing item being edited, if any (null if creating a new item)
  final T? existing;

  @override
  TrackingEditorModalState createState();
}

/// Abstract base state class that all editor modals must implement
/// This enforces a consistent structure while allowing customization
abstract class TrackingEditorModalState<T extends TrackingEditorModal>
    extends State<T> {
  /// Abstract methods that each modal must implement
  /// These define the core functionality that varies between tracking types
  Widget buildForm(); // Creates the form fields specific to each tracking type
  void onSave(); // Handles saving data to the backend
  void onDelete(); // Handles deleting existing items

  /// Builds the complete modal dialog with consistent structure
  /// This method provides the same layout, buttons, and behavior for all modals
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
        width: double.maxFinite, // Use all available width
        constraints: BoxConstraints(
          // Responsive sizing based on screen size
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modal title
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
              // This is where each modal provides its specific form fields
              buildForm(),
              const SizedBox(height: 24),
              // Consistent button layout across all modals
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Delete button (only shown when editing existing items)
                  if (widget.existing != null)
                    TextButton(
                      onPressed: () {
                        // Show confirmation dialog before deleting
                        showDialog(
                          context: context,
                          builder: (alertDialogContext) => AlertDialog(
                            title: Text(localizations.confirmDelete),
                            content: Text(localizations
                                .deleteConfirmationMessage(getDeleteLabel())),
                            actions: [
                              // Cancel button to close the dialog
                              TextButton(
                                child: Text(localizations.cancel),
                                onPressed: () =>
                                    Navigator.of(alertDialogContext).pop(),
                              ),
                              // Confirm delete button
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

// Cancel button to close the modal without saving
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(localizations.cancel),
                  ),
                  // Save button to trigger the save operation
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

  /// Default implementations that can be overridden by specific modals

  /// Returns the label for the delete button
  String getDeleteLabel() => AppLocalizations.of(context)!.thisItem('item');

  /// Returns the title for the modal dialog
  String getTitle() => AppLocalizations.of(context)!.item('item');
}

// ===== SYMPTOM TRACKING MODAL =====
// Allows users to record and manage health symptoms

/// Modal for adding/editing symptom entries
/// Symptoms track health issues with severity levels and categories
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
  // ===== FORM CONTROLLERS =====
  // These manage the input fields and their current values
  late TextEditingController _nameC; // Symptom name
  final _customCatC = TextEditingController(); // Custom category input
  late TextEditingController _notesC; // Additional notes

  // ===== STATE VARIABLES =====
  String _category = 'Physical'; // Selected category
  bool _isCustomCategory = false; // Whether user selected custom category
  int _severity = 0; // Severity level (0-10)

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data or empty values
    _nameC = TextEditingController(text: widget.existing?.name ?? '');
    _notesC = TextEditingController(text: widget.existing?.notes ?? '');

    // Handle category initialization for editing existing symptoms
    if (widget.existing != null) {
      final predefinedCategories = ['Physical', 'Psychological'];
      if (predefinedCategories.contains(widget.existing!.category)) {
        _category = widget.existing!.category;
      } else {
        // If it's a custom category, switch to custom mode
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
        // ===== SYMPTOM NAME INPUT =====
        TextField(
          controller: _nameC,
          decoration: InputDecoration(labelText: localizations.name),
        ),
        const SizedBox(height: 12),
        // ===== CATEGORY SELECTION =====
        // Users can choose from predefined categories or create custom ones
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations.category}:'),
            const SizedBox(height: 8),
            // Show custom category input if user selected "Custom"
            if (_isCustomCategory)
              TextFormField(
                controller: _customCatC,
                decoration:
                    InputDecoration(labelText: localizations.customCategory),
                onChanged: (value) => setState(() => _category = value),
              )
            else
              // Show dropdown for predefined categories
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
                    // Handle category changes and switch to custom mode if needed
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
        // ===== SEVERITY SLIDER =====
        // Visual slider for selecting symptom severity (0-10)
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
                // Display current severity value
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
        // ===== NOTES INPUT =====
        // Multi-line text field for additional symptom details
        TextField(
          controller: _notesC,
          decoration: InputDecoration(
            labelText: localizations.notes,
            hintText: localizations.symptomNotesHint,
          ),
          maxLines: null, // Allow multiple lines
        ),
      ],
    );
  }

  /// Saves the symptom data to the backend
  @override
  void onSave() async {
    // Validate required fields
    if (_nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.nameRequired)),
      );
      return;
    }

    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);

    // Determine which category value to save
    final categoryToSave = _isCustomCategory ? _customCatC.text : _category;

    if (widget.existing == null) {
      // Create a new symptom entry
      await ctrl.addSymptom(
        _nameC.text.trim(),
        categoryToSave,
        _severity,
        _notesC.text.trim(),
      );
    } else {
      // Update an existing symptom entry
      await ctrl.updateSymptom(
        widget.existing!.id,
        _nameC.text.trim(),
        categoryToSave,
        _severity,
        _notesC.text.trim(),
      );
    }
  }

  /// Deletes the existing symptom entry from the backend
  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteSymptom(widget.existing!.id, widget.ref);
  }

  /// Returns the label for the delete modal
  @override
  String getDeleteLabel() =>
      widget.existing?.name ?? AppLocalizations.of(context)!.thisSymptom;

  /// Returns the title for the modal dialog
  @override
  String getTitle() => AppLocalizations.of(context)!.symptom;
}

// ===== HABIT TRACKING MODAL =====
// Allows users to create and manage recurring habits
/// Modal for adding/editing habit entries
/// Habits track recurring activities with customizable frequencies
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
  // ===== FORM CONTROLLERS =====
  late TextEditingController _titleC,
      _descC; // Controllers for title and description inputs
  late String
      _freqLabel; // Current frequency label (e.g., Daily, Weekly, Monthly)
  List<int> _selectedDays = []; // Selected days for weekly/monthly habits
  bool _markAsCompleted = false; // Whether to mark the habit as completed today
  List<String>? _freqOpts; // List of frequency options
// Mapping between internal and display values
  String? _selectedDay;

  // List of weekdays for weekly habits
  final List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Map to translate between internal and UI values
  Map<String, String> _freqMapToDisplay = {};
  Map<String, String> _freqMapToInternal = {};

  @override
  void initState() {
    super.initState();

// Initialize controllers with existing data or empty values
    _titleC = TextEditingController(text: widget.existing?.title ?? '');
    _descC = TextEditingController(text: widget.existing?.description ?? '');
    _freqLabel = widget.existing != null
        ? _mapFrequencyToLabel(widget.existing!.frequency)
        : 'Daily';
    _selectedDays = widget.existing?.customDays ?? [];

// If editing an existing habit, check if it was completed today
    if (widget.existing?.lastCompleted != null) {
      final today = DateTime.now();
      _markAsCompleted = widget.existing!.lastCompleted!.year == today.year &&
          widget.existing!.lastCompleted!.month == today.month &&
          widget.existing!.lastCompleted!.day == today.day;
    }
  }

  /// Maps frequency integer to a human-readable label.
  /// This is used to convert internal frequency values to UI-friendly labels.
  String _mapFrequencyToLabel(int frequency) {
    if (frequency == 1) return 'Daily';
    if (frequency == 7) return 'Weekly';
    if (frequency == -1) return 'Monthly';
    return 'Daily'; // Default to Daily
  }

  /// Maps a human-readable label to a frequency integer.
  /// This is used to convert UI-friendly labels back to internal frequency values.
  int _mapLabelToFrequency(String label) {
    if (label == 'Daily' || label == _freqMapToInternal['Daily']) return 1;
    if (label == 'Weekly' || label == _freqMapToInternal['Weekly']) return 7;
    if (label == 'Monthly' || label == _freqMapToInternal['Monthly']) return -1;
    return 1; // Default to Daily
  }

  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;

    // Setup mapping between internal and UI values for localization
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
      // ===== HABIT TITLE =====
      TextField(
        controller: _titleC,
        decoration: InputDecoration(labelText: localizations.title),
      ),
// ===== HABIT DESCRIPTION =====
      const SizedBox(height: 12),
      TextField(
        controller: _descC,
        decoration: InputDecoration(labelText: localizations.description),
      ),
      const SizedBox(height: 12),
      // ===== HABIT FREQUENCY SELECTION =====
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

      // ===== WEEKLY/MONTHLY SELECTIONS =====
      // Show day selection options based on frequency
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

// ===== SELECTED DAYS DISPLAY =====
// Show selected days as chips
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
      // ===== COMPLETION TOGGLE FOR EXISTING HABITS =====
      // Allow users to mark the habit as completed for today
      if (widget.existing != null) ...[
        const SizedBox(height: 12),
        CheckboxListTile(
          title: Text(localizations.markAsCompleted),
          value: _markAsCompleted,
          onChanged: (value) {
            // Update the UI state immediately
            setState(() => _markAsCompleted = value ?? false);

            // Capture controller reference before async operation
            final ctrl = widget.ref.read(trackerControllerProvider);

            // Schedule the backend update after the current frame
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

  /// Saves the habit data to the backend
  @override
  void onSave() async {
    final localizations = AppLocalizations.of(context)!;

    // Validate required fields
    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.titleRequired)),
      );
      return;
    }

    // Validate that weekly/monthly habits have selected days
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

  /// Deletes the existing habit entry from the backend
  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteHabit(widget.existing!.id);
  }

  /// Returns the label for the delete modal
  /// This is used to show the item being deleted in the confirmation dialog
  @override
  String getDeleteLabel() =>
      widget.existing?.title ?? AppLocalizations.of(context)!.thisHabit;

  /// Returns the title for the modal dialog
  /// This is used as the modal header
  @override
  String getTitle() => AppLocalizations.of(context)!.habit;
}

// ===== TASK MANAGEMENT MODAL =====
// Comprehensive task creation and editing with AI-powered features

/// Modal for adding/editing task entries
/// Tasks support subtasks, time estimation, priorities, and AI-powered task breakdown
class TaskEditorModal extends TrackingEditorModal {
  final TaskModel? existing;
  final String? initialStatus; // Predefined status to set on creation
  final String? initialValue; // Initial value for the task title or description

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
// ===== FORM CONTROLLERS =====
  late TextEditingController _titleC, _descC;

  // ===== STATE VARIABLES =====
  String _status = 'Pending';
  DateTime? _dueDate;
  DateTime? _completedAt;
  String? _estimatedTime;
  late int _priority;
  DateTime? _startTime;
  DateTime? _endTime;

  // ===== SUBTASK MANAGEMENT =====
  final List<SubtaskModel> _subtasks = [];
  bool _isLoadingSubtasks = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data or empty values
    _titleC = TextEditingController(text: widget.existing?.title ?? '');
    _descC = TextEditingController(text: widget.existing?.description ?? '');
    _status = widget.existing?.status ?? 'Pending';
    _dueDate = widget.existing?.dueDate;
    _completedAt = widget.existing?.completedAt;
    _estimatedTime = widget.existing?.estimatedTime;
    _priority = widget.existing?.priority ?? 1;

    // Override status if provided
    if (widget.initialStatus != null) {
      _status = widget.initialStatus!;
    }
    _startTime = widget.existing?.startTime;
    _endTime = widget.existing?.endTime;
  }

  /// Helper method to get localized version of the status
  /// This is used to display the status in the UI
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

  /// Helper method to convert localized status back to internal format
  /// This is used when saving the task to ensure we use the correct internal representation
  String _getInternalStatus(
      String localizedStatus, AppLocalizations localizations) {
    if (localizedStatus == localizations.pending) return 'Pending';
    if (localizedStatus == localizations.inProgress) return 'In Progress';
    if (localizedStatus == localizations.done) return 'Done';
    return 'Pending';
  }

  /// Shows the date picker and updates the specified date field
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

  /// Shows the time picker and updates the specified time field
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

  /// Generates subtasks using AI-powered task breakdown
  /// This method creates subtasks based on the task title and description
  /// This function is called when the user clicks the "Generate Subtasks" button
  Future<void> _generateSubtasks() async {
    final localizations = AppLocalizations.of(context)!;
    debugPrint('Generating subtasks...');

    // Validate required fields before generating subtasks
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
            .fold<int>(0, (max, order) => order > max ? order : max);
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

        // Close the modal after generating subtasks
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
            // ===== TASK TITLE =====
            TextField(
              controller: _titleC,
              decoration: InputDecoration(labelText: '${localizations.title}*'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            // ===== TASK DESCRIPTION =====
            TextField(
              controller: _descC,
              decoration: InputDecoration(labelText: localizations.description),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            // ===== STATUS DROPDOWN =====
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
            // ===== DUE DATE =====
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
            // ===== COMPLETION DATE =====
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show the completion status text
                Text(
                  _completedAt == null
                      ? localizations.notCompleted
                      : '${localizations.completed}: ${DateFormat.yMd().format(_completedAt!)}',
                ),
                const SizedBox(height: 8),

                // Show the buttons underneath
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
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: Text(localizations.clearCompletion),
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

            // ===== PRIORITY SLIDER =====
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

            // ===== START/END TIME PICKERS =====
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
            // ===== TIME ESTIMATION SECTION =====
            Row(
              children: [
                Expanded(
                  child: EstimatorWidget(
                    title: _titleC.text,
                    description: _descC.text,
                    ref: widget.ref,
                    onEstimated: (estimatedValue) {
                      setState(() {
                        _estimatedTime = estimatedValue;
                      });
                    },
                  ),
                ),
              ],
            ),

            // Display current time estimate
            if (_estimatedTime != null && _estimatedTime!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${localizations.estimatedTimeLabel}: $_estimatedTime',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Display current time estimate
            if (_estimatedTime != null && _estimatedTime!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                    '${localizations.estimatedTimeLabel}: $_estimatedTime!.'),
              ),
            const SizedBox(height: 16),

            // ===== SUBTASKS GENERATION SECTION =====
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

  /// Saves the task data to the backend
  @override
  void onSave() async {
    final localizations = AppLocalizations.of(context)!;

    // Validate required fields
    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.titleRequired)),
      );
      return;
    }

    // Capture all needed references before async operations
    final ctrl = widget.ref.read(trackerControllerProvider);

    // Ensure status and completedAt are synchronized
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
        // Adding a new task
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
        // Updating an existing task
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
        if (_startTime != null) {
          await _scheduleTaskWithTimes();
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

  /// Returns the label for the delete modal
  @override
  String getDeleteLabel() =>
      widget.existing?.title ?? AppLocalizations.of(context)!.thisTask;

  /// Returns the title for the modal dialog
  @override
  String getTitle() => AppLocalizations.of(context)!.task;

  /// Deletes the existing task entry from the backend
  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteTask(widget.existing!.id);
  }

  Future<void> _scheduleTaskWithTimes() async {
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

      // Schedule the task using the controller
      await widget.ref
          .read(timeBlockControllerProvider.notifier)
          .scheduleTask(widget.existing!, startTimeOfDay, endTimeOfDay);
    }
  }
}

// ===== SUBTASK MANAGEMENT MODAL =====
// Detailed editing for individual subtasks

/// Modal for editing subtask details
/// Subtasks are components of larger tasks with their own status and time tracking
class SubtaskEditorModal extends TrackingEditorModal<SubtaskModel> {
  // Specify SubtaskModel as the generic type
  final TaskModel parentTask; // This is the parent task for the subtask
  final SubtaskModel subtask; // This is the subtask being edited

  const SubtaskEditorModal({
    super.key,
    required super.ref,
    required this.parentTask,
    required this.subtask,
  }) : super(
            existing:
                subtask); // Pass the subtask to 'existing' (to the base class)

  @override
  SubtaskEditorModalState createState() => SubtaskEditorModalState();
}

class SubtaskEditorModalState
    extends TrackingEditorModalState<SubtaskEditorModal> {
  // ===== FORM CONTROLLERS =====
  late TextEditingController _titleC;
  late TextEditingController _descC;

  // ===== STATE VARIABLES =====
  late bool _completed; // Completion status
  late String _status; // Current status of the subtask
  DateTime? _startTime; // Start time for the subtask
  DateTime? _endTime; // End time for the subtask
  String _rawTimeUnit = ''; // Raw time unit for estimation
  String _rawTimeValue = ''; // Raw time value for estimation

  @override
  void initState() {
    super.initState();

    // Initialize form fields with existing subtask data
    _titleC = TextEditingController(text: widget.subtask.title);
    _descC = TextEditingController();
    _completed = widget.subtask.completed;
    _status = widget.subtask.status; // Initialize status
    _rawTimeValue = widget.subtask.rawTimeValue ?? '';
    _startTime = widget.subtask.startTime;
    _endTime = widget.subtask.endTime;
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
        // ===== CONTEXT INFORMATION =====
        Text(localizations.subtaskFor(widget.parentTask.title),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // ===== SUBTASK TITLE =====
        TextField(
          controller: _titleC,
          decoration: InputDecoration(labelText: '${localizations.title}*'),
          maxLines: 5,
          autofocus: true,
        ),
        const SizedBox(height: 12),

        // ===== SUBTASK STATUS DROPDOWN =====
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

                // Only sync completion when status is done
                // For 'in_progress', leave completion state as is
                if (_status == 'done') {
                  _completed = true;
                } else if (_status == 'todo') {
                  _completed = false;
                }
              });
            }
          },
        ),

        const SizedBox(height: 12),
        // ===== START TIME SECTION =====
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
        // ===== END TIME SECTION =====
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
        // ===== TIME ESTIMATOR SECTION =====
        Row(
          children: [
            Expanded(
              child: EstimatorWidget(
                title: _titleC.text,
                description: _descC.text,
                ref: widget.ref,
                onEstimated: (estimatedValue) {
                  setState(() {
                    _rawTimeValue = estimatedValue;
                  });
                },
              ),
            ),
          ],
        ),

        // Display current time estimate
        if (_rawTimeValue.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${localizations.estimatedTimeLabel}: $_rawTimeValue',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 12),

        // ===== COMPLETED CHECKBOX =====
        CheckboxListTile(
          title: Text(localizations.completed),
          value: _completed,
          onChanged: (value) => setState(() {
            _completed = value ?? false;

            // Simplified sync logic for checkbox
            // If status is 'in_progress', leave it as is when unchecking
            if (_completed) {
              _status = 'done';
            } else if (_status == 'done') {
              _status = 'todo';
            }
          }),
        ),
      ],
    );
  }

  /// Saves the subtask data to the backend
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

      // Update the subtask with the provided data
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

      // If all subtasks have time estimates, calculate the total for the parent task
      if (allSubtasks.isNotEmpty &&
          allSubtasks.every((st) => st.rawTimeValue?.isNotEmpty == true)) {
        int totalSeconds = 0;
        final regex = RegExp(r'^(\d+(?:\.\d+)?)\s*(\w+)$');

        // Sum up all subtasks' time estimates
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

        // Convert total seconds to a human-readable format
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

        // Update the parent task with the new total estimate
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

  /// Deletes the subtask from the backend
  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteSubtask(widget.subtask.id, widget.subtask.taskId);
  }

  /// Returns the label for the delete modal
  @override
  String getDeleteLabel() => widget.subtask.title;

  /// Returns the title for the modal dialog
  @override
  String getTitle() => AppLocalizations.of(context)!.subtask;

  /// Shows the date picker and updates the specified date field
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

// ===== MOOD TRACKING MODAL =====
// Simple numerical mood tracking with notes

/// Modal for adding/editing mood level entries
/// Mood tracking uses a 1-10 scale with optional notes
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
  // ===== STATE VARIABLES =====
  int? _value;
  late TextEditingController _notesC;

  @override
  void initState() {
    // Initialize state variables with existing mood data or defaults
    super.initState();
    _value = widget.existing?.moodLevel;
    _notesC = TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // ===== MOOD LEVEL SELECTION =====
      // Display mood levels as a grid of selectable boxes
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
              child: Center(child: Text('$v', key: ValueKey('moodValue_$v'))),
            ),
          );
        }),
      ),
      const SizedBox(height: 12),

      // ===== NOTES TEXT FIELD =====
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

  /// Saves the mood level entry to the backend
  @override
  void onSave() async {
    final localizations = AppLocalizations.of(context)!;
    debugPrint(
        "[MoodLevelEditorModal.onSave] Entered onSave. Value: $_value. Existing: ${widget.existing != null}");

    // Validate that a mood level has been selected
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

  /// Returns the label for the delete modal
  @override
  String getDeleteLabel() {
    final localizations = AppLocalizations.of(context)!;
    return widget.existing?.notes?.isNotEmpty == true
        ? widget.existing!.notes!
        : localizations.thisMoodEntry;
  }

  /// Returns the title for the modal dialog
  @override
  String getTitle() {
    final localizations = AppLocalizations.of(context)!;
    return localizations.mood;
  }

  /// Deletes the existing mood entry from the backend
  @override
  void onDelete() async {
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

// ===== ENERGY LEVEL TRACKING MODAL =====
/// Modal for adding/editing energy level entries
/// Energy tracking uses a 1-10 scale with optional notes
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
  // ===== STATE VARIABLES =====
  int? _value;
  late TextEditingController _notesC;

  @override
  void initState() {
    super.initState();
    // Initialize state variables with existing energy data or defaults
    _value = widget.existing?.energyLevel;
    _notesC = TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  Widget buildForm() {
    final localizations = AppLocalizations.of(context)!;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // ===== ENERGY LEVEL SELECTION =====
      // Display energy levels as a grid of selectable boxes
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
      // ===== NOTES TEXT FIELD =====
      // Text field for optional notes about the energy level
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

  /// Saves the energy level entry to the backend
  @override
  void onSave() async {
    // Validate that a mood level has been selected
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

  /// Returns the label for the delete modal
  @override
  String getDeleteLabel() => widget.existing?.notes?.isNotEmpty == true
      ? widget.existing!.notes!
      : AppLocalizations.of(context)!.thisEnergyEntry;

  /// Returns the title for the modal dialog
  @override
  String getTitle() => AppLocalizations.of(context)!.energy;

  /// Deletes the existing energy entry from the backend
  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteEnergy(widget.existing!.id, widget.ref);
  }
}

// ===== MEDICATION TRACKING MODAL =====
/// Modal for adding/editing medication entries
/// Medication tracking includes name, dose, unit, frequency, and taken status
/// This modal allows users to track their medication intake
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
  // ===== FORM CONTROLLERS =====
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
    // Initialize form fields with existing medication data if available
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

  // Helper method to map localized frequency label to internal representation
  String _mapLabelToFrequency(String label) {
    final localizations = AppLocalizations.of(context)!;

    if (label == localizations.daily) return 'daily';
    if (label == localizations.weekly) return 'weekly';
    if (label == localizations.monthly) return 'monthly';
    return 'daily';
  }

  // Maps internal frequency to localized string
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
    // Define the predefined units and their localized versions
    final predefinedUnits = ['ml', 'mg', 'g', 'tablets', 'custom'];
    // Helper function to get the localized unit string
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

    // Get the correctly localized frequency value
    final localizedFreq = _getLocalizedFrequency();

    // Define the available frequency options
    final freqOptions = [
      localizations.daily,
      localizations.weekly,
      localizations.monthly
    ];

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // ===== MEDICATION NAME =====
      TextFormField(
        controller: _nameC,
        decoration: InputDecoration(labelText: localizations.name),
      ),
      const SizedBox(height: 16),

      // ===== DOSE AND UNIT =====
      LayoutBuilder(
        builder: (context, constraints) {
          // If there is a custom unit, show a text field for it. If not, show a dropdown for predefined units.
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
                  // Use DropdownButtonFormField for unit selection
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

      // ===== FREQUENCY SELECTION =====
      DropdownButtonFormField<String>(
        value: localizedFreq,
        decoration: InputDecoration(labelText: localizations.frequency),
        items: freqOptions
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() {
          // Map the localized value back to internal representation
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

      // If thetimes per day selection is custom, show a text field. Otherwise, show a dropdown.
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
                  // Generate a dropdown for times per day
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

      //Generates the checkbox or progress indicator based on existing medication
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

  /// Saves the medication entry to the backend
  @override
  void onSave() async {
    final localizations = AppLocalizations.of(context)!;

    // Validate required fields
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

  /// Returns the label for the delete modal
  @override
  String getDeleteLabel() =>
      widget.existing?.name ?? AppLocalizations.of(context)!.thisMedication;

  /// Returns the title for the modal dialog
  @override
  String getTitle() => AppLocalizations.of(context)!.medication;

  /// Deletes the existing medication entry from the backend
  @override
  void onDelete() async {
    Navigator.of(context).pop();
    final ctrl = widget.ref.read(trackerControllerProvider);
    await ctrl.deleteMedication(widget.existing!.id);
  }
}