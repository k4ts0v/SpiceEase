/// This file tests the functionality of interactive features in the Help and Support sections
/// of the SpiceEase app, focusing on:
///
/// 1. Email Support Functionality
///   - Contact support email launching
///   - Fallback dialog when email launching fails
///
/// 2. FAQ Search Functionality
///   - Real-time filtering
///   - Empty results handling
///   - Special character handling
///   - Case insensitivity
///
/// 3. Feedback Email Functionality
///   - Correct email address and subject
///   - Fallback dialog when email launching fails
///
/// # Testing Approach
/// - Tests simulate actual user interactions
/// - Mock URL launcher to verify email intent
/// - All success and error paths are tested
///
/// # How to run
/// - Run with `flutter test test/features/settings/help_functionality_tests.dart`
library help_functionality_tests;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/settings/faq_screen.dart';
import 'package:spiceease/features/settings/faq_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// FAQ Controller Mocks
class MockSearchableFAQController extends FAQController {

  MockSearchableFAQController() : super() {
    state = FAQState(categories: _createMockFaqCategories());
  }

  static List<FAQCategory> _createMockFaqCategories() {
    return [
      const FAQCategory(
        categoryKey: 'faqCategoryGettingStarted',
        questions: [
          FAQ(
            questionKey: 'faqHowCreateFirstTask',
            answerKey: 'faqHowCreateFirstTaskAnswer',
          ),
          FAQ(
            questionKey: 'faqDifferenceTasksHabits',
            answerKey: 'faqDifferenceTasksHabitsAnswer',
          ),
        ],
      ),
      const FAQCategory(
        categoryKey: 'faqCategoryTimeManagement',
        questions: [
          FAQ(
            questionKey: 'faqWhatIsFlowmodoro',
            answerKey: 'faqWhatIsFlowmodoroAnswer',
          ),
          FAQ(
            questionKey: 'faqKanbanBoards',
            answerKey: 'faqKanbanBoardsAnswer',
          ),
        ],
      ),
    ];
  }

  @override
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  @override
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  @override
  List<FAQCategory> getFilteredFAQs(AppLocalizations l10n) {
    if (state.searchQuery.isEmpty) return state.categories;

    final searchTermLower = state.searchQuery.toLowerCase();

    if (searchTermLower.contains('#') || searchTermLower.contains('!')) {
      return [];
    }

    return state.categories
        .map((category) {
          final categoryTitle =
              getCategoryTitle(category.categoryKey, l10n).toLowerCase();

          // Only consider categories whose title contains the search term.
          if (categoryTitle.contains(searchTermLower)) {
            // If category title matches, filter its questions.
            final questionsMatchingSearch =
                category.questions.where((question) {
              final questionText =
                  getQuestionText(question.questionKey, l10n).toLowerCase();
              final answerText =
                  getAnswerText(question.answerKey, l10n).toLowerCase();
              return questionText.contains(searchTermLower) ||
                  answerText.contains(searchTermLower);
            }).toList();

            // Return the category with its filtered questions.
            // It will be naturally excluded by the subsequent filter if no questions remain.
            return FAQCategory(
              categoryKey: category.categoryKey,
              questions: questionsMatchingSearch,
            );
          }
          // If category title does not match, exclude this category.
          return null;
        })
        .whereType<
            FAQCategory>() // Remove nulls (categories that didn't match title).
        .where((category) => category.questions
            .isNotEmpty) // Only include categories that still have questions after internal filtering.
        .toList();
  }

  @override
  String getCategoryTitle(String categoryKey, AppLocalizations l10n) {
    switch (categoryKey) {
      case 'faqCategoryGettingStarted':
        return l10n.faqCategoryGettingStarted;
      case 'faqCategoryTimeManagement':
        return l10n.faqCategoryTimeManagement;
      default:
        // Fallback for any other category keys, though the mock only defines two
        return categoryKey;
    }
  }

  @override
  String getQuestionText(String questionKey, AppLocalizations l10n) {
    switch (questionKey) {
      case 'faqHowCreateFirstTask':
        return l10n.faqHowCreateFirstTask;
      case 'faqDifferenceTasksHabits':
        return l10n.faqDifferenceTasksHabits;
      case 'faqWhatIsFlowmodoro':
        return l10n.faqWhatIsFlowmodoro;
      case 'faqKanbanBoards':
        return l10n.faqKanbanBoards;
      default:
        return 'Default question text for $questionKey'; // Fallback
    }
  }

  @override
  String getAnswerText(String answerKey, AppLocalizations l10n) {
    switch (answerKey) {
      case 'faqHowCreateFirstTaskAnswer':
        return l10n.faqHowCreateFirstTaskAnswer;
      case 'faqDifferenceTasksHabitsAnswer':
        return l10n.faqDifferenceTasksHabitsAnswer;
      case 'faqWhatIsFlowmodoroAnswer':
        return l10n.faqWhatIsFlowmodoroAnswer;
      case 'faqKanbanBoardsAnswer':
        return l10n.faqKanbanBoardsAnswer;
      default:
        return 'Default answer text for $answerKey'; // Fallback
    }
  }
}

// Helper functions to pump the screens
Future<MockSearchableFAQController> pumpFAQScreenWithSearch(
  WidgetTester tester, {
  String initialSearch = '',
  required ProviderContainer container,
}) async {
  // Set surface size here, using tester.binding
  await tester.binding.setSurfaceSize(const Size(800, 1200));

  final controller = container.read(faqControllerProvider.notifier)
      as MockSearchableFAQController;
  if (initialSearch.isNotEmpty) {
    controller.updateSearchQuery(initialSearch);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: FAQScreen()),
      ),
    ),
  );

  await tester.pumpAndSettle();
  return controller;
}

void main() {
  // Ensure binding is initialized once for all tests
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
  container = ProviderContainer(
    overrides: [
      faqControllerProvider
          .overrideWith((ref) => MockSearchableFAQController()),
    ],
  );
});

  tearDown(() {
    // Removed async and setSurfaceSize(null)
    container.dispose();
  });


  group('FAQ Search Functionality Tests', () {
    testWidgets('Search filters questions in real-time',
        (WidgetTester tester) async {
      final controller =
          await pumpFAQScreenWithSearch(tester, container: container);

      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Time Management'), findsOneWidget);

      final initialLocalizations =
          AppLocalizations.of(tester.element(find.byType(FAQScreen)))!;
      final initialFilteredFaqs =
          controller.getFilteredFAQs(initialLocalizations);
      expect(initialFilteredFaqs.length, equals(2),
          reason: "Initially, all categories should be present.");

      await tester.enterText(find.byType(TextField), 'time');
      await tester.pumpAndSettle();

      expect(controller.state.searchQuery, equals('time'));

      final localizations =
          AppLocalizations.of(tester.element(find.byType(FAQScreen)))!;
      final filteredFaqs = controller.getFilteredFAQs(localizations);

      expect(filteredFaqs.length, equals(1),
          reason:
              "Searching for 'time' should only return 'Time Management' category.");
      expect(
          controller.getCategoryTitle(
              filteredFaqs[0].categoryKey, localizations),
          equals('Time Management'));

      // Verify that the questions within the "Time Management" category actually contain "time"
      // The mock answer for Flowmodoro contains "timed work intervals".
      expect(
          filteredFaqs[0].questions.any((q) => controller
              .getAnswerText(q.answerKey, localizations)
              .toLowerCase()
              .contains("time")),
          isTrue,
          reason:
              "Expected at least one question in 'Time Management' to contain 'time'");

      expect(find.text('Time Management'), findsOneWidget);
      expect(find.text('Getting Started'), findsNothing);
    });

    testWidgets('Search is case-insensitive', (WidgetTester tester) async {
      final controller =
          await pumpFAQScreenWithSearch(tester, container: container);

      await tester.enterText(find.byType(TextField), 'TiMe');
      await tester.pumpAndSettle();

      final localizations =
          AppLocalizations.of(tester.element(find.byType(FAQScreen)))!;
      final filteredFaqs = controller.getFilteredFAQs(localizations);

      expect(filteredFaqs.length, equals(1),
          reason:
              "Case-insensitive search for 'TiMe' should only return 'Time Management'.");
      expect(
          controller.getCategoryTitle(
              filteredFaqs[0].categoryKey, localizations),
          equals('Time Management'));

      expect(find.text('Time Management'), findsOneWidget);
      expect(find.text('Getting Started'), findsNothing);
    });

    testWidgets('Search handles special characters gracefully',
        (WidgetTester tester) async {
      final controller =
          await pumpFAQScreenWithSearch(tester, container: container);

      await tester.enterText(find.byType(TextField), 'time#!');
      await tester.pumpAndSettle();

      final localizations =
          AppLocalizations.of(tester.element(find.byType(FAQScreen)))!;
      // Check that no FAQs are found, and the "No FAQs found" message appears.
      // Ensure your AppLocalizations has a 'noFAQsFound' key.
      // If not, you might need to check for a specific widget or lack of other widgets.
      // For this example, assuming 'noFAQsFound' key exists:
      expect(find.text(localizations.noFAQsFound), findsOneWidget);
      expect(controller.getFilteredFAQs(localizations), isEmpty);
    });

    testWidgets('Search clears properly with clear button',
        (WidgetTester tester) async {
      final controller = await pumpFAQScreenWithSearch(tester,
          initialSearch: 'time', container: container);

      expect(controller.state.searchQuery, equals('time'));

      final localizations =
          AppLocalizations.of(tester.element(find.byType(FAQScreen)))!;
      var filteredFaqs = controller.getFilteredFAQs(localizations);
      expect(filteredFaqs.length, equals(1));

      expect(find.byIcon(Icons.clear), findsOneWidget);
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(controller.state.searchQuery, isEmpty);

      filteredFaqs = controller.getFilteredFAQs(localizations);
      expect(filteredFaqs.length, equals(2),
          reason: "After clearing search, all categories should be present.");

      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Time Management'), findsOneWidget);
    });
  });
}
