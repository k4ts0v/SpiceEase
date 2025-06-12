import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/services/task_service.dart';

class TaskStateNotifier extends StateNotifier<List<TaskModel>> {
  final TaskService _taskService;
  final DateTime _date;
  bool _isLoading = false;
  String? _error;

  TaskStateNotifier(this._taskService, this._date) : super([]) {
    // Automatically initialize when the notifier is created
    _initialize();
  }

  // Private initialization method
  void _initialize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        init();
      }
    });
  }

  Future<void> init() async {
    await fetchTasks();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks() async {
    if (!mounted) return;
    _setLoading(true);
    _setError(null);

    try {
      print("TaskStateNotifier - Fetching tasks for date: $_date");
      final tasks = await _taskService.getTasksForDate(_date);
      print("TaskStateNotifier - Fetched ${tasks.length} tasks for $_date");

      // Log each task for debugging
      for (int i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        print(
            "TaskStateNotifier - Task $i: ${task.title} (Created: ${task.createdAt}, Due: ${task.dueDate})");
      }

      if (!mounted) return;
      state = tasks;
      print("TaskStateNotifier - State updated with ${state.length} tasks");
      _setLoading(false);
    } catch (e) {
      print("TaskStateNotifier - Error fetching tasks: $e");
      if (!mounted) return;
      _setLoading(false);
      _setError(e.toString());
    }
  }

  void _setLoading(bool loading) => _isLoading = loading;
  void _setError(String? error) => _error = error;

  // Add method to refresh tasks
  Future<void> refresh() async {
    await fetchTasks();
  }
}
