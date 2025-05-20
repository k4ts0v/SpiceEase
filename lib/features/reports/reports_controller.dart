import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/database/firerstore_date_adapter.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/data/providers/flowmodoro_provider.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/mood_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/services/flowmodoro_service.dart';
import 'package:spiceease/data/services/subtask_service.dart';
import 'package:spiceease/data/services/symptom_service.dart';
import 'package:spiceease/data/services/task_service.dart';
import 'package:spiceease/data/services/mood_service.dart';
import 'package:spiceease/data/services/habit_service.dart';
import 'package:spiceease/data/services/energy_service.dart';
import 'package:spiceease/features/reports/metrics_data.dart';
import 'package:spiceease/features/reports/pie_data.dart';

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

  ReportsController({
    required this.taskService,
    required this.subtaskService,
    required this.moodService,
    required this.habitService,
    required this.symptomsService,
    required this.energyService,
    required this.flowmodoroService,
  }) : super(
          const ReportsState(
            lineChartData: [],
            pieData: [],
            tasksCompleted: 0,
            habitsCompleted: 0,
          ),
        );

  int _calculateTasksStreak(List tasks, List subtasks) {
    Map<String, bool> completedDates = {};
    for (final task in tasks) {
      if (task.completedAt != null) {
        final date = FirestoreDateAdapter.fromFirestore(task.completedAt);
        completedDates['${date.year}-${date.month}-${date.day}'] = true;
      }
    }
    for (final subtask in subtasks) {
      if (subtask.completed) {
        final date = FirestoreDateAdapter.fromFirestore(subtask.updatedAt);
        completedDates['${date.year}-${date.month}-${date.day}'] = true;
      }
    }
    return _calculateLongestStreak(completedDates);
  }

  int _calculateHabitsStreak(List habits) {
    Map<String, bool> completedDates = {};
    for (final habit in habits) {
      if (habit.lastCompleted != null) {
        final date = FirestoreDateAdapter.fromFirestore(habit.lastCompleted);
        completedDates['${date.year}-${date.month}-${date.day}'] = true;
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
      return ((task.startTime != null && task.endTime != null) ||
              task.estimatedTime != null) &&
          task.completedAt != null;
    }).toList();
  }

  Future<(int, double, double, double)> fetchFlowmodoroStats() async {
    final sessions = await flowmodoroService.getAllFlowmodoro();
    double focus = 0.0, breaks = 0.0;
    for (final session in sessions) {
      focus += ((session.focusMinutes ?? 0) * (session.pomoCount ?? 1)) / 60.0;
      breaks += ((session.breakMinutes ?? 0) * (session.pomoCount ?? 1)) / 60.0;
    }
    return (sessions.length, focus, breaks, focus + breaks);
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

  String formatTimeDisplay(double hours) {
    return hours < 1.0
        ? "${(hours * 60).round()} minutes"
        : "${hours.toStringAsFixed(1)} hours";
  }

  Future<void> fetchReportsForTimeRange(String timeRange,
      [DateTime? selectedDate]) async {
    final referenceDate = selectedDate ?? DateTime.now();
    final tasks = await taskService.getAllTasks();
    final subtasks = await subtaskService.getAllSubtasks();
    final habits = await habitService.getAllHabits();
    final moodEntries = await moodService.getAllMoods();
    final energyEntries = await energyService.getAllEnergyEntries();
    final symptoms = await symptomsService.getAllSymptoms();
    final flowmodoro = await flowmodoroService.getAllFlowmodoro();

    final tasksCompleted = tasks.where((t) => t.completedAt != null).length +
        subtasks.where((s) => s.completed).length;
    final habitsCompleted = habits.where((h) => h.lastCompleted != null).length;
    final tasksStreak = _calculateTasksStreak(tasks, subtasks);
    final habitsStreak = _calculateHabitsStreak(habits);

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
            _countTasks(tasks, subtasks, day, day.add(const Duration(days: 1))),
            _countHabits(habits, day, day.add(const Duration(days: 1))),
          ));
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
          ));
        }
        break;
    }

    final filteredFlow = flowmodoro
        .where((s) =>
            FirestoreDateAdapter.fromFirestore(s.createdAt)
                .isAfter(rangeStart) &&
            FirestoreDateAdapter.fromFirestore(s.createdAt).isBefore(rangeEnd))
        .toList();

    final (flowCount, focusHours, breakHours, totalFlowHours) =
        await fetchFlowmodoroStats();
    final timeBlocks = (await fetchTimeBlocks())
        .where((t) =>
            FirestoreDateAdapter.fromFirestore(t.completedAt)
                .isAfter(rangeStart) &&
            FirestoreDateAdapter.fromFirestore(t.completedAt)
                .isBefore(rangeEnd))
        .toList();

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
      return date.isAfter(start) && date.isBefore(end);
    }).toList();

    if (filtered.isEmpty) return 0;
    if (entries.first is MoodModel) {
      return filtered.map((m) => m.moodLevel.toDouble()).average;
    }
    return filtered.map((e) => e.energyLevel.toDouble()).average;
  }

  double _countEntries(List entries, DateTime start, DateTime end) {
    return entries
        .where((e) {
          final date = FirestoreDateAdapter.fromFirestore(e.createdAt);
          return date.isAfter(start) && date.isBefore(end);
        })
        .length
        .toDouble();
  }

  double _countTasks(List tasks, List subtasks, DateTime start, DateTime end) {
    final taskCount = tasks.where((t) {
      final date = t.completedAt != null
          ? FirestoreDateAdapter.fromFirestore(t.completedAt)
          : null;
      return date != null && date.isAfter(start) && date.isBefore(end);
    }).length;

    final subtaskCount = subtasks.where((s) {
      return s.completed &&
          FirestoreDateAdapter.fromFirestore(s.updatedAt).isAfter(start) &&
          FirestoreDateAdapter.fromFirestore(s.updatedAt).isBefore(end);
    }).length;

    return (taskCount + subtaskCount).toDouble();
  }

  double _countHabits(List habits, DateTime start, DateTime end) {
    return habits
        .where((h) {
          final date = h.lastCompleted != null
              ? FirestoreDateAdapter.fromFirestore(h.lastCompleted)
              : null;
          return date != null && date.isAfter(start) && date.isBefore(end);
        })
        .length
        .toDouble();
  }

  double calculateTotalTime(List<TaskModel> blocks) {
    double total = 0.0;
    for (final block in blocks) {
      if (block.startTime != null && block.endTime != null) {
        final start = FirestoreDateAdapter.fromFirestore(block.startTime);
        final end = FirestoreDateAdapter.fromFirestore(block.endTime);
        total += end.difference(start).inMinutes / 60.0;
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

extension on Iterable {
  double get average => isEmpty
      ? 0
      : reduce((a, b) => a + b) / length.toDouble();
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
  );
});


