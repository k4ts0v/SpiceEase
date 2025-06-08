import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/data/models/flowmodoro_model.dart';
import 'package:spiceease/data/repositories/flowmodoro_repository.dart';

/// A service layer that coordinates flowmodoro-related business logic.
///
/// This class depends on the [FlowmodoroRepository] and provides higher-level
/// operations for managing flowmodoro. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class FlowmodoroService {
  final FlowmodoroRepository
      _repository; // Dependency for accessing the repository.

  const FlowmodoroService(
      this._repository, AuthService auth, DatabaseService db);

  /// Retrieves all flowmodoro by delegating to the repository.
  Future<List<FlowmodoroModel>> getAllFlowmodoro() =>
      _repository.getAllFlowmodoro();

  /// Retrieves a specific flowmodoro by ID through the repository.
  Future<FlowmodoroModel?> getFlowmodoroById(String id) =>
      _repository.getFlowmodoroById(id);

  /// Creates a new flowmodoro by delegating to the repository.
  Future<FlowmodoroModel> createFlowmodoro(FlowmodoroModel flowmodoro) =>
      _repository.createFlowmodoro(flowmodoro);

  /// Updates an existing flowmodoro by delegating to the repository.
  Future<FlowmodoroModel> updateFlowmodoro(
          String id, FlowmodoroModel flowmodoro) =>
      _repository.updateFlowmodoro(id, flowmodoro);

  /// Deletes a flowmodoro by delegating to the repository.
  Future<void> deleteFlowmodoro(String id) => _repository.deleteFlowmodoro(id);

  /// Provides flowmodoro entries for the authenticated user in a specified date.
  Future<List<FlowmodoroModel>> getFlowmodorosForDate(DateTime date) =>
      _repository.getFlowmodorosForDate(date);
}
