import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';
import 'package:spiceease/features/tracker/presentation/tracker_controller.dart';
import 'package:spiceease/features/tracker/presentation/widgets/entity_section.dart';
import 'package:spiceease/features/tracker/presentation/widgets/subtask_list.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class EntitySections extends ConsumerWidget {
  final Function(BuildContext, Widget) showModal;
  final DateTime selectedDate;

  const EntitySections({
    super.key,
    required this.showModal,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptoms = ref.watch(symptomStateNotifierProvider(selectedDate));
    final medications =
        ref.watch(medicationStateNotifierProvider(selectedDate));
    final tasks = ref.watch(taskStateNotifierProvider(selectedDate));
    final habits = ref.watch(habitStateNotifierProvider(selectedDate));
    final theme = Theme.of(context);

    // Extract data, loading status, and errors manually
    List<SymptomModel> symptomsList = symptoms;
    bool symptomsLoading = false;
    String? symptomsError;

    List<MedicationModel> medicationsList = medications;
    bool medicationsLoading = false;
    String? medicationsError;

    List<TaskModel> tasksList = tasks;
    bool tasksLoading = false;
    String? tasksError;

    List<HabitModel> habitsList = habits;
    bool habitsLoading = false;
    String? habitsError;

    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        EntitySection<SymptomModel>(
          title: localizations.symptoms,
          items: symptomsList,
          isLoading: symptomsLoading,
          error: symptomsError,
          onTap: (symptom) => showModal(
            context,
            SymptomEditorModal(ref: ref, existing: symptom),
          ),
          onAdd: () => showModal(context, SymptomEditorModal(ref: ref)),
          itemBuilder: (symptom) => ListTile(
            title: Text(symptom.name),
            subtitle: Text(
                '${localizations.category}: ${symptom.category} | ${localizations.severity}: ${symptom.severity}'),
            trailing: Text(
              DateFormat('HH:mm').format(symptom.createdAt.toLocal()),
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        const SizedBox(height: 20),
        EntitySection<MedicationModel>(
          title: localizations.medication,
          items: medicationsList,
          isLoading: medicationsLoading,
          error: medicationsError,
          onTap: (medication) => showModal(
            context,
            MedicationEditorModal(ref: ref, existing: medication),
          ),
          onAdd: () => showModal(context, MedicationEditorModal(ref: ref)),
          itemBuilder: (medication) {
            final selectedDate = ref.watch(selectedDateProvider);
            final takenCount = medication.getTakenCountForDate(selectedDate);
            final timesPerDay = medication.timesPerDay;

            return ListTile(
              title: Text(medication.name),
              subtitle: Text(
                  '${localizations.dose}: ${medication.dose} ${medication.unit}'),
              trailing: timesPerDay <= 1
                  ? StatefulBuilder(
                      builder: (context, setState) {
                        return Checkbox(
                          value: takenCount >= 1,
                          onChanged: (bool? value) async {
                            setState(() {});
                            try {
                              final newCount = (value == true) ? 1 : 0;
                              final controller =
                                  ref.read(trackerControllerProvider);
                              await controller.updateMedication(
                                id: medication.id,
                                newCount: newCount,
                                forDate: selectedDate,
                              );
                            } catch (e) {
                              setState(() {});
                              SnackBar(
                                  content: Text(
                                      '${localizations.failedToUpdate}: $e'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '${localizations.failedToUpdate}: $e')),
                              );
                            }
                          },
                        );
                      },
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: takenCount > 0
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                          ),
                          onPressed: takenCount > 0
                              ? () async {
                                  final newCount = takenCount - 1;
                                  final controller =
                                      ref.read(trackerControllerProvider);
                                  await controller.updateMedication(
                                    id: medication.id,
                                    newCount: newCount,
                                    forDate: selectedDate,
                                  );
                                }
                              : null,
                        ),
                        Text(
                          '$takenCount/$timesPerDay',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: takenCount < timesPerDay
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                          ),
                          onPressed: takenCount < timesPerDay
                              ? () async {
                                  final newCount = takenCount + 1;
                                  final controller =
                                      ref.read(trackerControllerProvider);
                                  await controller.updateMedication(
                                    id: medication.id,
                                    newCount: newCount,
                                    forDate: selectedDate,
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
            );
          },
        ),
        const SizedBox(height: 20),
        EntitySection<TaskModel>(
            title: localizations.tasks,
            items: tasksList,
            isLoading: tasksLoading,
            error: tasksError,
            onTap: (task) =>
                showModal(context, TaskEditorModal(ref: ref, existing: task)),
            onAdd: () => showModal(context, TaskEditorModal(ref: ref)),
            itemBuilder: (task) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                      // Move the completion calculation inside StatefulBuilder
                      bool localIsCompleted =
                          task.status == 'Done' || task.completedAt != null;

                      // Also calculate visual completion state for styling
                      final isCompleted = localIsCompleted;

                      return ListTile(
                        leading: Icon(
                          Icons.task_alt,
                          color: isCompleted
                              ? theme.colorScheme.primary.withValues(alpha: 0.7)
                              : theme.colorScheme.primary,
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          '${task.dueDate != null ? "${localizations.due}: ${DateFormat('EEE, d MMMM').format(task.dueDate!.toLocal())}" : localizations.noDueDate} | ${localizations.status}: ${_getLocalizedStatus(task.status, localizations)}',
                          style: TextStyle(
                            color: isCompleted
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Checkbox(
                          value: localIsCompleted,
                          onChanged: (value) async {
                            // Store previous state for potential revert
                            final previousState = localIsCompleted;

                            // Optimistic UI update - update immediately
                            setState(() {
                              localIsCompleted = value ?? false;
                            });

                            try {
                              final controller =
                                  ref.read(trackerControllerProvider);

                              // Use the controller's updateTask method with proper status and completedAt handling
                              await controller.updateTask(
                                task.id,
                                task.title,
                                task.description,
                                (value ?? false)
                                    ? 'Done'
                                    : 'In Progress', // Match the model's logic
                                task.dueDate,
                                (value ?? false)
                                    ? selectedDate
                                    : null, // completedAt
                                task.estimatedTime,
                                task.priority,
                                null,
                                task.startTime,
                                task.endTime,
                              );
                            } catch (e) {
                              // Revert to previous state on error
                              setState(() {
                                localIsCompleted = previousState;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '${localizations.failedToUpdate}: $e')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),

                  // Display subtasks if parent has them flagged
                  if (task.hasSubtasks)
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
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
                            ref: ref,
                          ),
                        ],
                      ),
                    )
                ],
              );
            }),
        const SizedBox(height: 20),
        EntitySection<HabitModel>(
          title: localizations.habits,
          items: habitsList,
          isLoading: habitsLoading,
          error: habitsError,
          onTap: (habit) => showModal(
            context,
            HabitEditorModal(ref: ref, existing: habit),
          ),
          onAdd: () => showModal(context, HabitEditorModal(ref: ref)),
          itemBuilder: (habit) {
            final selectedDate = ref.watch(selectedDateProvider);
            final displayDate = selectedDate;

            // Check if habit is completed for the display date
            final isCompleted = habit.completedDates.any((d) =>
                d.year == displayDate.year &&
                d.month == displayDate.month &&
                d.day == displayDate.day);

            // Frequency text function
            String getFrequencyText() {
              switch (habit.frequency) {
                case 1:
                  return localizations.daily;
                case 7:
                  return localizations.weekly;
                case -1:
                  final days = habit.customDays?.join(', ') ?? '';
                  return '${localizations.monthlyDays} $days';
                default:
                  return '';
              }
            }

            return ListTile(
              leading: Icon(
                Icons.sync_rounded,
                color: isCompleted
                    ? theme.colorScheme.primary.withValues(alpha: 0.7)
                    : theme.colorScheme.primary,
              ),
              title: Text(
                habit.title,
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                '${habit.description.isNotEmpty ? habit.description : localizations.noDescription} | ${localizations.frequency}: ${getFrequencyText()}',
              ),
              trailing: StatefulBuilder(
                builder: (context, setState) {
                  return Checkbox(
                    value: isCompleted,
                    onChanged: (value) async {
                      // Optimistic UI update
                      setState(() {});

                      final controller = ref.read(trackerControllerProvider);
                      try {
                        await controller.updateHabit(
                          habit.id,
                          habit.title,
                          habit.description,
                          habit.frequency,
                          habit.customDays,
                          value ?? false,
                        );
                      } catch (e) {
                        // Revert on error
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('${localizations.failedToUpdate}: $e')),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

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
}
