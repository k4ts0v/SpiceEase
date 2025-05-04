import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/services/task_service.dart';

class TaskStateNotifier extends StateNotifier<List<TaskModel>> {
  final TaskService _taskService;
  final DateTime _date;
  bool _isLoading = false;
  String? _error;

  TaskStateNotifier(this._taskService, this._date) : super([]) {
    fetchTasks();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks() async {
    if (!mounted) return;
    _setLoading(true);
    try {
      final tasks = await _taskService.getTasksForDate(_date);
      print("TaskStateNotifier - Fetched ${tasks.length} tasks");
      if (!mounted) return;
      state = tasks; // UI should update here
      print("TaskStateNotifier - State updated with ${state.length} tasks");
      _setLoading(false);
    } catch (e) {
      if (!mounted) return;
      _setLoading(false);
      _setError(e.toString());
      print("TaskStateNotifier - Error: $e");
    }
  }

  void _setLoading(bool loading) => _isLoading = loading;
  void _setError(String error) => _error = error;
}
