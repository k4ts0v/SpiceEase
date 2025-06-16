/// This file tests the localization functionality of the Help and Support screens
/// in the SpiceEase app.
library help_localization_tests;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/settings/troubleshooting_screen.dart';
import 'package:spiceease/features/settings/faq_screen.dart';
import 'package:spiceease/features/settings/help_screen.dart';
import 'package:spiceease/features/settings/tips_screen.dart';
import 'package:spiceease/features/settings/tutorials_screen.dart';
import 'package:spiceease/features/settings/troubleshooting_controller.dart';
import 'package:spiceease/features/settings/faq_controller.dart';
import 'package:spiceease/features/settings/help_controller.dart';
import 'package:spiceease/features/settings/tips_controller.dart';
import 'package:spiceease/features/settings/tutorials_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// --------------------------------------------------------------------------
// Mock Controllers
// --------------------------------------------------------------------------

class MockHelpController extends HelpController {
  MockHelpController() : super();

  @override
  HelpState get state => HelpState(
        isLoading: false,
        sections: [
          HelpSection(
            title: 'Getting Started',
            options: [
              HelpOption(
                icon: Icons.school_outlined,
                titleKey: 'tutorials',
                subtitleKey: 'tutorialsSubtitle',
                onTap: () {},
              ),
              HelpOption(
                icon: Icons.tips_and_updates_outlined,
                titleKey: 'tips',
                subtitleKey: 'tipsSubtitle',
                onTap: () {},
              ),
            ],
          ),
          HelpSection(
            title: 'Support',
            options: [
              HelpOption(
                icon: Icons.help_outline,
                titleKey: 'frequentlyAskedQuestions',
                subtitleKey: 'frequentlyAskedQuestionsSubtitle',
                onTap: () {},
              ),
              HelpOption(
                icon: Icons.build_outlined,
                titleKey: 'troubleshooting',
                subtitleKey: 'troubleshootingSubtitle',
                onTap: () {},
              ),
              HelpOption(
                icon: Icons.support_agent_outlined,
                titleKey: 'contactSupport',
                subtitleKey: 'contactSupportSubtitle',
                onTap: () {},
              ),
            ],
          ),
        ],
      );

  @override
  void setContext(BuildContext context) {
    // Mock implementation - does nothing in tests
  }
}

class MockTroubleshootingController extends TroubleshootingController {
  MockTroubleshootingController() : super();

  @override
  TroubleshootingState get state => const TroubleshootingState(
        isLoading: false,
        issues: [
          TroubleshootingIssue(
            titleKey: 'appCrashesOrFreezes',
            icon: Icons.error_outline,
            descriptionKey: 'appCrashesDescription',
            solutionKeys: [
              'forceCloseRestart',
              'restartDevice',
              'checkStorageSpace'
            ],
          ),
          TroubleshootingIssue(
            titleKey: 'dataSyncIssues',
            icon: Icons.sync_problem,
            descriptionKey: 'dataSyncDescription',
            solutionKeys: ['checkInternetConnection', 'checkCorrectDate'],
          ),
        ],
      );
}

class MockFAQController extends FAQController {
  MockFAQController() : super();

  @override
  FAQState get state => const FAQState(
        categories: [
          FAQCategory(
            categoryKey: 'faqCategoryGettingStarted',
            questions: [
              FAQ(
                  questionKey: 'faqHowCreateFirstTask',
                  answerKey: 'faqHowCreateFirstTaskAnswer'),
              FAQ(
                  questionKey: 'faqDifferenceTasksHabits',
                  answerKey: 'faqDifferenceTasksHabitsAnswer'),
            ],
          ),
          FAQCategory(
            categoryKey: 'faqCategoryTimeManagement',
            questions: [
              FAQ(
                  questionKey: 'faqWhatIsFlowmodoro',
                  answerKey: 'faqWhatIsFlowmodoroAnswer'),
              FAQ(
                  questionKey: 'faqKanbanBoards',
                  answerKey: 'faqKanbanBoardsAnswer'),
            ],
          ),
        ],
      );
}

class MockTipsController extends TipsController {
  MockTipsController() : super();

  @override
  TipsState get state => const TipsState(
        categories: [
          TipCategory(
            category: 'Productivity',
            icon: Icons.trending_up,
            tips: [
              Tip(
                title: 'Use the 2-Minute Rule',
                content:
                    'If a task takes less than 2 minutes, do it immediately instead of adding it to your task list.',
              ),
              Tip(
                title: 'Time Block Your Calendar',
                content:
                    'Assign specific time blocks for different types of tasks. This helps maintain focus and reduces context switching.',
              ),
            ],
          ),
          TipCategory(
            category: 'Habit Building',
            icon: Icons.auto_awesome,
            tips: [
              Tip(
                title: 'Start Small',
                content:
                    'Begin with tiny habits that are almost impossible to fail. Want to exercise daily? Start with just 5 push-ups.',
              ),
            ],
          ),
        ],
      );

  String getScreenTitle(AppLocalizations l10n) {
    return l10n.tips;
  }
}

class MockTutorialsController extends TutorialsController {
  MockTutorialsController() : super();

  @override
  TutorialsState get state => const TutorialsState(
        isLoading: false,
        tutorials: [],
        groupedTutorials: {
          'tutorialCategoryGettingStarted': [
            Tutorial(
              titleKey: 'tutorialUnderstandingIconGrid',
              icon: Icons.grid_view,
              difficultyKey: 'tutorialBeginner',
              durationKey: 'tutorial2Min',
              categoryKey: 'tutorialCategoryGettingStarted',
              stepKeys: [
                'tutorialIconGridStep1',
                'tutorialIconGridStep2',
                'tutorialIconGridStep3'
              ],
            ),
          ],
          'tutorialCategoryTasks': [
            Tutorial(
              titleKey: 'tutorialCreatingFirstTask',
              icon: Icons.task_alt,
              difficultyKey: 'tutorialIntermediate',
              durationKey: 'tutorial3Min',
              categoryKey: 'tutorialCategoryTasks',
              stepKeys: ['tutorialFirstTaskStep1', 'tutorialFirstTaskStep2'],
            ),
          ],
        },
      );
}

// --------------------------------------------------------------------------
// Helper methods to pump the screens for testing
// --------------------------------------------------------------------------

Future<void> pumpHelpScreen(
  WidgetTester tester, {
  required String localeCode,
}) async {
  final controller = MockHelpController();

  await tester.binding.setSurfaceSize(const Size(400, 800));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        helpControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp(
        locale: Locale(localeCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HelpScreen(),
      ),
    ),
  );

  // We need to pump twice to ensure all text is properly rendered
  // First pump loads the widget, second pump completes any pending futures
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> pumpTroubleshootingScreen(
  WidgetTester tester, {
  required String localeCode,
}) async {
  final controller = MockTroubleshootingController();

  await tester.binding.setSurfaceSize(const Size(400, 800));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        troubleshootingControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp(
        locale: Locale(localeCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TroubleshootingScreen(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> pumpFAQScreen(
  WidgetTester tester, {
  required String localeCode,
}) async {
  final controller = MockFAQController();

  await tester.binding.setSurfaceSize(const Size(400, 800));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        faqControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp(
        locale: Locale(localeCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FAQScreen(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> pumpTipsScreen(
  WidgetTester tester, {
  required String localeCode,
}) async {
  final controller = MockTipsController();

  await tester.binding.setSurfaceSize(const Size(400, 800));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tipsControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp(
        locale: Locale(localeCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TipsScreen(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> pumpTutorialsScreen(
  WidgetTester tester, {
  required String localeCode,
}) async {
  final controller = MockTutorialsController();

  await tester.binding.setSurfaceSize(const Size(400, 800));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tutorialsControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp(
        locale: Locale(localeCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TutorialsScreen(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  group('HelpScreen Localization Tests', () {
    testWidgets('Displays correct text in English',
        (WidgetTester tester) async {
      await pumpHelpScreen(tester, localeCode: 'en');

      final context = tester.element(find.byType(HelpScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.help), findsOneWidget);
      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);

      expect(find.text(l10n.tutorials), findsOneWidget);
      expect(find.text(l10n.tutorialsSubtitle), findsOneWidget);

      expect(find.text(l10n.tips), findsOneWidget);
      expect(find.text(l10n.tipsSubtitle), findsOneWidget);

      expect(find.text(l10n.frequentlyAskedQuestions), findsOneWidget);
      expect(find.text(l10n.frequentlyAskedQuestionsSubtitle), findsOneWidget);

      expect(find.text(l10n.troubleshooting), findsOneWidget);
      expect(find.text(l10n.troubleshootingSubtitle), findsOneWidget);

      expect(find.text(l10n.contactSupport), findsOneWidget);
      expect(find.text(l10n.contactSupportSubtitle), findsOneWidget);
    });

    testWidgets('Displays correct text in Spanish',
        (WidgetTester tester) async {
      await pumpHelpScreen(tester, localeCode: 'es');

      final context = tester.element(find.byType(HelpScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.help), findsOneWidget);
      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);

      expect(find.text(l10n.tutorials), findsOneWidget);
      expect(find.text(l10n.tutorialsSubtitle), findsOneWidget);

      expect(find.text(l10n.tips), findsOneWidget);
      expect(find.text(l10n.tipsSubtitle), findsOneWidget);

      expect(find.text(l10n.frequentlyAskedQuestions), findsOneWidget);
      expect(find.text(l10n.frequentlyAskedQuestionsSubtitle), findsOneWidget);

      expect(find.text(l10n.troubleshooting), findsOneWidget);
      expect(find.text(l10n.troubleshootingSubtitle), findsOneWidget);

      expect(find.text(l10n.contactSupport), findsOneWidget);
      expect(find.text(l10n.contactSupportSubtitle), findsOneWidget);
    });

    testWidgets('Updates text when locale changes',
        (WidgetTester tester) async {
      // Start with English
      await pumpHelpScreen(tester, localeCode: 'en');

      final englishContext = tester.element(find.byType(HelpScreen));
      final englishL10n = AppLocalizations.of(englishContext)!;

      expect(find.text(englishL10n.help), findsOneWidget);
      expect(find.text(englishL10n.tutorials), findsOneWidget);

      // Switch to Spanish
      await pumpHelpScreen(tester, localeCode: 'es');

      final spanishContext = tester.element(find.byType(HelpScreen));
      final spanishL10n = AppLocalizations.of(spanishContext)!;

      expect(find.text(spanishL10n.help), findsOneWidget);
      expect(find.text(spanishL10n.tutorials), findsOneWidget);
      expect(find.text(englishL10n.help), findsNothing);

      // Back to English
      await pumpHelpScreen(tester, localeCode: 'en');

      final newEnglishContext = tester.element(find.byType(HelpScreen));
      final newEnglishL10n = AppLocalizations.of(newEnglishContext)!;

      expect(find.text(newEnglishL10n.help), findsOneWidget);
      expect(find.text(newEnglishL10n.tutorials), findsOneWidget);
      expect(find.text(spanishL10n.help), findsNothing);
    });
  });

  group('TroubleshootingScreen Localization Tests', () {
    testWidgets('Displays correct text in English',
        (WidgetTester tester) async {
      await pumpTroubleshootingScreen(tester, localeCode: 'en');

      final context = tester.element(find.byType(TroubleshootingScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.troubleshooting), findsOneWidget);

      // Tap to expand first issue
      await tester.tap(find.text(l10n.appCrashesOrFreezes));
      await tester.pumpAndSettle();

      expect(find.text(l10n.tryTheseSolutions), findsOneWidget);
      expect(find.text(l10n.forceCloseRestart), findsOneWidget);
      expect(find.text(l10n.restartDevice), findsOneWidget);
      expect(find.text(l10n.stillHavingIssues), findsOneWidget);
    });

    testWidgets('Displays correct text in Spanish',
        (WidgetTester tester) async {
      await pumpTroubleshootingScreen(tester, localeCode: 'es');

      final context = tester.element(find.byType(TroubleshootingScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.troubleshooting), findsOneWidget);

      // Tap to expand first issue
      await tester.tap(find.text(l10n.appCrashesOrFreezes));
      await tester.pumpAndSettle();

      expect(find.text(l10n.tryTheseSolutions), findsOneWidget);
      expect(find.text(l10n.forceCloseRestart), findsOneWidget);
      expect(find.text(l10n.restartDevice), findsOneWidget);
      expect(find.text(l10n.stillHavingIssues), findsOneWidget);
    });

    testWidgets('Updates text when locale changes',
        (WidgetTester tester) async {
      // Start with English
      await pumpTroubleshootingScreen(tester, localeCode: 'en');

      final englishContext = tester.element(find.byType(TroubleshootingScreen));
      final englishL10n = AppLocalizations.of(englishContext)!;

      expect(find.text(englishL10n.troubleshooting), findsOneWidget);
      expect(find.text(englishL10n.appCrashesOrFreezes), findsOneWidget);

      // Switch to Spanish
      await pumpTroubleshootingScreen(tester, localeCode: 'es');

      final spanishContext = tester.element(find.byType(TroubleshootingScreen));
      final spanishL10n = AppLocalizations.of(spanishContext)!;

      expect(find.text(spanishL10n.troubleshooting), findsOneWidget);
      expect(find.text(spanishL10n.appCrashesOrFreezes), findsOneWidget);
      expect(find.text(englishL10n.troubleshooting), findsNothing);

      // Back to English
      await pumpTroubleshootingScreen(tester, localeCode: 'en');

      final newEnglishContext =
          tester.element(find.byType(TroubleshootingScreen));
      final newEnglishL10n = AppLocalizations.of(newEnglishContext)!;

      expect(find.text(newEnglishL10n.troubleshooting), findsOneWidget);
      expect(find.text(newEnglishL10n.appCrashesOrFreezes), findsOneWidget);
      expect(find.text(spanishL10n.troubleshooting), findsNothing);
    });
  });

  group('FAQ Screen Localization Tests', () {
    testWidgets('Displays correct text in English',
        (WidgetTester tester) async {
      await pumpFAQScreen(tester, localeCode: 'en');

      final context = tester.element(find.byType(FAQScreen));
      final l10n = AppLocalizations.of(context)!;
      final controller = tester.state<ConsumerState>(find.byType(FAQScreen));
      final faqController = controller.ref.read(faqControllerProvider.notifier);

      expect(find.text(l10n.frequentlyAskedQuestions), findsOneWidget);
      expect(find.widgetWithText(TextField, l10n.searchFAQs), findsOneWidget);

      expect(
          find.text(faqController.getCategoryTitle(
              'faqCategoryGettingStarted', l10n)),
          findsOneWidget);
      expect(
          find.text(faqController.getCategoryTitle(
              'faqCategoryTimeManagement', l10n)),
          findsOneWidget);

      // Expand first category
      await tester.tap(find.text(
          faqController.getCategoryTitle('faqCategoryGettingStarted', l10n)));
      await tester.pumpAndSettle();

      expect(
          find.text(
              faqController.getQuestionText('faqHowCreateFirstTask', l10n)),
          findsOneWidget);
    });

    testWidgets('Displays correct text in Spanish',
        (WidgetTester tester) async {
      await pumpFAQScreen(tester, localeCode: 'es');

      final context = tester.element(find.byType(FAQScreen));
      final l10n = AppLocalizations.of(context)!;
      final controller = tester.state<ConsumerState>(find.byType(FAQScreen));
      final faqController = controller.ref.read(faqControllerProvider.notifier);

      expect(find.text(l10n.frequentlyAskedQuestions), findsOneWidget);
      expect(find.widgetWithText(TextField, l10n.searchFAQs), findsOneWidget);

      expect(
          find.text(faqController.getCategoryTitle(
              'faqCategoryGettingStarted', l10n)),
          findsOneWidget);
      expect(
          find.text(faqController.getCategoryTitle(
              'faqCategoryTimeManagement', l10n)),
          findsOneWidget);
    });
  });

  group('Tips Screen Localization Tests', () {
    testWidgets('Displays correct text in English',
        (WidgetTester tester) async {
      await pumpTipsScreen(tester, localeCode: 'en');

      final context = tester.element(find.byType(TipsScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.tips), findsOneWidget);
      expect(find.text('Productivity'), findsOneWidget);
      expect(find.text('Habit Building'), findsOneWidget);
    });

    testWidgets('Displays correct text in Spanish',
        (WidgetTester tester) async {
      await pumpTipsScreen(tester, localeCode: 'es');

      final context = tester.element(find.byType(TipsScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.tips), findsOneWidget);
      expect(find.text('Productivity'),
          findsOneWidget); // Category names aren't translated
      expect(find.text('Habit Building'), findsOneWidget);
    });
  });

  group('Tutorials Screen Localization Tests', () {
    testWidgets('Displays correct text in English',
        (WidgetTester tester) async {
      await pumpTutorialsScreen(tester, localeCode: 'en');

      final context = tester.element(find.byType(TutorialsScreen));
      final l10n = AppLocalizations.of(context)!;
      tester.widget<ConsumerWidget>(find.byType(TutorialsScreen));
      final ref = ProviderScope.containerOf(context);
      final tutorialsController =
          ref.read(tutorialsControllerProvider.notifier);

      expect(find.text(l10n.tutorials), findsOneWidget);

      expect(
          find.text(tutorialsController.getCategoryTitle(
              'tutorialCategoryGettingStarted', l10n)),
          findsOneWidget);
      expect(
          find.text(tutorialsController.getCategoryTitle(
              'tutorialCategoryTasks', l10n)),
          findsOneWidget);

      expect(
          find.text(tutorialsController.getTutorialTitle(
              'tutorialUnderstandingIconGrid', l10n)),
          findsOneWidget);
      expect(
          find.text(tutorialsController.getTutorialTitle(
              'tutorialCreatingFirstTask', l10n)),
          findsOneWidget);
    });

    testWidgets('Displays correct text in Spanish',
        (WidgetTester tester) async {
      await pumpTutorialsScreen(tester, localeCode: 'es');

      final context = tester.element(find.byType(TutorialsScreen));
      final l10n = AppLocalizations.of(context)!;
      final ref = ProviderScope.containerOf(context);
      final tutorialsController =
          ref.read(tutorialsControllerProvider.notifier);

      expect(find.text(l10n.tutorials), findsOneWidget);

      expect(
          find.text(tutorialsController.getCategoryTitle(
              'tutorialCategoryGettingStarted', l10n)),
          findsOneWidget);
      expect(
          find.text(tutorialsController.getCategoryTitle(
              'tutorialCategoryTasks', l10n)),
          findsOneWidget);

      expect(
          find.text(tutorialsController.getTutorialTitle(
              'tutorialUnderstandingIconGrid', l10n)),
          findsOneWidget);
      expect(
          find.text(tutorialsController.getTutorialTitle(
              'tutorialCreatingFirstTask', l10n)),
          findsOneWidget);
    });

    testWidgets('Updates text when locale changes',
        (WidgetTester tester) async {
      // Start with English
      await pumpTutorialsScreen(tester, localeCode: 'en');

      final englishContext = tester.element(find.byType(TutorialsScreen));
      final englishL10n = AppLocalizations.of(englishContext)!;
      final englishRef = ProviderScope.containerOf(englishContext);
      final englishController =
          englishRef.read(tutorialsControllerProvider.notifier);

      final englishTitle = englishL10n.tutorials;
      final englishTutorialTitle = englishController.getTutorialTitle(
          'tutorialUnderstandingIconGrid', englishL10n);

      expect(find.text(englishTitle), findsOneWidget);
      expect(find.text(englishTutorialTitle), findsOneWidget);

      // Switch to Spanish
      await pumpTutorialsScreen(tester, localeCode: 'es');

      final spanishContext = tester.element(find.byType(TutorialsScreen));
      final spanishL10n = AppLocalizations.of(spanishContext)!;
      final spanishRef = ProviderScope.containerOf(spanishContext);
      final spanishController =
          spanishRef.read(tutorialsControllerProvider.notifier);

      final spanishTitle = spanishL10n.tutorials;
      final spanishTutorialTitle = spanishController.getTutorialTitle(
          'tutorialUnderstandingIconGrid', spanishL10n);

      expect(find.text(spanishTitle), findsOneWidget);
      expect(find.text(spanishTutorialTitle), findsOneWidget);
      expect(find.text(englishTitle), findsNothing);

      // Back to English
      await pumpTutorialsScreen(tester, localeCode: 'en');

      expect(find.text(englishTitle), findsOneWidget);
      expect(find.text(englishTutorialTitle), findsOneWidget);
      expect(find.text(spanishTitle), findsNothing);
    });
  });
}
