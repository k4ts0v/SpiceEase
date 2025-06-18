// Standard Flutter imports for UI components and state management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Data models that define the structure of tracking entities
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';

// Providers for data access
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

// Editor modals for different tracking types
import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';

// Controller that handles business logic
import 'package:spiceease/features/tracker/presentation/controllers/entity_sections_controller.dart';

// Reusable components for displaying entity sections
import 'package:spiceease/features/tracker/presentation/widgets/entity_section.dart';
import 'package:spiceease/features/tracker/presentation/widgets/subtask_list.dart';

// Internationalization for multi-language support
import 'package:spiceease/l10n/app_localizations.dart';

// ===== ENTITY SECTIONS UI COMPONENT =====
// This section provides the pure UI for displaying different tracking entity types

/// A widget that displays organized sections for different tracking entities
///
/// This UI component focuses purely on rendering and user interactions,
/// while delegating all business logic to EntitySectionsController.
/// It provides:
/// - Clean separation of UI and business logic
/// - Reactive UI updates based on controller state
/// - User interaction handling with controller delegation
/// - Consistent styling and behavior across all entity types
///
/// The widget displays four main entity types:
/// - Symptoms: Health symptom tracking with categories and severity
/// - Medications: Dosage tracking with completion status
/// - Tasks: Project management with subtasks and due dates
/// - Habits: Recurring activity tracking with custom frequencies
class EntitySections extends ConsumerWidget {
  /// Function to display modal dialogs for editing entities
  final Function(BuildContext, Widget) showModal;

  /// The currently selected date for filtering entity data
  final DateTime selectedDate;

  const EntitySections({
    super.key,
    required this.showModal,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ===== WATCH DATA PROVIDERS AND CONTROLLER STATE =====
    // Watch the actual data providers for reactive updates
    final symptoms = ref.watch(symptomStateNotifierProvider(selectedDate));
    final medications =
        ref.watch(medicationStateNotifierProvider(selectedDate));
    final tasks = ref.watch(taskStateNotifierProvider(selectedDate));
    final habits = ref.watch(habitStateNotifierProvider(selectedDate));

    // ===== WATCH CONTROLLER STATE FOR OPTIMISTIC UPDATES =====
    // This ensures UI updates immediately when controller state changes
    ref.watch(entitySectionsControllerProvider(selectedDate));
    final controller =
        ref.read(entitySectionsControllerProvider(selectedDate).notifier);

    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        // ===== SYMPTOMS SECTION =====
        _buildSymptomsSection(
          context,
          ref,
          symptoms,
          theme,
          localizations,
        ),
        const SizedBox(height: 20),

        // ===== MEDICATIONS SECTION =====
        _buildMedicationsSection(
          context,
          ref,
          controller,
          medications,
          theme,
          localizations,
        ),
        const SizedBox(height: 20),

        // ===== TASKS SECTION =====
        _buildTasksSection(
          context,
          ref,
          controller,
          tasks,
          theme,
          localizations,
        ),
        const SizedBox(height: 20),

        // ===== HABITS SECTION =====
        _buildHabitsSection(
          context,
          ref,
          controller,
          habits,
          theme,
          localizations,
        ),
      ],
    );
  }

  /// Builds the symptoms section UI
  Widget _buildSymptomsSection(
    BuildContext context,
    WidgetRef ref,
    List<SymptomModel> symptoms,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return EntitySection<SymptomModel>(
      title: localizations.symptoms,
      items: symptoms,
      isLoading: false,
      error: null,
      onTap: (symptom) => showModal(
        context,
        SymptomEditorModal(ref: ref, existing: symptom),
      ),
      onAdd: () => showModal(
        context,
        SymptomEditorModal(ref: ref),
      ),
      itemBuilder: (symptom) => ListTile(
        title: Text(symptom.name),
        subtitle: Text(
          '${localizations.category}: ${symptom.category} | ${localizations.severity}: ${symptom.severity}',
        ),
        trailing: Text(
          DateFormat('HH:mm').format(symptom.createdAt.toLocal()),
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  /// Builds the medications section UI with tracking controls
  Widget _buildMedicationsSection(
    BuildContext context,
    WidgetRef ref,
    EntitySectionsController controller,
    List<MedicationModel> medications,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return EntitySection<MedicationModel>(
      title: localizations.medication,
      items: medications,
      isLoading: false,
      error: null,
      onTap: (medication) => showModal(
        context,
        MedicationEditorModal(ref: ref, existing: medication),
      ),
      onAdd: () => showModal(
        context,
        MedicationEditorModal(ref: ref),
      ),
      itemBuilder: (medication) => Consumer(
        builder: (context, ref, child) {
          // Watch controller state to ensure reactivity for this specific medication
          ref.watch(entitySectionsControllerProvider(selectedDate));

          return _buildMedicationItem(
            context,
            ref,
            controller,
            medication,
            theme,
            localizations,
          );
        },
      ),
    );
  }

  /// Builds individual medication item with tracking controls
  Widget _buildMedicationItem(
    BuildContext context,
    WidgetRef ref,
    EntitySectionsController controller,
    MedicationModel medication,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final takenCount = controller.getEffectiveMedicationCount(medication);
    final timesPerDay = medication.timesPerDay;
    final isCompleted = takenCount >= timesPerDay;

    return ListTile(
      title: Text(
        medication.name,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted
              ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
              : null,
        ),
      ),
      subtitle: Text(
        '${localizations.dose}: ${medication.dose} ${medication.unit}',
      ),
      trailing: timesPerDay <= 1
          ? _buildSingleDoseCheckbox(
              context,
              controller,
              medication,
              takenCount,
              localizations,
            )
          : _buildMultiDoseCounter(
              context,
              controller,
              medication,
              takenCount,
              timesPerDay,
              isCompleted,
              theme,
              localizations,
            ),
    );
  }

  /// Builds single dose checkbox for once-daily medications
  Widget _buildSingleDoseCheckbox(
    BuildContext context,
    EntitySectionsController controller,
    MedicationModel medication,
    int takenCount,
    AppLocalizations localizations,
  ) {
    return Checkbox(
      value: takenCount >= 1,
      onChanged: (bool? value) {
        final newIsCompleted = value == true;
        controller.updateMedicationCompletion(
          medicationId: medication.id,
          isCompleted: newIsCompleted,
          onError: () => _showErrorSnackBar(
            context,
            '${localizations.failedToUpdate}',
          ),
        );
      },
    );
  }

  /// Builds multi-dose counter for medications taken multiple times per day
  Widget _buildMultiDoseCounter(
    BuildContext context,
    EntitySectionsController controller,
    MedicationModel medication,
    int takenCount,
    int timesPerDay,
    bool isCompleted,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrease button
        IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: takenCount > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          onPressed: takenCount > 0
              ? () => controller.updateMedicationDoseCount(
                    medicationId: medication.id,
                    currentCount: takenCount,
                    newCount: takenCount - 1,
                    timesPerDay: timesPerDay,
                    onError: () => _showErrorSnackBar(
                      context,
                      '${localizations.failedToUpdate}',
                    ),
                  )
              : null,
        ),
        // Count display
        Text(
          '$takenCount/$timesPerDay',
          style: TextStyle(
            color: isCompleted ? Colors.green : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Increase button
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: !isCompleted
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          onPressed: !isCompleted
              ? () => controller.updateMedicationDoseCount(
                    medicationId: medication.id,
                    currentCount: takenCount,
                    newCount: takenCount + 1,
                    timesPerDay: timesPerDay,
                    onError: () => _showErrorSnackBar(
                      context,
                      '${localizations.failedToUpdate}',
                    ),
                  )
              : null,
        ),
      ],
    );
  }

  /// Builds the tasks section UI with completion tracking
  Widget _buildTasksSection(
    BuildContext context,
    WidgetRef ref,
    EntitySectionsController controller,
    List<TaskModel> tasks,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return EntitySection<TaskModel>(
      title: localizations.tasks,
      items: tasks,
      isLoading: false,
      error: null,
      onTap: (task) => showModal(
        context,
        TaskEditorModal(ref: ref, existing: task),
      ),
      onAdd: () => showModal(
        context,
        TaskEditorModal(ref: ref),
      ),
      itemBuilder: (task) => Consumer(
        builder: (context, ref, child) {
          // Watch controller state to ensure reactivity for this specific task
          ref.watch(entitySectionsControllerProvider(selectedDate));

          return _buildTaskItem(
            context,
            controller,
            task,
            theme,
            localizations,
          );
        },
      ),
    );
  }

  /// Builds individual task item with completion tracking and subtasks
  Widget _buildTaskItem(
    BuildContext context,
    EntitySectionsController controller,
    TaskModel task,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final localIsCompleted = controller.getEffectiveTaskCompletion(task);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(
            Icons.task_alt,
            color: localIsCompleted
                ? theme.colorScheme.primary.withValues(alpha: 0.7)
                : theme.colorScheme.primary,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: localIsCompleted ? TextDecoration.lineThrough : null,
              color: localIsCompleted
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                  : theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            '${task.dueDate != null ? "${localizations.due}: ${DateFormat('EEE, d MMMM').format(task.dueDate!.toLocal())}" : localizations.noDueDate} | ${localizations.status}: ${controller.getLocalizedStatus(task.status, localizations)}',
            style: TextStyle(
              color: localIsCompleted
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                  : theme.colorScheme.onSurface,
            ),
          ),
          trailing: Checkbox(
            value: localIsCompleted,
            onChanged: (value) {
              final newIsCompleted = value ?? false;
              controller.updateTaskCompletion(
                task: task,
                isCompleted: newIsCompleted,
                onError: () => _showErrorSnackBar(
                  context,
                  '${localizations.failedToUpdate}',
                ),
              );
            },
          ),
        ),

        // Subtasks display
        if (task.hasSubtasks)
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    localizations.subtasks,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SubtaskList(
                  parentTaskId: task.id,
                  parentTask: task,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Builds the habits section UI with completion tracking
  Widget _buildHabitsSection(
    BuildContext context,
    WidgetRef ref,
    EntitySectionsController controller,
    List<HabitModel> habits,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return EntitySection<HabitModel>(
      title: localizations.habits,
      items: habits,
      isLoading: false,
      error: null,
      onTap: (habit) => showModal(
        context,
        HabitEditorModal(ref: ref, existing: habit),
      ),
      onAdd: () => showModal(
        context,
        HabitEditorModal(ref: ref),
      ),
      itemBuilder: (habit) => Consumer(
        builder: (context, ref, child) {
          // Watch controller state to ensure reactivity for this specific habit
          ref.watch(entitySectionsControllerProvider(selectedDate));

          return _buildHabitItem(
            context,
            controller,
            habit,
            theme,
            localizations,
          );
        },
      ),
    );
  }

  /// Builds individual habit item with completion tracking
  Widget _buildHabitItem(
    BuildContext context,
    EntitySectionsController controller,
    HabitModel habit,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final localIsCompleted = controller.getEffectiveHabitCompletion(habit);

    return ListTile(
      leading: Icon(
        Icons.sync_rounded,
        color: localIsCompleted
            ? theme.colorScheme.primary.withValues(alpha: 0.7)
            : theme.colorScheme.primary,
      ),
      title: Text(
        habit.title,
        style: TextStyle(
          decoration: localIsCompleted ? TextDecoration.lineThrough : null,
          color: localIsCompleted
              ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        '${habit.description.isNotEmpty ? habit.description : localizations.noDescription} | ${localizations.frequency}: ${controller.getLocalizedFrequency(habit, localizations)}',
      ),
      trailing: Checkbox(
        value: localIsCompleted,
        onChanged: (value) {
          final newIsCompleted = value ?? false;
          controller.updateHabitCompletion(
            habit: habit,
            isCompleted: newIsCompleted,
            onError: () => _showErrorSnackBar(
              context,
              '${localizations.failedToUpdate}',
            ),
          );
        },
      ),
    );
  }

  /// Shows error snackbar with the given message
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
