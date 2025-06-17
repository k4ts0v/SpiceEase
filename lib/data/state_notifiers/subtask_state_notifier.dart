import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/services/subtask_service.dart';

class SubtaskStateNotifier extends StateNotifier<List<SubtaskModel>> {
  final SubtaskService _service;
  final String _taskId;
  final Ref _ref;
  bool _isLoading = false;
  String? _error;

  SubtaskStateNotifier(this._service, this._taskId, this._ref) : super([]) {
    fetchSubtasks();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSubtasks() async {
    if (!mounted) return;
    _setLoading(true);
    _setError(null);

    try {
      // Get the selected date for filtering
      final selectedDate = _ref.read(selectedDateProvider);

      print(
          "SubtaskStateNotifier - Fetching subtasks for task: $_taskId, date: $selectedDate");

      // Use the service's filtered method for tracker
      final subtasks =
          await _service.getSubtasksForTaskFiltered(_taskId, selectedDate);

      print(
          "SubtaskStateNotifier - Fetched ${subtasks.length} filtered subtasks for $_taskId");

      // Log each filtered subtask for debugging
      for (int i = 0; i < subtasks.length; i++) {
        final subtask = subtasks[i];
        print(
            "SubtaskStateNotifier - Subtask $i: ${subtask.title} (Status: ${subtask.status}, Completed: ${subtask.completedAt})");
      }

      if (!mounted) return;
      state = subtasks;
      _setLoading(false);
    } catch (e) {
      print("SubtaskStateNotifier - Error fetching subtasks: $e");
      if (!mounted) return;
      _setLoading(false);
      _setError(e.toString());
    }
  }

  void _setLoading(bool loading) => _isLoading = loading;
  void _setError(String? error) => _error = error;

  Future<void> refresh() async {
    await fetchSubtasks();
  }
}

final subtaskStateNotifierProvider = StateNotifierProvider.family<
    SubtaskStateNotifier, List<SubtaskModel>, String>(
  (ref, taskId) {
    final service = ref.watch(subtaskServiceProvider);
    return SubtaskStateNotifier(service, taskId, ref);
  },
);
