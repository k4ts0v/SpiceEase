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

class EntitySections extends ConsumerStatefulWidget {
  final Function(BuildContext, Widget) showModal;
  final DateTime selectedDate;

  const EntitySections({
    super.key,
    required this.showModal,
    required this.selectedDate,
  });

  @override
  ConsumerState<EntitySections> createState() => _EntitySectionsState();
}

class _EntitySectionsState extends ConsumerState<EntitySections> {
  // Local state for optimistic updates
  final Map<String, int> _localMedicationCounts = {};
  final Map<String, bool> _localTaskCompletion = {};
  final Map<String, bool> _localHabitCompletion = {};

  @override
  void didUpdateWidget(EntitySections oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear local state when date changes
    if (widget.selectedDate != oldWidget.selectedDate) {
      _localMedicationCounts.clear();
      _localTaskCompletion.clear();
      _localHabitCompletion.clear();
    }
  }

  // Helper methods for local state
  int _getEffectiveMedicationCount(MedicationModel medication) {
    return _localMedicationCounts[medication.id] ??
        medication.getTakenCountForDate(widget.selectedDate);
  }

  bool _getEffectiveTaskCompletion(TaskModel task) {
    return _localTaskCompletion[task.id] ??
        (task.status == 'Done' || task.completedAt != null);
  }

  bool _getEffectiveHabitCompletion(HabitModel habit) {
    if (_localHabitCompletion.containsKey(habit.id)) {
      return _localHabitCompletion[habit.id]!;
    }

    final displayDate = widget.selectedDate;
    return habit.completedDates.any((d) =>
        d.year == displayDate.year &&
        d.month == displayDate.month &&
        d.day == displayDate.day);
  }

  @override
  Widget build(BuildContext context) {
    final symptoms =
        ref.watch(symptomStateNotifierProvider(widget.selectedDate));
    final medications =
        ref.watch(medicationStateNotifierProvider(widget.selectedDate));
    final tasks = ref.watch(taskStateNotifierProvider(widget.selectedDate));
    final habits = ref.watch(habitStateNotifierProvider(widget.selectedDate));
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
          onTap: (symptom) => widget.showModal(
            context,
            SymptomEditorModal(ref: ref, existing: symptom),
          ),
          onAdd: () => widget.showModal(context, SymptomEditorModal(ref: ref)),
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
          onTap: (medication) => widget.showModal(
            context,
            MedicationEditorModal(ref: ref, existing: medication),
          ),
          onAdd: () =>
              widget.showModal(context, MedicationEditorModal(ref: ref)),
          itemBuilder: (medication) {
            final takenCount = _getEffectiveMedicationCount(medication);
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
                  '${localizations.dose}: ${medication.dose} ${medication.unit}'),
              trailing: timesPerDay <= 1
                  ? Checkbox(
                      value: takenCount >= 1,
                      onChanged: (bool? value) async {
                        final newIsCompleted = value == true;

                        // Optimistic UI update
                        setState(() {
                          _localMedicationCounts[medication.id] =
                              newIsCompleted ? 1 : 0;
                        });

                        try {
                          final controller =
                              ref.read(trackerControllerProvider);
                          await controller.updateMedication(
                              id: medication.id,
                              isCompleted: newIsCompleted,
                              forDate: widget.selectedDate,
                              skipRefresh: true);
                        } catch (e) {
                          // Revert optimistic update on error
                          if (mounted) {
                            setState(() {
                              _localMedicationCounts.remove(medication.id);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${localizations.failedToUpdate}: $e')),
                            );
                          }
                        }
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
                                  final wasCompleted = isCompleted;
                                  final willBeCompleted =
                                      newCount >= timesPerDay;

                                  // Optimistic UI update
                                  setState(() {
                                    _localMedicationCounts[medication.id] =
                                        newCount;
                                  });

                                  // Only update backend if completion status changes
                                  if (wasCompleted && !willBeCompleted) {
                                    try {
                                      final controller =
                                          ref.read(trackerControllerProvider);
                                      await controller.updateMedication(
                                          id: medication.id,
                                          isCompleted: false,
                                          forDate: widget.selectedDate,
                                          skipRefresh: true);
                                    } catch (e) {
                                      // Revert on error
                                      if (mounted) {
                                        setState(() {
                                          _localMedicationCounts[
                                              medication.id] = takenCount;
                                        });
                                      }
                                    }
                                  }
                                }
                              : null,
                        ),
                        Text(
                          '$takenCount/$timesPerDay',
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.green
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: !isCompleted
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                          ),
                          onPressed: !isCompleted
                              ? () async {
                                  final newCount = takenCount + 1;
                                  final willBeCompleted =
                                      newCount >= timesPerDay;

                                  // Optimistic UI update
                                  setState(() {
                                    _localMedicationCounts[medication.id] =
                                        newCount;
                                  });

                                  // Update backend if now completed
                                  if (willBeCompleted) {
                                    try {
                                      final controller =
                                          ref.read(trackerControllerProvider);
                                      await controller.updateMedication(
                                          id: medication.id,
                                          isCompleted: true,
                                          forDate: widget.selectedDate,
                                          skipRefresh: true);
                                    } catch (e) {
                                      // Revert on error
                                      if (mounted) {
                                        setState(() {
                                          _localMedicationCounts[
                                              medication.id] = takenCount;
                                        });
                                      }
                                    }
                                  }
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
          onTap: (task) => widget.showModal(
              context, TaskEditorModal(ref: ref, existing: task)),
          onAdd: () => widget.showModal(context, TaskEditorModal(ref: ref)),
          itemBuilder: (task) {
            // Use local state for completion status
            final localIsCompleted = _getEffectiveTaskCompletion(task);

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
                      decoration:
                          localIsCompleted ? TextDecoration.lineThrough : null,
                      color: localIsCompleted
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '${task.dueDate != null ? "${localizations.due}: ${DateFormat('EEE, d MMMM').format(task.dueDate!.toLocal())}" : localizations.noDueDate} | ${localizations.status}: ${_getLocalizedStatus(task.status, localizations)}',
                    style: TextStyle(
                      color: localIsCompleted
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: Checkbox(
                    value: localIsCompleted,
                    onChanged: (value) async {
                      final newIsCompleted = value ?? false;

                      // Update local state immediately
                      setState(() {
                        _localTaskCompletion[task.id] = newIsCompleted;
                      });

                      // Delay the backend update to prevent immediate refreshes
                      Future.delayed(const Duration(milliseconds: 100),
                          () async {
                        try {
                          final controller =
                              ref.read(trackerControllerProvider);
                          await controller.updateTask(
                            task.id,
                            task.title,
                            task.description,
                            newIsCompleted ? 'Done' : 'In Progress',
                            task.dueDate,
                            newIsCompleted ? widget.selectedDate : null,
                            task.estimatedTime,
                            task.priority,
                            null,
                            task.startTime,
                            task.endTime,
                            skipRefresh: true,
                          );
                        } catch (e) {
                          // Revert local state on error
                          if (mounted) {
                            setState(() {
                              _localTaskCompletion.remove(task.id);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${localizations.failedToUpdate}: $e'),
                              ),
                            );
                          }
                        }
                      });
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
                  )
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        EntitySection<HabitModel>(
          title: localizations.habits,
          items: habitsList,
          isLoading: habitsLoading,
          error: habitsError,
          onTap: (habit) => widget.showModal(
            context,
            HabitEditorModal(ref: ref, existing: habit),
          ),
          onAdd: () => widget.showModal(context, HabitEditorModal(ref: ref)),
          itemBuilder: (habit) {
            // Use local state for completion status
            final localIsCompleted = _getEffectiveHabitCompletion(habit);

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
                color: localIsCompleted
                    ? theme.colorScheme.primary.withValues(alpha: 0.7)
                    : theme.colorScheme.primary,
              ),
              title: Text(
                habit.title,
                style: TextStyle(
                  decoration:
                      localIsCompleted ? TextDecoration.lineThrough : null,
                  color: localIsCompleted
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                '${habit.description.isNotEmpty ? habit.description : localizations.noDescription} | ${localizations.frequency}: ${getFrequencyText()}',
              ),
              trailing: Checkbox(
                value: localIsCompleted,
                onChanged: (value) async {
                  final newIsCompleted = value ?? false;

                  // Update local state immediately
                  setState(() {
                    _localHabitCompletion[habit.id] = newIsCompleted;
                  });

                  // Delay the backend update
                  Future.delayed(const Duration(milliseconds: 100), () async {
                    try {
                      final controller = ref.read(trackerControllerProvider);
                      await controller.updateHabit(
                        habit.id,
                        habit.title,
                        habit.description,
                        habit.frequency,
                        habit.customDays,
                        newIsCompleted,
                        skipRefresh: true,
                      );
                    } catch (e) {
                      // Revert local state on error
                      if (mounted) {
                        setState(() {
                          _localHabitCompletion.remove(habit.id);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${localizations.failedToUpdate}: $e'),
                          ),
                        );
                      }
                    }
                  });
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
