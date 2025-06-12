import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/services/subtask_service.dart';
import 'package:spiceease/data/repositories/subtask_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';

/// ── Repository Layer ── ///

final subtaskRepositoryProvider = Provider<SubtaskRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return SubtaskRepository(db, ref);
});

/// ── Service Layer ── ///

final subtaskServiceProvider = Provider<SubtaskService>((ref) {
  final repo = ref.watch(subtaskRepositoryProvider);
  return SubtaskService(repo, ref);
});

/// ── State Management ── ///

final subtaskStateNotifierProvider = StateNotifierProvider.family<
    SubtaskStateNotifier,
    AsyncValue<List<SubtaskModel>>,
    String>((ref, taskId) {
  final service = ref.watch(subtaskServiceProvider);
  return SubtaskStateNotifier(service: service, taskId: taskId);
});

class SubtaskStateNotifier
    extends StateNotifier<AsyncValue<List<SubtaskModel>>> {
  final SubtaskService _service;
  final String _taskId;

  SubtaskStateNotifier({
    required SubtaskService service,
    required String taskId,
  })  : _service = service,
        _taskId = taskId,
        super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final subtasks = await _service.getSubtasksForTask(_taskId);
      if (mounted) {
        state = AsyncValue.data(subtasks);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> fetchSubtasks() async {
    if (!mounted) return;
    await _init();
  }

  Future<void> refresh() async {
    if (!mounted) return;
    await _init();
  }

  Future<void> updateSubtask(SubtaskModel subtask) async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      await _service.updateSubtask(subtask.id, subtask);
      if (mounted) {
        await _init(); // Refresh the list after update
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> deleteSubtask(String subtaskId) async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      await _service.deleteSubtask(subtaskId);
      if (mounted) {
        await _init(); // Refresh the list after deletion
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}

/// ── Analytics Providers ── ///

final allSubtasksProvider =
    FutureProvider.autoDispose<List<SubtaskModel>>((ref) {
  final service = ref.watch(subtaskServiceProvider);
  return service.getAllSubtasks();
});

final completedSubtasksCountProvider = Provider.autoDispose<int>((ref) {
  final subtasks = ref.watch(allSubtasksProvider).value ?? [];
  return subtasks.where((subtask) => subtask.completed).length;
});

final pendingSubtasksCountProvider = Provider.autoDispose<int>((ref) {
  final subtasks = ref.watch(allSubtasksProvider).value ?? [];
  return subtasks.where((subtask) => !subtask.completed).length;
});

final subtasksCompletionRateProvider = Provider.autoDispose<double>((ref) {
  final subtasks = ref.watch(allSubtasksProvider).value ?? [];
  if (subtasks.isEmpty) return 0.0;
  return ref.watch(completedSubtasksCountProvider) / subtasks.length;
});

/// ── Sorted Subtasks Provider ── ///

final sortedSubtasksForTaskProvider =
    Provider.family<AsyncValue<List<SubtaskModel>>, String>((ref, taskId) {
  final subtasksAsync = ref.watch(subtaskStateNotifierProvider(taskId));

  return subtasksAsync.whenData((subtasks) {
    return subtasks..sort((a, b) => a.order.compareTo(b.order));
  });
});