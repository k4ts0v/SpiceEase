import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/core/database/firerstore_date_adapter.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/repositories/symptom_repository.dart';

class SymptomService {
  final SymptomRepository _repository;
  final AuthService _authService;
  final DatabaseService _db;

  SymptomService(this._repository, this._authService, this._db);

  Future<List<SymptomModel>> getAllSymptoms() => _repository.getAllSymptoms();
  Future<SymptomModel?> getSymptomById(String id) =>
      _repository.getSymptomById(id);
  Future<SymptomModel> createSymptom(SymptomModel symptom) =>
      _repository.createSymptom(symptom);
  Future<SymptomModel> updateSymptom(String id, SymptomModel symptom) =>
      _repository.updateSymptom(id, symptom);
  Future<void> deleteSymptom(String id) => _repository.deleteSymptom(id);

  // Provides symptom entries for the authenticated user in a specified date.
  Future<List<SymptomModel>> getSymptomsForDate(DateTime date) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];

    final start = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day));
    final end = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day).add(Duration(days: 1)));

    final raw = await _db.query(
      collection: DatabaseService.symptoms,
      filters: [
        QueryFilter.basic('user_id', QueryOperator.equal, user.uid),
        QueryFilter.basic(
            'created_at', QueryOperator.greaterThanOrEqual, start),
        QueryFilter.basic('created_at', QueryOperator.lessThan, end),
      ],
      orderBy: [QueryOrder('created_at')],
    );

    return raw.map((e) => SymptomModel.fromMap(e)).toList();
  }

  String generateId() => _db.generateId(); // Generate unique ID

  Future<String> getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }
}
