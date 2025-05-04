import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/providers/energy_provider.dart';

final magicTodoServiceProvider = Provider((ref) => MagicTodoService(ref));

class MagicTodoService {
  final Ref ref;
  final Dio _dio = Dio();

  MagicTodoService(this.ref);

  /// Maps energy level to spiciness.
  int _spicinessFromEnergy(int energy) {
    if (energy <= 2) return 5;
    if (energy <= 4) return 4;
    if (energy <= 6) return 3;
    if (energy <= 8) return 2;
    return 1;
  }

  /// Divides the task using goblin.tools API.
  Future<List<SubtaskModel>> divideTask(
      {required String title, required String description}) async {
    // Get last recorded energy from EnergyService.
    final energyService = ref.read(energyServiceProvider);
    final int? lastEnergy =
        (await energyService.getLastEnergyEntry())?.energyLevel;

    final int spiciness = _spicinessFromEnergy(lastEnergy ?? 0);

    final body = {
      "text": "$title $description",
      "spiciness": spiciness.toString(),
      "Ancestors": [],
    };

    try {
      final response = await _dio.post(
        "https://goblin.tools/api/todo",
        data: body,
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      if (response.data is List) {
        print("Goblin API returned a List: ${response.data}");
        return (response.data as List).map((subtaskTitle) {
          return SubtaskModel(
            id: DateTime.now()
                .millisecondsSinceEpoch
                .toString(), // temporary ID
            taskId: '', // will be set when main task is created
            title: subtaskTitle.toString(),
            order: response.data.indexOf(subtaskTitle),
            completed: false,
          );
        }).toList();
      } else if (response.data is String) {
        print("Goblin API returned a String: ${response.data}");
        // Split string response by newlines if it's a single string
        final subtasks = response.data
            .toString()
            .split('\n')
            .where((line) => line.trim().isNotEmpty);
        print(subtasks);
        return subtasks.map((subtaskTitle) {
          return SubtaskModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            taskId: '',
            title: subtaskTitle.trim(),
            order: subtasks.toList().indexOf(subtaskTitle),
            completed: false,
          );
        }).toList();
      }

      return [];
    } catch (e) {
      print('Error dividing task: $e');
      return [];
    }
  }
}
