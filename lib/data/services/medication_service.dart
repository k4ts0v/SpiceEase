// ...existing imports...

import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/repositories/medication_repository.dart';

class MedicationService {
  final MedicationRepository _repository;
  final AuthService _authService;
  final DatabaseService _db;

  MedicationService(this._repository, this._authService, this._db);

  Future<List<MedicationModel>> getAllMedications() =>
      _repository.getAllMedications();

  Future<MedicationModel?> getMedicationById(String id) =>
      _repository.getMedicationById(id);

  Future<MedicationModel> createMedication(MedicationModel medication) =>
      _repository.createMedication(medication);

  Future<MedicationModel> updateMedication(
          String id, MedicationModel medication) =>
      _repository.updateMedication(id, medication);

  Future<void> deleteMedication(String id) => _repository.deleteMedication(id);

  Future<List<MedicationModel>> getMedicationsForDate(DateTime date) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];

    final allMedicationsQuery = await _db.query(
      collection: DatabaseService.medications,
      filters: [QueryFilter.basic('user_id', QueryOperator.equal, user.uid)],
    );

    final medications = allMedicationsQuery
        .map((e) => MedicationModel.fromMap(e))
        .where((medication) {
      // Check if medication was taken on this date
      final takenOnDate = medication.completedDates.any((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day);

      if (takenOnDate) {
        return true; // Show medications taken today
      }

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

      // Check next_due_date
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

    return medications;
  }

  String generateId() => _db.generateId();

  Future<String> getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }
}