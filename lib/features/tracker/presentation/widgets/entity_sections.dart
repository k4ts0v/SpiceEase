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
              final isToday = selectedDate.year == DateTime.now().year &&
                  selectedDate.month == DateTime.now().month &&
                  selectedDate.day == DateTime.now().day;

              final isTakenToday = medication.isTakenOnDate(selectedDate);
              final displayTakenTimes =
                  isTakenToday ? medication.takenTimes : 0;

              return ListTile(
                title: Text(medication.name),
                subtitle: Text(
                  '${localizations.dose}: ${medication.dose} ${medication.unit}' +
                      (medication.timesPerDay <= 1
                          ? ' | ${displayTakenTimes > 0 ? localizations.takenS : localizations.notTaken}'
                          : ' | $displayTakenTimes/${medication.timesPerDay} ${localizations.taken}'),
                ),
                trailing: medication.timesPerDay <= 1
                    ? Checkbox(
                        value: displayTakenTimes >= medication.timesPerDay,
                        onChanged: (bool? value) async {
                          final service = ref.read(medicationServiceProvider);
                          MedicationModel updatedMedication;

                          if (value == true) {
                            updatedMedication = medication.copyWith(
                              takenTimes: medication.timesPerDay,
                              lastTaken: selectedDate,
                              nextDueDate: medication.calculateNextDueDate(),
                              updatedAt: DateTime.now(),
                            );
                          } else {
                            updatedMedication = medication.copyWith(
                              takenTimes: 0,
                              lastTaken: isToday ? null : medication.lastTaken,
                              nextDueDate:
                                  isToday ? null : medication.nextDueDate,
                              updatedAt: DateTime.now(),
                            );
                          }

                          await service.updateMedication(
                              medication.id, updatedMedication);
                          ref.invalidate(
                              medicationStateNotifierProvider(selectedDate));
                        },
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: displayTakenTimes > 0
                                ? () async {
                                    final service =
                                        ref.read(medicationServiceProvider);
                                    int newTimes = displayTakenTimes - 1;

                                    MedicationModel updatedMedication =
                                        medication.copyWith(
                                      takenTimes: newTimes,
                                      lastTaken:
                                          newTimes > 0 ? selectedDate : null,
                                      nextDueDate: newTimes >=
                                              medication.timesPerDay
                                          ? medication.calculateNextDueDate()
                                          : null,
                                      updatedAt: DateTime.now(),
                                    );

                                    await service.updateMedication(
                                        medication.id, updatedMedication);
                                    ref.invalidate(
                                        medicationStateNotifierProvider(
                                            selectedDate));
                                  }
                                : null,
                          ),
                          Text('$displayTakenTimes/${medication.timesPerDay}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: displayTakenTimes <
                                    medication.timesPerDay
                                ? () async {
                                    final service =
                                        ref.read(medicationServiceProvider);
                                    int newTimes = displayTakenTimes + 1;

                                    MedicationModel updatedMedication =
                                        medication.copyWith(
                                      takenTimes: newTimes,
                                      lastTaken: selectedDate,
                                      nextDueDate: newTimes >=
                                              medication.timesPerDay
                                          ? medication.calculateNextDueDate()
                                          : null,
                                      updatedAt: DateTime.now(),
                                    );

                                    await service.updateMedication(
                                        medication.id, updatedMedication);
                                    ref.invalidate(
                                        medicationStateNotifierProvider(
                                            selectedDate));
                                  }
                                : null,
                          ),
                        ],
                      ),
              );
            }),
        const SizedBox(height: 20),
        //TODO: Bug: Tasks are not being displayed in the REST implementation. Error: flutter: TaskStateNotifier - Error: type 'Null' is not a subtype of type 'List<dynamic>' in type cast
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          // Use the updated SubtaskList widget
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
