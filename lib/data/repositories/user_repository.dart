import 'package:spiceease/data/models/user_model.dart';
import 'package:spiceease/core/database/database_service.dart';

/// A repository layer that abstracts user-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching user data. It also handles the
/// conversion between [UserModel] and the Firestore-friendly map format.
class UserRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.

  const UserRepository(this._db);

  /// Fetches all user documents from the database.
  ///
  /// Queries the database for all documents in the users collection.
  /// Each document is converted from a map to a [UserModel] instance.
  Future<List<UserModel>> getAllUsers() async {
    final results = await _db.query(
        collection: DatabaseService.users); // Querying the users collection.
    return results
        .map((e) => UserModel.fromMap(e))
        .toList(); // Converting maps to UserModel instances.
  }

  /// Retrieves a user document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [UserModel]. Otherwise, returns null.
  Future<UserModel?> getUserById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.users}/$id'); // Fetching document by ID.
    return data != null
        ? UserModel.fromMap(data)
        : null; // Returning a UserModel or null.
  }

  /// Creates a new user in the database.
  ///
  /// Takes a [UserModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [UserModel].
  Future<UserModel> createUser(UserModel user) async {
    final data = await _db.createDocument(
        DatabaseService.users, user.toMap()); // Creating a new document.
    return UserModel.fromMap(
        data); // Returning the created user as a UserModel.
  }

  /// Updates an existing user document in the database.
  ///
  /// Takes a user ID and a [UserModel]. The user data is updated in the
  /// database, and the updated data is converted back to a [UserModel].
  Future<UserModel> updateUser(String id, UserModel user) async {
    final data = await _db.updateDocument(
      '${DatabaseService.users}/$id', // Document path.
      user.toMap(), // Updated data as a map.
    );
    return UserModel.fromMap(
        data); // Returning the updated user as a UserModel.
  }

  /// Deletes a user document by ID.
  ///
  /// Removes the specified user from the database.
  Future<void> deleteUser(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.users}/$id'); // Deleting the document by ID.
  }
}
