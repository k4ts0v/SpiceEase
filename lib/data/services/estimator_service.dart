import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/l10n/app_localizations.dart';

/// Provides an instance of [EstimatorService] to the app.
final estimatorServiceProvider = Provider((ref) => EstimatorService(ref));

/// A service responsible for estimating task durations based on task details,
/// user energy levels, and external API responses.
class EstimatorService {
  final Ref
      ref; // Reference to the provider container for accessing other providers.
  final Dio _dio; // Dio instance for making HTTP requests.

  /// Constructor for the `EstimatorService`.
  /// Accepts a `Ref` object to access other providers.
  /// Optionally accepts a `Dio` instance for HTTP requests.
  /// If no `Dio` instance is provided, a new one is created.
  /// This allows for easier testing and mocking of HTTP requests.
  EstimatorService(this.ref, {Dio? dio}) : _dio = dio ?? Dio() {
    // Configure Dio with timeout settings
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
  }

  /// Determines the "spiciness" level based on the user's energy level.
  /// Spiciness is a value between 1 and 5, where higher values indicate higher energy.
  int _spicinessFromEnergy(int energy) {
    if (energy <= 2) return 1;
    if (energy <= 4) return 2;
    if (energy <= 6) return 3;
    if (energy <= 8) return 4;
    return 5;
  }

  /// Estimates the time required for a task based on its title, description,
  /// and an optional condition. The estimation is influenced by the user's
  /// current energy level.
  ///
  /// Makes a POST request to an external API to fetch the estimation.
  ///
  /// - Parameters:
  ///   - `title`: The title of the task.
  ///   - `description`: A detailed description of the task.
  ///   - `condition`: An optional condition or context for the task.
  ///
  /// - Returns: The API response containing the estimated time.
  Future<dynamic> estimateTask(
    String title,
    String description,
    String? condition,
  ) async {
    try {
      print('Starting task estimation for: $title');

      final energyService = ref.read(energyServiceProvider);
      final lastEntry = await energyService.getLastEnergyEntry();
      final int spiciness = _spicinessFromEnergy(
          lastEntry?.energyLevel ?? 5); // Default to medium energy

      print('Spiciness level: $spiciness');

      // Construct API endpoint properly
      const String baseUrl = "https://goblin.tools";
      const String endpoint = "/api/estimator";

      // Prepare request body
      final body = {
        "text":
            "$title ${description.isNotEmpty ? description : ''} ${condition ?? ''}"
                .trim(),
        "spiciness": spiciness,
        "Ancestors": [],
      };

      print('Request body: $body');
      print('Making request to: $baseUrl$endpoint');

      // Make the POST request to the API with proper error handling
      final response = await _dio.post(
        "$baseUrl$endpoint",
        data: body,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

      print('Estimation API response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('DioException during estimation: ${e.type} - ${e.message}');

      // Handle different types of network errors
      switch (e.type) {
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw Exception(
              'Network timeout. Please check your internet connection.');

        case DioExceptionType.connectionError:
          throw Exception(
              'Connection failed. Please check your internet connection.');

        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          throw Exception(
              'Server error (${statusCode ?? 'unknown'}). Please try again later.');

        default:
          throw Exception(
              'Failed to estimate task duration. Please try again.');
      }
    } catch (e) {
      print('Unexpected error during estimation: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Provides a fallback estimation when API is unavailable
  /// Returns a basic estimate based on task complexity and energy level
  Map<String, dynamic> getFallbackEstimation(
      String title, String description, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Simple heuristic based on title and description length
    final totalLength = title.length + description.length;
    int estimateMinutes;

    if (totalLength < 20) {
      estimateMinutes = 15; // Simple task
    } else if (totalLength < 50) {
      estimateMinutes = 30; // Medium task
    } else if (totalLength < 100) {
      estimateMinutes = 60; // Complex task
    } else {
      estimateMinutes = 120; // Very complex task
    }

    return {
      "estimate": estimateMinutes.toString(),
      "unit": l10n.minutes,
    };
  }

  /// Parses the API response to extract a numeric estimate and its unit.
  /// Supports multiple languages and formats, such as "10 minutes" or "10 to 30 minutes".
  ///
  /// - Parameters:
  ///   - `response`: The raw response string from the API.
  ///   - `context`: The current `BuildContext` for accessing localization.
  ///
  /// - Returns: A map containing the numeric estimate and its unit, or `null` if parsing fails.
  Future<Map<String, dynamic>?> parseResponseWithLocale(
    String response,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final unitMappings = _getUnitMappings(l10n);
    final unitsToMinutes = _getUnitConversions();

    try {
      print('Parsing estimation response: $response');

      // Special case: "0 seconds" → just return 5 minutes as default
      if (_hasZeroSeconds(response, unitMappings['second']!)) {
        return {"estimate": "5", "unit": l10n.minutes};
      }

      // Handle ranges like "10 to 30 minutes"
      final multiRegex = RegExp(
          r'(\d+)\s+([A-Za-záéíóúÁÉÍÓÚñÑ]+)\s+(?:to|a)\s+(\d+)\s+([A-Za-záéíóúÁÉÍÓÚñÑ]+)');
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

      // Handle English ranges like "10 to 30 minutes"
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

      // Handle Spanish ranges like "10 a 30 minutos"
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

      // Handle single values like "10 minutes"
      final singleExp = RegExp(r'(\d+)\s+([A-Za-záéíóúÁÉÍÓÚñÑ]+)');
      final matchSingle = singleExp.firstMatch(response);
      if (matchSingle != null) {
        final a = int.parse(matchSingle.group(1)!);
        final rawUnit = matchSingle.group(2)!;

        final base = _findBaseUnit(rawUnit.toLowerCase(), unitMappings);
        final avgMin = a * unitsToMinutes[base]!;

        return _formatAverage(avgMin, unitMappings, unitsToMinutes);
      }

      // Fallback: Extract the first number and assume minutes
      final onlyNum = RegExp(r'(\d+)').firstMatch(response);
      if (onlyNum != null) {
        return {"estimate": onlyNum.group(1)!, "unit": l10n.minutes};
      }
    } catch (e) {
      print("Error parsing estimation: $e");
    }
    return null;
  }

  /// Picks the best display unit for the computed average (in minutes).
  /// For example, 35.0 remains "35 minutes" instead of "0.58 hours,"
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
    final numericValue =
        (value % 1 == 0) ? value.toInt().toString() : value.toStringAsFixed(2);

    // Use the first plural form from unitMappings for the chosen unit
    // (Assume the first is singular, second is plural, fallback to English)
    final mapping = unitMappings[chosen];
    String displayUnit;
    if (mapping != null && mapping.length > 1) {
      displayUnit = mapping[1]; // plural
    } else if (mapping != null && mapping.isNotEmpty) {
      displayUnit = mapping[0];
    } else {
      displayUnit = chosen; // fallback
    }

    return {
      "estimate": numericValue,
      "unit": displayUnit,
    };
  }

  /// Returns the dictionary of recognized (English + Spanish + from l10n) units
  Map<String, List<String>> _getUnitMappings(AppLocalizations l10n) {
    return {
      'second': [
        'second',
        'seconds',
        'segundo',
        'segundos',
        l10n.second,
        l10n.seconds
      ],
      'minute': [
        'minute',
        'minutes',
        'minuto',
        'minutos',
        l10n.minute,
        l10n.minutes
      ],
      'hour': ['hour', 'hours', 'hora', 'horas', l10n.hour, l10n.hours],
      'day': ['day', 'days', 'día', 'dias', 'dia', l10n.day, l10n.days],
      'week': ['week', 'weeks', 'semana', 'semanas', l10n.week, l10n.weeks],
      'month': ['month', 'months', 'mes', 'meses', l10n.month, l10n.months],
    };
  }

  /// Each key is a base unit; each value is how many minutes that unit has
  Map<String, double> _getUnitConversions() {
    return {
      'second': 1 / 60,
      'minute': 1,
      'hour': 60,
      'day': 60 * 24,
      'week': 60 * 24 * 7,
      'month': 60 * 24 * 30,
    };
  }

  /// Checks if the text contains "0 seconds" in any recognized form.
  /// This is a special case where we want to return a default value of 5 seconds.
  /// This is used to handle cases where the API might return "0 seconds" as a valid response.
  /// - Parameters:
  ///   - `text`: The text to check.
  ///   - `seconds`: A list of recognized forms of "seconds."
  /// - Returns: `true` if "0 seconds" is found in any form, `false` otherwise.
  bool _hasZeroSeconds(String text, List<String> seconds) {
    final t = text.toLowerCase();
    return seconds.any((x) => t.contains("0 $x"));
  }

  /// Finds the "base unit" of any recognized label in [unitMappings].
  String _findBaseUnit(String raw, Map<String, List<String>> unitMappings) {
    return unitMappings.entries
        .firstWhere(
          (e) => e.value.any((u) => raw.contains(u.toLowerCase())),
          orElse: () => MapEntry('minute', []),
        )
        .key;
  }
}
