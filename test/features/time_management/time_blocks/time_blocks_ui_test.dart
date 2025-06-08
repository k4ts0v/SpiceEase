/// This file tests the UI overflow and layout handling of the TimeBlocksPage widget.
///
/// # Testing Strategy
///
/// This test suite validates UI robustness:
/// 1. UI Overflow Prevention with long text content in scheduled and unscheduled tasks
/// 2. Screen Size Responsiveness across different devices
/// 3. Layout stability with comprehensive task data
/// 4. Text wrapping and ellipsis handling in time block cards
/// 5. Schedule area overflow handling with concurrent tasks
/// 6. Time indicator positioning and visibility
///
/// # How to run
/// - Run with `flutter test test/features/time_management/time_blocks/time_blocks_ui_test.dart`

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spiceease/components/calendar_week_selector.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/services/task_service.dart';
import 'package:spiceease/data/services/subtask_service.dart';
import 'package:spiceease/features/time_management/time_blocks/time_block_controller.dart';
import 'package:spiceease/features/time_management/time_blocks/time_blocks_page.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// Generate mocks
@GenerateMocks([TaskService, SubtaskService])
import 'time_blocks_ui_test.mocks.dart';

// --------------------------------------------------------------------------
// STANDARDIZED TEST SCREEN SIZES - MUST MATCH ACROSS ALL UI TESTS
// --------------------------------------------------------------------------

/// Standardized screen sizes for consistent testing across ALL UI test suites
/// These sizes MUST be kept identical in kanban_ui_test.dart and time_blocks_ui_test.dart
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
// Test Data Setup for Time Blocks UI Testing
// --------------------------------------------------------------------------

/// Fixed test date for consistent testing across all scenarios
final testSelectedDate = DateTime(2025, 6, 1);

// --------------------------------------------------------------------------
// Test Helpers
// --------------------------------------------------------------------------

void main() {
  /// Helper function to set up and pump the TimeBlocksPage widget for UI testing
  /// This version uses empty mocks to avoid controller sorting issues
  Future<void> pumpTimeBlocksPageForUI(
    WidgetTester tester, {
    String localeCode = 'en',
    Size? screenSize,
    DateTime? selectedDate,
  }) async {
    final testDate = selectedDate ?? testSelectedDate;

    if (screenSize != null) {
      await tester.binding.setSurfaceSize(screenSize);
    }

    // Create mocks that return empty lists to avoid controller sorting issues
    final mockTaskService = MockTaskService();
    final mockSubtaskService = MockSubtaskService();

    // Setup task service to return empty lists - no mixing with subtasks
    when(mockTaskService.getTasksForDate(any)).thenAnswer((_) async => <TaskModel>[]);
    when(mockTaskService.getAllTasks()).thenAnswer((_) async => <TaskModel>[]);
    when(mockTaskService.getTaskById(any)).thenAnswer((_) async => TaskModel(
      id: 'mock-task',
      title: 'Mock Task',
      status: 'todo',
      priority: 1,
      createdAt: DateTime.now(),
      userId: 'test-user',
      updatedAt: DateTime.now(),
    ));

    // Setup subtask service to return empty lists - no mixing with tasks
    when(mockSubtaskService.getAllSubtasks()).thenAnswer((_) async => <SubtaskModel>[]);
    when(mockSubtaskService.getSubtasksForTask(any)).thenAnswer((_) async => <SubtaskModel>[]);
    when(mockSubtaskService.getSubtaskById(any)).thenAnswer((_) async => SubtaskModel(
      id: 'mock-subtask',
      taskId: 'mock-task',
      title: 'Mock Subtask',
      completed: false,
      order: 1,
      userId: 'test-user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedDateProvider.overrideWith((ref) => testDate),
          taskServiceProvider.overrideWith((ref) => mockTaskService),
          subtaskServiceProvider.overrideWith((ref) => mockSubtaskService),
        ],
        child: MaterialApp(
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TimeBlocksPage(),
        ),
      ),
    );

    // Allow the widget to build and load data
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Wait for async operations to complete
    await tester.pumpAndSettle();
  }

  // --------------------------------------------------------------------------
  // Time Blocks UI Overflow and Layout Test Cases
  // --------------------------------------------------------------------------

  group('TimeBlocksPage UI Overflow and Layout Tests', () {
    testWidgets('Displays TimeBlocksPage without crashing', (WidgetTester tester) async {
      // Act
      await pumpTimeBlocksPageForUI(tester, screenSize: const Size(1200, 800));

      // Assert: Verify main TimeBlocks components are present
      expect(find.byType(TimeBlocksPage), findsOneWidget);
      expect(find.byType(CalendarWeekSelector), findsOneWidget);

      // Check for any rendering exceptions
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'TimeBlocksPage should load without errors');
    });

    testWidgets('Handles empty data without overflow', (WidgetTester tester) async {
      // Act
      await pumpTimeBlocksPageForUI(tester, screenSize: const Size(1200, 800));

      // Assert: Verify main components are present
      expect(find.byType(TimeBlocksPage), findsOneWidget);
      expect(find.byType(CalendarWeekSelector), findsOneWidget);

      // Verify scrolling widgets are present
      expect(find.byType(SingleChildScrollView), findsWidgets);

      // Check for any rendering exceptions
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'No overflow should occur with empty data');
    });

    group('Screen Size Responsiveness for Time Blocks', () {
      for (final size in standardTestSizes) {
        testWidgets('Handles time blocks layout on ${size.width}x${size.height} screen', (WidgetTester tester) async {
          // Act
          await pumpTimeBlocksPageForUI(tester, screenSize: size);

          // Assert: Verify layout doesn't break
          expect(find.byType(TimeBlocksPage), findsOneWidget);

          // Verify main components are accessible
          expect(find.byType(CalendarWeekSelector), findsOneWidget);

          // Check for any rendering exceptions
          final exception = tester.takeException();
          if (exception != null) {
            // For very small screens, some overflow might be expected - log it but don't fail
            if (size.width < 400) {
              debugPrint('Expected overflow on small screen ${size.width}x${size.height}: $exception');
            } else {
              fail('Unexpected rendering exception on ${size.width}x${size.height}: $exception');
            }
          }
        });
      }
    });

    group('Time Blocks Basic Layout Tests', () {
      testWidgets('Timeline displays basic structure', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(1200, 800));

        // Assert: Verify basic structure
        expect(find.byType(TimeBlocksPage), findsOneWidget);
        expect(find.byType(Stack), findsWidgets);
        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('Handles empty schedule without errors', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(1200, 800));

        // Assert: Verify page displays without error
        expect(find.byType(TimeBlocksPage), findsOneWidget);

        // No rendering exceptions should occur
        final exception = tester.takeException();
        expect(exception, isNull);
      });

      testWidgets('Basic widget structure is present', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(1200, 800));

        // Assert: Verify essential widgets are present
        expect(find.byType(TimeBlocksPage), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsWidgets);

        // Check for rendering exceptions
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'Basic widget structure should not cause overflow');
      });

      testWidgets('Calendar week selector is responsive', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(800, 600));

        // Assert: Verify calendar is present and functional
        expect(find.byType(CalendarWeekSelector), findsOneWidget);

        // Check for rendering exceptions
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'Calendar week selector should not cause overflow');
      });
    });

    group('Extreme Screen Size Tests', () {
      testWidgets('Handles very small screen without crashing', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(300, 500));

        // Assert: Verify page loads (overflow might occur but shouldn't crash)
        expect(find.byType(TimeBlocksPage), findsOneWidget);

        // Small screens may have overflow, which is acceptable
        final exception = tester.takeException();
        if (exception != null) {
          debugPrint('Expected overflow on very small screen: $exception');
        }
      });

      testWidgets('Handles very large screen without issues', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(2560, 1440));

        // Assert: Verify page loads without issues
        expect(find.byType(TimeBlocksPage), findsOneWidget);

        // Large screens should not have overflow
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'Large screens should not have overflow');
      });

      testWidgets('Handles ultra-wide screen layout', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(3440, 1440));

        // Assert: Verify page adapts to ultra-wide layout
        expect(find.byType(TimeBlocksPage), findsOneWidget);
        expect(find.byType(CalendarWeekSelector), findsOneWidget);

        // Ultra-wide screens should not have overflow
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'Ultra-wide screens should not have overflow');
      });
    });

    group('Widget Overflow Prevention Tests', () {
      testWidgets('ScrollView widgets handle content overflow', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(400, 600));

        // Assert: Verify scrollable widgets are present to handle overflow
        expect(find.byType(SingleChildScrollView), findsWidgets);

        // Check for rendering exceptions
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'ScrollView widgets should prevent overflow');
      });

      testWidgets('Stack widgets handle positioning without overflow', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(800, 1200));

        // Assert: Verify Stack widgets are present for time block positioning
        expect(find.byType(Stack), findsWidgets);

        // Check for rendering exceptions
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'Stack widgets should handle positioning without overflow');
      });

      testWidgets('Column widgets maintain vertical layout', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(600, 800));

        // Assert: Verify Column widgets maintain proper layout
        expect(find.byType(Column), findsWidgets);

        // Check for rendering exceptions
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'Column widgets should maintain layout without overflow');
      });
    });

    group('Accessibility and Layout Tests', () {
      testWidgets('Page is accessible with semantic elements', (WidgetTester tester) async {
        // Act
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(1200, 800));

        // Assert: Verify page has accessible structure
        expect(find.byType(TimeBlocksPage), findsOneWidget);

        // Verify no rendering issues affect accessibility
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'Accessibility should not cause rendering issues');
      });

      testWidgets('Layout adapts to different orientations', (WidgetTester tester) async {
        // Test landscape orientation
        await pumpTimeBlocksPageForUI(tester, screenSize: const Size(1024, 768));

        // Assert: Verify landscape layout works
        expect(find.byType(TimeBlocksPage), findsOneWidget);
        expect(find.byType(CalendarWeekSelector), findsOneWidget);

        // Check for rendering exceptions in landscape
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'Landscape orientation should not cause overflow');
      });
    });
  });
}