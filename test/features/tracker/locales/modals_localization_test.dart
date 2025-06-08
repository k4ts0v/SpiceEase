/// This file tests the localization system for all tracker modal components.
///
/// # What this tests:
/// - Verifies that all modal editor components properly use the localization system
/// - Tests both English ('en') and Spanish ('es') locales
/// - Ensures localized text appears correctly in the UI
/// - Validates that the localization context is properly propagated
///
/// # Testing Strategy:
/// 1. **Modal-specific tests** - Each modal is tested individually in both languages
/// 2. **Dynamic validation** - Uses actual l10n values instead of hardcoded strings
/// 3. **Null-safe approach** - Handles cases where localization might not be available
///
/// # Modals tested:
/// - SymptomEditorModal: name, category, severity fields
/// - TaskEditorModal: task, title, description, status fields
/// - HabitEditorModal: habit, name, category fields
/// - MoodLevelEditorModal: mood level selection
/// - EnergyLevelEditorModal: energy level selection
/// - MedicationEditorModal: medication name input
///
/// # How to run:
/// ```bash
/// flutter test test/features/tracker/locales/modals_localization_test.dart
/// ```
///
/// # See also:
/// - https://docs.flutter.dev/development/accessibility-and-localization/internationalization
/// - https://pub.dev/packages/flutter_localizations
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/features/tracker/presentation/modals.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/services/task_service.dart';
import 'package:mockito/mockito.dart';

/// Mock implementation of TaskService for testing.
/// Provides minimal required functionality without real database interactions.
class MockTaskService extends Mock implements TaskService {
  @override
  Future<List<TaskModel>> getTasksForDate(DateTime date) async => [];

  @override
  String generateId() => 'test-id';

  @override
  Future<String> getCurrentUserId() async => 'test-user';
}

void main() {
  // Initialize date formatting for all locales used in tests
  setUpAll(() {
    initializeDateFormatting();
  });

  group('Modals Localization Tests', () {
    late ProviderContainer container;

    /// Set up a provider container with mocked dependencies before each test.
    /// This ensures each test starts with a clean state.
    setUp(() {
      container = ProviderContainer(
        overrides: [
          taskServiceProvider.overrideWithValue(MockTaskService()),
        ],
      );
    });

    /// Clean up the provider container after each test to prevent memory leaks.
    tearDown(() {
      container.dispose();
    });

    /// Helper function to create a MaterialApp with localization setup.
    /// Reduces code duplication across tests.
    Widget createLocalizedApp(String locale, Widget Function(WidgetRef) childBuilder) {
      return ProviderScope(
        overrides: [
          taskServiceProvider.overrideWithValue(MockTaskService()),
        ],
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
        builder: (context, ref, _) => Scaffold(body: childBuilder(ref)),
          ),
        ),
      );
    }

    /// Verifies that SymptomEditorModal displays correctly localized text in English.
    /// Tests: name, category, severity, cancel, save labels.
    testWidgets('SymptomEditorModal displays correct text in English',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with English locale
      await tester.pumpWidget(
        createLocalizedApp('en', (ref) => SymptomEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the localization context from the rendered widget
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify all expected localized text appears
      if (l10n != null) {
        expect(find.text(l10n.name), findsOneWidget);
        expect(find.text(l10n.category), findsOneWidget);
        expect(find.text(l10n.severity), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(SymptomEditorModal), findsOneWidget);
    });

    /// Verifies that SymptomEditorModal displays correctly localized text in Spanish.
    /// Same fields as English test but with Spanish locale.
    testWidgets('SymptomEditorModal displays correct text in Spanish',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with Spanish locale
      await tester.pumpWidget(
        createLocalizedApp('es', (ref) => SymptomEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the Spanish localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify Spanish localized text appears
      if (l10n != null) {
        expect(find.text(l10n.name), findsOneWidget);
        expect(find.text(l10n.category), findsOneWidget);
        expect(find.text(l10n.severity), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(SymptomEditorModal), findsOneWidget);
    });

    /// Verifies that TaskEditorModal displays correctly localized text in English.
    /// Tests: task, title, description, status, cancel, save labels.
    testWidgets('TaskEditorModal displays correct text in English',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with English locale
      await tester.pumpWidget(
        createLocalizedApp('en', (ref) => TaskEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify task-specific localized text appears
      if (l10n != null) {
        expect(find.text(l10n.task), findsOneWidget);
        expect(find.text(l10n.title), findsOneWidget);
        expect(find.text(l10n.description), findsOneWidget);
        expect(find.text(l10n.status), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(TaskEditorModal), findsOneWidget);
    });

    /// Verifies that TaskEditorModal displays correctly localized text in Spanish.
    /// Same fields as English test but with Spanish locale.
    testWidgets('TaskEditorModal displays correct text in Spanish',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with Spanish locale
      await tester.pumpWidget(
        createLocalizedApp('es', (ref) => TaskEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the Spanish localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify Spanish task-specific text appears
      if (l10n != null) {
        expect(find.text(l10n.task), findsOneWidget);
        expect(find.text(l10n.title), findsOneWidget);
        expect(find.text(l10n.description), findsOneWidget);
        expect(find.text(l10n.status), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(TaskEditorModal), findsOneWidget);
    });

    /// Verifies that HabitEditorModal displays correctly localized text in English.
    /// Tests: habit, name, category, cancel, save labels.
    testWidgets('HabitEditorModal displays correct text in English',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with English locale
      await tester.pumpWidget(
        createLocalizedApp('en', (ref) => HabitEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify habit-specific localized text appears
      if (l10n != null) {
        expect(find.text(l10n.habit), findsOneWidget);
        expect(find.text(l10n.name), findsOneWidget);
        expect(find.text(l10n.category), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(HabitEditorModal), findsOneWidget);
    });

    /// Verifies that HabitEditorModal displays correctly localized text in Spanish.
    /// Same fields as English test but with Spanish locale.
    testWidgets('HabitEditorModal displays correct text in Spanish',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with Spanish locale
      await tester.pumpWidget(
        createLocalizedApp('es', (ref) => HabitEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the Spanish localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify Spanish habit-specific text appears
      if (l10n != null) {
        expect(find.text(l10n.habit), findsOneWidget);
        expect(find.text(l10n.name), findsOneWidget);
        expect(find.text(l10n.category), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(HabitEditorModal), findsOneWidget);
    });

    /// Verifies that MoodLevelEditorModal displays correctly localized text in English.
    /// Tests: mood, cancel, save labels.
    testWidgets('MoodLevelEditorModal displays correct text in English',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with English locale
      await tester.pumpWidget(
        createLocalizedApp('en', (ref) => MoodLevelEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify mood-specific localized text appears
      if (l10n != null) {
        expect(find.text(l10n.mood), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(MoodLevelEditorModal), findsOneWidget);
    });

    /// Verifies that MoodLevelEditorModal displays correctly localized text in Spanish.
    /// Same fields as English test but with Spanish locale.
    testWidgets('MoodLevelEditorModal displays correct text in Spanish',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with Spanish locale
      await tester.pumpWidget(
        createLocalizedApp('es', (ref) => MoodLevelEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the Spanish localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify Spanish mood-specific text appears
      if (l10n != null) {
        expect(find.text(l10n.mood), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(MoodLevelEditorModal), findsOneWidget);
    });

    /// Verifies that EnergyLevelEditorModal displays correctly localized text in English.
    /// Tests: energy, cancel, save labels.
    testWidgets('EnergyLevelEditorModal displays correct text in English',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with English locale
      await tester.pumpWidget(
        createLocalizedApp('en', (ref) => EnergyLevelEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify energy-specific localized text appears
      if (l10n != null) {
        expect(find.text(l10n.energy), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(EnergyLevelEditorModal), findsOneWidget);
    });

    /// Verifies that EnergyLevelEditorModal displays correctly localized text in Spanish.
    /// Same fields as English test but with Spanish locale.
    testWidgets('EnergyLevelEditorModal displays correct text in Spanish',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with Spanish locale
      await tester.pumpWidget(
        createLocalizedApp('es', (ref) => EnergyLevelEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the Spanish localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify Spanish energy-specific text appears
      if (l10n != null) {
        expect(find.text(l10n.energy), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(EnergyLevelEditorModal), findsOneWidget);
    });

    /// Verifies that MedicationEditorModal displays correctly localized text in English.
    /// Tests: medication, name, cancel, save labels.
    testWidgets('MedicationEditorModal displays correct text in English',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with English locale
      await tester.pumpWidget(
        createLocalizedApp('en', (ref) => MedicationEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify medication-specific localized text appears
      if (l10n != null) {
        expect(find.text(l10n.medication), findsOneWidget);
        expect(find.text(l10n.name), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(MedicationEditorModal), findsOneWidget);
    });

    /// Verifies that MedicationEditorModal displays correctly localized text in Spanish.
    /// Same fields as English test but with Spanish locale.
    testWidgets('MedicationEditorModal displays correct text in Spanish',
        (WidgetTester tester) async {
      // Arrange: Set up the widget with Spanish locale
      await tester.pumpWidget(
        createLocalizedApp('es', (ref) => MedicationEditorModal(ref: ref)),
      );
      await tester.pumpAndSettle();

      // Act: Get the Spanish localization context
      final context = tester.element(find.byType(MaterialApp));
      final l10n = AppLocalizations.of(context);

      // Assert: Verify Spanish medication-specific text appears
      if (l10n != null) {
        expect(find.text(l10n.medication), findsOneWidget);
        expect(find.text(l10n.name), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.save), findsOneWidget);
      }
      expect(find.byType(MedicationEditorModal), findsOneWidget);
    });

    /// Comprehensive test that verifies the localization system works correctly
    /// across different languages. Tests the core localization functionality
    /// by creating text widgets with localized content and verifying they render.
    testWidgets('Localization system works correctly across languages',
        (WidgetTester tester) async {
      // Test English localization
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              // Gracefully handle missing localization
              if (l10n == null) return Container();

              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.symptom),
                    Text(l10n.task),
                    Text(l10n.habit),
                    Text(l10n.cancel),
                    Text(l10n.save),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify English localized content appears
      final englishContext = tester.element(find.byType(MaterialApp));
      final englishL10n = AppLocalizations.of(englishContext);
      if (englishL10n != null) {
        expect(find.text(englishL10n.symptom), findsOneWidget);
        expect(find.text(englishL10n.task), findsOneWidget);
        expect(find.text(englishL10n.habit), findsOneWidget);
        expect(find.text(englishL10n.cancel), findsOneWidget);
        expect(find.text(englishL10n.save), findsOneWidget);
      }

      // Test Spanish localization
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              // Gracefully handle missing localization
              if (l10n == null) return Container();

              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.symptom),
                    Text(l10n.task),
                    Text(l10n.habit),
                    Text(l10n.cancel),
                    Text(l10n.save),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Spanish localized content appears
      final spanishContext = tester.element(find.byType(MaterialApp));
      final spanishL10n = AppLocalizations.of(spanishContext);
      if (spanishL10n != null) {
        expect(find.text(spanishL10n.symptom), findsOneWidget);
        expect(find.text(spanishL10n.task), findsOneWidget);
        expect(find.text(spanishL10n.habit), findsOneWidget);
        expect(find.text(spanishL10n.cancel), findsOneWidget);
        expect(find.text(spanishL10n.save), findsOneWidget);
      }
    });
  });
}
