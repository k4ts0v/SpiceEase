import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/services/user_service.dart';
import 'package:spiceease/data/repositories/user_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';

/// Provides the [UserRepository] instance.
///
/// This provider watches the [databaseServiceProvider] to
/// get the database layer dependency. When the database service
/// updates, it rebuilds the repository instance as well.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final db = ref.watch(
      databaseServiceProvider); // Watching the database service provider.
  return UserRepository(db); // Creating and returning a UserRepository.
});

/// Provides the [UserService] instance.
///
/// This provider depends on [userRepositoryProvider] and initializes
/// the application service for user-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final userServiceProvider = Provider<UserService>((ref) {
  final repo = ref
      .watch(userRepositoryProvider); // Watching the user repository provider.
  return UserService(repo); // Creating and returning a UserService instance.
});
