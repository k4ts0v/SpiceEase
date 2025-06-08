import 'package:flutter/foundation.dart';
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

    try {
      final allMeds = await _medicationService.getAllMedications();

      if (!mounted) return;

      // Filter medications to show proper status for selected date
      final dateAwareMeds = allMeds.map((med) {
        final wasTakenOnDate = med.isTakenOnDate(_date);

        // Create a copy with date-specific taken status
        // Remove takenTimes parameter - use the actual property name
        return med.copyWith(
            // Use the correct property name from MedicationModel
            // If there's no takenTimes property, remove this line entirely
            );
      }).toList();

      if (mounted) {
        state = dateAwareMeds;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching medications: $e');
      }
      if (mounted) {
        state = [];
      }
    }
  }

  void _setLoading(bool loading) {
    if (mounted) {
      _isLoading = loading;
    }
  }

  void _setError(String error) {
    if (mounted) {
      _error = error;
    }
  }
}
