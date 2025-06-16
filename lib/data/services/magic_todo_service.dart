import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';
import 'package:spiceease/data/providers/energy_provider.dart';

/// Provides an instance of [MagicTodoService] to the app.
final magicTodoServiceProvider = Provider((ref) => MagicTodoService(ref));

/// A service responsible for dividing a task into subtasks using goblin.tools API,
/// taking into account the user's current energy level to adjust the "spiciness" parameter.
class MagicTodoService {
  final Ref ref; // Reference to the provider container for accessing other providers.
  final Dio _dio; // Dio instance for making HTTP requests.

  /// Constructor for the `MagicTodoService`.
  /// Accepts a `Ref` object to access other providers.
  /// Optionally accepts a `Dio` instance for HTTP requests.
  /// If no `Dio` instance is provided, a new one is created.
  /// This allows for easier testing and mocking of HTTP requests.
  MagicTodoService(this.ref, {Dio? dio}) : _dio = dio ?? Dio();

  /// Maps the user's energy level to a "spiciness" value for the API.
  /// Lower energy means higher spiciness (harder tasks).
  /// - [energy]: The user's energy level (integer).
  /// - Returns: An integer spiciness value between 1 and 5.
  int _spicinessFromEnergy(int energy) {
    if (energy <= 2) return 5;
    if (energy <= 4) return 4;
    if (energy <= 6) return 3;
    if (energy <= 8) return 2;
    return 1;
  }

  /// Divides a task into subtasks using the goblin.tools API.
  ///
  /// - Parameters:
  ///   - `title`: The title of the task.
  ///   - `description`: A detailed description of the task.
  ///
  /// - Returns: A list of [SubtaskModel] representing the subtasks.
  ///   If the API returns a list, each item is a subtask title.
  ///   If the API returns a string, it is split by newlines into subtasks.
  ///   Returns an empty list if the API call fails.
  Future<List<SubtaskModel>> divideTask({
    required String title,
    required String description,
  }) async {
    // Get last recorded energy from EnergyService.
    final energyService = ref.read(energyServiceProvider);
    final int? lastEnergy =
        (await energyService.getLastEnergyEntry())?.energyLevel;

    final int spiciness = _spicinessFromEnergy(lastEnergy ?? 0);
    const String gt = "goblin" "." "tools" "/";
    const String ep = "api/todo";

    // Prepare the request body for the API.
    final body = {
      "text": "$title $description",
      "spiciness": spiciness.toString(),
      "Ancestors": [],
    };

    try {
      // Make the POST request to the goblin.tools API.
      final response = await _dio.post(
        "https://$gt$ep",
        data: body,
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      // Get current user from unified auth provider
      final currentUser = ref.watch(unifiedAuthProvider).value;

      // If the API returns a List, map each item to a SubtaskModel.
      if (response.data is List) {
        print("Goblin API returned a List: ${response.data}");
        return (response.data as List).map((subtaskTitle) {
          return SubtaskModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(), // temporary ID
            userId: currentUser?.uid ?? '',
            taskId: '', // will be set when main task is created
            title: subtaskTitle.toString(),
            order: response.data.indexOf(subtaskTitle),
            completed: false,
          );
        }).toList();
      }
      // If the API returns a String, split by newlines and map to SubtaskModel.
      else if (response.data is String) {
        print("Goblin API returned a String: ${response.data}");
        final subtasks = response.data
            .toString()
            .split('\n')
            .where((line) => line.trim().isNotEmpty);
        print(subtasks);
        return subtasks.map((subtaskTitle) {
          return SubtaskModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: currentUser?.uid ?? '',
            taskId: '',
            title: subtaskTitle.trim(),
            order: subtasks.toList().indexOf(subtaskTitle),
            completed: false,
          );
        }).toList();
      }

      // If the API returns neither a List nor a String, return an empty list.
      return [];
    } catch (e) {
      print('Error dividing task: $e');
      return [];
    }
  }
}