import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/services/medication_service.dart';

class MedicationStateNotifier extends StateNotifier<List<MedicationModel>> {
  final MedicationService _medicationService;
  final DateTime _date;
  bool _isLoading = false;
  String? _error;

  MedicationStateNotifier(this._medicationService, this._date) : super([]) {
    fetchMedications();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMedications() async {
    if (!mounted) return;
    _setLoading(true);
    try {
      final medications = await _medicationService.getMedicationsForDate(_date);
      if (!mounted) return;
      state = medications;
      _setLoading(false);
    } catch (e) {
      if (!mounted) return;
      _setLoading(false);
      _setError(e.toString());
    }
  }

  void _setLoading(bool loading) => _isLoading = loading;
  void _setError(String error) => _error = error;
}
