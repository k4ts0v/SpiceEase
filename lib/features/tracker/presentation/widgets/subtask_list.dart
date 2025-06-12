import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';
import 'package:spiceease/features/tracker/presentation/tracker_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class SubtaskList extends ConsumerWidget {
  final String parentTaskId;
  final TaskModel parentTask;
  final WidgetRef ref;

  const SubtaskList({
    super.key,
    required this.parentTaskId,
    required this.parentTask,
    required this.ref,
  });

  // Helper method to get localized version of the status
  String _getLocalizedStatus(String? status, AppLocalizations localizations) {
    if (status == null) return localizations.todo;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final subtasksAsync = ref.watch(subtaskStateNotifierProvider(parentTaskId));

    return subtasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Text('${localizations.errorLoadingSubtasks}: $error'),
      data: (subtasks) {
        debugPrint(
            'SubtaskList: Found ${subtasks.length} subtasks for task $parentTaskId');

        final sortedSubtasks = List<SubtaskModel>.from(subtasks)
          ..sort((a, b) => a.order.compareTo(b.order));

        List<Widget> subtaskWidgets = sortedSubtasks.map<Widget>((subtask) {
          debugPrint(
              'Rendering subtask: ${subtask.id}, order: ${subtask.order}, title: ${subtask.title}, rawTimeValue: ${subtask.rawTimeValue}');

          return Container(
            margin: const EdgeInsets.only(left: 15.0),
            child: ListTile(
              contentPadding: const EdgeInsets.only(
                  left: 0, right: 0), // Adjusted for new trailing
              leading: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.task_alt, size: 20),
              ),
              title: Text(
                subtask.title,
                style: TextStyle(
                  decoration:
                      subtask.completed ? TextDecoration.lineThrough : null,
                  color: subtask.completed
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurface,
                  fontSize: 14.0,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator
                  Text(
                    '${localizations.status}: ${_getLocalizedStatus(subtask.status, localizations)}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  // Time estimate
                  Text(
                    subtask.rawTimeValue != null &&
                            subtask.rawTimeValue!.isNotEmpty
                        ? '${localizations.estimatedTimeLabel}: ${subtask.rawTimeValue}'
                        : '${localizations.estimatedTimeLabel}: ${localizations.noTimeEstimate}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => SubtaskEditorModal(
                    ref: ref,
                    parentTask: parentTask,
                    subtask: subtask,
                  ),
                );
              },
              // In the SubtaskList widget's checkbox onChanged method
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    child: Checkbox(
                      value: subtask.completed,
                      onChanged: (_) async {
                        // Capture controller reference before async operation
                        final ctrl = ref.read(trackerControllerProvider);

                        try {
                          // Calculate the new status based on completion
                          final newCompleted = !subtask.completed;
                          final newStatus = newCompleted ? 'done' : 'todo';

                          await ctrl.updateSubtask(
                            parentTaskId,
                            subtask,
                            subtask.title,
                            newCompleted,
                            newStatus,
                            subtask.rawTimeValue ?? '',
                            subtask.startTime,
                            subtask.endTime,
                          );
                        } catch (e) {
                          debugPrint('Error updating subtask completion: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Failed to update subtask: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();

        if (subtasks.isEmpty) {
          subtaskWidgets.add(Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 8.0, bottom: 8.0),
            child: Text(localizations.noSubtasks),
          ));
        }

        subtaskWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.add, size: 14),
              label: Text(localizations.addNew),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    final titleController = TextEditingController();
                    return AlertDialog(
                      // Fix: Use theme-aware background color instead of hardcoded white
                      backgroundColor: theme.colorScheme.surface,
                      title: Text(
                        localizations.addNewSubtask,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      content: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: localizations.title,
                          labelStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.colorScheme.primary),
                          ),
                        ),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            localizations.cancel,
                            style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (titleController.text.trim().isNotEmpty) {
                              Navigator.of(dialogContext).pop();
                              final ctrl = ref.read(trackerControllerProvider);

                              // Fix: Calculate the next order to add subtask to the bottom
                              final currentSubtasks = subtasks;
                              final nextOrder = currentSubtasks.isEmpty
                                  ? 0
                                  : currentSubtasks
                                          .map((s) => s.order)
                                          .reduce((a, b) => a > b ? a : b) +
                                      1;

                              await ctrl.createSubtask(
                                parentTaskId,
                                titleController.text.trim(),
                                '', // Default status is empty, will be set to 'todo'
                                nextOrder, // Add the order parameter
                              );
                            }
                          },
                          child: Text(
                            localizations.addNewSubtask,
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );

        return Column(children: subtaskWidgets);
      },
    );
  }
}
