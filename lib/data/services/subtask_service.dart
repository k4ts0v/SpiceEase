import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/repositories/subtask_repository.dart';
import 'package:spiceease/data/services/task_service.dart';

/// A service layer that coordinates subtask-related business logic.
///
/// This class depends on the [SubtaskRepository] and provides higher-level
/// operations for managing subtasks. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class SubtaskService {
  final SubtaskRepository
      _repository; // Dependency for accessing the repository.
  final Ref _ref;

  const SubtaskService(this._repository, this._ref);

  /// Retrieves all subtasks by delegating to the repository.
  Future<List<SubtaskModel>> getAllSubtasks() => _repository.getAllSubtasks();

  /// Retrieves a specific subtask by ID through the repository.
  Future<SubtaskModel?> getSubtaskById(String id) =>
      _repository.getSubtaskById(id);

  /// Creates a new subtask by delegating to the repository.
  Future<SubtaskModel> createSubtask(SubtaskModel subtask) =>
      _repository.createSubtask(subtask);

  /// Updates an existing subtask by delegating to the repository.
  Future<SubtaskModel> updateSubtask(String id, SubtaskModel subtask) =>
      _repository.updateSubtask(id, subtask);

  /// Deletes a subtask by delegating to the repository.
  Future<void> deleteSubtask(String id) => _repository.deleteSubtask(id);

  // Task-specific operations
  Future<List<SubtaskModel>> getSubtasksForTask(String taskId) =>
      _repository.getSubtasksForTask(taskId);

  // Task-coordination methods - service layer is the right place for these
  Future<SubtaskModel> createSubtaskAndUpdateParent(
      SubtaskModel subtask) async {
    // First create the subtask using the repository
    final createdSubtask = await _repository.createSubtask(subtask);
    final _taskService = _ref.read(taskServiceProvider);

    // Then update the parent task to mark hasSubtasks=true
    final parentTask = await _taskService.getTaskById(subtask.taskId);
    if (parentTask != null && !parentTask.hasSubtasks) {
      await _taskService.updateTask(
          parentTask.id, parentTask.copyWith(hasSubtasks: true));
    }

    return createdSubtask;
  }

  Future<void> deleteSubtaskAndUpdateParent(String id) async {
    final subtask = await _repository.getSubtaskById(id);
    if (subtask == null) return;

    final taskId = subtask.taskId;

    // Delete the subtask
    await _repository.deleteSubtask(id);

    final _taskService = _ref.read(taskServiceProvider);
    // Check if parent task has any remaining subtasks
    final remainingSubtasks = await _repository.getSubtasksForTask(taskId);
    if (remainingSubtasks.isEmpty) {
      final parentTask = await _taskService.getTaskById(taskId);
      if (parentTask != null && parentTask.hasSubtasks) {
        // Update parent to reflect it no longer has subtasks
        await _taskService.updateTask(
            taskId, parentTask.copyWith(hasSubtasks: false));
      }
    }
  }
}
