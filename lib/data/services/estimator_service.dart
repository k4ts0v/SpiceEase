import 'package:dio/dio.dart';
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
  Future<dynamic> estimateTask(String title, String description, String? condition) async {
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

  Future<Map<String, dynamic>> parseResponse(dynamic response) async {
    if (response is! String) return {'estimate': 0, 'unit': 'hours'};

    String input = response.toLowerCase();
    int estimate = 0;
    String unit = 'hours';

    // Handle "X to Y" format with different units
    if (input.contains(' to ')) {
      final parts = input.split(' to ');
      input = parts[0]; // Take the lower range.
    }

    // Extract numbers and unit
    final RegExp rangePattern = RegExp(r'(\d+)-(\d+)\s+(\w+)');
    final RegExp singlePattern = RegExp(r'(\d+)\s+(\w+)');

    var match = rangePattern.firstMatch(input);
    if (match != null) {
      // For range format "1-3 days", take the lower number
      estimate = int.parse(match.group(1)!);
      unit = match.group(3)!;
    } else {
      match = singlePattern.firstMatch(input);
      if (match != null) {
        // For single number format "2 hours"
        estimate = int.parse(match.group(1)!);
        unit = match.group(2)!;
      }
    }

    // Delete plural form of the unit if the estimate is 1.
    if (unit.endsWith('s') && estimate == 1)
      unit = unit.substring(0, unit.length - 1);

    return {'estimate': estimate, 'unit': unit};
  }
}
