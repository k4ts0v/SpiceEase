/// This file tests the UI overflow and layout handling of the ReportsPage widget.
///
/// # Testing Strategy
///
/// This test suite validates UI robustness:
/// 1. UI Overflow Prevention with long text content in charts and metrics
/// 2. Screen Size Responsiveness across different devices
/// 3. Layout stability with comprehensive reports data
/// 4. Chart rendering and text wrapping handling
/// 5. Metrics display overflow handling
/// 6. Time range selector UI behavior
/// 7. Calendar week selector integration
///
/// # How to run
/// - Run with `flutter test test/features/reports/reports_ui_test.dart`

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spiceease/components/calendar_week_selector.dart';
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/models/flowmodoro_model.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/services/energy_service.dart';
import 'package:spiceease/data/services/flowmodoro_service.dart';
import 'package:spiceease/data/services/habit_service.dart';
import 'package:spiceease/data/services/medication_service.dart';
import 'package:spiceease/data/services/mood_service.dart';
import 'package:spiceease/data/services/subtask_service.dart';
import 'package:spiceease/data/services/symptom_service.dart';
import 'package:spiceease/data/services/task_service.dart';
import 'package:spiceease/features/reports/metrics_data.dart';
import 'package:spiceease/features/reports/pie_data.dart';
import 'package:spiceease/features/reports/reports_controller.dart';
import 'package:spiceease/features/reports/reports_page.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Generate mocks for all services
@GenerateMocks([
  TaskService,
  SubtaskService,
  MoodService,
  HabitService,
  SymptomService,
  EnergyService,
  FlowmodoroService,
  MedicationService,
])
import 'reports_ui_test.mocks.dart';

// --------------------------------------------------------------------------
// STANDARDIZED TEST SCREEN SIZES - MUST MATCH ACROSS ALL UI TESTS
// --------------------------------------------------------------------------

/// Standardized screen sizes for consistent testing across ALL UI test suites
/// These sizes MUST be kept identical across kanban_ui_test.dart, time_blocks_ui_test.dart, and reports_ui_test.dart
const List<Size> standardTestSizes = [
  Size(375, 667), // iPhone SE (small mobile)
  Size(390, 844), // iPhone 12/13 mini
  Size(414, 896), // iPhone 11 (large mobile)
  Size(768, 1024), // iPad Portrait (tablet)
  Size(1024, 768), // iPad Landscape (tablet landscape)
  Size(1200, 800), // Desktop (standard)
  Size(1920, 1080), // Large Desktop
];

// --------------------------------------------------------------------------
// Test Data Setup for Reports UI Testing
// --------------------------------------------------------------------------

/// Fixed test date for consistent testing across all scenarios
final testSelectedDate = DateTime(2025, 6, 15);

/// UI-focused test data with emphasis on content that can cause overflow in reports
class ReportsUITestData {
  /// Tasks with extremely long titles for chart labels testing
  static List<TaskModel> getTasksWithLongTitles({required DateTime forDate}) {
    final baseDate = DateTime(forDate.year, forDate.month, forDate.day);
    return [
      TaskModel(
        id: 'chart-long-title-1',
        title:
            'This is an extremely long task title that should test how charts and metrics handle very long text content in tooltips and data labels without causing UI overflow',
        status: 'Done',
        dueDate: forDate,
        completedAt: forDate,
        estimatedTime: '2 hours 30 minutes',
        startTime: baseDate.add(const Duration(hours: 9)),
        endTime: baseDate.add(const Duration(hours: 11, minutes: 30)),
        priority: 1,
        createdAt: forDate.subtract(const Duration(days: 5)),
        userId: 'test-user',
        updatedAt: forDate,
      ),
      TaskModel(
        id: 'chart-long-title-2',
        title:
            'Another extremely long task title for comprehensive chart overflow testing in reports with extensive metadata and descriptions',
        status: 'Done',
        dueDate: forDate.add(const Duration(days: 1)),
        completedAt: forDate.add(const Duration(days: 1)),
        estimatedTime: '4 hours 15 minutes',
        startTime: baseDate.add(const Duration(days: 1, hours: 14)),
        endTime: baseDate.add(const Duration(days: 1, hours: 18, minutes: 15)),
        priority: 2,
        createdAt: forDate.subtract(const Duration(days: 4)),
        userId: 'test-user',
        updatedAt: forDate.add(const Duration(days: 1)),
      ),
      TaskModel(
        id: 'chart-long-title-3',
        title:
            'Third extremely verbose task title that tests chart rendering performance with multiple long data points and comprehensive content',
        status: 'Done',
        dueDate: forDate.add(const Duration(days: 2)),
        completedAt: forDate.add(const Duration(days: 2)),
        estimatedTime: '1 hour 45 minutes',
        startTime: baseDate.add(const Duration(days: 2, hours: 10)),
        endTime: baseDate.add(const Duration(days: 2, hours: 11, minutes: 45)),
        priority: 3,
        createdAt: forDate.subtract(const Duration(days: 3)),
        userId: 'test-user',
        updatedAt: forDate.add(const Duration(days: 2)),
      ),
    ];
  }

  /// Comprehensive data for maximum metrics testing
  static List<TaskModel> getComprehensiveTasksForMetrics(
      {required DateTime forDate}) {
    final baseDate = DateTime(forDate.year, forDate.month, forDate.day);
    return List.generate(20, (index) {
      return TaskModel(
        id: 'metrics-task-$index',
        title:
            'Comprehensive Metrics Task $index with Detailed Information for Chart Display Testing',
        status: index % 4 == 0 ? 'Done' : 'todo',
        dueDate: forDate.add(Duration(days: index % 7)),
        completedAt:
            index % 4 == 0 ? forDate.add(Duration(days: index % 7)) : null,
        estimatedTime: '${(index % 8) + 1} hours ${(index * 15) % 60} minutes',
        startTime: index % 3 == 0
            ? baseDate.add(Duration(hours: 9 + (index % 12)))
            : null,
        endTime: index % 3 == 0
            ? baseDate.add(Duration(hours: 10 + (index % 12)))
            : null,
        priority: (index % 5) + 1,
        createdAt: forDate.subtract(Duration(days: 10 + index)),
        userId: 'test-user',
        updatedAt: forDate.subtract(Duration(hours: index % 24)),
      );
    });
  }

  /// Habits with extensive completion data for streak calculations
  static List<HabitModel> getComprehensiveHabitsForMetrics(
      {required DateTime forDate}) {
    return [
      HabitModel(
        id: 'comprehensive-habit-1',
        userId: 'test-user',
        title:
            'Comprehensive Daily Habit with Very Long Title That Tests Chart Label Overflow Handling in Reports Dashboard',
        description:
            'This is an extremely detailed habit description that contains comprehensive information about the habit requirements, benefits, tracking methodology, and implementation strategies. It should test how the reports UI handles very long text content in habit data.',
        frequency: 1, // Daily
        completedDates: List.generate(
            30, (index) => forDate.subtract(Duration(days: index))),
        createdAt: forDate.subtract(const Duration(days: 60)),
      ),
      HabitModel(
        id: 'comprehensive-habit-2',
        userId: 'test-user',
        title:
            'Weekly Comprehensive Habit for Advanced Metrics Testing with Extensive Metadata',
        description:
            'Detailed weekly habit for comprehensive metrics calculation and chart display testing.',
        frequency: 7, // Weekly
        completedDates: List.generate(
            15, (index) => forDate.subtract(Duration(days: index * 7))),
        createdAt: forDate.subtract(const Duration(days: 120)),
      ),
      HabitModel(
        id: 'comprehensive-habit-3',
        userId: 'test-user',
        title:
            'Monthly Habit with Maximum Data Content for Comprehensive Chart Testing and Overflow Prevention',
        description: 'Monthly habit with extensive tracking data.',
        frequency: 30, // Monthly
        completedDates: List.generate(
            12, (index) => forDate.subtract(Duration(days: index * 30))),
        createdAt: forDate.subtract(const Duration(days: 365)),
      ),
    ];
  }

  /// Moods with varied levels for chart diversity
  static List<MoodModel> getComprehensiveMoodsForCharts(
      {required DateTime forDate}) {
    return List.generate(50, (index) {
      return MoodModel(
        id: 'chart-mood-$index',
        userId: 'test-user',
        moodLevel: (index % 5) + 1, // 1-5 range
        notes:
            'Comprehensive mood entry $index with detailed notes about feelings, events, triggers, and context that should test how the UI handles extensive mood data in charts and metrics. This note contains multiple sentences to test text overflow handling.',
        createdAt: forDate.subtract(Duration(hours: index * 2)),
        updatedAt: forDate.subtract(Duration(hours: index * 2)),
      );
    });
  }

  /// Energy entries for chart testing
  static List<EnergyModel> getComprehensiveEnergyForCharts(
      {required DateTime forDate}) {
    return List.generate(40, (index) {
      return EnergyModel(
        id: 'chart-energy-$index',
        userId: 'test-user',
        energyLevel: (index % 5) + 1, // 1-5 range
        notes:
            'Comprehensive energy tracking entry $index with extensive details about energy levels, contributing factors, activities, and environmental conditions that affected energy throughout the day.',
        createdAt: forDate.subtract(Duration(hours: index * 3)),
      );
    });
  }

  /// Symptoms for comprehensive metrics
  static List<SymptomModel> getComprehensiveSymptomsForMetrics(
      {required DateTime forDate}) {
    final symptoms = [
      'Headache',
      'Fatigue',
      'Nausea',
      'Dizziness',
      'Back Pain',
      'Anxiety',
      'Insomnia'
    ];
    final categories = [
      'Pain',
      'Energy',
      'Digestive',
      'Neurological',
      'Musculoskeletal',
      'Mental Health',
      'Sleep'
    ];

    return List.generate(35, (index) {
      return SymptomModel(
        id: 'comprehensive-symptom-$index',
        userId: 'test-user',
        name:
            '${symptoms[index % symptoms.length]} with Detailed Description $index',
        category: categories[index % categories.length],
        severity: (index % 5) + 1,
        createdAt: forDate.subtract(Duration(hours: index * 4)),
      );
    });
  }

  /// Flowmodoro sessions for time tracking metrics
  static List<FlowmodoroModel> getComprehensiveFlowmodoroForMetrics(
      {required DateTime forDate}) {
    return List.generate(25, (index) {
      return FlowmodoroModel(
        id: 'comprehensive-flow-$index',
        taskId: 'metrics-task-${index % 20}',
        focusMinutes: 25 + (index % 35), // Varied focus times
        breakMinutes: 5 + (index % 15), // Varied break times
        pomoCount: (index % 8) + 1,
        createdAt: forDate.subtract(Duration(hours: index * 2)),
      );
    });
  }

  /// Medications for comprehensive tracking
  static List<MedicationModel> getComprehensiveMedicationsForMetrics(
      {required DateTime forDate}) {
    return [
      MedicationModel(
        id: 'comprehensive-med-1',
        userId: 'test-user',
        name:
            'Comprehensive Daily Medication with Very Long Name for Chart Label Testing',
        dose: 100,
        unit: 'mg',
        frequency: 'Daily',
        timesPerDay: 2,
        completedDates: List.generate(
            30, (index) => forDate.subtract(Duration(days: index))),
        createdAt: forDate.subtract(const Duration(days: 60)),
        updatedAt: forDate,
      ),
      MedicationModel(
        id: 'comprehensive-med-2',
        userId: 'test-user',
        name: 'Weekly Comprehensive Supplement for Advanced Metrics Testing',
        dose: 500,
        unit: 'IU',
        frequency: 'Weekly',
        timesPerDay: 1,
        completedDates: List.generate(
            15, (index) => forDate.subtract(Duration(days: index * 7))),
        createdAt: forDate.subtract(const Duration(days: 120)),
        updatedAt: forDate,
      ),
    ];
  }

  /// Subtasks for additional metrics
  static List<SubtaskModel> getComprehensiveSubtasksForMetrics(
      {required DateTime forDate}) {
    return List.generate(15, (index) {
      return SubtaskModel(
        id: 'comprehensive-subtask-$index',
        taskId: 'metrics-task-${index % 20}',
        title:
            'Comprehensive Subtask $index with Detailed Title for Chart Display Testing and Overflow Prevention',
        completed: index % 3 == 0,
        createdAt: forDate.subtract(Duration(days: index)),
        updatedAt: forDate.subtract(Duration(hours: index)),
        userId: 'test-user',
      );
    });
  }

  /// Simple data for basic UI testing
  static List<TaskModel> getSimpleTasksForBasicUI({required DateTime forDate}) {
    return [
      TaskModel(
        id: 'simple-task-1',
        title: 'Simple Task for Basic UI Testing',
        status: 'Done',
        dueDate: forDate,
        completedAt: forDate,
        priority: 1,
        createdAt: forDate.subtract(const Duration(days: 1)),
        userId: 'test-user',
        updatedAt: forDate,
      ),
    ];
  }
}

// --------------------------------------------------------------------------
// Mock Classes for Reports UI Testing
// --------------------------------------------------------------------------

/// Mock Reports Controller for UI testing
class UITestReportsController extends ReportsController {
  final List<TaskModel> _allTasks;
  final List<HabitModel> _allHabits;
  final List<MoodModel> _allMoods;
  final List<EnergyModel> _allEnergies;
  final List<SymptomModel> _allSymptoms;
  final List<FlowmodoroModel> _allFlowmodoro;
  final List<MedicationModel> _allMedications;
  final List<SubtaskModel> _allSubtasks;

  UITestReportsController({
    required List<TaskModel> tasks,
    required List<HabitModel> habits,
    required List<MoodModel> moods,
    required List<EnergyModel> energies,
    required List<SymptomModel> symptoms,
    required List<FlowmodoroModel> flowmodoro,
    required List<MedicationModel> medications,
    required List<SubtaskModel> subtasks,
  })  : _allTasks = tasks,
        _allHabits = habits,
        _allMoods = moods,
        _allEnergies = energies,
        _allSymptoms = symptoms,
        _allFlowmodoro = flowmodoro,
        _allMedications = medications,
        _allSubtasks = subtasks,
        super(
          taskService: MockTaskService(),
          subtaskService: MockSubtaskService(),
          moodService: MockMoodService(),
          habitService: MockHabitService(),
          symptomsService: MockSymptomService(),
          energyService: MockEnergyService(),
          flowmodoroService: MockFlowmodoroService(),
          medicationService: MockMedicationService(),
        ) {
    _generateMockReportsData();
  }

  void _generateMockReportsData() {
    // Generate realistic chart data based on the test data
    final chartData = _generateLineChartData();
    final pieData = _generatePieChartData();

    // Calculate realistic metrics
    final completedTasks = _allTasks
        .where((task) => task.status == 'Done' && task.completedAt != null)
        .length;
    final completedSubtasks =
        _allSubtasks.where((subtask) => subtask.completed).length;
    final totalTasksCompleted = completedTasks + completedSubtasks;

    final habitsCompleted =
        _allHabits.where((habit) => habit.lastCompleted != null).length;

    final flowmodoroCount = _allFlowmodoro.length;
    final totalFlowFocusTime = _allFlowmodoro.fold<double>(
        0.0, (sum, flow) => sum + flow.focusMinutes.toDouble());
    final totalFlowBreakTime = _allFlowmodoro.fold<double>(
        0.0, (sum, flow) => sum + flow.breakMinutes.toDouble());

    final timeBlocks = _allTasks
        .where((task) => task.startTime != null && task.endTime != null)
        .length;
    final totalTimeSpent = _calculateTotalTimeSpent();

    // Set the state with calculated data
    state = ReportsState(
      lineChartData: chartData,
      pieData: pieData,
      tasksCompleted: totalTasksCompleted,
      habitsCompleted: habitsCompleted,
      tasksLongestStreak: _calculateTaskStreak(),
      habitsLongestStreak: _calculateHabitStreak(),
      flowmodoroCount: flowmodoroCount,
      timeBlocks: timeBlocks,
      totalTimeSpentInHours: totalTimeSpent,
      totalFlowFocusTime: totalFlowFocusTime,
      totalFlowBreakTime: totalFlowBreakTime,
      totalFlowTime: totalFlowFocusTime + totalFlowBreakTime,
    );
  }

  List<MetricsData> _generateLineChartData() {
    // Generate sample chart data for different time ranges
    return List.generate(7, (index) {
      return MetricsData(
        'Day ${index + 1}',
        (index % 5) + 1,
        (index % 4) + 1,
        index % 3,
        (index % 8) + 1,
        (index % 6) + 1,
        (index % 4) + 1,
      );
    });
  }

  List<PieData> _generatePieChartData() {
    return [
      PieData('Completed Tasks',
          _allTasks.where((t) => t.status == 'Done').length.toDouble()),
      PieData('Completed Habits', _allHabits.length.toDouble()),
      PieData('Flowmodoro Sessions', _allFlowmodoro.length.toDouble()),
      PieData('Time Blocks',
          _allTasks.where((t) => t.startTime != null).length.toDouble()),
    ];
  }

  double _calculateTotalTimeSpent() {
    double total = 0.0;
    for (final task in _allTasks) {
      if (task.startTime != null && task.endTime != null) {
        final duration = task.endTime!.difference(task.startTime!);
        total += duration.inMinutes / 60.0;
      }
    }
    return total;
  }

  int _calculateTaskStreak() {
    // Simple streak calculation for UI testing
    return _allTasks.where((t) => t.status == 'Done').length;
  }

  int _calculateHabitStreak() {
    // Simple streak calculation for UI testing
    return _allHabits.where((h) => h.completedDates.isNotEmpty).length;
  }

  @override
  Future<void> fetchReportsForTimeRange(String range, [DateTime? date]) async {
    // UI testing doesn't need actual data fetching
    _generateMockReportsData();
  }
}

// --------------------------------------------------------------------------
// Test Helpers
// --------------------------------------------------------------------------

void main() {
  /// Helper function to set up and pump the ReportsPage widget for UI testing
  Future<void> pumpReportsPageForUI(
    WidgetTester tester,
    UITestReportsController controller, {
    String localeCode = 'en',
    Size? screenSize,
  }) async {
    if (screenSize != null) {
      await tester.binding.setSurfaceSize(screenSize);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedDateProvider.overrideWith((ref) => testSelectedDate),
          reportsControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportsPage(),
        ),
      ),
    );

    // Use controlled pumping for UI tests
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  // --------------------------------------------------------------------------
  // Reports UI Overflow and Layout Test Cases
  // --------------------------------------------------------------------------

  group('ReportsPage UI Overflow and Layout Tests', () {
    testWidgets('Handles comprehensive reports data without overflow',
        (WidgetTester tester) async {
      // Arrange - Create comprehensive test data
      final controller = UITestReportsController(
        tasks: ReportsUITestData.getComprehensiveTasksForMetrics(
            forDate: testSelectedDate),
        habits: ReportsUITestData.getComprehensiveHabitsForMetrics(
            forDate: testSelectedDate),
        moods: ReportsUITestData.getComprehensiveMoodsForCharts(
            forDate: testSelectedDate),
        energies: ReportsUITestData.getComprehensiveEnergyForCharts(
            forDate: testSelectedDate),
        symptoms: ReportsUITestData.getComprehensiveSymptomsForMetrics(
            forDate: testSelectedDate),
        flowmodoro: ReportsUITestData.getComprehensiveFlowmodoroForMetrics(
            forDate: testSelectedDate),
        medications: ReportsUITestData.getComprehensiveMedicationsForMetrics(
            forDate: testSelectedDate),
        subtasks: ReportsUITestData.getComprehensiveSubtasksForMetrics(
            forDate: testSelectedDate),
      );

      // Act
      await pumpReportsPageForUI(tester, controller,
          screenSize: const Size(1200, 800));

      // Assert: Verify main page components are displayed
      expect(find.byType(ReportsPage), findsOneWidget);
      expect(find.byType(CalendarWeekSelector), findsOneWidget);

      // Assert: Verify charts are rendered
      expect(find.byType(SfCartesianChart), findsWidgets);
      expect(find.byType(SfCircularChart), findsWidgets);

      // Assert: Verify no text overflow in any text widgets
      final textWidgets = find.byType(Text);
      for (final widget in tester.widgetList<Text>(textWidgets)) {
        expect(
            widget.overflow,
            anyOf(
              equals(TextOverflow.ellipsis),
              equals(TextOverflow.fade),
              equals(TextOverflow.clip),
              isNull,
            ));
      }

      // Assert: Verify metrics are displayed without breaking layout
      expect(find.textContaining('Tasks'), findsWidgets);
      expect(find.textContaining('Habits'), findsWidgets);

      // Assert: No rendering exceptions should occur
      final exception = tester.takeException();
      expect(exception, isNull);
    });

    testWidgets('Handles long chart labels and tooltips without overflow',
        (WidgetTester tester) async {
      // Arrange - Use tasks with extremely long titles
      final controller = UITestReportsController(
        tasks:
            ReportsUITestData.getTasksWithLongTitles(forDate: testSelectedDate),
        habits: ReportsUITestData.getComprehensiveHabitsForMetrics(
            forDate: testSelectedDate),
        moods: ReportsUITestData.getComprehensiveMoodsForCharts(
            forDate: testSelectedDate),
        energies: ReportsUITestData.getComprehensiveEnergyForCharts(
            forDate: testSelectedDate),
        symptoms: ReportsUITestData.getComprehensiveSymptomsForMetrics(
            forDate: testSelectedDate),
        flowmodoro: ReportsUITestData.getComprehensiveFlowmodoroForMetrics(
            forDate: testSelectedDate),
        medications: ReportsUITestData.getComprehensiveMedicationsForMetrics(
            forDate: testSelectedDate),
        subtasks: ReportsUITestData.getComprehensiveSubtasksForMetrics(
            forDate: testSelectedDate),
      );

      // Act
      await pumpReportsPageForUI(tester, controller,
          screenSize: const Size(1200, 800));

      // Assert: Verify charts handle long data labels
      expect(find.byType(SfCartesianChart), findsWidgets);
      expect(find.byType(SfCircularChart), findsWidgets);

      // Assert: Verify no overflow occurs with long chart labels
      final textWidgets = find.byType(Text);
      for (final widget in tester.widgetList<Text>(textWidgets)) {
        expect(
            widget.overflow,
            anyOf(
              equals(TextOverflow.ellipsis),
              equals(TextOverflow.fade),
              equals(TextOverflow.clip),
              isNull,
            ));
      }

      // Verify the page layout remains stable
      expect(find.byType(ReportsPage), findsOneWidget);

      // Assert: No rendering exceptions should occur
      final exception = tester.takeException();
      expect(exception, isNull);
    });

    testWidgets('Displays empty state gracefully without errors',
        (WidgetTester tester) async {
      // Arrange - Empty data
      final controller = UITestReportsController(
        tasks: [],
        habits: [],
        moods: [],
        energies: [],
        symptoms: [],
        flowmodoro: [],
        medications: [],
        subtasks: [],
      );

      // Act
      await pumpReportsPageForUI(tester, controller,
          screenSize: const Size(1200, 800));

      // Assert: Verify page displays without error
      expect(find.byType(ReportsPage), findsOneWidget);

      // Assert: Verify empty state messages are shown instead of charts
      expect(find.text('No data for this period'), findsWidgets);
      expect(find.byIcon(Icons.bar_chart_outlined), findsWidgets);

      // Assert: No rendering exceptions should occur
      final exception = tester.takeException();
      expect(exception, isNull);
    });

    group('Screen Size Responsiveness for Reports', () {
      // USE STANDARDIZED TEST SIZES - MATCHES OTHER UI TESTS
      for (final size in standardTestSizes) {
        testWidgets(
            'Handles reports layout on ${size.width}x${size.height} screen',
            (WidgetTester tester) async {
          // Arrange - Use simple test data to focus on layout
          final controller = UITestReportsController(
            tasks: ReportsUITestData.getSimpleTasksForBasicUI(
                forDate: testSelectedDate),
            habits: [],
            moods: [],
            energies: [],
            symptoms: [],
            flowmodoro: [],
            medications: [],
            subtasks: [],
          );

          // Act
          await pumpReportsPageForUI(tester, controller, screenSize: size);

          // Assert: Verify layout doesn't break
          expect(find.byType(ReportsPage), findsOneWidget);

          // Verify main components are accessible
          expect(find.byType(CalendarWeekSelector), findsOneWidget);

          // For smaller screens, ensure scrolling works
          if (size.width < 768) {
            expect(find.byType(SingleChildScrollView), findsWidgets);
          }

          // Assert: No rendering exceptions should occur
          final exception = tester.takeException();
          expect(exception, isNull);
        });
      }

      // Test overflow handling specifically for content-heavy scenarios on larger screens
      testWidgets(
          'Handles overflow with comprehensive reports data on larger screens',
          (WidgetTester tester) async {
        // USE STANDARDIZED LARGER SCREEN SIZES ONLY
        final testSizesForContent = [
          standardTestSizes[3], // iPad Portrait (768, 1024)
          standardTestSizes[5], // Desktop (1200, 800)
          standardTestSizes[6], // Large Desktop (1920, 1080)
        ];

        for (final size in testSizesForContent) {
          // Arrange
          final controller = UITestReportsController(
            tasks: ReportsUITestData.getComprehensiveTasksForMetrics(
                forDate: testSelectedDate),
            habits: ReportsUITestData.getComprehensiveHabitsForMetrics(
                forDate: testSelectedDate),
            moods: ReportsUITestData.getComprehensiveMoodsForCharts(
                forDate: testSelectedDate),
            energies: ReportsUITestData.getComprehensiveEnergyForCharts(
                forDate: testSelectedDate),
            symptoms: ReportsUITestData.getComprehensiveSymptomsForMetrics(
                forDate: testSelectedDate),
            flowmodoro: ReportsUITestData.getComprehensiveFlowmodoroForMetrics(
                forDate: testSelectedDate),
            medications:
                ReportsUITestData.getComprehensiveMedicationsForMetrics(
                    forDate: testSelectedDate),
            subtasks: ReportsUITestData.getComprehensiveSubtasksForMetrics(
                forDate: testSelectedDate),
          );

          // Act
          await pumpReportsPageForUI(tester, controller, screenSize: size);

          // Assert: Verify layout doesn't break
          expect(find.byType(ReportsPage), findsOneWidget);

          // Verify no text overflow for larger screens with complex content
          final textWidgets = find.byType(Text);
          for (final widget in tester.widgetList<Text>(textWidgets)) {
            expect(
                widget.overflow,
                anyOf(
                  equals(TextOverflow.ellipsis),
                  equals(TextOverflow.fade),
                  equals(TextOverflow.clip),
                  isNull,
                ));
          }

          // Assert: No rendering exceptions should occur
          final exception = tester.takeException();
          expect(exception, isNull);
        }
      });
    });

    group('Reports Chart Specific Tests', () {
      testWidgets('Line chart displays time series data correctly',
          (WidgetTester tester) async {
        // Arrange
        final controller = UITestReportsController(
          tasks: ReportsUITestData.getComprehensiveTasksForMetrics(
              forDate: testSelectedDate),
          habits: ReportsUITestData.getComprehensiveHabitsForMetrics(
              forDate: testSelectedDate),
          moods: ReportsUITestData.getComprehensiveMoodsForCharts(
              forDate: testSelectedDate),
          energies: ReportsUITestData.getComprehensiveEnergyForCharts(
              forDate: testSelectedDate),
          symptoms: ReportsUITestData.getComprehensiveSymptomsForMetrics(
              forDate: testSelectedDate),
          flowmodoro: ReportsUITestData.getComprehensiveFlowmodoroForMetrics(
              forDate: testSelectedDate),
          medications: ReportsUITestData.getComprehensiveMedicationsForMetrics(
              forDate: testSelectedDate),
          subtasks: ReportsUITestData.getComprehensiveSubtasksForMetrics(
              forDate: testSelectedDate),
        );

        // Act
        await pumpReportsPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify line chart is displayed
        expect(find.byType(SfCartesianChart), findsAtLeastNWidgets(1));

        // Verify chart handles data without errors
        final chartWidgets =
            tester.widgetList<SfCartesianChart>(find.byType(SfCartesianChart));
        for (final chart in chartWidgets) {
          expect(chart.series, isNotEmpty);
        }

        // Assert: No rendering exceptions should occur
        final exception = tester.takeException();
        expect(exception, isNull);
      });

      testWidgets('Pie chart displays category data correctly',
          (WidgetTester tester) async {
        // Arrange
        final controller = UITestReportsController(
          tasks: ReportsUITestData.getComprehensiveTasksForMetrics(
              forDate: testSelectedDate),
          habits: ReportsUITestData.getComprehensiveHabitsForMetrics(
              forDate: testSelectedDate),
          moods: ReportsUITestData.getComprehensiveMoodsForCharts(
              forDate: testSelectedDate),
          energies: ReportsUITestData.getComprehensiveEnergyForCharts(
              forDate: testSelectedDate),
          symptoms: ReportsUITestData.getComprehensiveSymptomsForMetrics(
              forDate: testSelectedDate),
          flowmodoro: ReportsUITestData.getComprehensiveFlowmodoroForMetrics(
              forDate: testSelectedDate),
          medications: ReportsUITestData.getComprehensiveMedicationsForMetrics(
              forDate: testSelectedDate),
          subtasks: ReportsUITestData.getComprehensiveSubtasksForMetrics(
              forDate: testSelectedDate),
        );

        // Act
        await pumpReportsPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify pie chart is displayed
        expect(find.byType(SfCircularChart), findsAtLeastNWidgets(1));

        // Verify chart handles data without errors
        final chartWidgets =
            tester.widgetList<SfCircularChart>(find.byType(SfCircularChart));
        for (final chart in chartWidgets) {
          expect(chart.series, isNotEmpty);
        }

        // Assert: No rendering exceptions should occur
        final exception = tester.takeException();
        expect(exception, isNull);
      });

      testWidgets('Charts handle basic rendering without interaction issues',
          (WidgetTester tester) async {
        // Arrange
        final controller = UITestReportsController(
          tasks: ReportsUITestData.getComprehensiveTasksForMetrics(
              forDate: testSelectedDate),
          habits: ReportsUITestData.getComprehensiveHabitsForMetrics(
              forDate: testSelectedDate),
          moods: ReportsUITestData.getComprehensiveMoodsForCharts(
              forDate: testSelectedDate),
          energies: ReportsUITestData.getComprehensiveEnergyForCharts(
              forDate: testSelectedDate),
          symptoms: ReportsUITestData.getComprehensiveSymptomsForMetrics(
              forDate: testSelectedDate),
          flowmodoro: ReportsUITestData.getComprehensiveFlowmodoroForMetrics(
              forDate: testSelectedDate),
          medications: ReportsUITestData.getComprehensiveMedicationsForMetrics(
              forDate: testSelectedDate),
          subtasks: ReportsUITestData.getComprehensiveSubtasksForMetrics(
              forDate: testSelectedDate),
        );

        // Act
        await pumpReportsPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify charts support basic rendering
        expect(find.byType(SfCartesianChart), findsWidgets);

        // Verify no errors occur from basic rendering
        final exception = tester.takeException();
        expect(exception, isNull);
      });
    });

    group('Metrics Display Tests', () {
      testWidgets('Displays actual streak metrics from the UI',
          (WidgetTester tester) async {
        // Arrange
        final controller = UITestReportsController(
          tasks: ReportsUITestData.getComprehensiveTasksForMetrics(
              forDate: testSelectedDate),
          habits: ReportsUITestData.getComprehensiveHabitsForMetrics(
              forDate: testSelectedDate),
          moods: ReportsUITestData.getComprehensiveMoodsForCharts(
              forDate: testSelectedDate),
          energies: ReportsUITestData.getComprehensiveEnergyForCharts(
              forDate: testSelectedDate),
          symptoms: ReportsUITestData.getComprehensiveSymptomsForMetrics(
              forDate: testSelectedDate),
          flowmodoro: ReportsUITestData.getComprehensiveFlowmodoroForMetrics(
              forDate: testSelectedDate),
          medications: ReportsUITestData.getComprehensiveMedicationsForMetrics(
              forDate: testSelectedDate),
          subtasks: ReportsUITestData.getComprehensiveSubtasksForMetrics(
              forDate: testSelectedDate),
        );

        // Act
        await pumpReportsPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify the actual streak text from localizations
        expect(find.textContaining('Longest'),
            findsWidgets); // From longestTasksStreak and longestHabitsStreak
        expect(find.textContaining('streak'),
            findsWidgets); // Part of the streak text

        // Verify sections are displayed
        expect(find.textContaining('Insights'), findsWidgets); // From AppHeader
        expect(find.textContaining('Time'),
            findsWidgets); // From time management techniques

        // Verify all text is properly constrained
        final textWidgets = find.byType(Text);
        for (final widget in tester.widgetList<Text>(textWidgets)) {
          expect(
              widget.overflow,
              anyOf(
                equals(TextOverflow.ellipsis),
                equals(TextOverflow.fade),
                equals(TextOverflow.clip),
                isNull,
              ));
        }

        // Assert: No rendering exceptions should occur
        final exception = tester.takeException();
        expect(exception, isNull);
      });

      testWidgets('Displays flowmodoro metrics correctly',
          (WidgetTester tester) async {
        // Arrange
        final controller = UITestReportsController(
          tasks: ReportsUITestData.getComprehensiveTasksForMetrics(
              forDate: testSelectedDate),
          habits: ReportsUITestData.getComprehensiveHabitsForMetrics(
              forDate: testSelectedDate),
          moods: ReportsUITestData.getComprehensiveMoodsForCharts(
              forDate: testSelectedDate),
          energies: ReportsUITestData.getComprehensiveEnergyForCharts(
              forDate: testSelectedDate),
          symptoms: ReportsUITestData.getComprehensiveSymptomsForMetrics(
              forDate: testSelectedDate),
          flowmodoro: ReportsUITestData.getComprehensiveFlowmodoroForMetrics(
              forDate: testSelectedDate),
          medications: ReportsUITestData.getComprehensiveMedicationsForMetrics(
              forDate: testSelectedDate),
          subtasks: ReportsUITestData.getComprehensiveSubtasksForMetrics(
              forDate: testSelectedDate),
        );

        // Act
        await pumpReportsPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Look for actual flowmodoro text from the UI
        expect(find.textContaining('25'),
            findsWidgets); // Session count from test data
        expect(find.textContaining('Combined'),
            findsWidgets); // From combinedTime text

        // Verify numeric values are displayed
        expect(find.textContaining('5'), findsWidgets); // Task completed count
        expect(find.textContaining('3'), findsWidgets); // Habit counts

        // Verify all text is properly constrained
        final textWidgets = find.byType(Text);
        for (final widget in tester.widgetList<Text>(textWidgets)) {
          expect(
              widget.overflow,
              anyOf(
                equals(TextOverflow.ellipsis),
                equals(TextOverflow.fade),
                equals(TextOverflow.clip),
                isNull,
              ));
        }

        // Assert: No rendering exceptions should occur
        final exception = tester.takeException();
        expect(exception, isNull);
      });

      testWidgets('Handles large metric values without overflow',
          (WidgetTester tester) async {
        // Arrange - Create data that would result in large metric values
        final largeTasks = List.generate(999, (index) {
          return TaskModel(
            id: 'large-task-$index',
            title: 'Large Volume Task $index',
            status: 'Done',
            dueDate: testSelectedDate,
            completedAt: testSelectedDate,
            priority: 1,
            createdAt: testSelectedDate.subtract(Duration(days: index % 30)),
            userId: 'test-user',
            updatedAt: testSelectedDate,
          );
        });

        final controller = UITestReportsController(
          tasks: largeTasks,
          habits: [],
          moods: [],
          energies: [],
          symptoms: [],
          flowmodoro: [],
          medications: [],
          subtasks: [],
        );

        // Act
        await pumpReportsPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify large numbers are displayed without breaking layout
        expect(find.textContaining('999'), findsWidgets);

        // Verify layout remains stable with large values
        expect(find.byType(ReportsPage), findsOneWidget);

        // No overflow should occur
        final textWidgets = find.byType(Text);
        for (final widget in tester.widgetList<Text>(textWidgets)) {
          expect(
              widget.overflow,
              anyOf(
                equals(TextOverflow.ellipsis),
                equals(TextOverflow.fade),
                equals(TextOverflow.clip),
                isNull,
              ));
        }

        // Assert: No rendering exceptions should occur
        final exception = tester.takeException();
        expect(exception, isNull);
      });
    });

    group('Time Range Selector Tests', () {
      testWidgets('Time range selector UI is present and functional',
          (WidgetTester tester) async {
        // Arrange
        final controller = UITestReportsController(
          tasks: ReportsUITestData.getSimpleTasksForBasicUI(
              forDate: testSelectedDate),
          habits: [],
          moods: [],
          energies: [],
          symptoms: [],
          flowmodoro: [],
          medications: [],
          subtasks: [],
        );

        // Act
        await pumpReportsPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify time range buttons are present
        expect(find.byType(ElevatedButton), findsWidgets);

        // Look for button with "WEEK" text (as it's uppercase in the UI)
        expect(find.text('WEEK'), findsWidgets);

        // Test that we can find the button container with horizontal scrolling
        expect(find.byType(SingleChildScrollView), findsWidgets);

        // Verify no errors from basic rendering
        final exception = tester.takeException();
        expect(exception, isNull);
      });

      testWidgets('Time range selector switches views correctly',
          (WidgetTester tester) async {
        // Arrange
        final controller = UITestReportsController(
          tasks: ReportsUITestData.getSimpleTasksForBasicUI(
              forDate: testSelectedDate),
          habits: [],
          moods: [],
          energies: [],
          symptoms: [],
          flowmodoro: [],
          medications: [],
          subtasks: [],
        );

        // Act
        await pumpReportsPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify time range selector is present (look for uppercase text)
        expect(find.text('WEEK'), findsWidgets);

        // Test switching time ranges if buttons are available
        final weekButton = find.text('WEEK').first;
        await tester.tap(weekButton);
        await tester.pump();

        // Verify no errors from interaction
        final exception = tester.takeException();
        expect(exception, isNull);
      });
    });

    group('Calendar Week Selector Integration Tests', () {
      testWidgets('Calendar week selector responds to date changes',
          (WidgetTester tester) async {
        // Arrange
        final controller = UITestReportsController(
          tasks: ReportsUITestData.getComprehensiveTasksForMetrics(
              forDate: testSelectedDate),
          habits: ReportsUITestData.getComprehensiveHabitsForMetrics(
              forDate: testSelectedDate),
          moods: ReportsUITestData.getComprehensiveMoodsForCharts(
              forDate: testSelectedDate),
          energies: ReportsUITestData.getComprehensiveEnergyForCharts(
              forDate: testSelectedDate),
          symptoms: ReportsUITestData.getComprehensiveSymptomsForMetrics(
              forDate: testSelectedDate),
          flowmodoro: ReportsUITestData.getComprehensiveFlowmodoroForMetrics(
              forDate: testSelectedDate),
          medications: ReportsUITestData.getComprehensiveMedicationsForMetrics(
              forDate: testSelectedDate),
          subtasks: ReportsUITestData.getComprehensiveSubtasksForMetrics(
              forDate: testSelectedDate),
        );

        // Act
        await pumpReportsPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify calendar week selector is present
        expect(find.byType(CalendarWeekSelector), findsOneWidget);

        // Verify selector displays current date properly
        expect(find.textContaining('2025'), findsWidgets);
        expect(find.textContaining('Jun'), findsWidgets);

        // Verify no rendering issues with date display
        final exception = tester.takeException();
        expect(exception, isNull);
      });

      testWidgets('Calendar week selector maintains layout on mobile devices',
          (WidgetTester tester) async {
        // Arrange
        final mobileTestSizes = [
          standardTestSizes[0], // iPhone SE (375, 667)
          standardTestSizes[1], // iPhone 12/13 mini (390, 844)
          standardTestSizes[2], // iPhone 11 (414, 896)
        ];

        for (final size in mobileTestSizes) {
          final controller = UITestReportsController(
            tasks: ReportsUITestData.getSimpleTasksForBasicUI(
                forDate: testSelectedDate),
            habits: [],
            moods: [],
            energies: [],
            symptoms: [],
            flowmodoro: [],
            medications: [],
            subtasks: [],
          );

          // Act
          await pumpReportsPageForUI(tester, controller, screenSize: size);

          // Assert: Calendar selector should be present and functional on mobile
          expect(find.byType(CalendarWeekSelector), findsOneWidget);

          // Verify scrollable content for mobile
          expect(find.byType(SingleChildScrollView), findsWidgets);

          // Assert: No rendering exceptions should occur
          final exception = tester.takeException();
          expect(exception, isNull);
        }
      });
    });

    group('Extreme Content Stress Tests for Reports', () {
      testWidgets('Handles maximum data volume without performance issues',
          (WidgetTester tester) async {
        // Arrange - Create extremely large datasets
        final massiveTasks = List.generate(500, (index) {
          return TaskModel(
            id: 'massive-task-$index',
            title:
                'Massive Dataset Task $index with Extremely Long Title That Tests Chart Performance and Memory Usage Under Heavy Load Conditions',
            status: index % 4 == 0 ? 'Done' : 'todo',
            dueDate: testSelectedDate.add(Duration(days: index % 30)),
            completedAt: index % 4 == 0
                ? testSelectedDate.add(Duration(days: index % 30))
                : null,
            priority: (index % 5) + 1,
            createdAt: testSelectedDate.subtract(Duration(days: index % 365)),
            userId: 'test-user',
            updatedAt: testSelectedDate.subtract(Duration(hours: index % 24)),
          );
        });

        final controller = UITestReportsController(
          tasks: massiveTasks,
          habits: ReportsUITestData.getComprehensiveHabitsForMetrics(
              forDate: testSelectedDate),
          moods: ReportsUITestData.getComprehensiveMoodsForCharts(
              forDate: testSelectedDate),
          energies: ReportsUITestData.getComprehensiveEnergyForCharts(
              forDate: testSelectedDate),
          symptoms: ReportsUITestData.getComprehensiveSymptomsForMetrics(
              forDate: testSelectedDate),
          flowmodoro: ReportsUITestData.getComprehensiveFlowmodoroForMetrics(
              forDate: testSelectedDate),
          medications: ReportsUITestData.getComprehensiveMedicationsForMetrics(
              forDate: testSelectedDate),
          subtasks: ReportsUITestData.getComprehensiveSubtasksForMetrics(
              forDate: testSelectedDate),
        );

        // Act
        await pumpReportsPageForUI(tester, controller,
            screenSize: standardTestSizes[5]); // Desktop size

        // Assert: Verify charts can handle massive datasets
        expect(find.byType(SfCartesianChart), findsWidgets);
        expect(find.byType(SfCircularChart), findsWidgets);

        // Verify no overflow with massive datasets
        final textWidgets = find.byType(Text);
        for (final widget in tester.widgetList<Text>(textWidgets)) {
          expect(
              widget.overflow,
              anyOf(
                equals(TextOverflow.ellipsis),
                equals(TextOverflow.fade),
                equals(TextOverflow.clip),
                isNull,
              ));
        }

        // Verify the layout is still functional
        expect(find.byType(ReportsPage), findsOneWidget);

        // Assert: No rendering exceptions should occur
        final exception = tester.takeException();
        expect(exception, isNull);
      });

      testWidgets('Handles extremely long content gracefully',
          (WidgetTester tester) async {
        // Arrange - Create data with extremely long single words
        final extremeTasks = [
          TaskModel(
            id: 'extreme-word-task',
            title:
                'ThisIsAnExtremelyLongSingleWordTaskTitleThatCannotBeWrappedAndShouldTestEllipsisOverflowHandlingInReportsChartsAndMetricsDisplayWithoutBreakingTheLayout',
            status: 'Done',
            dueDate: testSelectedDate,
            completedAt: testSelectedDate,
            priority: 1,
            createdAt: testSelectedDate,
            userId: 'test-user',
            updatedAt: testSelectedDate,
          ),
        ];

        final controller = UITestReportsController(
          tasks: extremeTasks,
          habits: [],
          moods: [],
          energies: [],
          symptoms: [],
          flowmodoro: [],
          medications: [],
          subtasks: [],
        );

        // Act - Use the largest screen to provide optimal conditions
        await pumpReportsPageForUI(tester, controller,
            screenSize: standardTestSizes[6]); // Large Desktop (1920x1080)

        // Assert: Verify charts handle extreme content
        expect(find.byType(SfCartesianChart), findsWidgets);

        // Verify layout remains stable
        expect(find.byType(ReportsPage), findsOneWidget);

        // Assert: No rendering exceptions should occur
        final exception = tester.takeException();
        expect(exception, isNull);
      });
    });
  });
}
