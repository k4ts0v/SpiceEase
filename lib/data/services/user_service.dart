import 'package:spiceease/data/models/user_model.dart';
import 'package:spiceease/data/repositories/user_repository.dart';

/// A service layer that coordinates user-related business logic.
///
/// This class depends on the [UserRepository] and provides higher-level
/// operations for managing users. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class UserService {
  final UserRepository _repository; // Dependency for accessing the repository.

  const UserService(this._repository);

  /// Retrieves all users by delegating to the repository.
  Future<List<UserModel>> getAllUsers() => _repository.getAllUsers();

  /// Retrieves a specific user by ID through the repository.
  Future<UserModel?> getUserById(String id) => _repository.getUserById(id);

  /// Creates a new user by delegating to the repository.
  Future<UserModel> createUser(UserModel user) => _repository.createUser(user);

  /// Updates an existing user by delegating to the repository.
  Future<UserModel> updateUser(String id, UserModel user) =>
      _repository.updateUser(id, user);

  /// Deletes a user by delegating to the repository.
  Future<void> deleteUser(String id) => _repository.deleteUser(id);
}
