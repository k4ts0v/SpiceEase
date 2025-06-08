import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/database/firestore_date_adapter.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/data/providers/flowmodoro_provider.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/mood_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/services/flowmodoro_service.dart';
import 'package:spiceease/data/services/medication_service.dart';
import 'package:spiceease/data/services/subtask_service.dart';
import 'package:spiceease/data/services/symptom_service.dart';
import 'package:spiceease/data/services/task_service.dart';
import 'package:spiceease/data/services/mood_service.dart';
import 'package:spiceease/data/services/habit_service.dart';
import 'package:spiceease/data/services/energy_service.dart';
import 'package:spiceease/features/reports/metrics_data.dart';
import 'package:spiceease/features/reports/pie_data.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class ReportsState {
  final List<MetricsData> lineChartData;
  final List<PieData> pieData;
  final int tasksCompleted;
  final int habitsCompleted;
  final int tasksLongestStreak;
  final int habitsLongestStreak;
  final int flowmodoroCount;
  final int timeBlocks;
  final double totalTimeSpentInHours;
  final double totalFlowFocusTime;
  final double totalFlowBreakTime;
  final double totalFlowTime;

  const ReportsState({
    required this.lineChartData,
    required this.pieData,
    required this.tasksCompleted,
    required this.habitsCompleted,
    this.tasksLongestStreak = 0,
    this.habitsLongestStreak = 0,
    this.flowmodoroCount = 0,
    this.timeBlocks = 0,
    this.totalTimeSpentInHours = 0.0,
    this.totalFlowFocusTime = 0.0,
    this.totalFlowBreakTime = 0.0,
    this.totalFlowTime = 0.0,
  });

  ReportsState copyWith({
    List<MetricsData>? lineChartData,
    List<PieData>? pieData,
    int? tasksCompleted,
    int? habitsCompleted,
    int? tasksLongestStreak,
    int? habitsLongestStreak,
    int? flowmodoroCount,
    int? timeBlocks,
    double? totalTimeSpentInHours,
    double? totalFlowFocusTime,
    double? totalFlowBreakTime,
    double? totalFlowTime,
  }) {
    return ReportsState(
      lineChartData: lineChartData ?? this.lineChartData,
      pieData: pieData ?? this.pieData,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      habitsCompleted: habitsCompleted ?? this.habitsCompleted,
      tasksLongestStreak: tasksLongestStreak ?? this.tasksLongestStreak,
      habitsLongestStreak: habitsLongestStreak ?? this.habitsLongestStreak,
      flowmodoroCount: flowmodoroCount ?? this.flowmodoroCount,
      timeBlocks: timeBlocks ?? this.timeBlocks,
      totalTimeSpentInHours:
          totalTimeSpentInHours ?? this.totalTimeSpentInHours,
      totalFlowFocusTime: totalFlowFocusTime ?? this.totalFlowFocusTime,
      totalFlowBreakTime: totalFlowBreakTime ?? this.totalFlowBreakTime,
      totalFlowTime: totalFlowTime ?? this.totalFlowTime,
    );
  }
}

class ReportsController extends StateNotifier<ReportsState> {
  final TaskService taskService;
  final SubtaskService subtaskService;
  final MoodService moodService;
  final HabitService habitService;
  final SymptomService symptomsService;
  final EnergyService energyService;
  final FlowmodoroService flowmodoroService;
  final MedicationService medicationService;

  ReportsController({
    required this.taskService,
    required this.subtaskService,
    required this.moodService,
    required this.habitService,
    required this.symptomsService,
    required this.energyService,
    required this.flowmodoroService,
    required this.medicationService,
  }) : super(
          const ReportsState(
            lineChartData: [],
            pieData: [],
            tasksCompleted: 0,
            habitsCompleted: 0,
          ),
        );

  /// Checks if a date is valid for reporting (not null, not epoch/sentinel date)
  bool _isValidDate(DateTime? date) {
    if (date == null) return false;
    // Filter out epoch dates or dates very close to epoch (used as sentinels)
    return date.isAfter(DateTime(1970, 1, 2));
  }

  /// Safely extracts date from an object's field with validation
  DateTime? _safeGetDate(dynamic obj, String fieldName) {
    final date = FirestoreDateAdapter.fromFirestore(obj[fieldName]);
    return _isValidDate(date) ? date : null;
  }

  int _calculateTasksStreak(
      List tasks, List subtasks, DateTime rangeStart, DateTime rangeEnd) {
    Map<String, bool> completedDates = {};

    // Filter tasks within the time range
    for (final task in tasks) {
      final date = FirestoreDateAdapter.fromFirestore(task.completedAt);
      if (_isValidDate(date) &&
          date!.isAfter(rangeStart) &&
          date.isBefore(rangeEnd)) {
        completedDates['${date.year}-${date.month}-${date.day}'] = true;
      }
    }

    // Filter subtasks within the time range
    for (final subtask in subtasks) {
      if (subtask.completed) {
        final date = FirestoreDateAdapter.fromFirestore(subtask.updatedAt);
        if (_isValidDate(date) &&
            date!.isAfter(rangeStart) &&
            date.isBefore(rangeEnd)) {
          completedDates['${date.year}-${date.month}-${date.day}'] = true;
        }
      }
    }

    return _calculateLongestStreak(completedDates);
  }

  int _calculateHabitsStreak(
      List habits, DateTime rangeStart, DateTime rangeEnd) {
    Map<String, bool> completedDates = {};

    // Filter habits within the time range
    for (final habit in habits) {
      if (habit.lastCompleted != null) {
        final date = FirestoreDateAdapter.fromFirestore(habit.lastCompleted);
        if (_isValidDate(date) &&
            date!.isAfter(rangeStart) &&
            date.isBefore(rangeEnd)) {
          completedDates['${date.year}-${date.month}-${date.day}'] = true;
        }
      }
    }

    return _calculateLongestStreak(completedDates);
  }

  int _calculateLongestStreak(Map<String, bool> completedDates) {
    if (completedDates.isEmpty) return 0;
    final sortedDates = completedDates.keys.toList()..sort();
    int currentStreak = 1, longestStreak = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      final prev = sortedDates[i - 1].split('-').map(int.parse).toList();
      final curr = sortedDates[i].split('-').map(int.parse).toList();
      if (DateTime(curr[0], curr[1], curr[2])
              .difference(DateTime(prev[0], prev[1], prev[2]))
              .inDays ==
          1) {
        currentStreak++;
        longestStreak = max(longestStreak, currentStreak);
      } else {
        currentStreak = 1;
      }
    }
    return longestStreak;
  }

  Future<List<TaskModel>> fetchTimeBlocks() async {
    final tasks = await taskService.getAllTasks();
    return tasks.where((task) {
      final completedAt = FirestoreDateAdapter.fromFirestore(task.completedAt);
      final startTime = FirestoreDateAdapter.fromFirestore(task.startTime);
      final endTime = FirestoreDateAdapter.fromFirestore(task.endTime);

      return ((_isValidDate(startTime) && _isValidDate(endTime)) ||
              task.estimatedTime != null) &&
          _isValidDate(completedAt);
    }).toList();
  }

  Future<(int, double, double, double)> fetchFlowmodoroStats() async {
    final sessions = await flowmodoroService.getAllFlowmodoro();

    // Filter out sessions with invalid dates
    final validSessions = sessions.where((session) {
      final createdAt = FirestoreDateAdapter.fromFirestore(session.createdAt);
      return _isValidDate(createdAt);
    }).toList();

    double focus = 0.0, breaks = 0.0;
    for (final session in validSessions) {
      focus += ((session.focusMinutes ?? 0) * (session.pomoCount ?? 1)) / 60.0;
      breaks += ((session.breakMinutes ?? 0) * (session.pomoCount ?? 1)) / 60.0;
    }
    return (validSessions.length, focus, breaks, focus + breaks);
  }

  int _parseEstimatedTimeToMinutes(String estimatedTime) {
    estimatedTime = estimatedTime.toLowerCase();
    int minutes = 0;
    final hourMatch = RegExp(r'(\d+\.?\d*)').firstMatch(estimatedTime);
    if ((estimatedTime.contains("hour") || estimatedTime.contains("hr")) &&
        hourMatch != null) {
      minutes += (double.parse(hourMatch.group(1)!) * 60).round();
    }
    final minMatch = RegExp(r'(\d+)\s*(?:min|m)').firstMatch(estimatedTime);
    if (minMatch != null) minutes += int.parse(minMatch.group(1)!);
    return minutes > 0 ? minutes : 60;
  }

  String formatTimeDisplay(double hours, AppLocalizations localizations) {
    if (hours <= 0) {
      return "0 ${localizations.minutes}";
    }

    // Convert hours to minutes for small values
    if (hours < 1.0) {
      final minutes = (hours * 60).round();
      return "$minutes ${minutes == 1 ? localizations.minute : localizations.minutes}";
    }

    // For larger values, show hours with one decimal place
    if (hours < 10) {
      return "${hours.toStringAsFixed(1)} ${localizations.hours}";
    }

    // For very large values, round to nearest hour
    return "${hours.round()} ${localizations.hours}";
  }

  Future<void> fetchReportsForTimeRange(String timeRange,
      [DateTime? selectedDate]) async {
    final referenceDate = selectedDate ?? DateTime.now();
    final tasks = await taskService.getAllTasks();
    final subtasks = await subtaskService.getAllSubtasks();
    final habits = await habitService.getAllHabits();
    final medications = await medicationService.getAllMedications();
    final moodEntries = await moodService.getAllMoods();
    final energyEntries = await energyService.getAllEnergyEntries();
    final symptoms = await symptomsService.getAllSymptoms();
    final flowmodoro = await flowmodoroService.getAllFlowmodoro();

    DateTime rangeStart = referenceDate, rangeEnd = referenceDate;
    List<MetricsData> newLineData = [];

    switch (timeRange) {
      case 'day':
        rangeStart = DateTime(
            referenceDate.year, referenceDate.month, referenceDate.day);
        rangeEnd = rangeStart.add(const Duration(days: 1));
        for (int hour = 0; hour < 24; hour++) {
          final hourStart = rangeStart.add(Duration(hours: hour));
          final hourEnd = hourStart.add(const Duration(hours: 1));
          newLineData.add(MetricsData(
            '${hour.toString().padLeft(2, '0')}:00',
            _calculateAverage(moodEntries, hourStart, hourEnd),
            _calculateAverage(energyEntries, hourStart, hourEnd),
            _countEntries(symptoms, hourStart, hourEnd),
            _countTasks(tasks, subtasks, hourStart, hourEnd),
            _countHabits(habits, hourStart, hourEnd),
            _countMedications(medications, hourStart, hourEnd),
          ));
        }
        break;

      case 'week':
        final monday =
            referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
        rangeStart = DateTime(monday.year, monday.month, monday.day);
        rangeEnd = rangeStart.add(const Duration(days: 7));
        for (int i = 0; i < 7; i++) {
          final day = rangeStart.add(Duration(days: i));
          newLineData.add(MetricsData(
              '${day.month}/${day.day}',
              _calculateAverage(
                  moodEntries, day, day.add(const Duration(days: 1))),
              _calculateAverage(
                  energyEntries, day, day.add(const Duration(days: 1))),
              _countEntries(symptoms, day, day.add(const Duration(days: 1))),
              _countTasks(
                  tasks, subtasks, day, day.add(const Duration(days: 1))),
              _countHabits(habits, day, day.add(const Duration(days: 1))),
              _countMedications(
                  medications, day, day.add(const Duration(days: 1)))));
        }
        break;

      case 'month':
        rangeStart = DateTime(referenceDate.year, referenceDate.month, 1);
        rangeEnd = DateTime(referenceDate.year, referenceDate.month + 1, 1);
        final weeks = ((rangeEnd.difference(rangeStart).inDays) / 7).ceil();
        for (int week = 0; week < weeks; week++) {
          final weekStart = rangeStart.add(Duration(days: week * 7));
          final weekEnd = weekStart.add(const Duration(days: 7));
          newLineData.add(MetricsData(
            'W${week + 1}',
            _calculateAverage(moodEntries, weekStart, weekEnd),
            _calculateAverage(energyEntries, weekStart, weekEnd),
            _countEntries(symptoms, weekStart, weekEnd),
            _countTasks(tasks, subtasks, weekStart, weekEnd),
            _countHabits(habits, weekStart, weekEnd),
            _countMedications(medications, weekStart, weekEnd),
          ));
        }
        break;

      case 'year':
        rangeStart = DateTime(referenceDate.year, 1, 1);
        rangeEnd = DateTime(referenceDate.year + 1, 1, 1);
        for (int month = 0; month < 12; month++) {
          final monthStart = DateTime(referenceDate.year, month + 1, 1);
          final monthEnd = DateTime(referenceDate.year, month + 2, 1);
          newLineData.add(MetricsData(
              _getMonthName(month + 1),
              _calculateAverage(moodEntries, monthStart, monthEnd),
              _calculateAverage(energyEntries, monthStart, monthEnd),
              _countEntries(symptoms, monthStart, monthEnd),
              _countTasks(tasks, subtasks, monthStart, monthEnd),
              _countHabits(habits, monthStart, monthEnd),
              _countMedications(medications, monthStart, monthEnd)));
        }
        break;
    }

    // Count only tasks with valid completion dates within the range
    final tasksCompleted = tasks.where((t) {
          final completedAt = FirestoreDateAdapter.fromFirestore(t.completedAt);
          return _isValidDate(completedAt) &&
              completedAt!.isAfter(rangeStart) &&
              completedAt.isBefore(rangeEnd);
        }).length +
        subtasks.where((s) {
          if (s.completed) {
            final updatedAt = FirestoreDateAdapter.fromFirestore(s.updatedAt);
            return _isValidDate(updatedAt) &&
                updatedAt!.isAfter(rangeStart) &&
                updatedAt.isBefore(rangeEnd);
          }
          return false;
        }).length;

    // Count only habits with valid completion dates within the range
    final habitsCompleted = habits.where((h) {
      final lastCompleted = FirestoreDateAdapter.fromFirestore(h.lastCompleted);
      return _isValidDate(lastCompleted) &&
          lastCompleted!.isAfter(rangeStart) &&
          lastCompleted.isBefore(rangeEnd);
    }).length;

    // Calculate streaks within the selected time range
    final tasksStreak =
        _calculateTasksStreak(tasks, subtasks, rangeStart, rangeEnd);
    final habitsStreak = _calculateHabitsStreak(habits, rangeStart, rangeEnd);

    final filteredFlow = flowmodoro.where((s) {
      final createdAt = FirestoreDateAdapter.fromFirestore(s.createdAt);
      return _isValidDate(createdAt) &&
          createdAt!.isAfter(rangeStart) &&
          createdAt.isBefore(rangeEnd);
    }).toList();

    int flowCount = filteredFlow.length;
    double focusHours = 0.0, breakHours = 0.0;
    for (final session in filteredFlow) {
      focusHours += ((session.focusMinutes) * (session.pomoCount)) / 60.0;
      breakHours += ((session.breakMinutes) * (session.pomoCount)) / 60.0;
    }
    double totalFlowHours = focusHours + breakHours;

    final timeBlocks = (await fetchTimeBlocks()).where((t) {
      final completedAt = FirestoreDateAdapter.fromFirestore(t.completedAt);
      return _isValidDate(completedAt) &&
          completedAt!.isAfter(rangeStart) &&
          completedAt.isBefore(rangeEnd);
    }).toList();

    state = state.copyWith(
      lineChartData: newLineData,
      tasksCompleted: tasksCompleted,
      habitsCompleted: habitsCompleted,
      tasksLongestStreak: tasksStreak,
      habitsLongestStreak: habitsStreak,
      flowmodoroCount: flowCount,
      timeBlocks: timeBlocks.length,
      totalTimeSpentInHours: calculateTotalTime(timeBlocks),
      totalFlowFocusTime: focusHours,
      totalFlowBreakTime: breakHours,
      totalFlowTime: totalFlowHours,
    );
  }

  double _calculateAverage(List entries, DateTime start, DateTime end) {
    final filtered = entries.where((e) {
      final date = FirestoreDateAdapter.fromFirestore(e.createdAt);
      return _isValidDate(date) && !date!.isBefore(start) && !date.isAfter(end);
    }).toList();

    if (filtered.isEmpty) return 0;

    // Check the type of the first filtered entry
    final first = filtered.first;
    if (first is MoodModel) {
      return filtered.map((m) => (m as MoodModel).moodLevel.toDouble()).average;
    } else if (first.runtimeType.toString().contains('Energy')) {
      // Handles EnergyModel or dynamic with energyLevel
      return filtered.map((e) => (e as dynamic).energyLevel.toDouble()).average;
    } else if (first is Map && first.containsKey('moodLevel')) {
      return filtered.map((m) => m['moodLevel'].toDouble()).average;
    } else if (first is Map && first.containsKey('energyLevel')) {
      return filtered.map((e) => e['energyLevel'].toDouble()).average;
    }
    return 0;
  }

  double _countEntries(List entries, DateTime start, DateTime end) {
    return entries
        .where((e) {
          final date = FirestoreDateAdapter.fromFirestore(e.createdAt);
          return _isValidDate(date) &&
              date!.isAfter(start) &&
              date.isBefore(end);
        })
        .length
        .toDouble();
  }

  double _countTasks(List tasks, List subtasks, DateTime start, DateTime end) {
    final taskCount = tasks.where((t) {
      final date = FirestoreDateAdapter.fromFirestore(t.completedAt);
      return _isValidDate(date) && date!.isAfter(start) && date.isBefore(end);
    }).length;

    final subtaskCount = subtasks.where((s) {
      final date = FirestoreDateAdapter.fromFirestore(s.updatedAt);
      return s.completed &&
          _isValidDate(date) &&
          date!.isAfter(start) &&
          date.isBefore(end);
    }).length;

    return (taskCount + subtaskCount).toDouble();
  }

  double _countHabits(List habits, DateTime start, DateTime end) {
    return habits
        .where((h) {
          final date = FirestoreDateAdapter.fromFirestore(h.lastCompleted);
          return _isValidDate(date) &&
              date!.isAfter(start) &&
              date.isBefore(end);
        })
        .length
        .toDouble();
  }

  double _countMedications(List medications, DateTime start, DateTime end,
      {String timeRange = 'day'}) {
    int count = 0;
    for (final m in medications) {
      if (m.completedDates != null && m.completedDates.isNotEmpty) {
        // For 'day', count if any completedDate falls within the day range
        // For week/month/year, same logic applies (range is just wider)
        final takenInRange = m.completedDates
            .any((date) => !date.isBefore(start) && date.isBefore(end));
        if (takenInRange) {
          count++;
        }
      }
    }
    return count.toDouble();
  }

  double calculateTotalTime(List<TaskModel> blocks) {
    double total = 0.0;
    for (final block in blocks) {
      final startTime = FirestoreDateAdapter.fromFirestore(block.startTime);
      final endTime = FirestoreDateAdapter.fromFirestore(block.endTime);

      if (_isValidDate(startTime) && _isValidDate(endTime)) {
        total += endTime!.difference(startTime!).inMinutes / 60.0;
      } else if (block.estimatedTime != null) {
        total += _parseEstimatedTimeToMinutes(block.estimatedTime!) / 60.0;
      }
    }
    return total;
  }

  String _getMonthName(int month) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][month - 1];
}

extension AverageDouble on Iterable {
  double get average {
    if (isEmpty) return 0;
    return map((e) => (e as num).toDouble()).reduce((a, b) => a + b) / length;
  }
}

final reportsControllerProvider =
    StateNotifierProvider<ReportsController, ReportsState>((ref) {
  return ReportsController(
    taskService: ref.watch(taskServiceProvider),
    subtaskService: ref.watch(subtaskServiceProvider),
    moodService: ref.watch(moodServiceProvider),
    habitService: ref.watch(habitServiceProvider),
    symptomsService: ref.watch(symptomServiceProvider),
    energyService: ref.watch(energyServiceProvider),
    flowmodoroService: ref.watch(flowmodoroServiceProvider),
    medicationService: ref.watch(medicationServiceProvider),
  );
});
