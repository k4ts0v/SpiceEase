//// filepath: /home/k4ts0v/DAM/spiceease/lib/features/time_management/flowmodoro/flowmodoro_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/flowmodoro_model.dart';
import 'package:spiceease/data/providers/flowmodoro_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/services/flowmodoro_service.dart';
import 'package:spiceease/data/services/task_service.dart';

final flowmodoroControllerProvider =
    StateNotifierProvider<FlowmodoroController, FlowmodoroModel?>((ref) {
  final service = ref.watch(flowmodoroServiceProvider);
  return FlowmodoroController(service, ref.watch(taskServiceProvider));
});

class FlowmodoroController extends StateNotifier<FlowmodoroModel?> {
  final FlowmodoroService _service;
  final TaskService _taskService;

  FlowmodoroController(this._service, this._taskService) : super(null);

  Future<void> loadFlowmodoro(String id) async {
    final flow = await _service.getFlowmodoroById(id);
    state = flow;
  }

  Future<void> createFlowmodoro(String taskId) async {
    final newFlow = FlowmodoroModel(
      id: 'flow_${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
    );
    final created = await _service.createFlowmodoro(newFlow);
    state = created;
  }

  Future<void> updateFocusMinutes(int newMinutes) async {
    if (state == null) return;
    final updated = state!.copyWith(focusMinutes: newMinutes);
    final saved = await _service.updateFlowmodoro(updated.id, updated);
    state = saved;
  }

  Future<void> startFlowmodoro() async {
    if (state == null) return;
    final updated = state!.copyWith(isRunning: true);
    state = await _service.updateFlowmodoro(updated.id, updated);
  }

  Future<void> stopFlowmodoro() async {
    if (state == null) return;
    final updated = state!.copyWith(isRunning: false);
    state = await _service.updateFlowmodoro(updated.id, updated);
  }

  Future<void> deleteCurrentFlow() async {
    if (state == null) return;
    await _service.deleteFlowmodoro(state!.id);
    state = null;
  }

  /// Update the task status to mark it as completed
  Future<bool> completeTask(String taskId) async {
    try {
      // First, get the current task
      final task = await _taskService.getTaskById(taskId);
      if (task == null) {
        return false;
      }

      // Update the task status to "Done"
      final updatedTask = task.copyWith(status: "Done");

      // Save the updated task
      await _taskService.updateTask(taskId, updatedTask);
      return true;
    } catch (e) {
      print('Error completing task: $e');
      return false;
    }
  }

  Future<bool> saveCompletedFlowmodoro({
    required String taskId,
    required int focusMinutes,
    required int breakMinutes,
    required int cycles,
  }) async {
    try {
      // Create a new flowmodoro record with completion data
      final completedFlow = FlowmodoroModel(
        id: 'flow_${DateTime.now().millisecondsSinceEpoch}',
        taskId: taskId,
        focusMinutes: focusMinutes,
        breakMinutes: breakMinutes,
        pomoCount: cycles,
        isRunning: false,
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // Save to database
      await _service.createFlowmodoro(completedFlow);
      return true;
    } catch (e) {
      print('Error saving completed flowmodoro: $e');
      return false;
    }
  }
}
