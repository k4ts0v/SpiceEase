import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/tracker/presentation/widgets/calendar_widget.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // Initialize date formatting for all tests
  setUpAll(() {
    initializeDateFormatting();
  });

  group('CalendarWidget Localization Tests', () {
    testWidgets('Displays English month and day names',
        (WidgetTester tester) async {
      // 1. Arrange: Set up the test environment and data.
      // Define a fixed date for the calendar.
      final fixedDate = DateTime(2025, 5, 1); // May 2025

      // Pump the CalendarWidget inside a MaterialApp with the English locale.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedDateProvider.overrideWith((ref) => fixedDate),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CalendarWidget()),
          ),
        ),
      );

      // Wait for the widget to fully render.
      await tester.pumpAndSettle();

      // 2. Act: Find the widgets that display the month and day names.
      // Format the month name according to the locale
      final expectedMonthName = DateFormat.yMMMM('en').format(fixedDate);
      final monthFinder = find.text(expectedMonthName);

      // 3. Assert: Verify that the widgets display the correct localized text.
      // Verify that the English month name is displayed.
      expect(monthFinder, findsOneWidget,
          reason: "English month name should be displayed");

      // Verify that the English day names are displayed.
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
    });

    testWidgets('Displays Spanish month and day names',
        (WidgetTester tester) async {
      // 1. Arrange: Set up the test environment and data.
      // Define a fixed date for the calendar.
      final fixedDate = DateTime(2025, 5, 1); // May 2025

      // Pump the CalendarWidget inside a MaterialApp with the Spanish locale.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedDateProvider.overrideWith((ref) => fixedDate),
          ],
          child: const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CalendarWidget()),
          ),
        ),
      );

      // Wait for the widget to fully render.
      await tester.pumpAndSettle();

      // 2. Act: Find the widgets that display the month and day names.
      // Format the month name according to the locale
      final expectedMonthName = DateFormat.yMMMM('es').format(fixedDate);
      final monthFinder = find.text(expectedMonthName);

      // 3. Assert: Verify that the widgets display the correct localized text.
      // Verify that the Spanish month name is displayed.
      expect(monthFinder, findsOneWidget,
          reason: "Spanish month name should be displayed");

      // Verify that the Spanish day names are displayed.
      expect(find.text('lun'), findsOneWidget);
      expect(find.text('mar'), findsOneWidget);
      expect(find.text('mié'), findsOneWidget);
      expect(find.text('jue'), findsOneWidget);
      expect(find.text('vie'), findsOneWidget);
      expect(find.text('sáb'), findsOneWidget);
      expect(find.text('dom'), findsOneWidget);
    });

    testWidgets('Updates when locale changes', (WidgetTester tester) async {
      // 1. Arrange: Set up the test environment and data.
      // Define a fixed date for the calendar.
      final fixedDate = DateTime(2025, 5, 1);

      // Create a ProviderContainer to control the locale.
      final container = ProviderContainer(
        overrides: [
          selectedDateProvider.overrideWith((ref) => fixedDate),
        ],
      );

      // Pump the CalendarWidget inside a MaterialApp with the initial locale (English).
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CalendarWidget()),
          ),
        ),
      );

      // Wait for the widget to fully render.
      await tester.pumpAndSettle();

      // Verify that the initial locale is English.
      final expectedEnglishMonthName = DateFormat.yMMMM('en').format(fixedDate);
      expect(find.text(expectedEnglishMonthName), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);

      // 2. Act: Change the locale to Spanish.
      // Pump the CalendarWidget again with the Spanish locale.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CalendarWidget()),
          ),
        ),
      );

      // Wait for the widget to fully render.
      await tester.pumpAndSettle();

      // 3. Assert: Verify that the widget updates to display the Spanish locale.
      // Verify that the widget updates to display the Spanish locale.
      final expectedSpanishMonthName = DateFormat.yMMMM('es').format(fixedDate);
      expect(find.text(expectedSpanishMonthName), findsOneWidget);
      expect(find.text('lun'), findsOneWidget);
    });

    testWidgets('Month change matches expected locale output (in Spanish)',
        (WidgetTester tester) async {
      // 1. Arrange: Set up the test environment and data.
      // Define a fixed date for the calendar.
      final fixedDate = DateTime(2025, 5, 1);

      // Create a ProviderContainer to control the selected date.
      final container = ProviderContainer(
        overrides: [
          selectedDateProvider.overrideWith((ref) => fixedDate),
        ],
      );

      // Pump the CalendarWidget inside a MaterialApp with the Spanish locale.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: const Locale('es'), // Set the locale to Spanish
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CalendarWidget()),
          ),
        ),
      );

      // Wait for the widget to fully render.
      await tester.pumpAndSettle();

      // Verify that the initial locale is Spanish.
      final expectedInitialMonthName = DateFormat.yMMMM('es').format(fixedDate);
      expect(find.text(expectedInitialMonthName), findsOneWidget);

      // 2. Act: Change the month to June by swiping left on the calendar.
      // Find the CalendarWidget.
      final calendarFinder = find.byType(CalendarWidget);

      // Get the center of the CalendarWidget.
      final calendarCenter = tester.getCenter(calendarFinder);

      // Swipe left from the center of the CalendarWidget.
      await tester.dragFrom(calendarCenter, const Offset(-500, 0));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 3. Assert: Verify that the widget updates to display the Spanish locale for June.
      // Get the date for June 1, 2025
      final juneDate = DateTime(2025, 6, 1);

      // Format the month name according to the locale
      final expectedJuneMonthName = DateFormat.yMMMM('es').format(juneDate);

      // Verify that the widget updates to display the Spanish locale for June.
      expect(find.text(expectedJuneMonthName), findsOneWidget);
    });

    testWidgets('Month change matches expected locale output (in English)',
        (WidgetTester tester) async {
      // 1. Arrange: Set up the test environment and data.
      // Define a fixed date for the calendar.
      final fixedDate = DateTime(2025, 5, 1);

      // Create a ProviderContainer to control the selected date.
      final container = ProviderContainer(
        overrides: [
          selectedDateProvider.overrideWith((ref) => fixedDate),
        ],
      );

      // Pump the CalendarWidget inside a MaterialApp with the Spanish locale.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('en'), // Set the locale to Spanish
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: CalendarWidget()),
          ),
        ),
      );

      // Wait for the widget to fully render.
      await tester.pumpAndSettle();

      // Verify that the initial locale is Spanish.
      final expectedInitialMonthName = DateFormat.yMMMM('en').format(fixedDate);
      expect(find.text(expectedInitialMonthName), findsOneWidget);

      // 2. Act: Change the month to June by swiping left on the calendar.
      // Find the CalendarWidget.
      final calendarFinder = find.byType(CalendarWidget);

      // Get the center of the CalendarWidget.
      final calendarCenter = tester.getCenter(calendarFinder);

      // Swipe left from the center of the CalendarWidget.
      await tester.dragFrom(calendarCenter, const Offset(-500, 0));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 3. Assert: Verify that the widget updates to display the Spanish locale for June.
      // Get the date for June 1, 2025
      final juneDate = DateTime(2025, 6, 1);

      // Format the month name according to the locale
      final expectedJuneMonthName = DateFormat.yMMMM('en').format(juneDate);

      // Verify that the widget updates to display the Spanish locale for June.
      expect(find.text(expectedJuneMonthName), findsOneWidget);
    });
  });
}