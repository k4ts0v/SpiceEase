/// This file tests the localization functionality of the TimeManagementPage widget.
    ///
    /// # Testing Strategy
    ///
    /// This test suite validates three main scenarios:
    ///
    /// 1. **Static English localization tests**
    ///    - Verifies that all UI elements display correct English text when the app locale is set to English.
    ///    - Tests titles, descriptions, and common texts for all time management features.
    ///    - Uses scrollUntilVisible to handle scrollable content.
    ///
    /// 2. **Static Spanish localization tests**
    ///    - Verifies that all UI elements display correct Spanish text when the app locale is set to Spanish.
    ///    - Ensures translations are properly loaded and displayed for all features.
    ///    - Validates the same content as English tests but in Spanish locale.
    ///
    /// 3. **Dynamic locale change tests**
    ///    - Tests the behavior when the locale is changed dynamically from English to Spanish.
    ///    - Verifies that the widget tree correctly updates all localizable strings.
    ///    - Ensures the page structure remains intact after locale changes.
    ///    - Uses ensureVisible for more reliable widget visibility in dynamic scenarios.
    ///
    /// # Features Tested
    ///
    /// The tests cover localization for these time management features:
    /// - Flowmodoro: A productivity technique with flexible break times
    /// - Kanban: Task organization using boards and cards
    /// - Time Blocks: Scheduled time allocation for tasks
    /// - Speedrun: Gamified productivity challenges
    /// - Dice Roller: Random task selection tool
    ///
    /// Each feature is tested for both title and description text localization.
    ///
    /// # Technical Approach
    ///
    /// - Uses ProviderScope to provide Riverpod context for the widget
    /// - Wraps the TimeManagementPage in a MaterialApp with locale configuration
    /// - Employs scrollUntilVisible and ensureVisible for handling scrollable content
    /// - Uses AppLocalizations to access localized strings dynamically
    /// - Tests both on-screen and off-screen widget detection with skipOffstage parameter
    ///
    /// # Test Structure
    ///
    /// Each test follows the Arrange-Act-Assert pattern:
    /// - **Arrange**: Set up the widget with appropriate locale and get localization strings
    /// - **Act**: Pump the widget and perform scrolling/visibility actions
    /// - **Assert**: Verify that the expected localized text is displayed
    ///
    /// # How to run
    /// - Run with `flutter test` as usual
    /// - Requires AppLocalizations to be properly configured
    /// - No external dependencies beyond Flutter's localization system
    ///
    /// # See also
    /// - https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
    /// - https://pub.dev/packages/flutter_localizations

    import 'package:flutter/material.dart';
    import 'package:flutter_test/flutter_test.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:spiceease/features/time_management/time_management.dart';
    import 'package:spiceease/components/app_header.dart'; // For AppHeader
    import 'package:spiceease/l10n/app_localizations.dart';

    void main() {
      /// Helper function to pump the TimeManagementPage widget with a specific locale.
      ///
      /// This creates a complete widget tree with:
      /// - ProviderScope for Riverpod state management
      /// - MaterialApp with locale configuration
      /// - Proper localization delegates and supported locales
      /// - Fixed size container for consistent testing
      Future<void> pumpTimeManagementPage(
          WidgetTester tester, String localeCode) async {
        await tester.pumpWidget(
          SizedBox(
            width: 800,
            height: 1600, // Generous height to accommodate scrollable content
            child: ProviderScope(
              child: MaterialApp(
                locale: Locale(localeCode),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const TimeManagementPage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      /// Helper function to find the main scrollable component of the ListView.
      ///
      /// This assumes there is one primary ListView on the TimeManagementPage
      /// and returns a finder for its Scrollable descendant, which is needed
      /// for scrollUntilVisible operations.
      Finder findMainListScrollable() => find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable));

      group('TimeManagementPage Localization Tests', () {
        /// Verifies that all UI elements display correct English text.
        ///
        /// This test validates the static English localization by:
        /// 1. Setting up the widget with English locale
        /// 2. Sequentially scrolling to each time management feature
        /// 3. Verifying both titles and descriptions are in English
        /// 4. Checking common UI elements like "Coming Soon" text and AppHeader
        testWidgets('Displays English titles, descriptions, and other texts',
            (WidgetTester tester) async {
          // Arrange: Pump the page with English locale and get localization strings.
          await pumpTimeManagementPage(tester, 'en');
          final l10n =
              AppLocalizations.of(tester.element(find.byType(TimeManagementPage)))!;
          final mainListScrollable = findMainListScrollable();

          // Act & Assert: Sequentially scroll to and verify each item's English text.

          // --- Flowmodoro ---
          // Act: Scroll to make Flowmodoro title visible.
          await tester.scrollUntilVisible(find.text(l10n.flowmodoro), 500.0,
              scrollable: mainListScrollable);
          // Assert: Verify English Flowmodoro title is displayed.
          expect(find.text(l10n.flowmodoro), findsOneWidget,
              reason: "English Flowmodoro title");
          // Act: Scroll to make Flowmodoro description visible.
          await tester.scrollUntilVisible(
              find.textContaining(l10n.flowmodoroDescription), 200.0,
              scrollable: mainListScrollable);
          // Assert: Verify English Flowmodoro description is displayed.
          expect(find.textContaining(l10n.flowmodoroDescription), findsOneWidget,
              reason: "English Flowmodoro description");

          // --- Kanban ---
          // Act: Scroll to make Kanban title visible.
          await tester.scrollUntilVisible(find.text(l10n.kanban), 500.0,
              scrollable: mainListScrollable);
          // Assert: Verify English Kanban title is displayed.
          expect(find.text(l10n.kanban), findsOneWidget,
              reason: "English Kanban title");
          // Act: Scroll to make Kanban description visible.
          await tester.scrollUntilVisible(
              find.textContaining(l10n.kanbanDescription), 200.0,
              scrollable: mainListScrollable);
          // Assert: Verify English Kanban description is displayed.
          expect(find.textContaining(l10n.kanbanDescription), findsOneWidget,
              reason: "English Kanban description");

          // --- Time Blocks ---
          // Act: Scroll to make Time Blocks title visible.
          await tester.scrollUntilVisible(find.text(l10n.timeBlocks), 500.0,
              scrollable: mainListScrollable);
          // Assert: Verify English Time Blocks title is displayed.
          expect(find.text(l10n.timeBlocks), findsOneWidget,
              reason: "English Time Blocks title");
          // Act: Scroll to make Time Blocks description visible.
          await tester.scrollUntilVisible(
              find.textContaining(l10n.timeBlocksDescription), 200.0,
              scrollable: mainListScrollable);
          // Assert: Verify English Time Blocks description is displayed.
          expect(find.textContaining(l10n.timeBlocksDescription), findsOneWidget,
              reason: "English Time Blocks description");

          // --- Speedrun ---
          // Act: Scroll to make Speedrun title visible.
          await tester.scrollUntilVisible(find.text(l10n.speedrun), 500.0,
              scrollable: mainListScrollable);
          // Assert: Verify English Speedrun title is displayed.
          expect(find.text(l10n.speedrun), findsOneWidget,
              reason: "English Speedrun title");
          // Act: Scroll to make Speedrun description visible.
          await tester.scrollUntilVisible(
              find.textContaining(l10n.speedrunDescription), 200.0,
              scrollable: mainListScrollable);
          // Assert: Verify English Speedrun description is displayed.
          expect(find.textContaining(l10n.speedrunDescription), findsOneWidget,
              reason: "English Speedrun description");

          // --- Dice Roller ---
          // Act: Scroll to make Dice Roller title visible.
          await tester.scrollUntilVisible(find.text(l10n.diceRoller), 500.0,
              scrollable: mainListScrollable);
          // Assert: Verify English Dice Roller title is displayed.
          expect(find.text(l10n.diceRoller), findsOneWidget,
              reason: "English Dice Roller title");
          // Act: Scroll to make Dice Roller description visible.
          await tester.scrollUntilVisible(
              find.textContaining(l10n.diceRollerDescription), 200.0,
              scrollable: mainListScrollable);
          // Assert: Verify English Dice Roller description is displayed.
          expect(find.textContaining(l10n.diceRollerDescription), findsOneWidget,
              reason: "English Dice Roller description");

          // Assert: Verify common English UI elements.
          expect(find.text(l10n.comingSoon), findsNWidgets(2),
              reason: "English 'Coming Soon' text count");
          expect(find.byType(AppHeader), findsOneWidget,
              reason: "AppHeader presence");
        });

        /// Verifies that all UI elements display correct Spanish text.
        ///
        /// This test validates the static Spanish localization by:
        /// 1. Setting up the widget with Spanish locale
        /// 2. Sequentially scrolling to each time management feature
        /// 3. Verifying both titles and descriptions are in Spanish
        /// 4. Checking common UI elements are properly translated
        testWidgets('Displays Spanish titles, descriptions, and other texts',
            (WidgetTester tester) async {
          // Arrange: Pump the page with Spanish locale and get localization strings.
          await pumpTimeManagementPage(tester, 'es');
          final l10n =
              AppLocalizations.of(tester.element(find.byType(TimeManagementPage)))!;
          final mainListScrollable = findMainListScrollable();

          // Act & Assert: Sequentially scroll to and verify each item's Spanish text.

          // --- Flowmodoro ---
          // Act: Scroll to make Flowmodoro title visible.
          await tester.scrollUntilVisible(find.text(l10n.flowmodoro), 500.0,
              scrollable: mainListScrollable);
          // Assert: Verify Spanish Flowmodoro title is displayed.
          expect(find.text(l10n.flowmodoro), findsOneWidget,
              reason: "Spanish Flowmodoro title");
          // Act: Scroll to make Flowmodoro description visible.
          await tester.scrollUntilVisible(
              find.textContaining(l10n.flowmodoroDescription), 200.0,
              scrollable: mainListScrollable);
          // Assert: Verify Spanish Flowmodoro description is displayed.
          expect(find.textContaining(l10n.flowmodoroDescription), findsOneWidget,
              reason: "Spanish Flowmodoro description");

          // --- Kanban ---
          // Act: Scroll to make Kanban title visible.
          await tester.scrollUntilVisible(find.text(l10n.kanban), 500.0,
              scrollable: mainListScrollable);
          // Assert: Verify Spanish Kanban title is displayed.
          expect(find.text(l10n.kanban), findsOneWidget,
              reason: "Spanish Kanban title");
          // Act: Scroll to make Kanban description visible.
          await tester.scrollUntilVisible(
              find.textContaining(l10n.kanbanDescription), 200.0,
              scrollable: mainListScrollable);
          // Assert: Verify Spanish Kanban description is displayed.
          expect(find.textContaining(l10n.kanbanDescription), findsOneWidget,
              reason: "Spanish Kanban description");

          // --- Time Blocks ---
          // Act: Scroll to make Time Blocks title visible.
          await tester.scrollUntilVisible(find.text(l10n.timeBlocks), 500.0,
              scrollable: mainListScrollable);
          // Assert: Verify Spanish Time Blocks title is displayed.
          expect(find.text(l10n.timeBlocks), findsOneWidget,
              reason: "Spanish Time Blocks title");
          // Act: Scroll to make Time Blocks description visible.
          await tester.scrollUntilVisible(
              find.textContaining(l10n.timeBlocksDescription), 200.0,
              scrollable: mainListScrollable);
          // Assert: Verify Spanish Time Blocks description is displayed.
          expect(find.textContaining(l10n.timeBlocksDescription), findsOneWidget,
              reason: "Spanish Time Blocks description");

          // --- Speedrun ---
          // Act: Scroll to make Speedrun title visible.
          await tester.scrollUntilVisible(find.text(l10n.speedrun), 500.0,
              scrollable: mainListScrollable);
          // Assert: Verify Spanish Speedrun title is displayed.
          expect(find.text(l10n.speedrun), findsOneWidget,
              reason: "Spanish Speedrun title");
          // Act: Scroll to make Speedrun description visible.
          await tester.scrollUntilVisible(
              find.textContaining(l10n.speedrunDescription), 200.0,
              scrollable: mainListScrollable);
          // Assert: Verify Spanish Speedrun description is displayed.
          expect(find.textContaining(l10n.speedrunDescription), findsOneWidget,
              reason: "Spanish Speedrun description");

          // --- Dice Roller ---
          // Act: Scroll to make Dice Roller title visible.
          await tester.scrollUntilVisible(find.text(l10n.diceRoller), 500.0,
              scrollable: mainListScrollable);
          // Assert: Verify Spanish Dice Roller title is displayed.
          expect(find.text(l10n.diceRoller), findsOneWidget,
              reason: "Spanish Dice Roller title");
          // Act: Scroll to make Dice Roller description visible.
          await tester.scrollUntilVisible(
              find.textContaining(l10n.diceRollerDescription), 200.0,
              scrollable: mainListScrollable);
          // Assert: Verify Spanish Dice Roller description is displayed.
          expect(find.textContaining(l10n.diceRollerDescription), findsOneWidget,
              reason: "Spanish Dice Roller description");

          // Assert: Verify common Spanish UI elements.
          expect(find.text(l10n.comingSoon), findsNWidgets(2),
              reason: "Spanish 'Coming Soon' text count");
          expect(find.byType(AppHeader), findsOneWidget,
              reason: "AppHeader presence");
        });

        /// Verifies that the UI correctly updates all localizable strings
        /// when the locale is changed dynamically from English to Spanish.
        ///
        /// This test ensures that:
        /// 1. Initial English texts are displayed correctly
        /// 2. After changing locale to Spanish and re-pumping the widget:
        ///    a. The page structure (ListView, Scrollable) remains intact
        ///    b. All relevant titles and descriptions for Flowmodoro, Kanban,
        ///       Time Blocks, Speedrun, and Dice Roller are updated to Spanish
        ///    c. Common texts like "Coming Soon" and the AppHeader also reflect Spanish
        ///
        /// It uses `ensureVisible` to bring items into view before checking them,
        /// which is more reliable than `scrollUntilVisible` in dynamic locale scenarios.
        testWidgets('Updates when locale changes from English to Spanish',
            (WidgetTester tester) async {
          // --- Initial English Setup ---
          // Arrange: Pump the page with English locale and get localization strings.
          await pumpTimeManagementPage(tester, 'en');
          AppLocalizations l10nEn =
              AppLocalizations.of(tester.element(find.byType(TimeManagementPage)))!;
          final mainListScrollableEn = findMainListScrollable();

          // Act & Assert: Verify some initial English texts are present.
          // Scroll to Flowmodoro and check its title.
          await tester.scrollUntilVisible(find.text(l10nEn.flowmodoro), 500.0,
              scrollable: mainListScrollableEn);
          expect(find.text(l10nEn.flowmodoro), findsOneWidget,
              reason: "English Flowmodoro title should be present initially");

          // Scroll to Speedrun and check its title.
          await tester.scrollUntilVisible(find.text(l10nEn.speedrun), 500.0,
              scrollable: mainListScrollableEn);
          expect(find.text(l10nEn.speedrun), findsOneWidget,
              reason: "English Speedrun title should be present initially");

          // Scroll to Dice Roller and check its title.
          await tester.scrollUntilVisible(find.text(l10nEn.diceRoller), 500.0,
              scrollable: mainListScrollableEn);
          expect(find.text(l10nEn.diceRoller), findsOneWidget,
              reason: "English Dice Roller title should be present initially");

          // Assert: Check "Coming Soon" text count.
          expect(find.text(l10nEn.comingSoon), findsNWidgets(2),
              reason:
                  "English 'Coming Soon' should be present initially (2 instances)");

          // --- Change Locale to Spanish ---
          // Arrange: Pump the page again, this time with Spanish locale.
          // This simulates a dynamic locale change in the app.
          await pumpTimeManagementPage(tester, 'es');
          AppLocalizations l10nEs =
              AppLocalizations.of(tester.element(find.byType(TimeManagementPage)))!;

          // Assert: Verify basic page structure (ListView, Scrollable) is still present.
          expect(find.byType(ListView), findsOneWidget,
              reason: "ListView should be present after locale change to Spanish");
          expect(findMainListScrollable(), findsOneWidget,
              reason:
                  "Scrollable for ListView should be present after locale change to Spanish");

          // --- Verify Spanish Texts After Locale Change ---
          // Act & Assert: Sequentially ensure visibility and verify each item's Spanish text.

          // --- Flowmodoro (Spanish) ---
          // Arrange: Define finders for Flowmodoro title and description (allowing them to be offstage initially).
          final flowmodoroTitleFinderEs =
              find.text(l10nEs.flowmodoro, skipOffstage: false);
          final flowmodoroDescFinderEs = find
              .textContaining(l10nEs.flowmodoroDescription, skipOffstage: false);
          // Act: Ensure title is visible and pump.
          await tester.ensureVisible(flowmodoroTitleFinderEs);
          await tester.pumpAndSettle();
          // Assert: Verify title is now found (on-screen).
          expect(find.text(l10nEs.flowmodoro), findsOneWidget,
              reason: "Spanish Flowmodoro title after ensureVisible");
          // Act: Ensure description is visible and pump.
          await tester.ensureVisible(flowmodoroDescFinderEs);
          await tester.pumpAndSettle();
          // Assert: Verify description is now found (on-screen).
          expect(find.textContaining(l10nEs.flowmodoroDescription), findsOneWidget,
              reason: "Spanish Flowmodoro description after ensureVisible");
          await tester.pumpAndSettle(); // Extra settle for stability

          // --- Kanban (Spanish) ---
          // Arrange: Define finders for Kanban title and description.
          final kanbanTitleFinderEs = find.text(l10nEs.kanban, skipOffstage: false);
          final kanbanDescFinderEs =
              find.textContaining(l10nEs.kanbanDescription, skipOffstage: false);
          // Assert: Check if title exists in the tree (even if offstage).
          expect(kanbanTitleFinderEs, findsOneWidget,
              reason:
                  "Spanish Kanban title should exist in tree (skipOffstage: false)");
          // Act: Ensure title is visible.
          await tester.ensureVisible(kanbanTitleFinderEs);
          await tester.pumpAndSettle();
          // Assert: Verify title is on-screen.
          expect(find.text(l10nEs.kanban), findsOneWidget,
              reason: "Spanish Kanban title after ensureVisible");
          // Assert: Check if description exists in the tree.
          expect(kanbanDescFinderEs, findsOneWidget,
              reason:
                  "Spanish Kanban description should exist in tree (skipOffstage: false)");
          // Act: Ensure description is visible.
          await tester.ensureVisible(kanbanDescFinderEs);
          await tester.pumpAndSettle();
          // Assert: Verify description is on-screen.
          expect(find.textContaining(l10nEs.kanbanDescription), findsOneWidget,
              reason: "Spanish Kanban description after ensureVisible");
          await tester.pumpAndSettle();

          // --- Time Blocks (Spanish) ---
          // Arrange: Define finders for Time Blocks title and description.
          final timeBlocksTitleFinderEs =
              find.text(l10nEs.timeBlocks, skipOffstage: false);
          final timeBlocksDescFinderEs = find
              .textContaining(l10nEs.timeBlocksDescription, skipOffstage: false);
          // Assert: Check if title exists in the tree.
          expect(timeBlocksTitleFinderEs, findsOneWidget,
              reason:
                  "Spanish Time Blocks title should exist in tree (skipOffstage: false)");
          // Act: Ensure title is visible.
          await tester.ensureVisible(timeBlocksTitleFinderEs);
          await tester.pumpAndSettle();
          // Assert: Verify title is on-screen.
          expect(find.text(l10nEs.timeBlocks), findsOneWidget,
              reason: "Spanish Time Blocks title after ensureVisible");
          // Assert: Check if description exists in the tree.
          expect(timeBlocksDescFinderEs, findsOneWidget,
              reason:
                  "Spanish Time Blocks description should exist in tree (skipOffstage: false)");
          // Act: Ensure description is visible.
          await tester.ensureVisible(timeBlocksDescFinderEs);
          await tester.pumpAndSettle();
          // Assert: Verify description is on-screen.
          expect(find.textContaining(l10nEs.timeBlocksDescription), findsOneWidget,
              reason: "Spanish Time Blocks description after ensureVisible");
          await tester.pumpAndSettle();

          // --- Speedrun (Spanish) ---
          // Arrange: Define finders for Speedrun title and description.
          final speedrunTitleFinderEs =
              find.text(l10nEs.speedrun, skipOffstage: false);
          final speedrunDescFinderEs =
              find.textContaining(l10nEs.speedrunDescription, skipOffstage: false);
          // Assert: Check if title exists in the tree.
          expect(speedrunTitleFinderEs, findsOneWidget,
              reason:
                  "Spanish Speedrun title should exist in tree (skipOffstage: false)");
          // Act: Ensure title is visible.
          await tester.ensureVisible(speedrunTitleFinderEs);
          await tester.pumpAndSettle();
          // Assert: Verify title is on-screen.
          expect(find.text(l10nEs.speedrun), findsOneWidget,
              reason: "Spanish Speedrun title after ensureVisible");
          // Assert: Check if description exists in the tree.
          expect(speedrunDescFinderEs, findsOneWidget,
              reason:
                  "Spanish Speedrun description should exist in tree (skipOffstage: false)");
          // Act: Ensure description is visible.
          await tester.ensureVisible(speedrunDescFinderEs);
          await tester.pumpAndSettle();
          // Assert: Verify description is on-screen.
          expect(find.textContaining(l10nEs.speedrunDescription), findsOneWidget,
              reason: "Spanish Speedrun description after ensureVisible");
          await tester.pumpAndSettle();

          // --- Dice Roller (Spanish) ---
          // Arrange: Define finders for Dice Roller title and description.
          final diceRollerTitleFinderEs =
              find.text(l10nEs.diceRoller, skipOffstage: false);
          final diceRollerDescFinderEs = find
              .textContaining(l10nEs.diceRollerDescription, skipOffstage: false);
          // Assert: Check if title exists in the tree.
          expect(diceRollerTitleFinderEs, findsOneWidget,
              reason:
                  "Spanish Dice Roller title should exist in tree (skipOffstage: false)");
          // Act: Ensure title is visible.
          await tester.ensureVisible(diceRollerTitleFinderEs);
          await tester.pumpAndSettle();
          // Assert: Verify title is on-screen.
          expect(find.text(l10nEs.diceRoller), findsOneWidget,
              reason: "Spanish Dice Roller title after ensureVisible");
          // Assert: Check if description exists in the tree.
          expect(diceRollerDescFinderEs, findsOneWidget,
              reason:
                  "Spanish Dice Roller description should exist in tree (skipOffstage: false)");
          // Act: Ensure description is visible.
          await tester.ensureVisible(diceRollerDescFinderEs);
          await tester.pumpAndSettle();
          // Assert: Verify description is on-screen.
          expect(find.textContaining(l10nEs.diceRollerDescription), findsOneWidget,
              reason: "Spanish Dice Roller description after ensureVisible");
          await tester.pumpAndSettle();

          // Assert: Verify common texts like "Coming Soon" and AppHeader in Spanish.
          expect(find.text(l10nEs.comingSoon), findsNWidgets(2),
              reason:
                  "Spanish 'Coming Soon' should be present after locale change (2 instances)");
          expect(find.byType(AppHeader), findsOneWidget,
              reason: "AppHeader presence after locale change");
        });
      });
    }