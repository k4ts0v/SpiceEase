/// This file tests the localization functionality of the ReportsPage widget.
///
/// # Testing Strategy
///
/// This test suite validates three main scenarios for the ReportsPage:
///
/// 1.  **Static English Localization**:
///     - Verifies that all relevant UI elements (titles, buttons, chart labels, insight texts)
///       display the correct English text when the application's locale is set to 'en'.
///     - Ensures that `AppLocalizations.en` strings are correctly loaded and rendered.
///
/// 2.  **Static Spanish Localization**:
///     - Verifies that all relevant UI elements display the correct Spanish text when the
///       application's locale is set to 'es'.
///     - Ensures that `AppLocalizations.es` strings are correctly loaded and rendered.
///
/// 3.  **Dynamic Locale Change**:
///     - Tests the behavior of the ReportsPage when the locale is changed dynamically
///       (e.g., from English to Spanish) during runtime.
///     - Verifies that the widget tree rebuilds and all localizable strings are updated
///       to reflect the new locale.
///
/// # Features Tested
///
/// The localization tests cover a comprehensive set of UI elements within the ReportsPage:
/// - **AppBar Title**: e.g., "Insights".
/// - **Time Range Buttons**: e.g., "DAY", "WEEK", "MONTH", "YEAR".
/// - **Section Titles**: e.g., "Metrics Over Time", "Streaks", "Time Management Techniques",
///   "Flowmodoro Insights", "Time Block Insights".
/// - **Chart Series Names/Legends**: For various charts, including:
///   - Metrics Over Time chart legends: "Mood", "Energy", "Symptoms", "Tasks", "Habits", "Medication".
///   - Time Management Techniques pie chart labels: "Flowmodoro", "Time Blocks".
///   - Flowmodoro Insights doughnut chart labels: "Focus Time", "Break Time".
///   - Time Block Insights column chart series names: "Time Blocks", "Hours".
/// - **Insight Texts**: Dynamically generated texts incorporating localized strings, such as:
///   - Longest streak texts: e.g., "Longest Tasks Streak: X days".
///   - Flowmodoro session count: e.g., "X Sessions".
///   - Combined Flowmodoro time: e.g., "Combined Time: X.X hours".
///
/// # Technical Approach
///
/// - **ProviderScope & Overrides**: Each test sets up a `ProviderScope` to manage Riverpod state.
///   Key providers are overridden:
///   - `reportsControllerProvider`: Overridden with a `TestReportsController` instance. This
///     controller is initialized with `initialReportsState` to provide consistent data for tests
///     and has a mocked `fetchReportsForTimeRange` to prevent actual data fetching.
///   - `selectedDateProvider`: Overridden to provide a fixed date, ensuring consistency across tests.
/// - **MaterialApp Wrapper**: The `ReportsPage` is wrapped in a `MaterialApp` to provide the necessary
///   context for localization (locale, localizationsDelegates, supportedLocales).
/// - **`pumpReportsPage` Helper**: A utility function to encapsulate the widget pumping logic,
///   including setting the locale and providing the mocked controller.
/// - **`tester.ensureVisible` & `pumpAndSettle`**: Used to scroll to off-screen widgets and wait for
///   animations or UI updates to complete before making assertions. This is crucial for testing
///   content within `SingleChildScrollView`.
/// - **`AppLocalizations`**: Used to access localized strings programmatically for assertions,
///   ensuring that the tests are checking against the correct translations.
/// - **Mocking**: Services (`TaskService`, `MoodService`, etc.) are mocked using `mockito` to isolate
///   the `ReportsController` and `ReportsPage` from external dependencies.
///
/// # Test Structure
///
/// Each `testWidgets` follows the Arrange-Act-Assert pattern:
/// - **Arrange**:
///   - The `ReportsPage` is pumped with the desired locale ('en' or 'es') using `pumpReportsPage`.
///   - An instance of `AppLocalizations` for the current locale is obtained.
///   - Finders for various UI elements are prepared.
/// - **Act**:
///   - `tester.ensureVisible()` is called to scroll to specific sections or widgets if they
///     might be off-screen.
///   - `tester.pumpAndSettle()` is called after scrolling or actions that might trigger UI updates
///     to allow the widget tree to stabilize.
/// - **Assert**:
///   - `expect()` is used with various finders (`find.text`, `find.widgetWithText`) to verify
///     that the UI elements display the correct localized text.
///   - `skipOffstage: false` is used for finders where the widget might be part of a complex
///     layout or chart that could be partially offstage but still considered findable.
///   - `reason` strings are provided in assertions for clearer test failure messages.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:spiceease/app/app_initializer.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';
// import 'package:mockito/mockito.dart'; // Mockito is used via generated mocks
import 'package:spiceease/features/reports/data_models/metrics_data.dart';
import 'package:spiceease/features/reports/data_models/pie_data.dart';
import 'package:spiceease/features/reports/reports_page.dart';
import 'package:spiceease/features/reports/reports_controller.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// Import services (interfaces)
import 'package:spiceease/data/services/task_service.dart';
import 'package:spiceease/data/services/subtask_service.dart';
import 'package:spiceease/data/services/mood_service.dart';
import 'package:spiceease/data/services/habit_service.dart';
import 'package:spiceease/data/services/symptom_service.dart';
import 'package:spiceease/data/services/energy_service.dart';
import 'package:spiceease/data/services/flowmodoro_service.dart';
import 'package:spiceease/data/services/medication_service.dart';

// Import generated mocks
import 'reports_localization_test.mocks.dart';

/// Initial state for the reports, providing minimal but sufficient data
/// to ensure all charts and relevant UI sections can render for localization testing.
const initialReportsState = ReportsState(
  lineChartData: [
    // Provides data for the "Metrics Over Time" chart with all 6 series.
    MetricsData("Mon", 1, 2, 1, 2, 1, 1),
    MetricsData("Tue", 2, 1, 0, 1, 2, 0),
  ],
  // Provides data for the "Time Management Techniques" pie chart.
  pieData: [PieData("Flowmodoro", 1), PieData("TimeBlocks", 1)],
  tasksCompleted: 5,
  habitsCompleted: 3,
  tasksLongestStreak: 2,
  habitsLongestStreak: 1,
  flowmodoroCount: 2, // For "Flowmodoro Insights" sessions text.
  timeBlocks: 1,      // For "Time Block Insights" chart data.
  totalTimeSpentInHours: 1.5,
  totalFlowFocusTime: 1.0, // For "Flowmodoro Insights" doughnut chart.
  totalFlowBreakTime: 0.5, // For "Flowmodoro Insights" doughnut chart.
  totalFlowTime: 1.5,      // For "Flowmodoro Insights" combined time text.
);

/// A test-specific version of [ReportsController] that extends the original.
/// It allows initializing with a predefined [ReportsState] and overrides
/// `fetchReportsForTimeRange` to prevent actual data fetching during tests,
/// relying solely on the `initialState`.
/// The `formatTimeDisplay` method is also overridden to match the expected behavior
/// if it were complex, but here it mirrors a simplified version of typical app logic.
class TestReportsController extends ReportsController {
  TestReportsController(
    ReportsState initialState, {
    required super.taskService,
    required super.subtaskService,
    required super.moodService,
    required super.habitService,
    required super.symptomsService,
    required super.energyService,
    required super.flowmodoroService,
    required super.medicationService,
  }) {
    // Initialize the state directly.
    state = initialState;
  }

  @override
  Future<void> fetchReportsForTimeRange(String timeRange,
      [DateTime? selectedDate]) async {
    // Mock implementation: Do nothing. The UI will use the initialState.
    // This prevents network calls or actual data processing.
  }

  @override
  String formatTimeDisplay(double hours, AppLocalizations localizations) {
    // Provides a consistent way to format time for assertions,
    // matching how it might be displayed in the UI.
    if (hours <= 0) {
      return "0 ${localizations.minutes}";
    }
    if (hours < 1.0) {
      final minutes = (hours * 60).round();
      return "$minutes ${minutes == 1 ? localizations.minute : localizations.minutes}";
    }
    return "${hours.toStringAsFixed(1)} ${localizations.hours}";
  }
}

/// Observador de providers para registrar errores
class _ProviderLogger extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    print('Provider ${provider.name ?? provider.runtimeType} error: $error');
    print('Stack trace: $stackTrace');
  }
}

/// Mock AuthService class for testing
class MockAuthService implements AuthService {
  @override
  Future<String?> getCurrentUserId() async => 'test-user-id';

  @override
  Future<bool> isAuthenticated() async => true;

  // Implement other methods with minimal test implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Generates mock implementations for all services used by [ReportsController].
/// These mocks are used to satisfy the controller's dependencies without needing
/// real implementations or external connections (like Firebase).
@GenerateNiceMocks([
  MockSpec<TaskService>(),
  MockSpec<SubtaskService>(),
  MockSpec<MoodService>(),
  MockSpec<HabitService>(),
  MockSpec<SymptomService>(),
  MockSpec<EnergyService>(),
  MockSpec<FlowmodoroService>(),
  MockSpec<MedicationService>(),
])
void main() {
  // Declare mock instances for all services.
  late MockTaskService mockTaskService;
  late MockSubtaskService mockSubtaskService;
  late MockMoodService mockMoodService;
  late MockHabitService mockHabitService;
  late MockSymptomService mockSymptomService;
  late MockEnergyService mockEnergyService;
  late MockFlowmodoroService mockFlowmodoroService;
  late MockMedicationService mockMedicationService;

  /// `setUp` is called before each test or group of tests.
  /// Here, it initializes fresh mock instances for all services.
  setUp(() {
    mockTaskService = MockTaskService();
    mockSubtaskService = MockSubtaskService();
    mockMoodService = MockMoodService();
    mockHabitService = MockHabitService();
    mockSymptomService = MockSymptomService();
    mockEnergyService = MockEnergyService();
    mockFlowmodoroService = MockFlowmodoroService();
    mockMedicationService = MockMedicationService();
  });

  /// Helper function to pump the [ReportsPage] widget with a specific [localeCode].
  /// It sets up the necessary [ProviderScope] with overridden providers for
  /// `reportsControllerProvider` (using `TestReportsController` and `initialReportsState`)
  /// and `selectedDateProvider`.
  /// The page is wrapped in a [SizedBox] to constrain its size and a [MaterialApp]
  /// to provide localization context.
  Future<void> pumpReportsPage(WidgetTester tester, String localeCode) async {
    // Create a completed future for app initialization
    final appInitFuture = Future.value();

    // Envolver en un ProviderContainer con registro de errores personalizado
    final container = ProviderContainer(
      overrides: [
        // Override auth-related providers
        authServiceProvider.overrideWithValue(MockAuthService()),
        isAuthenticatedProvider.overrideWithValue(true),

        // Override app initializer with a completed future
        appInitializerProvider.overrideWith((_) => appInitFuture),

        // Existing overrides
        selectedDateProvider.overrideWith((ref) => DateTime(2025, 6, 1)),
        reportsControllerProvider.overrideWith(
          (_) => TestReportsController(
            initialReportsState,
            taskService: mockTaskService,
            subtaskService: mockSubtaskService,
            moodService: mockMoodService,
            habitService: mockHabitService,
            symptomsService: mockSymptomService,
            energyService: mockEnergyService,
            flowmodoroService: mockFlowmodoroService,
            medicationService: mockMedicationService,
          ),
        ),
      ],
      observers: [
        _ProviderLogger(), // Añadir un observador para registrar errores
      ],
    );

    await tester.pumpWidget(
      SizedBox(
        width: 800,
        height: 2000,
        child: UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: Locale(localeCode),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Groups all localization tests for the [ReportsPage].
  group('ReportsPage Localization Tests', () {
    /// Tests that all UI elements on the ReportsPage display correct English text
    /// when the locale is set to 'en'.
    testWidgets('Displays English titles, buttons, and chart labels',
        (WidgetTester tester) async {
      // Arrange: Pump the ReportsPage with English locale.
      await pumpReportsPage(tester, 'en');
      // Get the AppLocalizations instance for English.
      final l10n =
          AppLocalizations.of(tester.element(find.byType(ReportsPage)))!;

      // Assert: AppBar title.
      expect(find.text(l10n.insights), findsOneWidget,
          reason: "EN AppBar title");

      // Assert: Time Range Buttons.
      expect(find.widgetWithText(ElevatedButton, l10n.day.toUpperCase()),
          findsOneWidget,
          reason: "EN Day button");
      expect(find.widgetWithText(ElevatedButton, l10n.week.toUpperCase()),
          findsOneWidget,
          reason: "EN Week button");
      expect(find.widgetWithText(ElevatedButton, l10n.month.toUpperCase()),
          findsOneWidget,
          reason: "EN Month button");
      expect(find.widgetWithText(ElevatedButton, l10n.year.toUpperCase()),
          findsOneWidget,
          reason: "EN Year button");

      // Assert: Metrics Over Time Section.
      // Scroll to the section header and wait for UI to settle.
      final metricsOverTimeFinderEn = find.text(l10n.metricsOverTime);
      await tester.ensureVisible(metricsOverTimeFinderEn);
      await tester.pumpAndSettle();
      expect(metricsOverTimeFinderEn, findsOneWidget,
          reason: "EN Metrics Over Time title");
      // Check for chart legends (these might appear multiple times if used as axis labels too).
      expect(find.text(l10n.mood, skipOffstage: false), findsWidgets,
          reason: "EN Mood legend");
      expect(find.text(l10n.energy, skipOffstage: false), findsWidgets,
          reason: "EN Energy legend");
      expect(find.text(l10n.symptoms, skipOffstage: false), findsWidgets,
          reason: "EN Symptoms legend");
      expect(find.text(l10n.tasks, skipOffstage: false), findsWidgets,
          reason: "EN Tasks legend");
      expect(find.text(l10n.habits, skipOffstage: false), findsWidgets,
          reason: "EN Habits legend");
      expect(find.text(l10n.medication, skipOffstage: false), findsWidgets,
          reason: "EN Medication legend");

      // Assert: Streaks Section.
      final streaksFinderEn = find.text(l10n.streaks);
      await tester.ensureVisible(streaksFinderEn);
      await tester.pumpAndSettle();
      expect(streaksFinderEn, findsOneWidget, reason: "EN Streaks title");
      expect(
          find.text(
              l10n.longestTasksStreak(
                  initialReportsState.tasksLongestStreak.toString()),
              skipOffstage: false),
          findsOneWidget,
          reason: "EN Longest Tasks Streak text");
      expect(
          find.text(
              l10n.longestHabitsStreak(
                  initialReportsState.habitsLongestStreak.toString()),
              skipOffstage: false),
          findsOneWidget,
          reason: "EN Longest Habits Streak text");

      // Assert: Time Management Techniques Section.
      final timeManagementFinderEn = find.text(l10n.timeManagementTechniques);
      await tester.ensureVisible(timeManagementFinderEn);
      await tester.pumpAndSettle();
      expect(timeManagementFinderEn, findsOneWidget,
          reason: "EN Time Management Techniques title");
      expect(find.text(l10n.flowmodoro, skipOffstage: false), findsWidgets,
          reason: "EN Flowmodoro pie label/legend");
      expect(find.text(l10n.timeBlocks, skipOffstage: false), findsWidgets,
          reason: "EN Time Blocks pie label/legend");

      // Assert: Flowmodoro Insights Section.
      final flowmodoroInsightsFinderEn = find.text(l10n.flowmodoroInsights);
      await tester.ensureVisible(flowmodoroInsightsFinderEn);
      await tester.pumpAndSettle();
      expect(flowmodoroInsightsFinderEn, findsOneWidget,
          reason: "EN Flowmodoro Insights title");
      expect(find.text(l10n.focusTime, skipOffstage: false), findsWidgets,
          reason: "EN Focus Time doughnut label/legend");
      expect(find.text(l10n.breakTime, skipOffstage: false), findsWidgets,
          reason: "EN Break Time doughnut label/legend");
      expect(
          find.text(
              l10n.sessions(initialReportsState.flowmodoroCount.toString()),
              skipOffstage: false),
          findsOneWidget,
          reason: "EN Sessions text");

      // Prepare for combined time text assertion.
      final testController = TestReportsController(
        initialReportsState,
        taskService: mockTaskService,
        subtaskService: mockSubtaskService,
        moodService: mockMoodService,
        habitService: mockHabitService,
        symptomsService: mockSymptomService,
        energyService: mockEnergyService,
        flowmodoroService: mockFlowmodoroService,
        medicationService: mockMedicationService,
      );
      final expectedCombinedTimeEn = testController.formatTimeDisplay(
          initialReportsState.totalFlowTime, l10n);
      final combinedTimeFinderEn = find
          .text(l10n.combinedTime(expectedCombinedTimeEn), skipOffstage: false);
      await tester.ensureVisible(combinedTimeFinderEn);
      await tester.pumpAndSettle();
      expect(combinedTimeFinderEn, findsOneWidget,
          reason: "EN Combined Time text");

      // Assert: Time Block Insights Section.
      final timeBlockInsightsFinderEn = find.text(l10n.timeBlockInsights);
      await tester.ensureVisible(timeBlockInsightsFinderEn);
      await tester.pumpAndSettle();
      expect(timeBlockInsightsFinderEn, findsOneWidget,
          reason: "EN Time Block Insights title");
      // Verify chart series names (legends).
      expect(find.text(l10n.timeBlocks, skipOffstage: false), findsWidgets,
          reason: "EN Time Blocks column series name");
      expect(
          find.text('${l10n.hours[0].toUpperCase()}${l10n.hours.substring(1)}',
              skipOffstage: false),
          findsWidgets,
          reason: "EN Hours column series name");
    });

    /// Tests that all UI elements on the ReportsPage display correct Spanish text
    /// when the locale is set to 'es'.
    testWidgets('Displays Spanish titles, buttons, and chart labels',
        (WidgetTester tester) async {
      // Arrange: Pump the ReportsPage with Spanish locale.
      await pumpReportsPage(tester, 'es');
      // Get the AppLocalizations instance for Spanish.
      final l10n =
          AppLocalizations.of(tester.element(find.byType(ReportsPage)))!;

      // Assert: AppBar title.
      expect(find.text(l10n.insights), findsOneWidget,
          reason: "ES AppBar title");

      // Assert: Time Range Buttons.
      expect(find.widgetWithText(ElevatedButton, l10n.day.toUpperCase()),
          findsOneWidget,
          reason: "ES Day button");
      expect(find.widgetWithText(ElevatedButton, l10n.week.toUpperCase()),
          findsOneWidget,
          reason: "ES Week button");
      expect(find.widgetWithText(ElevatedButton, l10n.month.toUpperCase()),
          findsOneWidget,
          reason: "ES Month button");
      expect(find.widgetWithText(ElevatedButton, l10n.year.toUpperCase()),
          findsOneWidget,
          reason: "ES Year button");

      // Assert: Metrics Over Time Section.
      final metricsOverTimeFinderEs = find.text(l10n.metricsOverTime);
      await tester.ensureVisible(metricsOverTimeFinderEs);
      await tester.pumpAndSettle();
      expect(metricsOverTimeFinderEs, findsOneWidget,
          reason: "ES Metrics Over Time title");
      expect(find.text(l10n.mood, skipOffstage: false), findsWidgets,
          reason: "ES Mood legend");
      expect(find.text(l10n.energy, skipOffstage: false), findsWidgets,
          reason: "ES Energy legend");
      expect(find.text(l10n.symptoms, skipOffstage: false), findsWidgets,
          reason: "ES Symptoms legend");
      expect(find.text(l10n.tasks, skipOffstage: false), findsWidgets,
          reason: "ES Tasks legend");
      expect(find.text(l10n.habits, skipOffstage: false), findsWidgets,
          reason: "ES Habits legend");
      expect(find.text(l10n.medication, skipOffstage: false), findsWidgets,
          reason: "ES Medication legend");

      // Assert: Streaks Section.
      final streaksFinderEs = find.text(l10n.streaks);
      await tester.ensureVisible(streaksFinderEs);
      await tester.pumpAndSettle();
      expect(streaksFinderEs, findsOneWidget, reason: "ES Streaks title");
      expect(
          find.text(
              l10n.longestTasksStreak(
                  initialReportsState.tasksLongestStreak.toString()),
              skipOffstage: false),
          findsOneWidget,
          reason: "ES Longest Tasks Streak text");
      expect(
          find.text(
              l10n.longestHabitsStreak(
                  initialReportsState.habitsLongestStreak.toString()),
              skipOffstage: false),
          findsOneWidget,
          reason: "ES Longest Habits Streak text");

      // Assert: Time Management Techniques Section.
      final timeManagementFinderEs = find.text(l10n.timeManagementTechniques);
      await tester.ensureVisible(timeManagementFinderEs);
      await tester.pumpAndSettle();
      expect(timeManagementFinderEs, findsOneWidget,
          reason: "ES Time Management Techniques title");
      expect(find.text(l10n.flowmodoro, skipOffstage: false), findsWidgets,
          reason: "ES Flowmodoro pie label/legend");
      expect(find.text(l10n.timeBlocks, skipOffstage: false), findsWidgets,
          reason: "ES Time Blocks pie label/legend");

      // Assert: Flowmodoro Insights Section.
      final flowmodoroInsightsFinderEs = find.text(l10n.flowmodoroInsights);
      await tester.ensureVisible(flowmodoroInsightsFinderEs);
      await tester.pumpAndSettle();
      expect(flowmodoroInsightsFinderEs, findsOneWidget,
          reason: "ES Flowmodoro Insights title");
      expect(find.text(l10n.focusTime, skipOffstage: false), findsWidgets,
          reason: "ES Focus Time doughnut label/legend");
      expect(find.text(l10n.breakTime, skipOffstage: false), findsWidgets,
          reason: "ES Break Time doughnut label/legend");
      expect(
          find.text(
              l10n.sessions(initialReportsState.flowmodoroCount.toString()),
              skipOffstage: false),
          findsOneWidget,
          reason: "ES Sessions text");

      // Prepare for combined time text assertion.
      final testController = TestReportsController(
        initialReportsState,
        taskService: mockTaskService,
        subtaskService: mockSubtaskService,
        moodService: mockMoodService,
        habitService: mockHabitService,
        symptomsService: mockSymptomService,
        energyService: mockEnergyService,
        flowmodoroService: mockFlowmodoroService,
        medicationService: mockMedicationService,
      );
      final expectedCombinedTimeEs = testController.formatTimeDisplay(
          initialReportsState.totalFlowTime, l10n);
      final combinedTimeFinderEs = find
          .text(l10n.combinedTime(expectedCombinedTimeEs), skipOffstage: false);
      await tester.ensureVisible(combinedTimeFinderEs);
      await tester.pumpAndSettle();
      expect(combinedTimeFinderEs, findsOneWidget,
          reason: "ES Combined Time text");

      // Assert: Time Block Insights Section.
      final timeBlockInsightsFinderEs = find.text(l10n.timeBlockInsights);
      await tester.ensureVisible(timeBlockInsightsFinderEs);
      await tester.pumpAndSettle();
      expect(timeBlockInsightsFinderEs, findsOneWidget,
          reason: "ES Time Block Insights title");
      // Verify chart series names (legends).
      expect(find.text(l10n.timeBlocks, skipOffstage: false), findsWidgets,
          reason: "ES Time Blocks column series name");
      expect(
          find.text('${l10n.hours[0].toUpperCase()}${l10n.hours.substring(1)}',
              skipOffstage: false),
          findsWidgets,
          reason: "ES Hours column series name");
    });

    /// Tests that the ReportsPage UI correctly updates its text elements
    /// when the locale is changed dynamically from English to Spanish.
    testWidgets('Updates when locale changes from English to Spanish',
        (WidgetTester tester) async {
      // Arrange: Initial English Setup.
      await pumpReportsPage(tester, 'en');
      AppLocalizations l10nEn =
          AppLocalizations.of(tester.element(find.byType(ReportsPage)))!;

      // Assert initial English state for a few key elements.
      expect(find.text(l10nEn.insights), findsOneWidget,
          reason: "EN Insights initially");
      final metricsOverTimeEnFinder = find.text(l10nEn.metricsOverTime);
      await tester.ensureVisible(metricsOverTimeEnFinder);
      await tester.pumpAndSettle();
      expect(metricsOverTimeEnFinder, findsOneWidget,
          reason: "EN Metrics Over Time initially");

      // Create a TestReportsController instance to format time for English.
      final testControllerEn = TestReportsController(
        initialReportsState,
        taskService: mockTaskService,
        subtaskService: mockSubtaskService,
        moodService: mockMoodService,
        habitService: mockHabitService,
        symptomsService: mockSymptomService,
        energyService: mockEnergyService,
        flowmodoroService: mockFlowmodoroService,
        medicationService: mockMedicationService,
      );
      final englishCombinedTimeText = l10nEn.combinedTime(testControllerEn
          .formatTimeDisplay(initialReportsState.totalFlowTime, l10nEn));
      final combinedTimeEnFinder =
          find.text(englishCombinedTimeText, skipOffstage: false);
      await tester.ensureVisible(combinedTimeEnFinder);
      await tester.pumpAndSettle();
      expect(combinedTimeEnFinder, findsOneWidget,
          reason: "EN Combined Time initially");

      // Act: Change Locale to Spanish by re-pumping the widget.
      await pumpReportsPage(tester, 'es');
      AppLocalizations l10nEs =
          AppLocalizations.of(tester.element(find.byType(ReportsPage)))!;

      // Assert: Verify that UI elements now display Spanish text.
      expect(find.text(l10nEs.insights), findsOneWidget,
          reason: "ES Insights after change");
      final metricsOverTimeEsFinder =
          find.text(l10nEs.metricsOverTime, skipOffstage: false);
      await tester.ensureVisible(metricsOverTimeEsFinder);
      await tester.pumpAndSettle();
      expect(metricsOverTimeEsFinder, findsOneWidget,
          reason: "ES Metrics Over Time after change");

      // Create a TestReportsController instance to format time for Spanish.
      final testControllerEs = TestReportsController(
        initialReportsState,
        taskService: mockTaskService,
        subtaskService: mockSubtaskService,
        moodService: mockMoodService,
        habitService: mockHabitService,
        symptomsService: mockSymptomService,
        energyService: mockEnergyService,
        flowmodoroService: mockFlowmodoroService,
        medicationService: mockMedicationService,
      );
      final spanishCombinedTimeText = l10nEs.combinedTime(testControllerEs
          .formatTimeDisplay(initialReportsState.totalFlowTime, l10nEs));
      final combinedTimeEsFinder =
          find.text(spanishCombinedTimeText, skipOffstage: false);
      await tester.ensureVisible(combinedTimeEsFinder);
      await tester.pumpAndSettle();
      expect(combinedTimeEsFinder, findsOneWidget,
          reason: "ES Combined Time after change");

      // Assert: Ensure old English text (if different) is no longer present.
      if (englishCombinedTimeText != spanishCombinedTimeText) {
        expect(find.text(englishCombinedTimeText, skipOffstage: false),
            findsNothing,
            reason: "Old EN Combined Time should be gone");
      }
    });
  });
}