import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/repositories/medication_repository.dart';

/// A service layer that coordinates medication-related business logic.
///
/// This class depends on the [MedicationRepository] and provides higher-level
/// operations for managing medications. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class MedicationService {
  final MedicationRepository _repository; // Dependency for accessing the repository.
  final AuthService _authService;
  final DatabaseService _db;

  MedicationService(this._repository, this._authService, this._db);

  /// Retrieves all medications by delegating to the repository.
  Future<List<MedicationModel>> getAllMedications() => _repository.getAllMedications();

  /// Retrieves a specific medication by ID through the repository.
  Future<MedicationModel?> getMedicationById(String id) => _repository.getMedicationById(id);

  /// Creates a new medication by delegating to the repository.
  Future<MedicationModel> createMedication(MedicationModel medication) => _repository.createMedication(medication);

  /// Updates an existing medication by delegating to the repository.
  Future<MedicationModel> updateMedication(String id, MedicationModel medication) =>
      _repository.updateMedication(id, medication);

  /// Deletes a medication by delegating to the repository.
  Future<void> deleteMedication(String id) => _repository.deleteMedication(id);

    // Provides medication entries for the authenticated user in a specified date.
    Future<List<MedicationModel>> getMedicationsForDate(DateTime date) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];


    // Get all medications for the user first
    final allMedicationsQuery = await _db.query(
      collection: DatabaseService.medications,
      filters: [QueryFilter.basic('user_id', QueryOperator.equal, user.uid)],
    );

    // Process medications client-side to avoid Firestore limitations
    final medications = allMedicationsQuery
        .map((e) => MedicationModel.fromMap(e))
        .where((medication) {
      // Daily medications
      if (medication.frequency == 'daily') return true;

      // Weekly medications
      if (medication.frequency == 'weekly' &&
          medication.customDays != null &&
          medication.customDays!.contains(date.weekday)) {
        return true;
      }

      // Monthly medications
      if (medication.frequency == 'monthly' &&
          medication.customDays != null &&
          medication.customDays!.contains(date.day)) {
        return true;
      }

      // As needed medications - show if they have a next_due_date matching today
      if (medication.nextDueDate != null) {
        final nextDue = DateTime(
          medication.nextDueDate!.year,
          medication.nextDueDate!.month,
          medication.nextDueDate!.day,
        );
        final compareDate = DateTime(date.year, date.month, date.day);
        return nextDue.isAtSameMomentAs(compareDate);
      }

      return false;
    }).toList();

    print('Filtered medications count: ${medications.length}');
    for (final medication in medications) {
      print(
          'Medication: ${medication.name} (ID: ${medication.id}, Frequency: ${medication.frequency}, CustomDays: ${medication.customDays})');
    }

    return medications;
  }

  String generateId() => _db.generateId(); // Generate unique ID

  Future<String> getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }
}
