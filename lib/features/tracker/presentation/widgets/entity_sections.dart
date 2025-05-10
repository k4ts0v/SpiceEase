import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/features/tracker/presentation/modals.dart';
import 'package:spiceease/features/tracker/presentation/tracker_controller.dart';
import 'package:spiceease/features/tracker/presentation/widgets/entity_section.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class EntitySections extends ConsumerWidget {
  final Function(BuildContext, Widget) showModal;
  final DateTime selectedDate;

  const EntitySections({
    Key? key,
    required this.showModal,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptoms = ref.watch(symptomStateNotifierProvider(selectedDate));
    final medications =
        ref.watch(medicationStateNotifierProvider(selectedDate));
    final tasks = ref.watch(taskStateNotifierProvider(selectedDate));
    final habits = ref.watch(habitStateNotifierProvider(selectedDate));

    // Extract data, loading status, and errors manually
    List<SymptomModel> symptomsList =
        symptoms is List<SymptomModel> ? symptoms : [];
    bool symptomsLoading = false;
    String? symptomsError;

    List<MedicationModel> medicationsList =
        medications is List<MedicationModel> ? medications : [];
    bool medicationsLoading = false;
    String? medicationsError;

    List<TaskModel> tasksList = tasks is List<TaskModel> ? tasks : [];
    bool tasksLoading = false;
    String? tasksError;

    List<HabitModel> habitsList = habits is List<HabitModel> ? habits : [];
    bool habitsLoading = false;
    String? habitsError;

    final today = DateTime.now();
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
              style: const TextStyle(color: Colors.grey),
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
            // For all medications, use a consistent ListTile
            return ListTile(
              title: Text(medication.name),
              subtitle: Text(
                  '${localizations.dose}: ${medication.dose} ${medication.unit}' +
                      (medication.timesPerDay <= 1
                          ? ' | ${medication.takenTimes > 0 ? localizations.takenS : localizations.notTaken}'
                          : ' | ${medication.takenTimes}/${medication.timesPerDay} ${localizations.taken}')),
              trailing: medication.timesPerDay <= 1
                  ? // Simple checkbox for once-daily medications
                  Checkbox(
                      value: medication.takenTimes > 0,
                      onChanged: (value) async {
                        if (value != null) {
                          final newTakenTimes =
                              value ? medication.timesPerDay : 0;
                          await ref
                              .read(trackerControllerProvider)
                              .updateMedication(
                                medication.id,
                                medication.name,
                                medication.dose,
                                medication.unit,
                                newTakenTimes,
                                medication.frequency,
                                medication.customDays,
                                medication.timesPerDay,
                                value ? DateTime.now() : null,
                              );
                        }
                      },
                    )
                  : // For multi-dose medications, show +/- buttons
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                          onPressed: medication.takenTimes > 0
                              ? () async {
                                  await ref
                                      .read(trackerControllerProvider)
                                      .updateMedication(
                                        medication.id,
                                        medication.name,
                                        medication.dose,
                                        medication.unit,
                                        (medication.takenTimes - 1),
                                        medication.frequency,
                                        medication.customDays,
                                        medication.timesPerDay,
                                        medication.lastTaken,
                                      );
                                }
                              : null,
                          color: Colors.red,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                medication.takenTimes >= medication.timesPerDay
                                    ? Colors.green
                                    : Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${medication.takenTimes}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                          onPressed:
                              medication.takenTimes < medication.timesPerDay
                                  ? () async {
                                      await ref
                                          .read(trackerControllerProvider)
                                          .updateMedication(
                                            medication.id,
                                            medication.name,
                                            medication.dose,
                                            medication.unit,
                                            (medication.takenTimes + 1),
                                            medication.frequency,
                                            medication.customDays,
                                            medication.timesPerDay,
                                            medication.lastTaken,
                                          );
                                    }
                                  : null,
                          color: Colors.green,
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
              final isCompleted = task.completedAt != null &&
                  task.completedAt!.year == today.year &&
                  task.completedAt!.month == today.month &&
                  task.completedAt!.day == today.day;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.task_alt),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${task.dueDate != null ? "${localizations.due}: ${DateFormat('EEE, d MMMM').format(task.dueDate!.toLocal())}" : localizations.noDueDate} | ${localizations.status}: ${task.status}',
                    ),
                    trailing: Checkbox(
                      value: task.status == 'Done' || task.completedAt != null,
                      onChanged: (value) async {
                        final service = ref.read(taskServiceProvider);
                        final currentTask = await service.getTaskById(task.id);

                        if (currentTask != null) {
                          final updatedTask = currentTask.toggleCompletion();
                          await service.updateTask(currentTask.id, updatedTask);
                          ref.refresh(taskStateNotifierProvider(selectedDate));
                        }
                      },
                    ),
                  ),

                  // Display subtasks if present
                  if (task.subtasks != null && task.subtasks!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 0.0), // No extra padding needed
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              "${localizations.subtasks} (${task.subtasks!.length})",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          SubtaskList(
                            subtasks: task.subtasks!,
                            parentTask: task, // Pass the parent task
                            onToggle: (subtask) async {
                              final ctrl = ref.read(trackerControllerProvider);
                              final updated = subtask.copyWith(
                                  completed: !subtask.completed);
                              await ctrl.updateSubtask(
                                task.id,
                                subtask,
                                updated.title,
                                updated.completed,
                                rawTimeValue: updated.rawTimeValue ?? '',
                              );
                            }, ref: ref,
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
            // Original habit builder code
            final isCompleted = habit.lastCompleted != null &&
                habit.lastCompleted!.year == today.year &&
                habit.lastCompleted!.month == today.month &&
                habit.lastCompleted!.day == today.day;

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
              leading: const Icon(Icons.sync_rounded),
              title: Text(
                habit.title,
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text(
                '${habit.description.isNotEmpty ? habit.description : localizations.noDescription} | ${localizations.frequency}: ${getFrequencyText()}',
              ),
              trailing: Checkbox(
                value: isCompleted,
                onChanged: (value) async {
                  await ref.read(trackerControllerProvider).updateHabit(
                        habit.id,
                        habit.title,
                        habit.description,
                        habit.frequency,
                        habit.customDays,
                        markAsCompleted: value ?? false,
                      );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
