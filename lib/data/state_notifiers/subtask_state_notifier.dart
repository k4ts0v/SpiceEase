// StateNotifier for subtasks by parent task ID
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/services/subtask_service.dart';

class SubtaskStateNotifier extends StateNotifier<List<SubtaskModel>> {
  final SubtaskService _service;
  final String _taskId;

  SubtaskStateNotifier(this._service, this._taskId) : super([]) {
    fetchSubtasks();
  }

  Future<void> fetchSubtasks() async {
    state = await _service.getSubtasksForTask(_taskId);
  }
}

// Provider factory for subtasks by task ID
final subtaskStateNotifierProvider = StateNotifierProvider.family<
    SubtaskStateNotifier, List<SubtaskModel>, String>(
  (ref, taskId) {
    final service = ref.watch(subtaskServiceProvider);
    return SubtaskStateNotifier(service, taskId);
  },
);
