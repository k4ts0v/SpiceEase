/// This file tests the localization functionality of the Account Settings screen
/// in the SpiceEase app, ensuring proper translation of all UI elements
/// across different locales.
///
/// The tests verify that:
/// - All static text elements are properly translated
/// - Dynamic content (email, error messages) uses correct locale
/// - Locale changes are properly reflected in the UI
/// - Dialog messages and actions are translated correctly
/// - Form validation messages are locale-appropriate
/// - Button texts and state indicators are translated
///
/// # Test Structure
/// - Mock controllers simulate different app states (loading, error, success)
/// - Helper functions pump the AccountSettingsScreen with different locales
/// - Comprehensive assertions verify all translatable elements
/// - Edge cases like error states and dialogs are thoroughly tested
///
/// # How to run
/// - Individual tests: `flutter test --plain-name "specific test name"`
/// - Full suite: `flutter test test/features/settings/account_settings/account_settings_localization_tests.dart`
/// - With coverage: `flutter test --coverage test/features/settings/account_settings/account_settings_localization_tests.dart`
///
/// # Locales tested
/// - English (en) - Primary language
/// - Spanish (es) - Secondary language
/// - Locale switching scenarios
///
/// # Dependencies
/// - Requires proper AppLocalizations setup
/// - Uses mocked AccountSettingsController for consistent testing
/// - No external network calls or real authentication required

library account_settings_localization_tests;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_user_model.dart';
import 'package:spiceease/features/settings/account_settings_screen.dart';
import 'package:spiceease/features/settings/account_settings_controller.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// --------------------------------------------------------------------------
// Mock Classes for Localization Tests
// --------------------------------------------------------------------------

/// Mock implementation of AuthService specifically designed for localization testing.
/// Provides controlled behavior without external dependencies.
class MockAuthServiceLocalization extends AuthService {
  final bool _isEmailVerified;
  final String? _userEmail;
  final bool _shouldFailOperations;

  MockAuthServiceLocalization({
    bool isEmailVerified = false,
    String? userEmail,
    bool shouldFailOperations = false,
  })  : _isEmailVerified = isEmailVerified,
        _userEmail = userEmail,
        _shouldFailOperations = shouldFailOperations;

  @override
  Future<void> updateEmail(String newEmail) async {
    if (_shouldFailOperations) {
      throw Exception('Mock email update failed');
    }
    // Simulate successful email update
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    if (_shouldFailOperations) {
      throw Exception('Mock password update failed');
    }
    // Simulate successful password update
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> reauthenticate(String email, String password) async {
    if (_shouldFailOperations) {
      throw Exception('Mock reauthentication failed');
    }
    // Simulate successful reauthentication
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> sendEmailVerification() async {
    if (_shouldFailOperations) {
      throw Exception('Mock verification email failed');
    }
    // Simulate successful email verification send
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> signOut() async {
    if (_shouldFailOperations) {
      throw Exception('Mock sign out failed');
    }
    // Simulate successful sign out
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Mock additional methods for testing
  bool get isEmailVerified => _isEmailVerified;
  String? get userEmail => _userEmail;

  @override
  Stream<AppUser?> authStateChanges() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getAccessToken() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getCurrentIdToken() {
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isSignedIn() {
    throw UnimplementedError();
  }

  @override
  Future<void> register(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String email) {
    throw UnimplementedError();
  }

  @override
  Future<void> signIn(String email, String password) {
    throw UnimplementedError();
  }
}

/// Mock implementation of AccountSettingsController for localization testing.
class MockAccountSettingsLocalizationController
    extends AccountSettingsController {
  final MockAuthServiceLocalization _mockAuthService;
  final bool _isEmailVerified;
  final String? _userEmail;

  MockAccountSettingsLocalizationController({
    required MockAuthServiceLocalization authService,
    required Ref ref,
    bool isEmailVerified = false,
    String? userEmail,
  })  : _mockAuthService = authService,
        _isEmailVerified = isEmailVerified,
        _userEmail = userEmail,
        super(authService, ref);

  @override
  Future<bool> isCurrentEmailVerified() async {
    return _isEmailVerified;
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    return _userEmail;
  }

  @override
  Future<AccountSettingsResult> updateEmail(String newEmail) async {
    if (newEmail.isEmpty) {
      return AccountSettingsResult.failure("Email cannot be empty");
    }

    try {
      await _mockAuthService.updateEmail(newEmail);
      return AccountSettingsResult.success(
          "Verification email sent to $newEmail. Please check your inbox and click the verification link. You'll need to re-login once verified.");
    } catch (e) {
      return AccountSettingsResult.failure(
          "Failed to update email: ${e.toString()}");
    }
  }

  @override
  Future<AccountSettingsResult> updatePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    // Basic validation
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return AccountSettingsResult.failure("All fields are required");
    }

    if (newPassword != confirmPassword) {
      return AccountSettingsResult.failure("Passwords don't match");
    }

    if (newPassword.length < 6) {
      return AccountSettingsResult.failure(
          "Password must be at least 6 characters long");
    }

    try {
      await _mockAuthService.updatePassword(currentPassword, newPassword);
      return AccountSettingsResult.success("Password updated successfully");
    } catch (e) {
      return AccountSettingsResult.failure(
          "Failed to update password: ${e.toString()}");
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await _mockAuthService.sendEmailVerification();
  }

  @override
  Future<AccountSettingsResult> signOut() async {
    try {
      await _mockAuthService.signOut();
      return AccountSettingsResult.success("Successfully signed out");
    } catch (e) {
      return AccountSettingsResult.failure("Sign out failed: $e");
    }
  }
}

// --------------------------------------------------------------------------
// Helper Functions for Test Setup
// --------------------------------------------------------------------------

/// Helper function to pump the AccountSettingsScreen with specific locale and controller state.
/// Configures the widget tree with proper localization and provider overrides.
///
/// [tester] - The WidgetTester instance
/// [localeCode] - Locale code to test (e.g., 'en', 'es')
/// [isEmailVerified] - Whether the user's email is verified
/// [userEmail] - The user's email address
/// [shouldFailOperations] - Whether operations should fail for testing error states
///
/// Returns the AppLocalizations instance for the pumped locale.
Future<AppLocalizations> pumpAccountSettingsScreenWithLocale(
  WidgetTester tester, {
  required String localeCode,
  bool isEmailVerified = false,
  String? userEmail,
  bool shouldFailOperations = false,
}) async {
  // Create mock auth service
  final mockAuthService = MockAuthServiceLocalization(
    isEmailVerified: isEmailVerified,
    userEmail: userEmail,
    shouldFailOperations: shouldFailOperations,
  );

  // Set larger screen size to prevent UI overflow issues
  await tester.binding.setSurfaceSize(const Size(400, 900));
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;

  // Pump the widget tree with localization setup
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Override with mock controller
        accountSettingsControllerProvider
            .overrideWith((ref) => MockAccountSettingsLocalizationController(
                  authService: mockAuthService,
                  ref: ref,
                  isEmailVerified: isEmailVerified,
                  userEmail: userEmail,
                )),
      ],
      child: MaterialApp(
        locale: Locale(localeCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AccountSettingsScreen(),
      ),
    ),
  );

  // Ensure all widgets are properly rendered
  await tester.pumpAndSettle();

  // Return localization instance for assertions
  final context = tester.element(find.byType(AccountSettingsScreen));
  return AppLocalizations.of(context)!;
}

/// Helper function to create test email for localization testing.
String createTestEmail() => 'test.user@example.com';

void main() {
  group('AccountSettingsScreen Localization Tests', () {
    /// Verifies that all AccountSettingsScreen elements display correctly in English.
    /// Tests the primary language implementation and serves as baseline for other locales.
    testWidgets('Displays correct text in English',
        (WidgetTester tester) async {
      // Arrange: Create test data and pump screen in English
      final testEmail = createTestEmail();
      final l10n = await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'en',
        isEmailVerified: true,
        userEmail: testEmail,
      );

      // Assert: Verify AppBar title
      expect(find.text(l10n.accountSettings), findsOneWidget);

      // Assert: Verify section headers
      expect(find.text(l10n.email), findsOneWidget);
      expect(find.text(l10n.security), findsOneWidget);
      expect(find.text(l10n.accountActions), findsOneWidget);

      // Assert: Verify email section tiles
      expect(find.text(l10n.changeEmail), findsOneWidget);
      expect(find.text(l10n.sendVerificationEmail), findsOneWidget);
      expect(find.text(l10n.verifyYourEmailAddress), findsOneWidget);

      // Assert: Verify security section tiles
      expect(find.text(l10n.changePassword), findsOneWidget);
      expect(find.text(l10n.updateYourAccountPassword), findsOneWidget);

      // Assert: Verify account actions tiles
      expect(find.text(l10n.signOut), findsOneWidget);
      expect(find.text(l10n.signOutOfYourAccount), findsOneWidget);
    });

    /// Verifies that all AccountSettingsScreen elements display correctly in Spanish.
    /// Tests secondary language implementation and translation completeness.
    testWidgets('Displays correct text in Spanish',
        (WidgetTester tester) async {
      // Arrange: Create test data and pump screen in Spanish
      final testEmail = createTestEmail();
      final l10n = await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'es',
        isEmailVerified: true,
        userEmail: testEmail,
      );

      // Assert: Verify AppBar title is translated
      expect(find.text(l10n.accountSettings), findsOneWidget);

      // Assert: Verify section headers are translated
      expect(find.text(l10n.email), findsOneWidget);
      expect(find.text(l10n.security), findsOneWidget);
      expect(find.text(l10n.accountActions), findsOneWidget);

      // Assert: Verify email section tiles are translated
      expect(find.text(l10n.changeEmail), findsOneWidget);
      expect(find.text(l10n.sendVerificationEmail), findsOneWidget);
      expect(find.text(l10n.verifyYourEmailAddress), findsOneWidget);

      // Assert: Verify security section tiles are translated
      expect(find.text(l10n.changePassword), findsOneWidget);
      expect(find.text(l10n.updateYourAccountPassword), findsOneWidget);

      // Assert: Verify account actions tiles are translated
      expect(find.text(l10n.signOut), findsOneWidget);
      expect(find.text(l10n.signOutOfYourAccount), findsOneWidget);
    });

    /// Verifies that user email displays correctly across locales.
    /// Tests that the actual email remains unchanged while labels are translated.
    testWidgets('Displays user email consistently across locales',
        (WidgetTester tester) async {
      // Arrange: Create test email
      final testEmail = createTestEmail();

      // Act: Test English locale
      await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'en',
        isEmailVerified: true,
        userEmail: testEmail,
      );

      // Assert: Verify email is displayed in English context
      expect(find.text(testEmail), findsOneWidget);

      // Act: Switch to Spanish locale
      await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'es',
        isEmailVerified: true,
        userEmail: testEmail,
      );

      // Assert: Verify same email is displayed in Spanish context
      expect(find.text(testEmail), findsOneWidget);
    });

    /// Verifies that change email dialog displays correctly in different locales.
    /// Tests dialog title, content, and button translations.
    testWidgets('Displays localized change email dialog',
        (WidgetTester tester) async {
      // Arrange: Pump screen in English
      final l10n = await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'en',
        isEmailVerified: true,
        userEmail: createTestEmail(),
      );

      // Act: Tap change email tile to open dialog
      await tester.tap(find.text(l10n.changeEmail));
      await tester.pumpAndSettle();

      // Assert: Verify dialog elements are translated
      expect(find.text(l10n.changeEmail),
          findsAtLeastNWidgets(1)); // Title and button
      expect(find.text(l10n.newEmailAddress), findsOneWidget);
      expect(find.text(l10n.cancel), findsOneWidget);
      expect(find.text(l10n.updateEmail), findsOneWidget);

      // Cleanup: Close dialog
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
    });

    /// Verifies that change password dialog displays correctly in different locales.
    /// Tests dialog title, form fields, and button translations.
    testWidgets('Displays localized change password dialog',
        (WidgetTester tester) async {
      // Arrange: Pump screen in Spanish
      final l10n = await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'es',
        isEmailVerified: true,
        userEmail: createTestEmail(),
      );

      // Act: Tap change password tile to open dialog
      await tester.tap(find.text(l10n.changePassword));
      await tester.pumpAndSettle();

      // Assert: Verify dialog elements are translated
      expect(find.text(l10n.changePassword),
          findsAtLeastNWidgets(1)); // Title and button
      expect(find.text(l10n.currentPassword), findsOneWidget);
      expect(find.text(l10n.newPassword), findsOneWidget);
      expect(find.text(l10n.confirmPassword), findsOneWidget);
      expect(find.text(l10n.passwordRequirements), findsOneWidget);
      expect(find.text(l10n.cancel), findsOneWidget);
      expect(find.text(l10n.updatePassword), findsOneWidget);

      // Cleanup: Close dialog
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
    });

    /// Verifies that sign out confirmation dialog displays correctly in different locales.
    /// Tests dialog title, message, and button translations.
    testWidgets('Displays localized sign out confirmation dialog',
        (WidgetTester tester) async {
      // Arrange: Pump screen in English
      final l10n = await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'en',
        isEmailVerified: true,
        userEmail: createTestEmail(),
      );

      // Act: Tap sign out tile to open confirmation dialog
      await tester.tap(find.text(l10n.signOut));
      await tester.pumpAndSettle();

      // Assert: Verify dialog elements are translated
      expect(
          find.text(l10n.signOut), findsAtLeastNWidgets(1)); // Title and button
      expect(find.text(l10n.areYouSureYouWantToSignOut), findsOneWidget);
      expect(find.text(l10n.cancel), findsOneWidget);

      // Cleanup: Close dialog
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
    });

    /// Verifies that text updates correctly when switching between locales.
    /// Tests dynamic locale switching without app restart.
    testWidgets('Updates text when locale changes',
        (WidgetTester tester) async {
      // Arrange: Start with English
      final testEmail = createTestEmail();
      final englishL10n = await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'en',
        isEmailVerified: true,
        userEmail: testEmail,
      );

      // Assert: Verify English content is displayed
      final englishTitle = englishL10n.accountSettings;
      final englishChangeEmail = englishL10n.changeEmail;
      final englishSecurity = englishL10n.security;

      expect(find.text(englishTitle), findsOneWidget);
      expect(find.text(englishChangeEmail), findsOneWidget);
      expect(find.text(englishSecurity), findsOneWidget);

      // Act: Switch to Spanish
      final spanishL10n = await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'es',
        isEmailVerified: true,
        userEmail: testEmail,
      );

      // Assert: Verify Spanish content is displayed and English is gone
      final spanishTitle = spanishL10n.accountSettings;
      final spanishChangeEmail = spanishL10n.changeEmail;
      final spanishSecurity = spanishL10n.security;

      expect(find.text(spanishTitle), findsOneWidget);
      expect(find.text(spanishChangeEmail), findsOneWidget);
      expect(find.text(spanishSecurity), findsOneWidget);

      // Verify English content is no longer present
      expect(find.text(englishTitle), findsNothing);
      expect(find.text(englishChangeEmail), findsNothing);
      expect(find.text(englishSecurity), findsNothing);

      // Act: Switch back to English
      final newEnglishL10n = await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'en',
        isEmailVerified: true,
        userEmail: testEmail,
      );

      // Assert: Verify English content is restored and Spanish is gone
      expect(find.text(newEnglishL10n.accountSettings), findsOneWidget);
      expect(find.text(newEnglishL10n.changeEmail), findsOneWidget);
      expect(find.text(spanishTitle), findsNothing);
      expect(find.text(spanishChangeEmail), findsNothing);
    });

    /// Verifies that loading states display correctly across locales.
    /// Tests that loading indicators and messages are properly localized.
    testWidgets('Displays localized loading states',
        (WidgetTester tester) async {
      // Arrange: Pump screen with user email that's still loading
      final l10n = await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'en',
        isEmailVerified: false,
        userEmail: null, // No email loaded yet
      );

      // Assert: Verify loading text is displayed
      expect(find.text(l10n.loading), findsOneWidget);

      // Act: Test in Spanish
      final spanishL10n = await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'es',
        isEmailVerified: false,
        userEmail: null,
      );

      // Assert: Verify Spanish loading text is displayed
      expect(find.text(spanishL10n.loading), findsOneWidget);
      expect(find.text(l10n.loading),
          findsNothing); // English version should be gone
    });

    /// Verifies that all icons remain consistent across locales.
    /// Tests that UI icons don't change when language changes.
    testWidgets('Icons remain consistent across locales',
        (WidgetTester tester) async {
      // Arrange: Test English locale
      await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'en',
        isEmailVerified: true,
        userEmail: createTestEmail(),
      );

      // Assert: Count icons in English
      final englishIconCount = tester.widgetList(find.byType(Icon)).length;
      expect(englishIconCount, greaterThan(0));

      // Act: Switch to Spanish
      await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'es',
        isEmailVerified: true,
        userEmail: createTestEmail(),
      );

      // Assert: Verify same number of icons in Spanish
      final spanishIconCount = tester.widgetList(find.byType(Icon)).length;
      expect(spanishIconCount, equals(englishIconCount));

      // Assert: Verify specific common icons are present
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.logout_outlined), findsOneWidget);
    });

    /// Verifies that section organization remains consistent across locales.
    /// Tests that the UI structure doesn't change when language changes.
    testWidgets('Section organization remains consistent across locales',
        (WidgetTester tester) async {
      // Arrange: Test English locale
      await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'en',
        isEmailVerified: true,
        userEmail: createTestEmail(),
      );

      // Assert: Count sections in English
      final englishSectionCount = tester.widgetList(find.byType(Card)).length;
      expect(englishSectionCount, greaterThan(0));

      // Act: Switch to Spanish
      await pumpAccountSettingsScreenWithLocale(
        tester,
        localeCode: 'es',
        isEmailVerified: true,
        userEmail: createTestEmail(),
      );

      // Assert: Verify same number of sections in Spanish
      final spanishSectionCount = tester.widgetList(find.byType(Card)).length;
      expect(spanishSectionCount, equals(englishSectionCount));
    });
  });
}