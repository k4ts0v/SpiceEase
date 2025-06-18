// /// This file tests the UI behavior and layout of the tracker modals.
// ///
// /// # Testing Strategy
// ///
// /// This test suite validates UI robustness for tracker modals:
// /// 1. Modal layout and responsiveness across different screen sizes
// /// 2. UI overflow prevention with long text content
// /// 3. Visual state changes (selection, validation, error states)
// /// 4. Modal positioning and sizing behavior
// /// 5. Form field layout and interaction behavior
// /// 6. Chart and grid layout within modals
// ///
// /// # How to run
// /// - Run with `flutter test test/features/tracker/modals_unit_tests_test.dart`
// library;

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:spiceease/data/models/energy_model.dart';
// import 'package:spiceease/data/models/habit_model.dart';
// import 'package:spiceease/data/models/medication_model.dart';
// import 'package:spiceease/data/models/mood_model.dart';
// import 'package:spiceease/data/models/symptom_model.dart';
// import 'package:spiceease/data/models/task_model.dart';
// import 'package:spiceease/data/providers/selected_date_provider.dart';
// import 'package:spiceease/features/tracker/presentation/controllers/tracker_controller.dart';
// import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';
// import 'package:spiceease/l10n/app_localizations.dart';

// import 'modals_unit_tests_test.mocks.dart';

// // --------------------------------------------------------------------------
// // STANDARDIZED TEST SCREEN SIZES - MUST MATCH ACROSS ALL UI TESTS
// // --------------------------------------------------------------------------

// /// Standardized screen sizes for consistent testing across ALL UI test suites
// const List<Size> standardTestSizes = [
//   Size(375, 667), // iPhone SE (small mobile)
//   Size(390, 844), // iPhone 12/13 mini
//   Size(414, 896), // iPhone 11 (large mobile)
//   Size(768, 1024), // iPad Portrait (tablet)
//   Size(1024, 768), // iPad Landscape (tablet landscape)
//   Size(1200, 800), // Desktop (standard)
//   Size(1920, 1080), // Large Desktop
// ];

// // --------------------------------------------------------------------------
// // Test Data Setup for Modal UI Testing
// // --------------------------------------------------------------------------

// /// Fixed test date for consistent testing
// final testSelectedDate = DateTime(2025, 6, 15);

// /// Test data with long content for overflow testing
// class ModalUITestData {
//   /// Task with extremely long title and description for modal overflow testing
//   static TaskModel getTaskWithLongContent() {
//     return TaskModel(
//       id: 'long-content-task',
//       title:
//           'This is an extremely long task title that should test how modals handle very long text content without causing UI overflow or layout breaking in the task editor modal',
//       description:
//           'This is an extremely detailed task description that contains comprehensive information about the task requirements, implementation details, acceptance criteria, and extensive notes that should test how the modal handles very long text content in text fields and display areas without causing scrolling issues or layout problems.',
//       status: 'todo',
//       priority: 3,
//       estimatedTime:
//           '4 hours 30 minutes with extensive additional time estimates',
//       createdAt: testSelectedDate.subtract(const Duration(days: 5)),
//       userId: 'test-user',
//       updatedAt: testSelectedDate,
//     );
//   }

//   /// Habit with long title and description for modal testing
//   static HabitModel getHabitWithLongContent() {
//     return HabitModel(
//       id: 'long-content-habit',
//       title:
//           'This is an extremely long habit title that should test modal layout with extensive text content and overflow handling',
//       description:
//           'This is a very detailed habit description that contains comprehensive information about the habit goals, tracking methodology, implementation strategies, and extensive notes that should test how the habit editor modal handles long text content.',
//       frequency: 1,
//       userId: 'test-user',
//       createdAt: testSelectedDate.subtract(const Duration(days: 30)),
//       updatedAt: testSelectedDate,
//       completedDates: [testSelectedDate],
//     );
//   }

//   /// Medication with long name for modal testing
//   static MedicationModel getMedicationWithLongContent() {
//     return MedicationModel(
//       id: 'long-content-medication',
//       name:
//           'This is an extremely long medication name that should test how the medication editor modal handles very long pharmaceutical names and content',
//       dose: 250.0,
//       unit: 'mg',
//       frequency: 'twice daily with comprehensive dosing instructions',
//       timesPerDay: 2,
//       userId: 'test-user',
//       createdAt: testSelectedDate.subtract(const Duration(days: 60)),
//       updatedAt: testSelectedDate,
//       completedDates: [],
//     );
//   }

//   /// Symptom with long name and notes for modal testing
//   static SymptomModel getSymptomWithLongContent() {
//     return SymptomModel(
//       id: 'long-content-symptom',
//       name:
//           'This is an extremely long symptom name that should test modal layout with extensive medical terminology and content',
//       category:
//           'Comprehensive category with detailed medical classification information',
//       severity: 4,
//       notes:
//           'These are extremely detailed symptom notes that contain comprehensive information about triggers, duration, impact on daily activities, associated symptoms, and treatment responses that should test how the symptom modal handles extensive text content.',
//       userId: 'test-user',
//       createdAt: testSelectedDate,
//       updatedAt: testSelectedDate,
//     );
//   }
// }

// // --------------------------------------------------------------------------
// // Mock Classes for Modal UI Testing
// // --------------------------------------------------------------------------

// @GenerateMocks([TrackerController])
// void main() {
//   late MockTrackerController mockController;

//   setUp(() {
//     mockController = MockTrackerController();

//     // Set up default successful mocks - simplified approach
//     when(mockController.generateId()).thenReturn('test-ui-id');
//     when(mockController.addMood(any, any)).thenAnswer((_) async {});
//     when(mockController.updateMood(any, any, any)).thenAnswer((_) async {});
//     when(mockController.deleteMood(any, any)).thenAnswer((_) async {});
//     when(mockController.addEnergy(any, any)).thenAnswer((_) async {});
//     when(mockController.updateEnergy(any, any, any)).thenAnswer((_) async {});
//     when(mockController.deleteEnergy(any, any)).thenAnswer((_) async {});
//     when(mockController.addTask(
//       title: anyNamed('title'),
//       description: anyNamed('description'),
//       status: anyNamed('status'),
//       priority: anyNamed('priority'),
//       subtasks: anyNamed('subtasks'),
//     )).thenAnswer((_) async {});
//     when(mockController.updateTask(
//             anyString, anyString, anyString, anyString, anyString, anyString, anyString, anyString, anyString, anyInt, anyBool))
//         .thenAnswer((_) async {});
//     when(mockController.deleteTask(anyString)).thenAnswer((_) async {});
//     when(mockController.addHabit(
//       title: anyNamed('title'),
//       description: anyNamed('description'),
//       frequency: anyNamed('frequency'),
//     )).thenAnswer((_) async {});
//     when(mockController.updateHabit(anyString, anyString, anyString, anyString, anyInt, anyBool))
//         .thenAnswer((_) async {});
//     when(mockController.deleteHabit(anyString)).thenAnswer((_) async {});
//     when(mockController.addMedication(
//       name: anyNamed('name'),
//       dose: anyNamed('dose'),
//       unit: anyNamed('unit'),
//       frequency: anyNamed('frequency'),
//       timesPerDay: anyNamed('timesPerDay'),
//     )).thenAnswer((_) async {});
//     when(mockController.updateMedication(
//       id: any,
//       isCompleted: any,
//       forDate: any,
//     )).thenAnswer((_) async {});
//     when(mockController.deleteMedication(any)).thenAnswer((_) async {});
//     when(mockController.addSymptom(any, any, any, any))
//         .thenAnswer((_) async {});
//     when(mockController.updateSymptom(any, any, any, any, any))
//         .thenAnswer((_) async {});
//     when(mockController.deleteSymptom(any, any)).thenAnswer((_) async {});
//   });

//   /// Helper function to pump modal widgets with different screen sizes
//   Future<void> pumpModalForUI(
//     WidgetTester tester,
//     Widget modal, {
//     Size? screenSize,
//   }) async {
//     if (screenSize != null) {
//       await tester.binding.setSurfaceSize(screenSize);
//     }

//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           trackerControllerProvider.overrideWithValue(mockController),
//           selectedDateProvider.overrideWith((ref) => testSelectedDate),
//         ],
//         child: MaterialApp(
//           localizationsDelegates: AppLocalizations.localizationsDelegates,
//           supportedLocales: AppLocalizations.supportedLocales,
//           home: Scaffold(
//             body: Builder(
//               builder: (context) => modal,
//             ),
//           ),
//         ),
//       ),
//     );

//     // Use controlled pumping for UI tests
//     await tester.pump();
//     await tester.pump(const Duration(milliseconds: 100));
//   }

//   /// Helper function to check for layout overflow
//   void checkForOverflow(WidgetTester tester, String testName, Size screenSize) {
//     final exception = tester.takeException();
//     if (exception != null && exception.toString().contains('overflowed')) {
//       fail(
//           '$testName: Layout overflow detected on ${screenSize.width}x${screenSize.height}: $exception');
//     }
//   }

//   // --------------------------------------------------------------------------
//   // Modal UI Layout and Overflow Tests
//   // --------------------------------------------------------------------------

//   group('Modal UI Layout and Overflow Tests', () {
//     group('MoodLevelEditorModal UI Tests', () {
//       testWidgets('displays mood grid without overflow across screen sizes',
//           (WidgetTester tester) async {
//         for (final size in standardTestSizes) {
//           await pumpModalForUI(
//             tester,
//             Consumer(
//                 builder: (context, ref, child) =>
//                     MoodLevelEditorModal(ref: ref)),
//             screenSize: size,
//           );

//           // Assert: Modal should be present
//           expect(find.byType(MoodLevelEditorModal), findsOneWidget,
//               reason:
//                   'Modal should be present on ${size.width}x${size.height}');

//           // Assert: Mood level buttons should be present (1-10)
//           for (int i = 1; i <= 10; i++) {
//             expect(find.text('$i'), findsOneWidget,
//                 reason:
//                     'Mood level $i should be present on ${size.width}x${size.height}');
//           }

//           // Assert: Essential UI elements should be present
//           expect(find.byType(TextField), findsOneWidget,
//               reason:
//                   'Notes field should be present on ${size.width}x${size.height}');
//           expect(find.text('Save'), findsOneWidget,
//               reason:
//                   'Save button should be present on ${size.width}x${size.height}');
//           expect(find.text('Cancel'), findsOneWidget,
//               reason:
//                   'Cancel button should be present on ${size.width}x${size.height}');

//           // Check for overflow
//           checkForOverflow(tester, 'MoodLevelEditorModal', size);
//         }
//       });

//       testWidgets('handles long notes text without overflow',
//           (WidgetTester tester) async {
//         await pumpModalForUI(
//           tester,
//           Consumer(
//               builder: (context, ref, child) => MoodLevelEditorModal(ref: ref)),
//           screenSize: const Size(375, 667),
//         );

//         // Enter long text
//         const longText =
//             'This is a very long mood note that tests text field overflow handling in small screens with extensive content that might cause layout issues.';
//         await tester.enterText(find.byType(TextField), longText);
//         await tester.pumpAndSettle();

//         // Check for overflow
//         checkForOverflow(tester, 'MoodLevelEditorModal with long text',
//             const Size(375, 667));
//       });
//     });

//     group('EnergyLevelEditorModal UI Tests', () {
//       testWidgets('displays energy grid without overflow across screen sizes',
//           (WidgetTester tester) async {
//         for (final size in standardTestSizes) {
//           await pumpModalForUI(
//             tester,
//             Consumer(
//                 builder: (context, ref, child) =>
//                     EnergyLevelEditorModal(ref: ref)),
//             screenSize: size,
//           );

//           // Assert: Modal should be present
//           expect(find.byType(EnergyLevelEditorModal), findsOneWidget,
//               reason:
//                   'Modal should be present on ${size.width}x${size.height}');

//           // Assert: Energy level buttons should be present (1-10)
//           for (int i = 1; i <= 10; i++) {
//             expect(find.text('$i'), findsOneWidget,
//                 reason:
//                     'Energy level $i should be present on ${size.width}x${size.height}');
//           }

//           // Check for overflow
//           checkForOverflow(tester, 'EnergyLevelEditorModal', size);
//         }
//       });
//     });

//     group('TaskEditorModal UI Tests', () {
//       testWidgets('displays task form without overflow across screen sizes',
//           (WidgetTester tester) async {
//         for (final size in standardTestSizes) {
//           await pumpModalForUI(
//             tester,
//             Consumer(
//                 builder: (context, ref, child) => TaskEditorModal(ref: ref)),
//             screenSize: size,
//           );

//           // Assert: Modal should be present
//           expect(find.byType(TaskEditorModal), findsOneWidget,
//               reason:
//                   'Modal should be present on ${size.width}x${size.height}');

//           // Assert: Essential form fields should be present
//           expect(find.text('Title*'), findsOneWidget,
//               reason:
//                   'Title field should be present on ${size.width}x${size.height}');
//           expect(find.text('Description'), findsOneWidget,
//               reason:
//                   'Description field should be present on ${size.width}x${size.height}');
//           expect(find.text('Status'), findsOneWidget,
//               reason:
//                   'Status field should be present on ${size.width}x${size.height}');

//           // Check for overflow
//           checkForOverflow(tester, 'TaskEditorModal', size);
//         }
//       });

//       testWidgets('handles long task content without overflow',
//           (WidgetTester tester) async {
//         final longTask = ModalUITestData.getTaskWithLongContent();

//         await pumpModalForUI(
//           tester,
//           Consumer(
//               builder: (context, ref, child) =>
//                   TaskEditorModal(ref: ref, existing: longTask)),
//           screenSize: const Size(375, 667),
//         );

//         // Assert: Modal should handle long content
//         expect(find.byType(TaskEditorModal), findsOneWidget,
//             reason: 'Modal should handle long task content');

//         // Check for overflow
//         checkForOverflow(
//             tester, 'TaskEditorModal with long content', const Size(375, 667));
//       });
//     });

//     group('HabitEditorModal UI Tests', () {
//       testWidgets('displays habit form without overflow across screen sizes',
//           (WidgetTester tester) async {
//         for (final size in standardTestSizes) {
//           await pumpModalForUI(
//             tester,
//             Consumer(
//                 builder: (context, ref, child) => HabitEditorModal(ref: ref)),
//             screenSize: size,
//           );

//           // Assert: Modal should be present
//           expect(find.byType(HabitEditorModal), findsOneWidget,
//               reason:
//                   'Modal should be present on ${size.width}x${size.height}');

//           // Assert: Essential fields should be present
//           expect(find.text('Title'), findsOneWidget,
//               reason:
//                   'Title field should be present on ${size.width}x${size.height}');
//           expect(find.text('Description'), findsOneWidget,
//               reason:
//                   'Description field should be present on ${size.width}x${size.height}');

//           // Check for overflow
//           checkForOverflow(tester, 'HabitEditorModal', size);
//         }
//       });

//       testWidgets('handles long habit content without overflow',
//           (WidgetTester tester) async {
//         final longHabit = ModalUITestData.getHabitWithLongContent();

//         await pumpModalForUI(
//           tester,
//           Consumer(
//               builder: (context, ref, child) =>
//                   HabitEditorModal(ref: ref, existing: longHabit)),
//           screenSize: const Size(375, 667),
//         );

//         // Assert: Modal should handle long content
//         expect(find.byType(HabitEditorModal), findsOneWidget,
//             reason: 'Modal should handle long habit content');

//         // Check for overflow
//         checkForOverflow(
//             tester, 'HabitEditorModal with long content', const Size(375, 667));
//       });
//     });

//     group('MedicationEditorModal UI Tests', () {
//       testWidgets(
//           'displays medication form without overflow across screen sizes',
//           (WidgetTester tester) async {
//         for (final size in standardTestSizes) {
//           await pumpModalForUI(
//             tester,
//             Consumer(
//                 builder: (context, ref, child) =>
//                     MedicationEditorModal(ref: ref)),
//             screenSize: size,
//           );

//           // Assert: Modal should be present
//           expect(find.byType(MedicationEditorModal), findsOneWidget,
//               reason:
//                   'Modal should be present on ${size.width}x${size.height}');

//           // Assert: Essential medication fields should be present
//           expect(find.text('Name'), findsOneWidget,
//               reason:
//                   'Name field should be present on ${size.width}x${size.height}');
//           expect(find.text('Dose'), findsOneWidget,
//               reason:
//                   'Dose field should be present on ${size.width}x${size.height}');
//           expect(find.text('Unit'), findsOneWidget,
//               reason:
//                   'Unit field should be present on ${size.width}x${size.height}');

//           // Check for overflow
//           checkForOverflow(tester, 'MedicationEditorModal', size);
//         }
//       });

//       testWidgets('handles long medication content without overflow',
//           (WidgetTester tester) async {
//         final longMedication = ModalUITestData.getMedicationWithLongContent();

//         await pumpModalForUI(
//           tester,
//           Consumer(
//               builder: (context, ref, child) =>
//                   MedicationEditorModal(ref: ref, existing: longMedication)),
//           screenSize: const Size(375, 667),
//         );

//         // Assert: Modal should handle long content
//         expect(find.byType(MedicationEditorModal), findsOneWidget,
//             reason: 'Modal should handle long medication content');

//         // Check for overflow
//         checkForOverflow(tester, 'MedicationEditorModal with long content',
//             const Size(375, 667));
//       });

//       testWidgets('displays dose tracking UI without overflow',
//           (WidgetTester tester) async {
//         final multiDoseMed = MedicationModel(
//           id: 'multi-dose',
//           name: 'Test Medication',
//           dose: 500.0,
//           unit: 'mg',
//           frequency: 'daily',
//           timesPerDay: 3,
//           userId: 'test-user',
//           createdAt: testSelectedDate,
//           updatedAt: testSelectedDate,
//           completedDates: [],
//         );

//         await pumpModalForUI(
//           tester,
//           Consumer(
//               builder: (context, ref, child) =>
//                   MedicationEditorModal(ref: ref, existing: multiDoseMed)),
//           screenSize: const Size(375, 667),
//         );

//         // Assert: Should show dose tracking UI
//         expect(find.byType(LinearProgressIndicator), findsOneWidget,
//             reason: 'Dose tracking progress should be shown');

//         // Check for overflow
//         checkForOverflow(tester, 'MedicationEditorModal with dose tracking',
//             const Size(375, 667));
//       });
//     });

//     group('SymptomEditorModal UI Tests', () {
//       testWidgets('displays symptom form without overflow across screen sizes',
//           (WidgetTester tester) async {
//         for (final size in standardTestSizes) {
//           await pumpModalForUI(
//             tester,
//             Consumer(
//                 builder: (context, ref, child) => SymptomEditorModal(ref: ref)),
//             screenSize: size,
//           );

//           // Assert: Modal should be present
//           expect(find.byType(SymptomEditorModal), findsOneWidget,
//               reason:
//                   'Modal should be present on ${size.width}x${size.height}');

//           // Assert: Essential symptom fields should be present - look for specific widgets instead of text
//           expect(find.byType(TextField), findsAtLeastNWidgets(2),
//               reason:
//                   'Name and Notes fields should be present on ${size.width}x${size.height}');

//           // Fix: Look for the dropdown widget instead of text
//           expect(find.byType(DropdownButtonFormField<String>), findsOneWidget,
//               reason:
//                   'Category dropdown should be present on ${size.width}x${size.height}');

//           // Assert: Severity slider should be present
//           expect(find.byType(Slider), findsOneWidget,
//               reason:
//                   'Severity slider should be present on ${size.width}x${size.height}');

//           // Check for overflow
//           checkForOverflow(tester, 'SymptomEditorModal', size);
//         }
//       });

//       testWidgets('handles long symptom content without overflow',
//           (WidgetTester tester) async {
//         final longSymptom = ModalUITestData.getSymptomWithLongContent();

//         await pumpModalForUI(
//           tester,
//           Consumer(
//               builder: (context, ref, child) =>
//                   SymptomEditorModal(ref: ref, existing: longSymptom)),
//           screenSize: const Size(375, 667),
//         );

//         // Assert: Modal should handle long content
//         expect(find.byType(SymptomEditorModal), findsOneWidget,
//             reason: 'Modal should handle long symptom content');

//         // Check for overflow
//         checkForOverflow(tester, 'SymptomEditorModal with long content',
//             const Size(375, 667));
//       });
//     });
//   });

//   // --------------------------------------------------------------------------
//   // Modal Interaction Tests
//   // --------------------------------------------------------------------------

//   group('Modal Interaction Tests', () {
//     testWidgets('mood modal saves correctly without UI errors',
//         (WidgetTester tester) async {
//       await pumpModalForUI(
//         tester,
//         Consumer(
//             builder: (context, ref, child) => MoodLevelEditorModal(ref: ref)),
//         screenSize: const Size(768, 1024),
//       );

//       // Select mood level
//       await tester.tap(find.text('7'));
//       await tester.pumpAndSettle();

//       // Enter notes
//       await tester.enterText(find.byType(TextField), 'Test notes');
//       await tester.pumpAndSettle();

//       // Save
//       await tester.tap(find.text('Save'));
//       await tester.pumpAndSettle();

//       // Verify controller was called
//       verify(mockController.addMood(any, any)).called(1);

//       // Check for overflow after interaction
//       checkForOverflow(
//           tester, 'MoodLevelEditorModal after save', const Size(768, 1024));
//     });

//     testWidgets('energy modal saves correctly without UI errors',
//         (WidgetTester tester) async {
//       await pumpModalForUI(
//         tester,
//         Consumer(
//             builder: (context, ref, child) => EnergyLevelEditorModal(ref: ref)),
//         screenSize: const Size(768, 1024),
//       );

//       // Select energy level
//       await tester.tap(find.text('5'));
//       await tester.pumpAndSettle();

//       // Save
//       await tester.tap(find.text('Save'));
//       await tester.pumpAndSettle();

//       // Verify controller was called
//       verify(mockController.addEnergy(any, any)).called(1);

//       // Check for overflow after interaction
//       checkForOverflow(
//           tester, 'EnergyLevelEditorModal after save', const Size(768, 1024));
//     });

//     testWidgets('task modal scrolls properly on small screens',
//         (WidgetTester tester) async {
//       await pumpModalForUI(
//         tester,
//         Consumer(builder: (context, ref, child) => TaskEditorModal(ref: ref)),
//         screenSize: const Size(375, 667),
//       );

//       // Find scrollable content
//       expect(find.byType(SingleChildScrollView), findsWidgets,
//           reason: 'Should have scrollable content on small screens');

//       // Try to scroll to bottom
//       final scrollable = find.byType(SingleChildScrollView).first;
//       await tester.drag(scrollable, const Offset(0, -300));
//       await tester.pumpAndSettle();

//       // Check for overflow after scrolling
//       checkForOverflow(
//           tester, 'TaskEditorModal after scrolling', const Size(375, 667));
//     });

//     testWidgets('habit modal dropdown interactions work without overflow',
//         (WidgetTester tester) async {
//       await pumpModalForUI(
//         tester,
//         Consumer(builder: (context, ref, child) => HabitEditorModal(ref: ref)),
//         screenSize: const Size(375, 667),
//       );

//       // Tap frequency dropdown
//       await tester.tap(find.byType(DropdownButtonFormField<String>));
//       await tester.pumpAndSettle();

//       // Select weekly
//       await tester.tap(find.text('Weekly').last);
//       await tester.pumpAndSettle();

//       // Check for overflow after dropdown interaction
//       checkForOverflow(
//           tester, 'HabitEditorModal after dropdown', const Size(375, 667));
//     });

//     testWidgets('medication modal dose counters work without overflow',
//         (WidgetTester tester) async {
//       final multiDoseMed = MedicationModel(
//         id: 'multi-dose',
//         name: 'Test Medication',
//         dose: 500.0,
//         unit: 'mg',
//         frequency: 'daily',
//         timesPerDay: 3,
//         userId: 'test-user',
//         createdAt: testSelectedDate,
//         updatedAt: testSelectedDate,
//         completedDates: [],
//       );

//       await pumpModalForUI(
//         tester,
//         Consumer(
//             builder: (context, ref, child) =>
//                 MedicationEditorModal(ref: ref, existing: multiDoseMed)),
//         screenSize: const Size(375, 667),
//       );

//       // Tap increase dose button - use warnIfMissed: false to avoid warnings
//       await tester.tap(find.byIcon(Icons.add_circle), warnIfMissed: false);
//       await tester.pumpAndSettle();

//       // Tap decrease dose button
//       await tester.tap(find.byIcon(Icons.remove_circle), warnIfMissed: false);
//       await tester.pumpAndSettle();

//       // Check for overflow after counter interactions
//       checkForOverflow(
//           tester,
//           'MedicationEditorModal after counter interaction',
//           const Size(375, 667));
//     });

//     testWidgets('symptom modal severity slider works without overflow',
//         (WidgetTester tester) async {
//       await pumpModalForUI(
//         tester,
//         Consumer(
//             builder: (context, ref, child) => SymptomEditorModal(ref: ref)),
//         screenSize: const Size(375, 667),
//       );

//       // Interact with severity slider
//       final slider = find.byType(Slider);
//       await tester.drag(slider, const Offset(100, 0));
//       await tester.pumpAndSettle();

//       // Check for overflow after slider interaction
//       checkForOverflow(tester, 'SymptomEditorModal after slider interaction',
//           const Size(375, 667));
//     });
//   });

//   // Clean up after all tests
//   tearDownAll(() {
//     // Don't call setSurfaceSize in tearDownAll as it's not allowed outside of test context
//   });
// }
