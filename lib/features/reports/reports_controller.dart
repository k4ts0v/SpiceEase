// ===== CORE DART/FLUTTER IMPORTS =====
// Standard library imports for mathematical operations and state management
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===== APPLICATION CORE IMPORTS =====
// Database and date handling utilities
import 'package:spiceease/core/database/firestore_date_adapter.dart';

// ===== DATA MODEL IMPORTS =====
// Data models for various app entities
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/models/task_model.dart';

// ===== PROVIDER IMPORTS =====
// State providers for different data types
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/data/providers/flowmodoro_provider.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/mood_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

// ===== SERVICE IMPORTS =====
// Business logic services for data operations
import 'package:spiceease/data/services/flowmodoro_service.dart';
import 'package:spiceease/data/services/medication_service.dart';
import 'package:spiceease/data/services/subtask_service.dart';
import 'package:spiceease/data/services/symptom_service.dart';
import 'package:spiceease/data/services/task_service.dart';
import 'package:spiceease/data/services/mood_service.dart';
import 'package:spiceease/data/services/habit_service.dart';
import 'package:spiceease/data/services/energy_service.dart';

// ===== REPORTS DATA MODELS =====
// Chart and analytics specific data structures
import 'package:spiceease/features/reports/data_models/metrics_data.dart';
import 'package:spiceease/features/reports/data_models/pie_data.dart';

// ===== LOCALIZATION =====
// Internationalization support
import 'package:spiceease/l10n/app_localizations.dart';

// ===== REPORTS STATE CLASS =====
/// Immutable state class containing all analytics and reporting data
///
/// This class holds the complete state for the reports page, including:
/// - Line chart data for metrics over time (mood, energy, symptoms, etc.)
/// - Pie chart data for technique usage comparisons
/// - Completion counts and streaks for tasks and habits
/// - Flowmodoro session statistics (count, focus/break time breakdown)
/// - Time block analytics (count and total hours spent)
class ReportsState {
  // ===== CHART DATA =====
  /// Data points for multi-metric line charts showing trends over time
  /// Each MetricsData contains mood, energy, symptoms, tasks, habits, and medications for a time period
  final List<MetricsData> lineChartData;

  /// Data for pie charts comparing different categories or techniques
  /// Currently used for Flowmodoro vs Time Blocks comparison
  final List<PieData> pieData;

  // ===== COMPLETION METRICS =====
  /// Total number of tasks completed within the selected time range
  /// Includes both regular tasks and completed subtasks
  final int tasksCompleted;

  /// Total number of habits completed within the selected time range
  /// Based on lastCompleted timestamp of habit entries
  final int habitsCompleted;

  // ===== STREAK ANALYTICS =====
  /// Longest consecutive streak of task completion days within the time range
  /// Calculated by finding continuous sequences of daily task completions
  final int tasksLongestStreak;

  /// Longest consecutive streak of habit completion days within the time range
  /// Calculated by finding continuous sequences of daily habit completions
  final int habitsLongestStreak;

  // ===== FLOWMODORO ANALYTICS =====
  /// Total number of completed Flowmodoro sessions within the time range
  /// Each session represents one full Flowmodoro cycle completion
  final int flowmodoroCount;

  /// Total focus time accumulated across all Flowmodoro sessions (in hours)
  /// Calculated as: sum(focusMinutes * pomoCount) / 60 for each session
  final double totalFlowFocusTime;

  /// Total break time accumulated across all Flowmodoro sessions (in hours)
  /// Calculated as: sum(breakMinutes * pomoCount) / 60 for each session
  final double totalFlowBreakTime;

  /// Combined total time spent in Flowmodoro sessions (focus + break time)
  /// Used for overall time management insights
  final double totalFlowTime;

  // ===== TIME BLOCK ANALYTICS =====
  /// Total number of time block sessions completed within the time range
  /// Includes tasks with defined start/end times or estimated durations
  final int timeBlocks;

  /// Total hours spent in time block sessions
  /// Calculated from actual start/end times or estimated durations
  final double totalTimeSpentInHours;

  // ===== CONSTRUCTOR AND METHODS =====

  /// Creates an immutable ReportsState with all analytics data
  /// Uses default values for optional metrics that may not always be available
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

  /// Creates a new ReportsState with updated values while preserving existing data
  /// Follows the immutable state pattern for Riverpod state management
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

// ===== REPORTS CONTROLLER CLASS =====
/// Main controller managing all analytics data aggregation and processing
///
/// This controller orchestrates data collection from multiple services to generate
/// comprehensive reports and insights. It handles:
/// - Multi-service data aggregation from 8+ different data sources
/// - Time range filtering and segmentation (day/week/month/year views)
/// - Statistical calculations (averages, counts, streaks, totals)
/// - Data validation and filtering of invalid/sentinel dates
/// - Chart data preparation and formatting for visualization
/// - Complex streak calculations across discontinuous data sets
class ReportsController extends StateNotifier<ReportsState> {
  // ===== SERVICE DEPENDENCIES =====
  /// All services required for comprehensive analytics data collection
  final TaskService taskService;
  final SubtaskService subtaskService;
  final MoodService moodService;
  final HabitService habitService;
  final SymptomService symptomsService;
  final EnergyService energyService;
  final FlowmodoroService flowmodoroService;
  final MedicationService medicationService;

  /// Constructor initializing the controller with all required services
  /// Sets initial empty state that will be populated by fetchReportsForTimeRange
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

  // ===== DATE VALIDATION METHODS =====

  /// Validates if a date is suitable for reporting analytics
  /// Filters out null dates and sentinel values (epoch dates) commonly used as placeholders
  ///
  /// Returns false for:
  /// - Null dates
  /// - Epoch date (1970-01-01) and dates within 1 day of epoch
  /// - These are often used as "not set" sentinel values in the database
  bool _isValidDate(DateTime? date) {
    if (date == null) return false;
    // Filter out epoch dates or dates very close to epoch (used as sentinels)
    return date.isAfter(DateTime(1970, 1, 2));
  }

  // ===== STREAK CALCULATION METHODS =====

  /// Calculates the longest consecutive streak of task completion days within a time range
  ///
  /// Combines both regular tasks and completed subtasks to get a comprehensive view
  /// of daily productivity. Creates a map of completion dates and finds the longest
  /// sequence of consecutive days with at least one completion.
  int _calculateTasksStreak(
      List tasks, List subtasks, DateTime rangeStart, DateTime rangeEnd) {
    Map<String, bool> completedDates = {};

    // ===== PROCESS COMPLETED TASKS =====
    // Filter tasks within the time range and mark completion dates
    for (final task in tasks) {
      final date = FirestoreDateAdapter.fromFirestore(task.completedAt);
      if (_isValidDate(date) &&
          date!.isAfter(rangeStart) &&
          date.isBefore(rangeEnd)) {
        // Use date string as key to avoid duplicate counting on same day
        completedDates['${date.year}-${date.month}-${date.day}'] = true;
      }
    }

    // ===== PROCESS COMPLETED SUBTASKS =====
    // Filter subtasks within the time range and mark completion dates
    for (final subtask in subtasks) {
      if (subtask.completed) {
        final date = FirestoreDateAdapter.fromFirestore(subtask.updatedAt);
        if (_isValidDate(date) &&
            date!.isAfter(rangeStart) &&
            date.isBefore(rangeEnd)) {
          // Use date string as key to avoid duplicate counting on same day
          completedDates['${date.year}-${date.month}-${date.day}'] = true;
        }
      }
    }

    return _calculateLongestStreak(completedDates);
  }

  /// Calculates the longest consecutive streak of habit completion days within a time range
  ///
  /// Processes habit lastCompleted timestamps to identify daily habit completion patterns.
  /// Creates a map of completion dates and finds the longest sequence of consecutive days.
  int _calculateHabitsStreak(
      List habits, DateTime rangeStart, DateTime rangeEnd) {
    Map<String, bool> completedDates = {};

    // ===== PROCESS HABIT COMPLETIONS =====
    // Filter habits within the time range and mark completion dates
    for (final habit in habits) {
      if (habit.lastCompleted != null) {
        final date = FirestoreDateAdapter.fromFirestore(habit.lastCompleted);
        if (_isValidDate(date) &&
            date!.isAfter(rangeStart) &&
            date.isBefore(rangeEnd)) {
          // Use date string as key to avoid duplicate counting on same day
          completedDates['${date.year}-${date.month}-${date.day}'] = true;
        }
      }
    }

    return _calculateLongestStreak(completedDates);
  }

  /// Core algorithm for calculating longest consecutive streak from completion dates
  ///
  /// Takes a map of date strings and finds the longest sequence of consecutive calendar days.
  /// Uses efficient sorting and day-difference calculation to identify streaks.
  ///
  /// Algorithm:
  /// 1. Sort completion dates chronologically
  /// 2. Iterate through adjacent dates
  /// 3. If dates are exactly 1 day apart, extend current streak
  /// 4. If gap > 1 day, reset streak to 1
  /// 5. Track maximum streak encountered
  int _calculateLongestStreak(Map<String, bool> completedDates) {
    if (completedDates.isEmpty) return 0;

    // ===== SORT COMPLETION DATES =====
    final sortedDates = completedDates.keys.toList()..sort();
    int currentStreak = 1, longestStreak = 1;

    // ===== ITERATE THROUGH CONSECUTIVE DATES =====
    for (int i = 1; i < sortedDates.length; i++) {
      // ===== PARSE DATE STRINGS =====
      final prev = sortedDates[i - 1].split('-').map(int.parse).toList();
      final curr = sortedDates[i].split('-').map(int.parse).toList();

      // ===== CHECK CONSECUTIVE DAYS =====
      // If exactly 1 day difference, extend streak
      if (DateTime(curr[0], curr[1], curr[2])
              .difference(DateTime(prev[0], prev[1], prev[2]))
              .inDays ==
          1) {
        currentStreak++;
        longestStreak = max(longestStreak, currentStreak);
      } else {
        // ===== RESET STREAK ON GAP =====
        currentStreak = 1;
      }
    }
    return longestStreak;
  }

  // ===== TIME BLOCK DATA METHODS =====

  /// Fetches all tasks that qualify as time blocks for analytics
  ///
  /// Time blocks are tasks that have either:
  /// - Defined start and end times (actual time tracking)
  /// - Estimated time duration (planned time allocation)
  /// - And must have a valid completion date
  ///
  /// This data is used for time management technique comparison and total time calculations.
  Future<List<TaskModel>> fetchTimeBlocks() async {
    final tasks = await taskService.getAllTasks();
    return tasks.where((task) {
      final completedAt = FirestoreDateAdapter.fromFirestore(task.completedAt);
      final startTime = FirestoreDateAdapter.fromFirestore(task.startTime);
      final endTime = FirestoreDateAdapter.fromFirestore(task.endTime);

      // ===== TIME BLOCK QUALIFICATION =====
      // Must have either actual timing or estimated duration, plus completion date
      return ((_isValidDate(startTime) && _isValidDate(endTime)) ||
              task.estimatedTime != null) &&
          _isValidDate(completedAt);
    }).toList();
  }

  // ===== FLOWMODORO ANALYTICS METHODS =====

  /// Fetches comprehensive Flowmodoro session statistics
  ///
  /// Returns a tuple containing:
  /// - Session count: total number of completed sessions
  /// - Focus hours: total time spent in focus periods
  /// - Break hours: total time spent in break periods
  /// - Total hours: combined focus and break time
  ///
  /// Calculations account for multiple cycles per session (pomoCount)
  Future<(int, double, double, double)> fetchFlowmodoroStats() async {
    final sessions = await flowmodoroService.getAllFlowmodoro();

    // ===== FILTER VALID SESSIONS =====
    // Only include sessions with valid creation dates
    final validSessions = sessions.where((session) {
      final createdAt = FirestoreDateAdapter.fromFirestore(session.createdAt);
      return _isValidDate(createdAt);
    }).toList();

    // ===== CALCULATE TIME TOTALS =====
    double focus = 0.0, breaks = 0.0;
    for (final session in validSessions) {
      // Convert minutes to hours, multiply by cycle count for total session time
      focus += ((session.focusMinutes) * (session.pomoCount)) / 60.0;
      breaks += ((session.breakMinutes) * (session.pomoCount)) / 60.0;
    }
    return (validSessions.length, focus, breaks, focus + breaks);
  }

  // ===== TIME PARSING METHODS =====

  /// Parses estimated time strings into minutes for consistent time calculations
  ///
  /// Supports various formats:
  /// - "2 hours", "2.5 hrs" -> converted to minutes
  /// - "30 min", "30m" -> parsed as minutes
  /// - Mixed formats: "1 hour 30 min"
  /// - Default: 60 minutes for unparseable strings
  ///
  /// This normalization allows consistent time calculations across different input formats.
  int _parseEstimatedTimeToMinutes(String estimatedTime) {
    estimatedTime = estimatedTime.toLowerCase();
    int minutes = 0;

    // ===== PARSE HOURS COMPONENT =====
    final hourMatch = RegExp(r'(\d+\.?\d*)').firstMatch(estimatedTime);
    if ((estimatedTime.contains("hour") || estimatedTime.contains("hr")) &&
        hourMatch != null) {
      minutes += (double.parse(hourMatch.group(1)!) * 60).round();
    }

    // ===== PARSE MINUTES COMPONENT =====
    final minMatch = RegExp(r'(\d+)\s*(?:min|m)').firstMatch(estimatedTime);
    if (minMatch != null) minutes += int.parse(minMatch.group(1)!);

    // ===== DEFAULT FALLBACK =====
    return minutes > 0 ? minutes : 60;
  }

  // ===== TIME DISPLAY FORMATTING METHODS =====

  /// Formats time duration in hours to human-readable display strings
  ///
  /// Intelligent formatting based on magnitude:
  /// - < 1 hour: show in minutes ("30 minutes")
  /// - 1-10 hours: show with decimal ("2.5 hours")
  /// - > 10 hours: round to nearest hour ("12 hours")
  ///
  /// Uses localized strings for proper internationalization support.
  String formatTimeDisplay(double hours, AppLocalizations localizations) {
    if (hours <= 0) {
      return "0 ${localizations.minutes}";
    }

    // ===== SMALL VALUES: SHOW MINUTES =====
    // Convert hours to minutes for values less than 1 hour
    if (hours < 1.0) {
      final minutes = (hours * 60).round();
      return "$minutes ${minutes == 1 ? localizations.minute : localizations.minutes}";
    }

    // ===== MEDIUM VALUES: SHOW DECIMAL HOURS =====
    // For 1-10 hours, show one decimal place for precision
    if (hours < 10) {
      return "${hours.toStringAsFixed(1)} ${localizations.hours}";
    }

    // ===== LARGE VALUES: ROUND TO HOURS =====
    // For very large values, round to nearest hour for simplicity
    return "${hours.round()} ${localizations.hours}";
  }

  // ===== MAIN DATA AGGREGATION METHOD =====

  /// Main method that aggregates analytics data for a specific time range
  ///
  /// This is the core orchestration method that:
  /// 1. Fetches data from all 8+ services
  /// 2. Determines time range boundaries based on selection
  /// 3. Segments data into appropriate time buckets (hours/days/weeks/months)
  /// 4. Calculates metrics for each time segment
  /// 5. Computes overall statistics and streaks
  /// 6. Updates the state with all calculated analytics
  ///
  /// Supports four time range modes:
  /// - Day: 24 hourly data points
  /// - Week: 7 daily data points
  /// - Month: Weekly aggregated data points
  /// - Year: 12 monthly data points
  Future<void> fetchReportsForTimeRange(String timeRange,
      [DateTime? selectedDate]) async {
    // ===== REFERENCE DATE SETUP =====
    final referenceDate = selectedDate ?? DateTime.now();

    // ===== FETCH ALL DATA SOURCES =====
    // Parallel data fetching from all services for comprehensive analytics
    final tasks = await taskService.getAllTasks();
    final subtasks = await subtaskService.getAllSubtasks();
    final habits = await habitService.getAllHabits();
    final medications = await medicationService.getAllMedications();
    final moodEntries = await moodService.getAllMoods();
    final energyEntries = await energyService.getAllEnergyEntries();
    final symptoms = await symptomsService.getAllSymptoms();
    final flowmodoro = await flowmodoroService.getAllFlowmodoro();

    // ===== TIME RANGE CALCULATION =====
    DateTime rangeStart = referenceDate, rangeEnd = referenceDate;
    List<MetricsData> newLineData = [];

    // ===== TIME RANGE SEGMENTATION =====
    switch (timeRange) {
      case 'day':
        // ===== DAY VIEW: HOURLY BREAKDOWN =====
        // Show 24 data points representing each hour of the selected day
        rangeStart = DateTime(
            referenceDate.year, referenceDate.month, referenceDate.day);
        rangeEnd = rangeStart.add(const Duration(days: 1));

        for (int hour = 0; hour < 24; hour++) {
          final hourStart = rangeStart.add(Duration(hours: hour));
          final hourEnd = hourStart.add(const Duration(hours: 1));
          newLineData.add(MetricsData(
            '${hour.toString().padLeft(2, '0')}:00', // Format: "09:00"
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
        // ===== WEEK VIEW: DAILY BREAKDOWN =====
        // Show 7 data points representing each day of the week (Monday-Sunday)
        final monday =
            referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
        rangeStart = DateTime(monday.year, monday.month, monday.day);
        rangeEnd = rangeStart.add(const Duration(days: 7));

        for (int i = 0; i < 7; i++) {
          final day = rangeStart.add(Duration(days: i));
          newLineData.add(MetricsData(
              '${day.month}/${day.day}', // Format: "12/25"
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
        // ===== MONTH VIEW: WEEKLY BREAKDOWN =====
        // Show weekly aggregated data points for the entire month
        rangeStart = DateTime(referenceDate.year, referenceDate.month, 1);
        rangeEnd = DateTime(referenceDate.year, referenceDate.month + 1, 1);
        final weeks = ((rangeEnd.difference(rangeStart).inDays) / 7).ceil();

        for (int week = 0; week < weeks; week++) {
          final weekStart = rangeStart.add(Duration(days: week * 7));
          final weekEnd = weekStart.add(const Duration(days: 7));
          newLineData.add(MetricsData(
            'W${week + 1}', // Format: "W1", "W2", etc.
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
        // ===== YEAR VIEW: MONTHLY BREAKDOWN =====
        // Show 12 data points representing each month of the selected year
        rangeStart = DateTime(referenceDate.year, 1, 1);
        rangeEnd = DateTime(referenceDate.year + 1, 1, 1);

        for (int month = 0; month < 12; month++) {
          final monthStart = DateTime(referenceDate.year, month + 1, 1);
          final monthEnd = DateTime(referenceDate.year, month + 2, 1);
          newLineData.add(MetricsData(
              _getMonthName(month + 1), // Format: "Jan", "Feb", etc.
              _calculateAverage(moodEntries, monthStart, monthEnd),
              _calculateAverage(energyEntries, monthStart, monthEnd),
              _countEntries(symptoms, monthStart, monthEnd),
              _countTasks(tasks, subtasks, monthStart, monthEnd),
              _countHabits(habits, monthStart, monthEnd),
              _countMedications(medications, monthStart, monthEnd)));
        }
        break;
    }

    // ===== COMPLETION COUNTS CALCULATION =====

    // ===== TASKS COMPLETION COUNT =====
    // Count both regular tasks and completed subtasks within the time range
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

    // ===== HABITS COMPLETION COUNT =====
    // Count habits with lastCompleted timestamp within the time range
    final habitsCompleted = habits.where((h) {
      final lastCompleted = FirestoreDateAdapter.fromFirestore(h.lastCompleted);
      return _isValidDate(lastCompleted) &&
          lastCompleted!.isAfter(rangeStart) &&
          lastCompleted.isBefore(rangeEnd);
    }).length;

    // ===== STREAK CALCULATIONS =====
    // Calculate longest consecutive completion streaks within the time range
    final tasksStreak =
        _calculateTasksStreak(tasks, subtasks, rangeStart, rangeEnd);
    final habitsStreak = _calculateHabitsStreak(habits, rangeStart, rangeEnd);

    // ===== FLOWMODORO STATISTICS =====

    // ===== FILTER FLOWMODORO SESSIONS =====
    // Only include sessions created within the time range
    final filteredFlow = flowmodoro.where((s) {
      final createdAt = FirestoreDateAdapter.fromFirestore(s.createdAt);
      return _isValidDate(createdAt) &&
          createdAt!.isAfter(rangeStart) &&
          createdAt.isBefore(rangeEnd);
    }).toList();

    // ===== CALCULATE FLOWMODORO METRICS =====
    int flowCount = filteredFlow.length;
    double focusHours = 0.0, breakHours = 0.0;
    for (final session in filteredFlow) {
      // Convert minutes to hours, multiply by cycle count
      focusHours += ((session.focusMinutes) * (session.pomoCount)) / 60.0;
      breakHours += ((session.breakMinutes) * (session.pomoCount)) / 60.0;
    }
    double totalFlowHours = focusHours + breakHours;

    // ===== TIME BLOCK STATISTICS =====

    // ===== FILTER TIME BLOCKS =====
    // Get time blocks completed within the time range
    final timeBlocks = (await fetchTimeBlocks()).where((t) {
      final completedAt = FirestoreDateAdapter.fromFirestore(t.completedAt);
      return _isValidDate(completedAt) &&
          completedAt!.isAfter(rangeStart) &&
          completedAt.isBefore(rangeEnd);
    }).toList();

    // ===== UPDATE STATE =====
    // Create new state with all calculated analytics data
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

  // ===== METRIC CALCULATION METHODS =====

  /// Calculates average values for mood and energy metrics within a time range
  ///
  /// Handles different data types dynamically:
  /// - MoodModel objects with moodLevel property
  /// - EnergyModel objects with energyLevel property
  /// - Map objects with corresponding keys
  ///
  /// Returns 0 if no valid data found or unrecognized format.
  double _calculateAverage(List entries, DateTime start, DateTime end) {
    // ===== FILTER ENTRIES BY TIME RANGE =====
    final filtered = entries.where((e) {
      final date = FirestoreDateAdapter.fromFirestore(e.createdAt);
      return _isValidDate(date) && !date!.isBefore(start) && !date.isAfter(end);
    }).toList();

    if (filtered.isEmpty) return 0;

    // ===== DYNAMIC TYPE HANDLING =====
    // Check the type of the first filtered entry to determine data structure
    final first = filtered.first;
    if (first is MoodModel) {
      // ===== MOOD MODEL PROCESSING =====
      return filtered.map((m) => (m as MoodModel).moodLevel.toDouble()).average;
    } else if (first.runtimeType.toString().contains('Energy')) {
      // ===== ENERGY MODEL PROCESSING =====
      // Handles EnergyModel or dynamic objects with energyLevel
      return filtered.map((e) => (e as dynamic).energyLevel.toDouble()).average;
    } else if (first is Map && first.containsKey('moodLevel')) {
      // ===== MAP WITH MOOD DATA =====
      return filtered.map((m) => m['moodLevel'].toDouble()).average;
    } else if (first is Map && first.containsKey('energyLevel')) {
      // ===== MAP WITH ENERGY DATA =====
      return filtered.map((e) => e['energyLevel'].toDouble()).average;
    }
    return 0;
  }

  /// Counts total number of entries within a time range
  /// Used for symptoms and other discrete event tracking
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

  /// Counts completed tasks and subtasks within a time range
  ///
  /// Combines:
  /// - Regular tasks with valid completedAt timestamps
  /// - Subtasks marked as completed with valid updatedAt timestamps
  ///
  /// Returns total count as double for chart compatibility.
  double _countTasks(List tasks, List subtasks, DateTime start, DateTime end) {
    // ===== COUNT COMPLETED TASKS =====
    final taskCount = tasks.where((t) {
      final date = FirestoreDateAdapter.fromFirestore(t.completedAt);
      return _isValidDate(date) && date!.isAfter(start) && date.isBefore(end);
    }).length;

    // ===== COUNT COMPLETED SUBTASKS =====
    final subtaskCount = subtasks.where((s) {
      final date = FirestoreDateAdapter.fromFirestore(s.updatedAt);
      return s.completed &&
          _isValidDate(date) &&
          date!.isAfter(start) &&
          date.isBefore(end);
    }).length;

    return (taskCount + subtaskCount).toDouble();
  }

  /// Counts completed habits within a time range
  /// Based on lastCompleted timestamp filtering
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

  /// Counts medications taken within a time range
  ///
  /// Checks completedDates array for each medication to see if any
  /// doses were taken within the specified time range. Each medication
  /// is counted once if it has any completed dates in the range.
  double _countMedications(List medications, DateTime start, DateTime end) {
    int count = 0;
    for (final m in medications) {
      if (m.completedDates != null && m.completedDates.isNotEmpty) {
        // ===== CHECK FOR ANY DOSES IN RANGE =====
        // For day/week/month/year views, check if any dose falls within range
        final takenInRange = m.completedDates
            .any((date) => !date.isBefore(start) && date.isBefore(end));
        if (takenInRange) {
          count++;
        }
      }
    }
    return count.toDouble();
  }

  // ===== TIME CALCULATION METHODS =====

  /// Calculates total time spent across multiple time blocks
  ///
  /// Handles two time calculation methods:
  /// 1. Actual timing: Uses start/end time difference
  /// 2. Estimated timing: Parses estimatedTime string
  ///
  /// Returns total time in hours for consistent reporting.
  double calculateTotalTime(List<TaskModel> blocks) {
    double total = 0.0;
    for (final block in blocks) {
      final startTime = FirestoreDateAdapter.fromFirestore(block.startTime);
      final endTime = FirestoreDateAdapter.fromFirestore(block.endTime);

      if (_isValidDate(startTime) && _isValidDate(endTime)) {
        // ===== ACTUAL TIME CALCULATION =====
        // Use precise start/end time difference
        total += endTime!.difference(startTime!).inMinutes / 60.0;
      } else if (block.estimatedTime != null) {
        // ===== ESTIMATED TIME CALCULATION =====
        // Parse estimated time string and convert to hours
        total += _parseEstimatedTimeToMinutes(block.estimatedTime!) / 60.0;
      }
    }
    return total;
  }

  // ===== UTILITY METHODS =====

  /// Converts month number to abbreviated month name for chart labels
  /// Returns 3-letter month abbreviations for compact display
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

// ===== EXTENSION METHODS =====

/// Extension on Iterable to calculate averages for numeric collections
/// Provides a convenient .average getter for lists of numbers
/// Returns 0 for empty collections to avoid division by zero
extension AverageDouble on Iterable {
  double get average {
    if (isEmpty) return 0;
    return map((e) => (e as num).toDouble()).reduce((a, b) => a + b) / length;
  }
}

// ===== PROVIDER SETUP =====

/// Riverpod provider that creates and manages the ReportsController instance
///
/// Automatically injects all required service dependencies through the ref parameter.
/// This creates a reactive state management system where the reports controller
/// can access and watch changes from all data services.
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
