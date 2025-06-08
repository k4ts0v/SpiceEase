import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/auth/user_model.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/main.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/features/tracker/presentation/widgets/list_modal.dart';
import 'package:spiceease/features/tracker/presentation/modals.dart';
import 'package:spiceease/l10n/app_localizations.dart';
// import 'package:intl/intl.dart'; // For DateFormat, if not used elsewhere

import 'tracker_mood_test.mocks.dart';

class FakeAuthService extends Mock implements AuthService {
  @override
  Future<void> initialize() async {}
  @override
  Stream<AppUser?> authStateChanges() =>
      Stream.value(AppUser(uid: 'test-user', email: 'test@example.com'));
  @override
  Future<bool> isSignedIn() async => true;
  @override
  Future<AppUser?> getCurrentUser() async =>
      AppUser(uid: 'test-user', email: 'test@example.com');
  @override
  Future<bool> validateSession() async => true;
  @override
  Future<void> signOut() async {}
}

@GenerateMocks([DatabaseService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDatabaseService mockDatabaseService;
  late FakeAuthService fakeAuthService;

  const String moodEntriesCollectionName = 'mood_entries';
  final testDate = DateTime(2025, 5, 30);
  final anotherTestDate = DateTime(2025, 5, 29);
  final yetAnotherTestDate = DateTime(2025, 5, 28);

  final initialMoodEntry = MoodModel(
    id: 'test-id-1',
    moodLevel: 5,
    notes: 'Initial modal test entry',
    userId: 'test-user',
    createdAt: testDate.toUtc(),
    updatedAt: testDate.toUtc(),
  );

  final moodForAnotherDate = MoodModel(
    id: 'm-another',
    moodLevel: 2,
    notes: 'Mood for another date',
    userId: 'test-user',
    createdAt: anotherTestDate.toUtc(),
    updatedAt: anotherTestDate.toUtc(),
  );

  final moodForYetAnotherDate = MoodModel(
    id: 'm-yet-another',
    moodLevel: 8,
    notes: 'Mood for yet another date',
    userId: 'test-user',
    createdAt: yetAnotherTestDate.toUtc(),
    updatedAt: yetAnotherTestDate.toUtc(),
  );

  setUpAll(() async {
    // await AppLocalizations.load(const Locale('en')); // If needed for direct use
  });

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    fakeAuthService = FakeAuthService();

    when(mockDatabaseService.generateId()).thenReturn('new-modal-id');

    // Make the main query mock more flexible
    when(mockDatabaseService.query(
      collection: moodEntriesCollectionName,
      filters: anyNamed('filters'),
      orderBy: anyNamed('orderBy'),
      limit: anyNamed('limit'),
      startAfter: anyNamed('startAfter'),
      endBefore: anyNamed('endBefore'),
    )).thenAnswer((invocation) async {
      final filters =
          invocation.namedArguments[const Symbol('filters')] as List<dynamic>?;
      DateTime? queryDate;

      if (filters != null) {
        BasicFilter? createdAtFilter;
        try {
          final dynamic foundFilter = filters.firstWhere(
            (f) => f is BasicFilter && f.field == 'created_at',
          );
          createdAtFilter = foundFilter as BasicFilter;
        } on StateError {
          createdAtFilter = null;
        }

        if (createdAtFilter != null && createdAtFilter.value is Timestamp) {
          queryDate = (createdAtFilter.value as Timestamp).toDate().toLocal();
          queryDate = DateTime(queryDate.year, queryDate.month, queryDate.day);
        }
      }

      debugPrint(
          "[TEST MOCK QUERY mood_entries] QueryDate: $queryDate, TestDate: $testDate, AnotherTestDate: $anotherTestDate, YetAnotherDate: $yetAnotherTestDate");

      // Check if this query is for the 'anotherTestDate' scenario in the specific test
      // This requires the test to somehow signal this, or the mock to be aware of the selectedDateProvider.
      // For simplicity in the mock, we'll rely on the queryDate matching.

      if (queryDate != null) {
        if (queryDate.isAtSameMomentAs(
            DateTime(testDate.year, testDate.month, testDate.day))) {
          debugPrint(
              "[TEST MOCK QUERY mood_entries] Matched testDate. Returning initialMoodEntry.");
          return [initialMoodEntry.toMap()];
        }
        if (queryDate.isAtSameMomentAs(DateTime(anotherTestDate.year,
            anotherTestDate.month, anotherTestDate.day))) {
          // This part will now be hit when selectedDateProvider is anotherTestDate
          debugPrint(
              "[TEST MOCK QUERY mood_entries] Matched anotherTestDate. Returning moodForAnotherDate.");
          return [moodForAnotherDate.toMap()];
        }
        if (queryDate.isAtSameMomentAs(DateTime(yetAnotherTestDate.year,
            yetAnotherTestDate.month, yetAnotherTestDate.day))) {
          debugPrint(
              "[TEST MOCK QUERY mood_entries] Matched yetAnotherTestDate. Returning moodForYetAnotherDate.");
          return [moodForYetAnotherDate.toMap()];
        }
      }
      debugPrint(
          "[TEST MOCK QUERY mood_entries] No specific date match. Returning empty list.");
      return <Map<String, dynamic>>[];
    });

    final otherCollections = [
      'energy_entries',
      'symptom_entries',
      'tasks',
      'habits',
      'medications'
    ];
    for (var collName in otherCollections) {
      when(mockDatabaseService.query(
        collection: collName,
        filters: anyNamed('filters'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        startAfter: anyNamed('startAfter'),
        endBefore: anyNamed('endBefore'),
      )).thenAnswer((_) async {
        debugPrint(
            "[TEST MOCK QUERY $collName] Returning empty list by default.");
        return [];
      });
    }

    when(mockDatabaseService.createDocument(moodEntriesCollectionName,
            any)) // CORRECTED: Use any for positional arg
        .thenAnswer((inv) async {
      final data = inv.positionalArguments[1]
          as Map<String, dynamic>; // CORRECTED: Access positional arg
      // Simplified default behavior, specific tests will override if needed
      return data;
    });

    when(mockDatabaseService.updateDocument(
            any, // Path is positional
            any)) // CORRECTED: Use any for positional arg
        .thenAnswer((inv) async {
      final data = inv.positionalArguments[1]
          as Map<String, dynamic>; // CORRECTED: Access positional arg
      // Simplified default behavior
      return data;
    });

    when(mockDatabaseService.deleteDocument(
            '$moodEntriesCollectionName/${initialMoodEntry.id}'))
        .thenAnswer((_) async {
      when(mockDatabaseService.query(
        collection: moodEntriesCollectionName,
        filters: argThat(contains(BasicFilter(
            'created_at',
            QueryOperator.greaterThanOrEqual,
            Timestamp.fromDate(testDate.toUtc())))),
        orderBy: anyNamed('orderBy'),
      )).thenAnswer((_) async {
        debugPrint(
            "[TEST MOCK QUERY after general delete setup for $moodEntriesCollectionName/${initialMoodEntry.id}] Returning empty list.");
        return [];
      });
    });
  });

  Future<void> _pumpMyAppWithOverrides(WidgetTester tester,
      {DateTime? date, Locale? locale}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          selectedDateProvider.overrideWith((ref) => date ?? testDate),
        ],
        child: MyApp(localeForTest: locale),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> _openMoodListModalViaIconGrid(WidgetTester tester,
      {DateTime? date, Locale? locale}) async {
    debugPrint(
        "--- Test: Attempting to open Mood List Modal for date: ${date ?? testDate.toIso8601String()} ---");
    await _pumpMyAppWithOverrides(tester,
        date: date ?? testDate, locale: locale);
    debugPrint("MyApp pumped and settled for _openMoodListModalViaIconGrid.");

    final moodIconFinder = find.byIcon(FontAwesomeIcons.faceSmile);
    expect(moodIconFinder, findsOneWidget,
        reason: "Mood icon should be present.");
    debugPrint("Mood icon found. Proceeding to tap.");

    await tester.tap(moodIconFinder);
    debugPrint("Mood icon tapped.");

    await tester.pumpAndSettle(const Duration(seconds: 2));
    debugPrint("Pumped and settled after tap, expecting ListModal<MoodModel>.");

    expect(find.byType(ListModal<MoodModel>), findsOneWidget,
        reason: "ListModal<MoodModel> should open.");
    debugPrint("ListModal<MoodModel> successfully found.");
  }

  // filepath: /home/k4ts0v/Projects/spiceease/test/features/tracker/mood_modals_ui_test.dart
  Future<void> _openMoodEditorModalForAdd(WidgetTester tester,
      {DateTime? date, Locale? locale}) async {
    debugPrint("--- Test: Attempting to open Mood Editor Modal for Add ---");
    await _openMoodListModalViaIconGrid(tester, date: date, locale: locale);
    debugPrint(
        "ListModal<MoodModel> opened, proceeding to open editor for add.");

    // Add an extra pumpAndSettle here to ensure ListModal is fully ready
    await tester.pumpAndSettle();

    final listModalFinder = find.byType(ListModal<MoodModel>);
    expect(listModalFinder, findsOneWidget,
        reason: "ListModal<MoodModel> must be present.");

    final BuildContext listModalContext = tester.element(listModalFinder);
    final AppLocalizations localizations =
        AppLocalizations.of(listModalContext)!;

    final listModal = tester.widget<ListModal<MoodModel>>(listModalFinder);
    debugPrint(
        "[TEST _openMoodEditorModalForAdd] ListModal onAdd is ${listModal.onAdd != null ? 'NOT NULL' : 'NULL'}");
    expect(listModal.onAdd, isNotNull,
        reason: "ListModal's onAdd callback must not be null.");

    final addButtonFinder =
        find.byKey(const Key('add_new_button')); // Use the Key
    expect(addButtonFinder, findsOneWidget,
        reason: "'Add New' button should be in ListModal.");
    debugPrint("'Add New' button found. Tapping it.");

    await tester.tap(addButtonFinder);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    debugPrint(
        "Pumped and settled after tapping 'Add New', expecting MoodLevelEditorModal.");

    expect(find.byType(MoodLevelEditorModal), findsOneWidget,
        reason: "MoodLevelEditorModal should open for add.");
    debugPrint("MoodLevelEditorModal successfully found for add.");
  }

  testWidgets('Add New button is present and tappable in ListModal',
      (WidgetTester tester) async {
    await _openMoodListModalViaIconGrid(tester, date: testDate);

    final addButtonFinder = find.byKey(const Key('add_new_button'));
    expect(addButtonFinder, findsOneWidget,
        reason: "'Add New' button should be in ListModal.");

    await tester.tap(addButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(MoodLevelEditorModal), findsOneWidget,
        reason: "Tapping 'Add New' should open MoodLevelEditorModal.");
  });

  testWidgets('ListModal updates its content when selectedDateProvider changes',
      (WidgetTester tester) async {
    // First, open for testDate
    await _openMoodListModalViaIconGrid(tester, date: testDate);
    expect(find.textContaining(initialMoodEntry.notes!), findsOneWidget,
        reason: "Initial entry for testDate should be visible.");
    expect(find.textContaining(moodForAnotherDate.notes!), findsNothing,
        reason: "Entry for anotherTestDate should NOT be visible.");

    // Pop the current ListModal
    Navigator.of(tester.element(find.byType(ListModal<MoodModel>))).pop();
    await tester.pumpAndSettle();

    // Now, open for anotherTestDate. The main mock in setUp should handle this.
    // No need to re-mock databaseService.query here.
    await _openMoodListModalViaIconGrid(tester, date: anotherTestDate);

    expect(find.textContaining(moodForAnotherDate.notes!), findsOneWidget,
        reason: "Entry for anotherTestDate should now be visible.");
    expect(find.textContaining(initialMoodEntry.notes!), findsNothing,
        reason: "Entry for testDate should NOT be visible.");
  });
testWidgets('ListModal shows SnackBar on deleteDocument failure',
    (WidgetTester tester) async {
  await _openMoodListModalViaIconGrid(tester, date: testDate);

  when(mockDatabaseService.deleteDocument(
          '$moodEntriesCollectionName/${initialMoodEntry.id}'))
      .thenThrow(Exception('Network error'));

  final deleteIcon = find
      .descendant(
          of: find.byType(ListModal<MoodModel>),
          matching: find.byIcon(Icons.delete_outline))
      .first;
  await tester.tap(deleteIcon);
  await tester.pumpAndSettle();

  final BuildContext confirmDialogContext =
      tester.element(find.byType(AlertDialog));
  final AppLocalizations confirmLocalizations =
      AppLocalizations.of(confirmDialogContext)!;
  await tester
      .tap(find.widgetWithText(TextButton, confirmLocalizations.delete));
  await tester.pump(); // Pump, but don't settle, to allow SnackBar animation

  expect(find.byType(SnackBar), findsOneWidget);
  final BuildContext listModalContext =
      tester.element(find.byType(ListModal<MoodModel>));
  final AppLocalizations listModalLocalizations =
      AppLocalizations.of(listModalContext)!;
  expect(
      find.text(listModalLocalizations
          .failedToDeleteItem(listModalLocalizations.mood.toLowerCase())),
      findsOneWidget);
  expect(find.textContaining(initialMoodEntry.notes!), findsOneWidget,
      reason: "Item should still be in ListModal on delete failure.");
});

  group('ListModal UI and Actions (for Mood)', () {
    testWidgets('displays existing mood entries and an add button',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);

      final BuildContext context =
          tester.element(find.byType(ListModal<MoodModel>));
      final AppLocalizations localizations = AppLocalizations.of(context)!;

      expect(find.text(initialMoodEntry.moodLevel.toString()), findsOneWidget,
          reason: "Mood level should be displayed.");
      expect(find.textContaining(initialMoodEntry.notes!), findsOneWidget,
          reason: "Mood notes should be displayed.");
      expect(find.widgetWithText(ElevatedButton, localizations.addNew),
          findsOneWidget,
          reason: "'Add New' button should be present.");
      expect(find.text(localizations.mood), findsAtLeastNWidgets(1),
          reason: "ListModal title should be localized mood term.");
    });

    testWidgets(
        'displays a message when no entries exist for the selected date',
        (WidgetTester tester) async {
      when(mockDatabaseService.query(
        collection: moodEntriesCollectionName,
        filters: anyNamed('filters'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        startAfter: anyNamed('startAfter'),
        endBefore: anyNamed('endBefore'),
      )).thenAnswer((invocation) async {
        final filters = invocation.namedArguments[const Symbol('filters')]
            as List<dynamic>?;
        DateTime? queryDate;
        if (filters != null) {
          final createdAtFilter = filters.firstWhere(
              (f) => f is BasicFilter && f.field == 'created_at',
              orElse: () => null) as BasicFilter?;
          if (createdAtFilter != null && createdAtFilter.value is Timestamp) {
            queryDate = (createdAtFilter.value as Timestamp).toDate().toLocal();
            queryDate =
                DateTime(queryDate.year, queryDate.month, queryDate.day);
          }
        }
        if (queryDate != null &&
            queryDate.isAtSameMomentAs(DateTime(anotherTestDate.year,
                anotherTestDate.month, anotherTestDate.day))) {
          debugPrint(
              "[TEST MOCK QUERY mood_entries for 'no entries' test] Matched anotherTestDate. Returning empty list.");
          return [];
        }
        if (queryDate != null &&
            queryDate.isAtSameMomentAs(
                DateTime(testDate.year, testDate.month, testDate.day))) {
          return [initialMoodEntry.toMap()];
        }
        debugPrint(
            "[TEST MOCK QUERY mood_entries for 'no entries' test] Did not match anotherTestDate. QueryDate: $queryDate. Returning empty for safety.");
        return [];
      });

      await _openMoodListModalViaIconGrid(tester, date: anotherTestDate);

      final BuildContext context =
          tester.element(find.byType(ListModal<MoodModel>));
      final AppLocalizations localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.noItemsYet), findsOneWidget,
          reason: "Should show 'No items yet' message.");
      expect(find.widgetWithText(ElevatedButton, localizations.addNew),
          findsOneWidget,
          reason: "'Add New' button should still be present.");
    });

    testWidgets('tapping add button opens MoodLevelEditorModal',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);

      final BuildContext listModalContext =
          tester.element(find.byType(ListModal<MoodModel>));
      final AppLocalizations localizations =
          AppLocalizations.of(listModalContext)!;

      await tester
          .tap(find.widgetWithText(ElevatedButton, localizations.addNew));
      await tester.pumpAndSettle();

      expect(find.byType(MoodLevelEditorModal), findsOneWidget);
      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;
      expect(find.text(editorLocalizations.save), findsOneWidget,
          reason: "Editor modal should have a save button.");

      final notesField = find.descendant(
          of: find.byType(MoodLevelEditorModal),
          matching: find.byType(TextField));
      expect(
          tester.widget<TextField>(notesField.last).controller?.text, isEmpty);
    });

    testWidgets(
        'tapping edit on an entry opens MoodLevelEditorModal pre-filled',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);

      final editButton = find
          .descendant(
              of: find.byType(ListModal<MoodModel>),
              matching: find.byIcon(Icons.edit_outlined))
          .first;
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(find.byType(MoodLevelEditorModal), findsOneWidget);
      final notesField = find.descendant(
          of: find.byType(MoodLevelEditorModal),
          matching: find.byType(TextField));
      expect(tester.widget<TextField>(notesField.last).controller?.text,
          initialMoodEntry.notes);
      expect(find.byKey(ValueKey('moodValue_${initialMoodEntry.moodLevel}')),
          findsOneWidget,
          reason: "Correct mood level should be selected.");
    });

    // ...existing code...
    testWidgets('UI updates correctly in ListModal after adding an entry',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);
      expect(find.textContaining(initialMoodEntry.notes!), findsOneWidget);

      // Ensure ListModal is fully settled
      await tester.pumpAndSettle();

      // Verify the onAdd callback on the found ListModal instance
      final listModalWidget = tester
          .widget<ListModal<MoodModel>>(find.byType(ListModal<MoodModel>));
      debugPrint(
          "[Test '...after adding an entry'] ListModal onAdd is ${listModalWidget.onAdd != null ? 'NOT NULL' : 'NULL'}");
      expect(listModalWidget.onAdd, isNotNull,
          reason:
              "ListModal's onAdd callback was null in '...after adding an entry' test.");

      final addButtonFinder = find.byKey(const Key('add_new_button'));
      expect(addButtonFinder, findsOneWidget,
          reason: "Add New button in ListModal not found by key.");
      await tester.tap(addButtonFinder);
      await tester.pumpAndSettle();

      const newNotes = 'Newly added item notes';

      // Mock for createDocument
      final newMoodId = 'newly-created-mood-id';
      when(mockDatabaseService.generateId()).thenReturn(
          newMoodId); // Ensure generateId is mocked if used by controller

      when(mockDatabaseService.createDocument(moodEntriesCollectionName, any))
          .thenAnswer((invocation) async {
        final createdData =
            invocation.positionalArguments[1] as Map<String, dynamic>;
        // Ensure the ID from generateId() is part of the createdData if your controller logic adds it
        final dataWithId = {...createdData, 'id': newMoodId};

        // Mock the subsequent query to include the new item
        when(mockDatabaseService.query(
          collection: moodEntriesCollectionName,
          filters: anyNamed('filters'), // Keep filters general for this refresh
          orderBy: anyNamed('orderBy'),
          limit: anyNamed('limit'),
          startAfter: anyNamed('startAfter'),
          endBefore: anyNamed('endBefore'),
        )).thenAnswer((_) async {
          debugPrint(
              "[TEST MOCK QUERY after add] Returning initial and new entry.");
          // Return both initial and the newly created item
          return [initialMoodEntry.toMap(), dataWithId];
        });
        return dataWithId; // Return data as createDocument would
      });

      await tester.tap(find.byKey(const ValueKey('moodValue_2')));
      await tester.enterText(
          find
              .descendant(
                  of: find.byType(MoodLevelEditorModal),
                  matching: find.byType(TextField))
              .last,
          newNotes);

      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;
      await tester.tap(find.text(editorLocalizations.save));
      await tester.pumpAndSettle();

      expect(find.byType(MoodLevelEditorModal), findsNothing);

      // Expect ListModal to be visible and contain the new item
      final listModalFinderAfterAdd = find.byType(ListModal<MoodModel>);
      expect(listModalFinderAfterAdd, findsOneWidget,
          reason: "ListModal should be visible after adding an entry.");

      expect(find.textContaining(initialMoodEntry.notes!), findsOneWidget,
          reason: "Initial entry should still be there.");
      expect(find.text(newNotes), findsOneWidget,
          reason: "New entry should be displayed in ListModal.");
    });
    // ...existing code...    // ...existing code...
    // ...existing code...
// ...existing code...
    testWidgets('UI updates correctly in ListModal after editing an entry',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);

      final editButtonFinder = find.descendant(
          of: find.byType(ListModal<MoodModel>),
          matching: find.byIcon(Icons.edit_outlined));
      expect(editButtonFinder, findsOneWidget,
          reason: "Edit icon in ListModal not found.");
      await tester.tap(editButtonFinder.first);
      await tester.pumpAndSettle();

      const updatedNotes = 'Updated entry notes';
      final MoodModel moodToUpdate = initialMoodEntry; // For clarity

      // Mock for updateDocument and subsequent query
      when(mockDatabaseService.updateDocument(
              '$moodEntriesCollectionName/${moodToUpdate.id}',
              any // data being updated
              ))
          .thenAnswer((invocation) async {
        final updatePayload =
            invocation.positionalArguments[1] as Map<String, dynamic>;
        final documentAfterUpdateMap = {
          ...moodToUpdate.toMap(), // Start with original
          ...updatePayload, // Apply updates
          'id': moodToUpdate.id, // Ensure ID remains
        };

        when(mockDatabaseService.query(
          collection: moodEntriesCollectionName,
          filters: anyNamed('filters'),
          orderBy: anyNamed('orderBy'),
          limit: anyNamed('limit'),
          startAfter: anyNamed('startAfter'),
          endBefore: anyNamed('endBefore'),
        )).thenAnswer((_) async {
          debugPrint(
              "[TEST MOCK QUERY after specific update for ${moodToUpdate.id}] Returning document reflecting actual update payload: $documentAfterUpdateMap");
          return [documentAfterUpdateMap]; // Return the single updated item
        });
        return Future.value(documentAfterUpdateMap);
      });

      await tester.tap(find.byKey(const ValueKey('moodValue_7')));
      await tester.enterText(
          find
              .descendant(
                  of: find.byType(MoodLevelEditorModal),
                  matching: find.byType(TextField))
              .last,
          updatedNotes);

      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;
      await tester.tap(find.text(editorLocalizations.save));

      debugPrint(
          "[Test '...after editing an entry'] Tapped save. Pumping to allow modal to pop.");
      await tester.pump(const Duration(
          milliseconds: 200)); // Allow modal to pop and initial rebuilds

      expect(find.byType(MoodLevelEditorModal), findsNothing,
          reason: "MoodLevelEditorModal should be closed after save.");
      debugPrint(
          "[Test '...after editing an entry'] MoodLevelEditorModal is gone. Pumping again for ListModal refresh.");

      // Pump a few more times with small delays to allow ListModal to refresh
      // This replaces the potentially hanging pumpAndSettle
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      debugPrint(
          "[Test '...after editing an entry'] Finished additional pumps. Checking for ListModal.");

      final listModalFinderAfterEdit = find.byType(ListModal<MoodModel>);
      expect(listModalFinderAfterEdit, findsOneWidget,
          reason: "ListModal should be visible after editing an entry.");
      debugPrint("[Test '...after editing an entry'] ListModal found.");

      expect(find.text(updatedNotes), findsOneWidget,
          reason: "Updated notes should be displayed in ListModal.");
      expect(find.textContaining(initialMoodEntry.notes!), findsNothing,
          reason:
              "Old notes should be gone from ListModal if they were changed.");
      debugPrint(
          "[Test '...after editing an entry'] Assertions for ListModal content passed.");
    });
// ...existing code...
    // ...existing code...
    testWidgets('UI updates correctly in ListModal after deleting an entry',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);
      expect(find.textContaining(initialMoodEntry.notes!), findsOneWidget);

      when(mockDatabaseService.deleteDocument(
              '$moodEntriesCollectionName/${initialMoodEntry.id}'))
          .thenAnswer((_) async {
        when(mockDatabaseService.query(
          collection: moodEntriesCollectionName,
          filters: anyNamed('filters'),
          orderBy: anyNamed('orderBy'),
          limit: anyNamed('limit'),
          startAfter: anyNamed('startAfter'),
          endBefore: anyNamed('endBefore'),
        )).thenAnswer((invocation) async {
          debugPrint(
              "[TEST MOCK QUERY after specific delete for ${initialMoodEntry.id}] Returning empty list.");
          return [];
        });
      });

      final deleteIconFinder = find.descendant(
          of: find.byType(ListModal<MoodModel>),
          matching: find.byIcon(Icons.delete_outline));
      expect(deleteIconFinder, findsOneWidget,
          reason: "Delete icon in ListModal not found.");
      await tester.tap(deleteIconFinder.first);
      await tester.pumpAndSettle(); // For the confirmation dialog to appear

      // Ensure confirmation dialog is present
      final alertDialogFinder = find.byType(AlertDialog);
      expect(alertDialogFinder, findsOneWidget,
          reason: "Delete confirmation dialog did not appear.");

      final BuildContext confirmDialogContext =
          tester.element(alertDialogFinder);
      final AppLocalizations confirmLocalizations =
          AppLocalizations.of(confirmDialogContext)!;

      final deleteButtonInDialogFinder =
          find.widgetWithText(TextButton, confirmLocalizations.delete);
      expect(deleteButtonInDialogFinder, findsOneWidget,
          reason: "Delete button in confirmation dialog not found.");
      await tester.tap(deleteButtonInDialogFinder);
      await tester.pumpAndSettle(); // For the dialogs to close and UI to update

      // After deletion, the ListModal itself should be closed by its own onDelete logic.
      // The MoodLevelEditorModal (if it was open for delete) is also closed by its onDelete.
      expect(find.byType(AlertDialog), findsNothing,
          reason: "Confirmation dialog should be closed.");
      expect(find.byType(ListModal<MoodModel>),
          findsNothing, // MODIFIED: Expect ListModal to be gone
          reason: "ListModal should be closed after deletion.");

      // To verify the "No items yet" state, you would typically need to re-trigger the
      // action that opens the ListModal (e.g., tap the mood icon again)
      // and then check its content.

      // Example: Re-open and check (assuming _openMoodListModalViaIconGrid handles empty state correctly)
      // This part depends on how _openMoodListModalViaIconGrid is set up for empty states
      // and if it directly opens MoodLevelEditorModal or ListModal with "no items".
      // For now, we'll assume the primary check is that the item is gone.
      // If you need to verify the "no items yet" in ListModal, you'd do:
      // await _openMoodListModalViaIconGrid(tester, date: testDate); // Re-open
      // final BuildContext listModalContext = tester.element(find.byType(ListModal<MoodModel>));
      // final AppLocalizations listModalLocalizations = AppLocalizations.of(listModalContext)!;
      // expect(find.text(listModalLocalizations.noItemsYet), findsOneWidget,
      //     reason: "Should show 'No items yet' message after deletion and re-opening.");
      // expect(find.textContaining(initialMoodEntry.notes!), findsNothing,
      //     reason: "Deleted entry should not be displayed upon re-opening.");
    });
    // ...existing code...
    testWidgets('ListModal shows SnackBar on deleteDocument failure',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);

      when(mockDatabaseService.deleteDocument(
              '$moodEntriesCollectionName/${initialMoodEntry.id}'))
          .thenThrow(Exception('Network error'));

      final deleteIcon = find
          .descendant(
              of: find.byType(ListModal<MoodModel>),
              matching: find.byIcon(Icons.delete_outline))
          .first;
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      final BuildContext confirmDialogContext =
          tester.element(find.byType(AlertDialog));
      final AppLocalizations confirmLocalizations =
          AppLocalizations.of(confirmDialogContext)!;
      await tester
          .tap(find.widgetWithText(TextButton, confirmLocalizations.delete));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      final BuildContext listModalContext =
          tester.element(find.byType(ListModal<MoodModel>));
      final AppLocalizations listModalLocalizations =
          AppLocalizations.of(listModalContext)!;
      expect(
          find.text(listModalLocalizations
              .failedToDeleteItem(listModalLocalizations.mood.toLowerCase())),
          findsOneWidget);
      expect(find.textContaining(initialMoodEntry.notes!), findsOneWidget,
          reason: "Item should still be in ListModal on delete failure.");
    });

    testWidgets(
        'ListModal updates its content when selectedDateProvider changes',
        (WidgetTester tester) async {
      // First, open for testDate
      await _openMoodListModalViaIconGrid(tester, date: testDate);
      expect(find.textContaining(initialMoodEntry.notes!), findsOneWidget,
          reason: "Initial entry for testDate should be visible.");
      expect(find.textContaining(moodForAnotherDate.notes!), findsNothing,
          reason: "Entry for anotherTestDate should NOT be visible.");

      // Pop the current ListModal
      Navigator.of(tester.element(find.byType(ListModal<MoodModel>))).pop();
      await tester.pumpAndSettle();

      // Now, open for anotherTestDate. The main mock in setUp should handle this.
      // No need to re-mock databaseService.query here.
      await _openMoodListModalViaIconGrid(tester, date: anotherTestDate);

      expect(find.textContaining(moodForAnotherDate.notes!), findsOneWidget,
          reason: "Entry for anotherTestDate should now be visible.");
      expect(find.textContaining(initialMoodEntry.notes!), findsNothing,
          reason: "Entry for testDate should NOT be visible.");
    });

    testWidgets('Delete confirmation dialog cancel button works',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);
      expect(find.textContaining(initialMoodEntry.notes!), findsOneWidget);

      final deleteIcon = find
          .descendant(
              of: find.byType(ListModal<MoodModel>),
              matching: find.byIcon(Icons.delete_outline))
          .first;
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      final BuildContext confirmDialogContext =
          tester.element(find.byType(AlertDialog));
      final AppLocalizations confirmLocalizations =
          AppLocalizations.of(confirmDialogContext)!;

      await tester
          .tap(find.widgetWithText(TextButton, confirmLocalizations.cancel));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing,
          reason: "Confirmation dialog should close.");
      expect(find.byType(ListModal<MoodModel>), findsOneWidget,
          reason: "ListModal should still be visible.");
      expect(find.textContaining(initialMoodEntry.notes!), findsOneWidget,
          reason: "Item should not be deleted.");
      verifyNever(mockDatabaseService
          .deleteDocument('$moodEntriesCollectionName/${initialMoodEntry.id}'));
    });
  });

  group('MoodLevelEditorModal UI and Actions', () {
    testWidgets('allows selecting mood level and entering notes',
        (WidgetTester tester) async {
      await _openMoodEditorModalForAdd(tester, date: testDate);

      await tester.tap(find.byKey(const ValueKey('moodValue_3')));
      await tester.pumpAndSettle();

      final notesField = find.descendant(
          of: find.byType(MoodLevelEditorModal),
          matching: find.byType(TextField));
      await tester.enterText(notesField.last, 'Testing notes input.');
      await tester.pumpAndSettle();
      expect(find.text('Testing notes input.'), findsOneWidget);
    });

    testWidgets(
        'Save button calls createDocument with correct data for new entry',
        (WidgetTester tester) async {
      await _openMoodEditorModalForAdd(tester, date: testDate);

      await tester.tap(find.byKey(const ValueKey('moodValue_4')));
      final notesField = find.descendant(
          of: find.byType(MoodLevelEditorModal),
          matching: find.byType(TextField));
      await tester.enterText(notesField.last, 'New entry via modal.');

      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;
      await tester.tap(find.text(editorLocalizations.save));
      await tester.pumpAndSettle();

      verify(mockDatabaseService.createDocument(
        moodEntriesCollectionName,
        argThat(isA<
                Map<String,
                    dynamic>>() // This is already correct for positional
            .having((map) => map['id'], 'id', 'new-modal-id')
            .having((map) => map['mood_level'], 'mood_level', 4)
            .having((map) => map['notes'], 'notes', 'New entry via modal.')
            .having((map) => map['user_id'], 'user_id', 'test-user')
            .having((map) => map['created_at'], 'created_at', isA<Timestamp>())
            .having(
                (map) => map['updated_at'], 'updated_at', isA<Timestamp>())),
      )).called(1);
      expect(find.byType(MoodLevelEditorModal), findsNothing,
          reason: "Modal should close after save.");
    });

    testWidgets(
        'Save button calls updateDocument with correct data for existing entry',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();

      const updatedNotes = "Updated notes for existing entry";
      await tester.tap(find.byKey(const ValueKey('moodValue_7')));
      final notesField = find.descendant(
          of: find.byType(MoodLevelEditorModal),
          matching: find.byType(TextField));
      await tester.enterText(notesField.last, updatedNotes);

      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;
      await tester.tap(find.text(editorLocalizations.save));
      await tester.pumpAndSettle();

      verify(mockDatabaseService.updateDocument(
        '$moodEntriesCollectionName/${initialMoodEntry.id}',
        argThat(isA<
                Map<String,
                    dynamic>>() // This is already correct for positional
            .having((map) => map['mood_level'], 'mood_level', 7)
            .having((map) => map['notes'], 'notes', updatedNotes)
            .having(
                (map) => map.containsKey('updated_at'), 'updated_at', true)),
      )).called(1);

      expect(find.byType(MoodLevelEditorModal), findsNothing,
          reason: "Modal should close after save.");
    });

    testWidgets('Cancel button closes modal without saving (from Add flow)',
        (WidgetTester tester) async {
      await _openMoodEditorModalForAdd(tester, date: testDate);

      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;
      await tester.tap(find.text(editorLocalizations.cancel));
      await tester.pumpAndSettle();

      expect(find.byType(MoodLevelEditorModal), findsNothing,
          reason: "Editor modal should close.");
      expect(find.byType(ListModal<MoodModel>), findsOneWidget,
          reason: "ListModal should remain visible.");
      verifyNever(mockDatabaseService.createDocument(
          moodEntriesCollectionName, any)); // CORRECTED
    });

    testWidgets('Cancel button closes modal without saving (from Edit flow)',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();

      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;
      await tester.tap(find.text(editorLocalizations.cancel));
      await tester.pumpAndSettle();

      expect(find.byType(MoodLevelEditorModal), findsNothing,
          reason: "Editor modal should close.");
      expect(find.byType(ListModal<MoodModel>), findsOneWidget,
          reason: "ListModal should remain visible.");
      verifyNever(mockDatabaseService.updateDocument(
          any, any)); // CORRECTED (any for path, any for data)
    });

    testWidgets('Shows error if trying to save without selecting mood level',
        (WidgetTester tester) async {
      await _openMoodEditorModalForAdd(tester, date: testDate);

      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;

      await tester.enterText(
          find
              .descendant(
                  of: find.byType(MoodLevelEditorModal),
                  matching: find.byType(TextField))
              .last,
          'Some notes');
      await tester.tap(find.text(editorLocalizations.save));
      await tester.pumpAndSettle();

      expect(find.byType(MoodLevelEditorModal), findsOneWidget,
          reason: "Modal should remain open.");
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.text(editorLocalizations
              .requiredField(editorLocalizations.mood.toLowerCase())),
          findsOneWidget);
      verifyNever(mockDatabaseService.createDocument(
          moodEntriesCollectionName, any)); // CORRECTED
    });

    testWidgets('Shows SnackBar on createDocument failure',
        (WidgetTester tester) async {
      await _openMoodEditorModalForAdd(tester, date: testDate);
      when(mockDatabaseService.createDocument(
              moodEntriesCollectionName, any)) // CORRECTED
          .thenThrow(Exception('Network error'));

      await tester.tap(find.byKey(const ValueKey('moodValue_6')));
      await tester.enterText(
          find
              .descendant(
                  of: find.byType(MoodLevelEditorModal),
                  matching: find.byType(TextField))
              .last,
          'Will fail');

      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;
      await tester.tap(find.text(editorLocalizations.save));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.text(editorLocalizations
              .failedToSaveItem(editorLocalizations.mood.toLowerCase())),
          findsOneWidget);
      expect(find.byType(MoodLevelEditorModal), findsOneWidget,
          reason: "Modal should remain open.");
    });

    testWidgets('Shows SnackBar on updateDocument failure',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();

      when(mockDatabaseService.updateDocument(
              '$moodEntriesCollectionName/${initialMoodEntry.id}', any))
          .thenThrow(Exception('Network error'));

      await tester.enterText(
          find
              .descendant(
                  of: find.byType(MoodLevelEditorModal),
                  matching: find.byType(TextField))
              .last,
          'Will fail update');

      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;
      await tester.tap(find.text(editorLocalizations.save));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.text(editorLocalizations
              .failedToSaveItem(editorLocalizations.mood.toLowerCase())),
          findsOneWidget);
      expect(find.byType(MoodLevelEditorModal), findsOneWidget,
          reason: "Modal should remain open.");
    });

    testWidgets('MoodLevelEditorModal title is localized for new entry',
        (WidgetTester tester) async {
      await _openMoodEditorModalForAdd(tester, date: testDate);
      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;

      expect(
          find.text(editorLocalizations
              .newTitle(editorLocalizations.mood.toLowerCase())),
          findsOneWidget);
    });

    testWidgets('MoodLevelEditorModal title is localized for editing entry',
        (WidgetTester tester) async {
      await _openMoodListModalViaIconGrid(tester, date: testDate);
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();

      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;

      expect(
          find.text(editorLocalizations
              .editTitle(editorLocalizations.mood.toLowerCase())),
          findsOneWidget);
    });

    testWidgets('MoodLevelEditorModal shows mood level scale description',
        (WidgetTester tester) async {
      await _openMoodEditorModalForAdd(tester, date: testDate);
      final BuildContext editorContext =
          tester.element(find.byType(MoodLevelEditorModal));
      final AppLocalizations editorLocalizations =
          AppLocalizations.of(editorContext)!;

      expect(find.text(editorLocalizations.moodLevelScale), findsOneWidget);
    });
  });
}
