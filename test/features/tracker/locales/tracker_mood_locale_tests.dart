// filepath: /home/k4ts0v/Projects/spiceease/test/features/tracker/tracker_mood_locale_tests_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/features/tracker/presentation/tracker_screen.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/l10n/locale_provider.dart';
import 'package:spiceease/main.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/features/tracker/presentation/widgets/calendar_widget.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:spiceease/core/auth/auth_user_model.dart';
import 'package:spiceease/core/database/database_service.dart';

import '../ui/tracker_screen_ui_test.mocks.dart';

class MockAuthService extends Mock implements AuthService {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tracker Screen Localization Tests', () {
    late SharedPreferences sharedPreferences;
    late MockAuthService mockAuthService;
    late MockDatabaseService mockDatabaseService;

    setUp(() async {
      // Initialize shared preferences
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();

      // Initialize mocks
      mockAuthService = MockAuthService();
      mockDatabaseService = MockDatabaseService();

      // Stub necessary methods for AuthService
      when(mockAuthService.initialize()).thenAnswer((_) async {});
      when(mockAuthService.authStateChanges()).thenAnswer((_) =>
          Stream.value(AppUser(uid: 'test-user', email: 'test@example.com')));
      when(mockAuthService.isSignedIn()).thenAnswer((_) async => true);
      when(mockAuthService.getCurrentUser())
          .thenAnswer((_) async => AppUser(uid: 'test-user', email: 'test@example.com'));
      when(mockAuthService.validateSession()).thenAnswer((_) async => true);
      when(mockAuthService.signOut()).thenAnswer((_) async {});
    });

    group('English Locale', () {
      testWidgets('Calendar displays localized month and day names in English',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localeProvider.overrideWith((ref) => LocaleNotifier()
                ..state = const Locale('en')),
              authServiceProvider.overrideWithValue(mockAuthService),
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: TrackerScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final now = DateTime.now();
        final monthName = DateFormat('MMMM yyyy', 'en').format(now);
        final dayName = DateFormat('E', 'en').format(now);

        final monthNameFinder = find.text(monthName);
        final dayNameFinder = find.text(dayName);

        expect(monthNameFinder, findsWidgets,
            reason: "Calendar should display month name in English.");
        expect(dayNameFinder, findsWidgets,
            reason: "Calendar should display day name in English (3-letter).");
      });
    });

    group('Spanish Locale', () {
      testWidgets('Calendar displays localized month and day names in Spanish',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localeProvider.overrideWith((ref) => LocaleNotifier()
                ..state = const Locale('es')),
              authServiceProvider.overrideWithValue(mockAuthService),
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
            ],
            child: const MaterialApp(
              locale: Locale('es'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: TrackerScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final now = DateTime.now();
        final monthName = DateFormat('MMMM yyyy', 'es').format(now);
        final dayName = DateFormat('E', 'es').format(now).toLowerCase();

        final monthNameFinder = find.text(monthName);
        final dayNameFinder = find.text(dayName);

        expect(monthNameFinder, findsWidgets,
            reason: "Calendar should display month name in Spanish.");
        expect(dayNameFinder, findsWidgets,
            reason:
                "Calendar should display day name in Spanish (3-letter lowercase).");
      });
    });
  });
}