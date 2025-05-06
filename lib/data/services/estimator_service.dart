import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/providers/energy_provider.dart';

final estimatorServiceProvider = Provider((ref) => EstimatorService(ref));

class EstimatorService {
  final Ref ref;
  final Dio _dio = Dio();

  EstimatorService(this.ref);

  /// Maps energy level to spiciness.
  int _spicinessFromEnergy(int energy) {
    if (energy <= 2) return 5;
    if (energy <= 4) return 4;
    if (energy <= 6) return 3;
    if (energy <= 8) return 2;
    return 1;
  }

  /// Estimates the task using goblin.tools API.
  Future<dynamic> estimateTask(
      String title, String description, String? condition) async {
    // Get last recorded energy from EnergyService.
    final energyService = ref.read(energyServiceProvider);
    final int? lastEnergy =
        (await energyService.getLastEnergyEntry())?.energyLevel;

    final int spiciness = _spicinessFromEnergy(lastEnergy ?? 0);

    final body = {
      "text": "$title $description",
      "spiciness": spiciness,
      "Ancestors": [],
    };

    final response = await _dio.post(
      "https://goblin.tools/api/estimator",
      data: body,
      options: Options(
        headers: {"Content-Type": "application/json"},
      ),
    );

    print(body);
    print(response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> parseResponse(dynamic response,
      [BuildContext? context]) async {
    if (response is! String) return {'estimate': 0, 'unit': 'horas'};

    String input = response.toLowerCase().trim();
    int estimate = 0;
    String unit = 'horas';

    // Patterns to match various time formats
    final patterns = [
      // "2 a 8 horas" - Spanish range with space-a-space
      RegExp(r'(\d+)\s+a\s+\d+\s+(\w+)'),

      // "2-8 horas" - Range with hyphen
      RegExp(r'(\d+)-\d+\s+(\w+)'),

      // "from 2 to 8 hours" or "de 2 a 8 horas"
      RegExp(r'(?:from|de)\s+(\d+)\s+(?:to|a)\s+\d+\s+(\w+)'),

      // "2 hours" - Simple number and unit
      RegExp(r'(\d+)\s+(\w+)'),
    ];

    // Try each pattern in sequence
    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null) {
        // Always take the first number as the estimate (conservative approach)
        estimate = int.parse(match.group(1)!);
        // For the last pattern, group(2) is the unit, for the others we need to parse
        unit = match.group(2) ?? 'horas';
        break;
      }
    }

    // Use the Spanish unit with proper singular/plural form
    unit = _getSpanishUnit(unit, estimate);

    return {'estimate': estimate, 'unit': unit};
  }

  /// Returns the Spanish unit with proper singular/plural form based on the estimate
  String _getSpanishUnit(String unit, int estimate) {
    final String lowercaseUnit = unit.toLowerCase();

    // First detect what type of unit we have
    final String unitType = _detectUnitType(lowercaseUnit);

    // Then return the proper Spanish form based on estimate
    return _getSpanishForm(unitType, estimate);
  }

  /// Detects the unit type (minute, hour, day, etc.)
  String _detectUnitType(String unit) {
    if (unit.contains('min') || unit.contains('minut')) {
      return 'minute';
    } else if (unit.contains('hor') || unit.contains('hour')) {
      return 'hour';
    } else if (unit.contains('día') || unit.contains('day')) {
      return 'day';
    } else if (unit.contains('semana') || unit.contains('week')) {
      return 'week';
    } else if (unit.contains('mes') || unit.contains('month')) {
      return 'month';
    } else if (unit.contains('segundo') || unit.contains('second')) {
      return 'second';
    } else {
      return 'hour'; // Default to hour
    }
  }

  /// Returns the Spanish form of the unit based on count
  String _getSpanishForm(String unitType, int count) {
    switch (unitType) {
      case 'minute':
        return count == 1 ? 'minuto' : 'minutos';
      case 'hour':
        return count == 1 ? 'hora' : 'horas';
      case 'day':
        return count == 1 ? 'día' : 'días';
      case 'week':
        return count == 1 ? 'semana' : 'semanas';
      case 'month':
        return count == 1 ? 'mes' : 'meses';
      case 'second':
        return count == 1 ? 'segundo' : 'segundos';
      default:
        return count == 1 ? 'hora' : 'horas';
    }
  }
}
