import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/features/tracker/presentation/modals.dart';
import 'package:spiceease/features/tracker/presentation/tracker_controller.dart';
import 'package:spiceease/features/tracker/presentation/widgets/entity_section.dart';

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
    final tasks = ref.watch(taskStateNotifierProvider(selectedDate));
    final habits = ref.watch(habitStateNotifierProvider(selectedDate));

    // Add these prints to debug
    print("EntitySections - Selected date: $selectedDate");
    print("EntitySections - Symptoms: ${symptoms.length}");
    print("EntitySections - Tasks: ${tasks.length}");
    print(
        "EntitySections - Tasks titles: ${tasks.map((t) => t.title).toList()}");
    print("EntitySections - Habits: ${habits.length}");

    final today = DateTime.now();

    return Column(
      children: [
        EntitySection<SymptomModel>(
          title: 'Symptoms',
          items: symptoms,
          isLoading: false,
          error: null,
          onTap: (symptom) => showModal(
            context,
            SymptomEditorModal(ref: ref, existing: symptom),
          ),
          onAdd: () => showModal(context, SymptomEditorModal(ref: ref)),
          itemBuilder: (symptom) => ListTile(
            title: Text(symptom.name),
            subtitle: Text(
                'Category: ${symptom.category} | Severity: ${symptom.severity}'),
            trailing: Text(
              DateFormat('HH:mm').format(symptom.createdAt.toLocal()),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 20),
        EntitySection<TaskModel>(
          title: 'Tasks',
          items: tasks,
          isLoading: false,
          error: null,
          onTap: (task) =>
              showModal(context, TaskEditorModal(ref: ref, existing: task)),
          onAdd: () => showModal(context, TaskEditorModal(ref: ref)),
          // ...existing code...
          itemBuilder: (task) {
            final today = DateTime.now();
            final isCompleted = task.completedAt != null &&
                task.completedAt!.year == today.year &&
                task.completedAt!.month == today.month &&
                task.completedAt!.day == today.day;

            return Column(
              mainAxisSize: MainAxisSize.min,
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
                    '${task.dueDate != null ? "Due: ${DateFormat('EEE, d MMMM').format(task.dueDate!.toLocal())}" : "No due date"} | Status: ${task.status}',
                    style: TextStyle(
                      color:
                          isCompleted ? Colors.grey : const Color(0xFF5A5A5A),
                    ),
                  ),
                  trailing: Checkbox(
                    value: isCompleted,
                    onChanged: (value) async {
                      final newStatus = value == true ? 'Done' : 'Pending';
                      final newCompletedAt =
                          value == true ? DateTime.now() : null;

                      await ref.read(trackerControllerProvider).updateTask(
                            task.id,
                            task.title,
                            task.description,
                            newStatus,
                            task.dueDate,
                            newCompletedAt,
                            task.estimatedTime,
                            task.estimatedUnit,
                            task.priority,
                            task.subtasks,
                          );
                    },
                  ),
                ),
                // Replace the subtask mapping code with this:

                if (task.subtasks != null && task.subtasks!.isNotEmpty)
                  ...task.subtasks!.map(
                    (subtask) => ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(width: 32),
                          Icon(Icons.task_alt),
                        ],
                      ),
                      title: Text(
                        '${subtask.title}',
                        style: TextStyle(
                          decoration: subtask.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: subtask.completed ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text(subtask.rawTimeValue != null &&
                              subtask.rawTimeUnit != null
                          ? '${subtask.rawTimeValue} ${subtask.rawTimeUnit}'
                          : 'No time estimate'),
                      // Make subtask clickable
                      onTap: () {
                        showModal(
                          context,
                          SubtaskEditorModal(
                            ref: ref,
                            parentTask: task,
                            subtask: subtask,
                          ),
                        );
                      },
                      // Keep existing checkbox for quick toggling
                      trailing: Checkbox(
                        value: subtask.completed,
                        onChanged: (value) async {
                          final updatedSubtasks = [...task.subtasks!];
                          final index = updatedSubtasks.indexOf(subtask);
                          if (index != -1) {
                            updatedSubtasks[index] = subtask.copyWith(
                              completed: value ?? false,
                            );

                            await ref
                                .read(trackerControllerProvider)
                                .updateTask(
                                  task.id,
                                  task.title,
                                  task.description,
                                  task.status,
                                  task.dueDate,
                                  task.completedAt,
                                  task.estimatedTime,
                                  task.estimatedUnit,
                                  task.priority,
                                  updatedSubtasks,
                                );
                          }
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        EntitySection<HabitModel>(
          title: 'Habits',
          items: habits,
          isLoading: false,
          error: null,
          onTap: (habit) => showModal(
            context,
            HabitEditorModal(ref: ref, existing: habit),
          ),
          onAdd: () => showModal(context, HabitEditorModal(ref: ref)),
          itemBuilder: (habit) {
            final isCompleted = habit.lastCompleted != null &&
                habit.lastCompleted!.year == today.year &&
                habit.lastCompleted!.month == today.month &&
                habit.lastCompleted!.day == today.day;

            String getFrequencyText() {
              switch (habit.frequency) {
                case 1:
                  return 'daily';
                case 7:
                  return 'weekly';
                case -1:
                  final days = habit.customDays?.join(', ') ?? '';
                  return 'monthly (days $days)';
                default:
                  return '';
              }
            }

            return ListTile(
              leading: const Icon(Icons
                  .sync_rounded), // Changed to match tasks but with different icon
              title: Text(
                habit.title,
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text(
                '${habit.description.isNotEmpty ? habit.description : 'No description'} | Frequency: ${getFrequencyText()}',
                style: TextStyle(
                  color: isCompleted ? Colors.grey : Color(0xFF5A5A5A),
                ),
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
                  }),
            );
          },
        ),
      ],
    );
  }
}
