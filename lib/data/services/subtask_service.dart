import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/repositories/subtask_repository.dart';

class SubtaskService {
  final SubtaskRepository _repository;
  final Ref _ref;

  const SubtaskService(this._repository, this._ref);

  /// Filters subtasks to show completed subtasks until their completion date (not after)
  List<SubtaskModel> _filterSubtasksForSelectedDate(
      List<SubtaskModel> subtasks, DateTime selectedDate) {
    final selectedDay = DateUtils.dateOnly(selectedDate);

    return subtasks.where((subtask) {
      // If subtask is completed, only show if selected date is on or before completion date
      if (subtask.completed && subtask.status.toLowerCase() == 'done') {
        DateTime? completionDate = subtask.completedAt ?? subtask.updatedAt;

        if (completionDate != null) {
          final completedDay = DateUtils.dateOnly(completionDate);
          // Show if selected date is on or before the completion date
          return selectedDay.isBefore(completedDay) ||
                 selectedDay.isAtSameMomentAs(completedDay);
        }
        // Subtask marked as done but no completion date - don't show it
        return false;
      }

      // Show non-completed subtasks
      return true;
    }).toList();
  }

  Future<List<SubtaskModel>> getAllSubtasks() => _repository.getAllSubtasks();

  Future<SubtaskModel?> getSubtaskById(String id) =>
      _repository.getSubtaskById(id);

  Future<SubtaskModel> createSubtask(SubtaskModel subtask) =>
      _repository.createSubtask(subtask);

  Future<SubtaskModel> updateSubtask(String id, SubtaskModel subtask) async {
    final updatedSubtask = await _repository.updateSubtask(id, subtask);
    await _updateParentTaskStatus(subtask.taskId);
    return updatedSubtask;
  }

  Future<void> deleteSubtask(String id) => _repository.deleteSubtask(id);

  // Regular method without filtering (for Kanban)
  Future<List<SubtaskModel>> getSubtasksForTask(String taskId) =>
      _repository.getSubtasksForTask(taskId);

  // Filtered method for tracker
  Future<List<SubtaskModel>> getSubtasksForTaskFiltered(
      String taskId, DateTime selectedDate) async {
    final subtasks = await _repository.getSubtasksForTask(taskId);
    return _filterSubtasksForSelectedDate(subtasks, selectedDate);
  }

  Future<SubtaskModel> createSubtaskAndUpdateParent(
      SubtaskModel subtask) async {
    final createdSubtask = await _repository.createSubtask(subtask);
    final taskService = _ref.read(taskServiceProvider);

    final parentTask = await taskService.getTaskById(subtask.taskId);
    if (parentTask != null && !parentTask.hasSubtasks) {
      await taskService.updateTask(
          parentTask.id, parentTask.copyWith(hasSubtasks: true));
    }

    return createdSubtask;
  }

  Future<void> deleteSubtaskAndUpdateParent(String id) async {
    final subtask = await _repository.getSubtaskById(id);
    if (subtask == null) return;

    final taskId = subtask.taskId;
    await _repository.deleteSubtask(id);

    final taskService = _ref.read(taskServiceProvider);
    final remainingSubtasks = await _repository.getSubtasksForTask(taskId);
    if (remainingSubtasks.isEmpty) {
      final parentTask = await taskService.getTaskById(taskId);
      if (parentTask != null && parentTask.hasSubtasks) {
        await taskService.updateTask(
            taskId, parentTask.copyWith(hasSubtasks: false));
      }
    } else {
      await _updateParentTaskStatus(taskId);
    }
  }

  Future<void> _updateParentTaskStatus(String taskId) async {
    final taskService = _ref.read(taskServiceProvider);
    final parentTask = await taskService.getTaskById(taskId);

    if (parentTask == null) return;

    // Use unfiltered subtasks for parent status calculation
    final subtasks = await _repository.getSubtasksForTask(taskId);

    if (subtasks.isEmpty) return;

    final completedSubtasks = subtasks
        .where((s) => s.completed || s.status.toLowerCase() == 'done')
        .length;
    final inProgressSubtasks = subtasks
        .where((s) =>
            !s.completed &&
            (s.status.toLowerCase() == 'in progress' ||
                s.status.toLowerCase() == 'in_progress'))
        .length;

    String newParentStatus = parentTask.status ?? 'todo';
    DateTime? newCompletedAt = parentTask.completedAt;

    if (completedSubtasks == subtasks.length) {
      newParentStatus = 'done';

      DateTime? latestCompletionDate;
      for (final subtask in subtasks) {
        if (subtask.completed && subtask.completedAt != null) {
          if (latestCompletionDate == null ||
              subtask.completedAt!.isAfter(latestCompletionDate)) {
            latestCompletionDate = subtask.completedAt;
          }
        }
      }

      newCompletedAt = latestCompletionDate ?? DateTime.now();
    } else if (completedSubtasks > 0 || inProgressSubtasks > 0) {
      newParentStatus = 'in_progress';
      newCompletedAt = null;
    } else {
      final currentParentStatus = parentTask.status?.toLowerCase() ?? '';
      if (currentParentStatus == 'done' ||
          currentParentStatus == 'in_progress') {
        newParentStatus = 'todo';
        newCompletedAt = null;
      }
    }

    if (newParentStatus != parentTask.status ||
        newCompletedAt != parentTask.completedAt) {
      final updatedParentTask = parentTask.copyWith(
        status: newParentStatus,
        completedAt: newCompletedAt,
        updatedAt: DateTime.now(),
        clearCompletedAt: newCompletedAt == null,
      );

      await taskService.updateTask(parentTask.id, updatedParentTask);
    }
  }
}
