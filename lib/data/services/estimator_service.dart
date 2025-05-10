import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/l10n/app_localizations.dart';

final estimatorServiceProvider = Provider((ref) => EstimatorService(ref));

class EstimatorService {
  final Ref ref;
  final Dio _dio = Dio();

  /// Tip: to average 10 minutes and 1 hour, convert both to minutes:
  /// 10 → 10, 60 → 60, sum=70, avg=35 → 35 minutes.
  EstimatorService(this.ref);

  int _spicinessFromEnergy(int energy) {
    if (energy <= 2) return 1;
    if (energy <= 4) return 2;
    if (energy <= 6) return 3;
    if (energy <= 8) return 4;
    return 5;
  }

  Future<dynamic> estimateTask(
    String title,
    String description,
    String? condition,
  ) async {
    final energyService = ref.read(energyServiceProvider);
    final lastEntry = await energyService.getLastEnergyEntry();
    final int spiciness = _spicinessFromEnergy(lastEntry?.energyLevel ?? 0);

    final body = {
      "text": "$title $description $condition",
      "spiciness": spiciness,
      "Ancestors": [],
    };
    final response = await _dio.post(
      "https://goblin.tools/api/estimator",
      data: body,
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    print(body);
    print(response.data);
    return response.data;
  }

  /// Parses an API response like “10 minutes” or “10 to 30 minutes”
  /// into a numeric estimate + a final unit chosen by the numeric average.
  Future<Map<String, dynamic>?> parseResponseWithLocale(
    String response,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final unitMappings = _getUnitMappings(l10n);
    final unitsToMinutes = _getUnitConversions();

    try {
      // Special case: “0 seconds” → just return 5 seconds
      if (_hasZeroSeconds(response, unitMappings['second']!)) {
        return {"estimate": "5", "unit": "seconds"};
      }

      // “X u (to|a) Y v”
      final multiRegex = RegExp(
        r'(\d+)\s+([A-Za-záéíóúÁÉÍÓÚñÑ]+)\s+(?:to|a)\s+(\d+)\s+([A-Za-záéíóúÁÉÍÓÚñÑ]+)'
      );
      final mm = multiRegex.firstMatch(response);
      if (mm != null) {
        final a = int.parse(mm.group(1)!);
        final u1raw = mm.group(2)!;
        final b = int.parse(mm.group(3)!);
        final u2raw = mm.group(4)!;

        final base1 = _findBaseUnit(u1raw.toLowerCase(), unitMappings);
        final base2 = _findBaseUnit(u2raw.toLowerCase(), unitMappings);

        final m1 = a * unitsToMinutes[base1]!;
        final m2 = b * unitsToMinutes[base2]!;
        final avgMin = (m1 + m2) / 2;

        return _formatAverage(avgMin, unitMappings, unitsToMinutes);
      }

      // English range: “X to Y unit”
      final enRange = RegExp(r'(\d+)\s+to\s+(\d+)\s+([A-Za-záéíóúÁÉÍÓÚñÑ]+)');
      final matchEnRange = enRange.firstMatch(response);
      if (matchEnRange != null) {
        final a = int.parse(matchEnRange.group(1)!);
        final b = int.parse(matchEnRange.group(2)!);
        final rawUnit = matchEnRange.group(3)!;

        final base = _findBaseUnit(rawUnit.toLowerCase(), unitMappings);
        final avgMin = ((a + b) / 2) * unitsToMinutes[base]!;

        return _formatAverage(avgMin, unitMappings, unitsToMinutes);
      }

      // Spanish range: “X a Y unidad”
      final esRange = RegExp(r'(\d+)\s+a\s+(\d+)\s+([A-Za-záéíóúÁÉÍÓÚñÑ]+)');
      final matchEsRange = esRange.firstMatch(response);
      if (matchEsRange != null) {
        final a = int.parse(matchEsRange.group(1)!);
        final b = int.parse(matchEsRange.group(2)!);
        final rawUnit = matchEsRange.group(3)!;

        final base = _findBaseUnit(rawUnit.toLowerCase(), unitMappings);
        final avgMin = ((a + b) / 2) * unitsToMinutes[base]!;

        return _formatAverage(avgMin, unitMappings, unitsToMinutes);
      }

      // Single value: “X unit”
      final singleExp = RegExp(r'(\d+)\s+([A-Za-záéíóúÁÉÍÓÚñÑ]+)');
      final matchSingle = singleExp.firstMatch(response);
      if (matchSingle != null) {
        final a = int.parse(matchSingle.group(1)!);
        final rawUnit = matchSingle.group(2)!;

        final base = _findBaseUnit(rawUnit.toLowerCase(), unitMappings);
        final avgMin = a * unitsToMinutes[base]!;

        return _formatAverage(avgMin, unitMappings, unitsToMinutes);
      }

      // Fallback: any first number
      final onlyNum = RegExp(r'(\d+)').firstMatch(response);
      if (onlyNum != null) {
        return {"estimate": onlyNum.group(1)!, "unit": ""};
      }
    } catch (e) {
      print("Error parsing estimation: $e");
    }
    return null;
  }

  /// Picks the best display unit for the computed average (in minutes).
  /// For example, 35.0 remains “35 minutes” instead of “0.58 hours,”
  /// and 1.0 remains “1 minute.”
  Map<String, dynamic> _formatAverage(
    double avgMin,
    Map<String, List<String>> unitMappings,
    Map<String, double> unitsToMinutes,
  ) {
    // The top-down order from largest to smallest
    final order = ['month', 'week', 'day', 'hour', 'minute', 'second'];

    String chosen = 'minute';
    double value = avgMin;

    // find the largest unit for which the final numeric is >= 1
    for (final unit in order) {
      final conv = avgMin / unitsToMinutes[unit]!;
      if (conv >= 1) {
        chosen = unit;
        value = conv;
        break;
      }
    }

    // Round to int if no fraction, else 2 decimals
    final numericValue = (value % 1 == 0)
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

    // Some simple singular/plural logic for English
    // If we only have a float of exactly 1.0, it’s singular; otherwise plural.
    final doubleVal = double.tryParse(value.toString()) ?? 0;
    final isSingular = doubleVal == 1.0;

    // Basic map of English singular + plural forms
    // This is used solely when displaying "35 minutes," "2 hours," etc.
    final singularPlural = <String, List<String>>{
      'month':  ['month', 'months'],
      'week':   ['week', 'weeks'],
      'day':    ['day', 'days'],
      'hour':   ['hour', 'hours'],
      'minute': ['minute', 'minutes'],
      'second': ['second','seconds'],
    };
    final forms = singularPlural[chosen] ?? ['?', '?'];
    final displayUnit = isSingular ? forms[0] : forms[1];

    return {
      "estimate": numericValue,
      "unit": displayUnit,
    };
  }

  /// Returns the dictionary of recognized (English + Spanish + from l10n) units
  Map<String, List<String>> _getUnitMappings(AppLocalizations l10n) {
    return {
      'second': [
        'second','seconds','segundo','segundos',
        l10n.second, l10n.seconds
      ],
      'minute': [
        'minute','minutes','minuto','minutos',
        l10n.minute, l10n.minutes
      ],
      'hour': [
        'hour','hours','hora','horas',
        l10n.hour, l10n.hours
      ],
      'day': [
        'day','days','día','dias','dia',
        l10n.day, l10n.days
      ],
      'week': [
        'week','weeks','semana','semanas',
        l10n.week, l10n.weeks
      ],
      'month': [
        'month','months','mes','meses',
        l10n.month, l10n.months
      ],
    };
  }

  /// Each key is a base unit; each value is how many minutes that unit has
  Map<String, double> _getUnitConversions() {
    return {
      'second': 1 / 60,
      'minute': 1,
      'hour':   60,
      'day':    60 * 24,
      'week':   60 * 24 * 7,
      'month':  60 * 24 * 30,
    };
  }

  bool _hasZeroSeconds(String text, List<String> seconds) {
    final t = text.toLowerCase();
    return seconds.any((x) => t.contains("0 $x"));
  }

  /// Finds the “base unit” of any recognized label in [unitMappings].
  String _findBaseUnit(String raw, Map<String, List<String>> unitMappings) {
    return unitMappings.entries
        .firstWhere(
          (e) => e.value.any((u) => raw.contains(u.toLowerCase())),
          orElse: () => MapEntry('minute', []),
        )
        .key;
  }
}