import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/services/symptom_service.dart';

class SymptomStateNotifier extends StateNotifier<List<SymptomModel>> {
  final SymptomService _symptomService;
  final DateTime _date;
  bool _isLoading = false;
  String? _error;

  SymptomStateNotifier(this._symptomService, this._date) : super([]) {
    fetchSymptoms();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSymptoms() async {
    if (!mounted) return;
    _setLoading(true);
    try {
      final symptoms = await _symptomService.getSymptomsForDate(_date);
      if (!mounted) return;
      state = symptoms;
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
