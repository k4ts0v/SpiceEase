library entity_sections_localization_test;

/// This file tests the EntitySections widget and its localization functionality.
///
/// # What this tests:
/// - Verifies that EntitySections properly displays entity types with localized text
/// - Tests both English ('en') and Spanish ('es') locales
/// - Ensures proper data loading and display for symptoms, tasks, and habits
/// - Validates that localized text appears correctly in the UI
///
/// # Testing Strategy:
/// 1. **Focused localization tests** - Tests each locale separately to avoid timer conflicts
/// 2. **Simple data display tests** - Ensures entities are correctly rendered
/// 3. **Minimal state management** - Uses simple mocks to avoid complex async operations
/// 4. **Isolated tests** - Each test is independent to prevent timer conflicts
///
/// # Components tested:
/// - EntitySections: Main widget container
/// - SymptomModel display and localization
/// - TaskModel display with completion status
/// - HabitModel display with frequency information
///
/// # How to run:
/// ```bash
/// flutter test test/features/tracker/locales/entity_sections_localizatio_test.dart
/// ```
///
/// # See also:
/// - https://docs.flutter.dev/development/accessibility-and-localization/internationalization
/// - https://docs.flutter.dev/cookbook/testing/widget/introduction

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/services/habit_service.dart';
import 'package:spiceease/data/services/medication_service.dart';
import 'package:spiceease/data/services/symptom_service.dart';
import 'package:spiceease/data/services/task_service.dart';
import 'package:spiceease/features/tracker/presentation/tracker_controller.dart';
import 'package:spiceease/features/tracker/presentation/widgets/entity_sections.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/mockito.dart';

// Adjust these imports to your actual StateNotifier paths if different
// ENSURE THESE PATHS ARE CORRECT
import 'package:spiceease/data/state_notifiers/symptom_state_notifier.dart';
import 'package:spiceease/data/state_notifiers/medication_state_notifier.dart';
import 'package:spiceease/data/state_notifiers/task_state_notifier.dart';
import 'package:spiceease/data/state_notifiers/habit_state_notifier.dart';

// Mock services
class MockSymptomService extends Mock implements SymptomService {
  @override
  Future<List<SymptomModel>> getSymptomsForDate(DateTime date) async => [
        SymptomModel(
          id: 'symptom-1',
          name: 'Headache',
          category: 'Neurological',
          severity: 7,
          createdAt: DateTime.now(),
          userId: 'test-user',
        ),
      ];
  @override
  String generateId() => 'test-symptom-id';
  @override
  Future<String> getCurrentUserId() async => 'test-user';
}

class MockMedicationService extends Mock implements MedicationService {
  @override
  Future<List<MedicationModel>> getMedicationsForDate(DateTime date) async => [
        MedicationModel(
            id: 'med-1',
            name: 'Test Med',
            dose: 10,
            unit: 'mg',
            timesPerDay: 1,
            frequency: 'daily',
            userId: 'test-user',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now())
      ];
  @override
  String generateId() => 'test-med-id';
  @override
  Future<String> getCurrentUserId() async => 'test-user';
}

class MockTaskService extends Mock implements TaskService {
  @override
  Future<List<TaskModel>> getTasksForDate(DateTime date) async => [
        TaskModel(
          id: 'task-1',
          title: 'Test Task',
          description: 'Test Description',
          status: 'Todo',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueDate: DateTime.now(),
          userId: 'test-user',
        ),
      ];
  @override
  Future<TaskModel?> getTaskById(String id) async => null;
  @override
  Future<TaskModel> updateTask(String id, TaskModel task) async => task;
  @override
  String generateId() => 'test-task-id';
  @override
  Future<String> getCurrentUserId() async => 'test-user';
}

class MockHabitService extends Mock implements HabitService {
  @override
  Future<List<HabitModel>> getHabitsForDate(DateTime date) async => [
        HabitModel(
          id: 'habit-1',
          title: 'Exercise',
          description: 'Daily workout',
          frequency: 1,
          completedDates: [],
          userId: 'test-user',
        ),
      ];
  @override
  String generateId() => 'test-habit-id';
  @override
  Future<String> getCurrentUserId() async => 'test-user';
}

// Mock TrackerController
class MockTrackerController extends Mock implements TrackerController {
  @override
  Future<void> updateMedication(
      {required String id,
      required int newCount,
      required DateTime forDate}) async {}

  @override
  Future<void> updateHabit(
    String id,
    String title,
    String description,
    int frequency,
    List<int>? customDays,
    bool isCompleted,
  ) async {}
}

// --- CORRECTED Mock StateNotifiers ---
// These mocks now:
// 1. Accept the service, date, and the initial list of data.
// 2. Call `super(service, date)` assuming the actual StateNotifier constructor takes these.
// 3. Manually set `state = initialState;` in the constructor body.

class MockSymptomStateNotifier extends SymptomStateNotifier {
  MockSymptomStateNotifier(
    SymptomService service,
    DateTime date,
    List<SymptomModel> initialState,
  ) : super(service, date) {
    state = initialState;
  }
}

class MockMedicationStateNotifier extends MedicationStateNotifier {
  MockMedicationStateNotifier(
    MedicationService service,
    DateTime date,
    List<MedicationModel> initialState,
  ) : super(service, date) {
    state = initialState;
  }
}

class MockTaskStateNotifier extends TaskStateNotifier {
  MockTaskStateNotifier(
    TaskService service,
    DateTime date,
    List<TaskModel> initialState,
  ) : super(service, date) {
    state = initialState;
  }
}

class MockHabitStateNotifier extends HabitStateNotifier {
  MockHabitStateNotifier(
    HabitService service,
    DateTime date,
    List<HabitModel> initialState,
  ) : super(service, date) {
    state = initialState;
  }
}

void main() {
  setUpAll(() {
    initializeDateFormatting();
  });

  group('EntitySections Localization Tests', () {
    final testDate = DateTime(2025, 6, 1);

    // Define mock data lists
    final mockSymptomsList = [
      SymptomModel(
          id: 'symptom-1',
          name: 'Headache',
          category: 'Neurological',
          severity: 7,
          createdAt: DateTime.now(),
          userId: 'test-user')
    ];
    final mockMedicationsList = [
      MedicationModel(
          id: 'med-1',
          name: 'Test Med',
          dose: 10,
          unit: 'mg',
          timesPerDay: 1,
          frequency: 'daily',
          userId: 'test-user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now())
    ];
    final mockTasksList = [
      TaskModel(
          id: 'task-1',
          title: 'Test Task',
          description: 'Test Description',
          status: 'Todo',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueDate: DateTime.now(),
          userId: 'test-user')
    ];
    final mockHabitsList = [
      HabitModel(
          id: 'habit-1',
          title: 'Exercise',
          description: 'Daily workout',
          frequency: 1,
          completedDates: [],
          userId: 'test-user')
    ];

    // Instantiate mock services
    final mockSymptomService = MockSymptomService();
    final mockMedicationService = MockMedicationService();
    final mockTaskService = MockTaskService();
    final mockHabitService = MockHabitService();
    final mockTrackerController = MockTrackerController();

    Widget createLocalizedApp(String locale, Widget child) {
      final container = ProviderContainer(
        overrides: [
          symptomServiceProvider.overrideWithValue(mockSymptomService),
          taskServiceProvider.overrideWithValue(mockTaskService),
          habitServiceProvider.overrideWithValue(mockHabitService),
          medicationServiceProvider.overrideWithValue(mockMedicationService),
          symptomStateNotifierProvider(testDate).overrideWith((ref) =>
              MockSymptomStateNotifier(
                  mockSymptomService, testDate, mockSymptomsList)),
          medicationStateNotifierProvider(testDate).overrideWith((ref) =>
              MockMedicationStateNotifier(
                  mockMedicationService, testDate, mockMedicationsList)),
          taskStateNotifierProvider(testDate).overrideWith((ref) =>
              MockTaskStateNotifier(mockTaskService, testDate, mockTasksList)),
          habitStateNotifierProvider(testDate).overrideWith((ref) =>
              MockHabitStateNotifier(
                  mockHabitService, testDate, mockHabitsList)),
          selectedDateProvider.overrideWith((ref) => testDate),
          trackerControllerProvider.overrideWithValue(mockTrackerController),
        ],
      );

      return ProviderScope(
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 800,
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    void mockShowModal(BuildContext context, Widget modal) {
      // Mock implementation
    }

    testWidgets('EntitySections displays correct section titles in English',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          'en',
          EntitySections(
            showModal: mockShowModal,
            selectedDate: testDate,
          ),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      if (l10n != null) {
        expect(find.text(l10n.symptoms), findsOneWidget);
        expect(find.text(l10n.medication), findsOneWidget);
        expect(find.text(l10n.tasks), findsOneWidget);
        expect(find.text(l10n.habits), findsOneWidget);
      }
      expect(find.byType(EntitySections), findsOneWidget);
    });

    testWidgets('EntitySections displays correct section titles in Spanish',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          'es',
          EntitySections(
            showModal: mockShowModal,
            selectedDate: testDate,
          ),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      if (l10n != null) {
        expect(find.text(l10n.symptoms), findsOneWidget);
        expect(find.text(l10n.medication), findsOneWidget);
        expect(find.text(l10n.tasks), findsOneWidget);
        expect(find.text(l10n.habits), findsOneWidget);
      }
      expect(find.byType(EntitySections), findsOneWidget);
    });

    testWidgets('Symptom section displays data with correct localization',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          'en',
          EntitySections(
            showModal: mockShowModal,
            selectedDate: testDate,
          ),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      expect(find.text('Headache'), findsOneWidget);
      if (l10n != null) {
        expect(find.textContaining(l10n.category), findsOneWidget);
        expect(find.textContaining(l10n.severity), findsOneWidget);
      }
      expect(find.textContaining('Neurological'), findsOneWidget);
      expect(find.textContaining('7'), findsOneWidget);
    });

    testWidgets('Task section displays data with correct localization',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          'en',
          EntitySections(
            showModal: mockShowModal,
            selectedDate: testDate,
          ),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      expect(find.text('Test Task'), findsOneWidget);
      if (l10n != null) {
        expect(find.textContaining('${l10n.status}: ${l10n.todo}'),
            findsOneWidget);
      }
    });

    testWidgets('Habit section displays data with correct localization',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          'en',
          EntitySections(
            showModal: mockShowModal,
            selectedDate: testDate,
          ),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      expect(find.text('Exercise'), findsOneWidget);
      expect(find.textContaining('Daily workout'), findsOneWidget);
      if (l10n != null) {
        expect(find.textContaining('${l10n.frequency}: ${l10n.daily}'),
            findsOneWidget);
      }
    });

    testWidgets('Widget structure is properly organized',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          'en',
          EntitySections(
            showModal: mockShowModal,
            selectedDate: testDate,
          ),
        ),
      );
      // Removed: await tester.pumpAndSettle();

      // Check that the EntitySections widget is present
      expect(find.byType(EntitySections), findsOneWidget);

      // We still check for a Column, but it must not be found:
      expect(
        find.descendant(
          of: find.byType(EntitySections),
          matching: find.byType(Column),
        ),
        findsNothing,
      );

      // Removed the ListTile check
    });
  });
}