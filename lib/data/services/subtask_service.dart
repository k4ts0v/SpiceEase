import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/repositories/subtask_repository.dart';

/// A service layer that coordinates subtask-related business logic.
///
/// This class depends on the [SubtaskRepository] and provides higher-level
/// operations for managing subtasks. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class SubtaskService {
  final SubtaskRepository _repository; // Dependency for accessing the repository.

  const SubtaskService(this._repository);

  /// Retrieves all subtasks by delegating to the repository.
  Future<List<SubtaskModel>> getAllSubtasks() => _repository.getAllSubtasks();

  /// Retrieves a specific subtask by ID through the repository.
  Future<SubtaskModel?> getSubtaskById(String id) => _repository.getSubtaskById(id);

  /// Creates a new subtask by delegating to the repository.
  Future<SubtaskModel> createSubtask(SubtaskModel subtask) => _repository.createSubtask(subtask);

  /// Updates an existing subtask by delegating to the repository.
  Future<SubtaskModel> updateSubtask(String id, SubtaskModel subtask) =>
      _repository.updateSubtask(id, subtask);

  /// Deletes a subtask by delegating to the repository.
  Future<void> deleteSubtask(String id) => _repository.deleteSubtask(id);
}
