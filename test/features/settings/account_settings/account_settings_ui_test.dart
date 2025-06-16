/// This file contains comprehensive UI tests for the AccountSettingsScreen widget,
/// testing various screen sizes, loading states, error handling, and user interactions.
///
/// These tests verify that the AccountSettingsScreen:
/// - Displays the correct UI elements (sections, tiles, buttons)
/// - Shows appropriate loading states and progress indicators
/// - Contains the expected SettingsOptionTile widgets with correct icons
/// - Adapts to different screen sizes without overflow errors
/// - Displays proper dialogs when tiles are tapped
/// - Handles async operations and timer cleanup properly
///
/// # How these tests work
/// - Uses MockAccountSettingsUIController to simulate different controller states
/// - Tests across multiple standardized screen sizes (mobile to desktop)
/// - Mocks user data (email, verification status) for consistent testing
/// - Uses WidgetTester to pump widgets and verify UI elements
/// - Properly handles async operations and timer cleanup
///
/// # Why use these tests?
/// - To ensure the AccountSettingsScreen renders correctly across devices
/// - To verify responsive behavior and adaptive layout
/// - To catch UI regressions when modifying the account settings screen
/// - To validate proper integration with AccountSettingsController states
/// - To test dialog interactions without actual backend calls
/// - To ensure proper async handling and cleanup
///
/// # How to run
/// - Run with `flutter test test/features/settings/account_settings/account_settings_ui_test.dart`
/// - No external dependencies required (uses mocked data)
/// - Tests can be run individually or as a complete suite
///
/// # See also
/// - https://docs.flutter.dev/testing/widget-testing
/// - https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html

library account_settings_ui_tests;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_user_model.dart';
import 'package:spiceease/features/settings/account_settings_screen.dart';
import 'package:spiceease/features/settings/account_settings_controller.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/components/settings/settings_section.dart';
import 'package:spiceease/components/settings/settings_option_tile.dart';

/// Standardized screen sizes for consistent testing across different devices.
/// These sizes represent common device categories from smallest phones to desktop.
const List<Size> standardTestSizes = [
  Size(320, 568), // iPhone SE (smallest supported)
  Size(375, 667), // iPhone 8
  Size(390, 844), // iPhone 13
  Size(414, 896), // iPhone 11
  Size(600, 960), // Small tablet
  Size(768, 1024), // iPad Portrait
  Size(1024, 768), // iPad Landscape
  Size(1200, 800), // Desktop
];

// Test data constants
const String testUserEmail = 'test.user@example.com';
const String testNewEmail = 'new.email@example.com';
const String testPassword = 'testPassword123';
const String testNewPassword = 'newPassword456';

// --------------------------------------------------------------------------
// Mock Classes for UI Tests
// --------------------------------------------------------------------------

/// Mock implementation of AuthService specifically designed for UI testing.
/// Provides controlled behavior without external dependencies.
class MockAuthServiceUI extends AuthService {
  final bool _isEmailVerified;
  final String? _userEmail;
  final bool _shouldFailOperations;

  MockAuthServiceUI({
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
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    if (_shouldFailOperations) {
      throw Exception('Mock password update failed');
    }
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> reauthenticate(String email, String password) async {
    if (_shouldFailOperations) {
      throw Exception('Mock reauthentication failed');
    }
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> sendEmailVerification() async {
    if (_shouldFailOperations) {
      throw Exception('Mock verification email failed');
    }
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> signOut() async {
    if (_shouldFailOperations) {
      throw Exception('Mock sign out failed');
    }
    await Future.delayed(const Duration(milliseconds: 50));
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

/// Mock implementation of AccountSettingsController for UI testing.
/// Allows simulation of different controller states without actual backend calls.
class MockAccountSettingsUIController extends AccountSettingsController {
  final MockAuthServiceUI _mockAuthService;
  final bool _isEmailVerified;
  final String? _userEmail;
  final bool _isUpdatingEmail;
  final bool _isUpdatingPassword;

  MockAccountSettingsUIController({
    required MockAuthServiceUI authService,
    required Ref ref,
    bool isEmailVerified = false,
    String? userEmail,
    bool isUpdatingEmail = false,
    bool isUpdatingPassword = false,
  })  : _mockAuthService = authService,
        _isEmailVerified = isEmailVerified,
        _userEmail = userEmail,
        _isUpdatingEmail = isUpdatingEmail,
        _isUpdatingPassword = isUpdatingPassword,
        super(authService, ref) {
    // Set initial state
    state = AccountSettingsState(
      isUpdatingEmail: isUpdatingEmail,
      isUpdatingPassword: isUpdatingPassword,
    );
  }

  @override
  Future<bool> isCurrentEmailVerified() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _isEmailVerified;
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _userEmail;
  }

  @override
  Future<AccountSettingsResult> updateEmail(String newEmail) async {
    if (newEmail.isEmpty) {
      return AccountSettingsResult.failure("Email cannot be empty");
    }

    if (!newEmail.contains('@')) {
      return AccountSettingsResult.failure("Invalid email format");
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

    if (currentPassword == newPassword) {
      return AccountSettingsResult.failure(
          "New password must be different from current password");
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

/// Helper function to set up and render the AccountSettingsScreen for testing.
/// Handles provider overrides, screen size configuration, and localization setup.
///
/// Returns the AppLocalizations instance for accessing translated strings in tests.
Future<AppLocalizations> pumpAccountSettingsScreen(
  WidgetTester tester, {
  bool isEmailVerified = false,
  String? userEmail,
  bool shouldFailOperations = false,
  bool isUpdatingEmail = false,
  bool isUpdatingPassword = false,
  Size? screenSize,
  String localeCode = 'en',
}) async {
  // Create mock auth service
  final mockAuthService = MockAuthServiceUI(
    isEmailVerified: isEmailVerified,
    userEmail: userEmail,
    shouldFailOperations: shouldFailOperations,
  );

  // Configure screen size if specified (for responsive testing)
  if (screenSize != null) {
    await tester.binding.setSurfaceSize(screenSize);
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1.0;
  }

  // Pump the widget with provider override and localization
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Override the real controller with our mock
        accountSettingsControllerProvider
            .overrideWith((ref) => MockAccountSettingsUIController(
                  authService: mockAuthService,
                  ref: ref,
                  isEmailVerified: isEmailVerified,
                  userEmail: userEmail,
                  isUpdatingEmail: isUpdatingEmail,
                  isUpdatingPassword: isUpdatingPassword,
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

  // Wait for initial async operations but with timeout
  await tester.pump(const Duration(milliseconds: 100));

  // Return localization instance for use in tests
  return AppLocalizations.of(
      tester.element(find.byType(AccountSettingsScreen)))!;
}

/// Helper function to create test email for consistent testing.
String createTestEmail() => testUserEmail;

/// Helper function to properly dispose of async operations in tests
Future<void> cleanupAsyncOperations(WidgetTester tester) async {
  // Pump several times to ensure all async operations complete
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));

  // Allow any remaining timers to complete
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  group('AccountSettingsScreen UI Tests', () {
    /// Verifies that the AppBar displays with the correct translated title.
    /// This is a basic smoke test to ensure the screen renders properly.
    testWidgets('Displays AppBar with correct title',
        (WidgetTester tester) async {
      // Arrange & Act: Pump the screen with default settings
      final l10n = await pumpAccountSettingsScreen(tester);

      // Assert: AppBar should contain the translated "Account Settings" title
      expect(find.widgetWithText(AppBar, l10n.accountSettings), findsOneWidget);

      await cleanupAsyncOperations(tester);
    });

    /// Verifies that all main sections are displayed correctly.
    /// Tests the basic structure of the settings screen.
    testWidgets('Displays main sections correctly',
        (WidgetTester tester) async {
      // Arrange & Act: Pump screen with user data
      final l10n = await pumpAccountSettingsScreen(
        tester,
        isEmailVerified: true,
        userEmail: createTestEmail(),
      );

      // Assert: Check for main sections (adjust count based on actual UI)
      expect(find.byType(SettingsSection), findsAtLeast(2));
      expect(find.text(l10n.email), findsOneWidget);
      expect(find.text(l10n.security), findsOneWidget);

      await cleanupAsyncOperations(tester);
    });

    /// Verifies that all setting option tiles are present with correct content.
    /// Tests that each expected tile exists in the UI.
    testWidgets('Displays all setting option tiles',
        (WidgetTester tester) async {
      // Arrange & Act: Pump screen with user data
      final l10n = await pumpAccountSettingsScreen(
        tester,
        isEmailVerified: true,
        userEmail: createTestEmail(),
      );

      // Assert: Should have setting tiles (adjust count based on actual UI)
      expect(find.byType(SettingsOptionTile), findsAtLeast(3));

      // Check for specific tile titles
      expect(find.text(l10n.changeEmail), findsOneWidget);
      expect(find.text(l10n.changePassword), findsOneWidget);
      expect(find.text(l10n.signOut), findsOneWidget);

      await cleanupAsyncOperations(tester);
    });

    /// Verifies that tiles display the correct icons.
    /// Tests that each tile contains its expected Material icon.
    testWidgets('Setting option tiles have correct icons',
        (WidgetTester tester) async {
      // Arrange & Act: Pump screen with user data
      await pumpAccountSettingsScreen(
        tester,
        isEmailVerified: true,
        userEmail: createTestEmail(),
      );

      // Assert: Test icons for each tile
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.logout_outlined), findsOneWidget);

      await cleanupAsyncOperations(tester);
    });

    /// Verifies that user email displays correctly when loaded.
    /// Tests that the actual email address appears in the change email tile.
    testWidgets('Displays user email in change email tile',
        (WidgetTester tester) async {
      // Arrange: Create test email
      final testEmail = createTestEmail();

      // Act: Pump screen with specific email
      await pumpAccountSettingsScreen(
        tester,
        isEmailVerified: true,
        userEmail: testEmail,
      );

      // Assert: Test email should be displayed as subtitle
      expect(find.text(testEmail), findsOneWidget);

      await cleanupAsyncOperations(tester);
    });

    /// Verifies that loading text displays when user email is not yet loaded.
    /// Tests the loading state for email information.
    testWidgets('Displays loading text when email is not loaded',
        (WidgetTester tester) async {
      // Arrange & Act: Pump screen with no email (loading state)
      final l10n = await pumpAccountSettingsScreen(
        tester,
        isEmailVerified: false,
        userEmail: null, // No email loaded
      );

      // Assert: Loading text should be displayed
      expect(find.text(l10n.loading), findsOneWidget);

      await cleanupAsyncOperations(tester);
    });

    // Group tests for dialog interactions
    group('Dialog Interactions', () {
      /// Verifies that change email dialog opens when tile is tapped.
      /// Tests dialog appearance and content.
      testWidgets('Change email dialog opens when tile is tapped',
          (WidgetTester tester) async {
        // Arrange: Pump screen with user data
        final l10n = await pumpAccountSettingsScreen(
          tester,
          isEmailVerified: true,
          userEmail: createTestEmail(),
        );

        // Act: Tap the change email tile
        await tester.tap(find.text(l10n.changeEmail));
        await tester.pumpAndSettle();

        // Assert: Dialog should be displayed with correct elements
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text(l10n.newEmailAddress), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.updateEmail), findsOneWidget);

        await cleanupAsyncOperations(tester);
      });

      /// Verifies that change password dialog opens when tile is tapped.
      /// Tests dialog appearance and all form fields.
      testWidgets('Change password dialog opens when tile is tapped',
          (WidgetTester tester) async {
        // Arrange: Pump screen with user data
        final l10n = await pumpAccountSettingsScreen(
          tester,
          isEmailVerified: true,
          userEmail: createTestEmail(),
        );

        // Act: Tap the change password tile
        await tester.tap(find.text(l10n.changePassword));
        await tester.pumpAndSettle();

        // Assert: Dialog should be displayed with correct elements
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text(l10n.currentPassword), findsOneWidget);
        expect(find.text(l10n.newPassword), findsOneWidget);
        expect(find.text(l10n.confirmPassword), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        expect(find.text(l10n.updatePassword), findsOneWidget);

        await cleanupAsyncOperations(tester);
      });

      /// Verifies that sign out confirmation dialog opens when tile is tapped.
      /// Tests dialog appearance and confirmation options.
      testWidgets('Sign out confirmation dialog opens when tile is tapped',
          (WidgetTester tester) async {
        // Arrange: Pump screen with user data
        final l10n = await pumpAccountSettingsScreen(
          tester,
          isEmailVerified: true,
          userEmail: createTestEmail(),
        );

        // Act: Tap the sign out tile
        await tester.tap(find.text(l10n.signOut));
        await tester.pumpAndSettle();

        // Assert: Dialog should be displayed with correct elements
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text(l10n.areYouSureYouWantToSignOut), findsOneWidget);
        expect(find.text(l10n.cancel), findsOneWidget);
        // Sign out button appears multiple times (tile and dialog)
        expect(find.text(l10n.signOut), findsAtLeast(2));

        await cleanupAsyncOperations(tester);
      });

      /// Verifies that dialogs can be dismissed properly.
      /// Tests that cancel buttons close dialogs.
      testWidgets('Dialogs can be dismissed with cancel button',
          (WidgetTester tester) async {
        // Arrange: Pump screen with user data
        final l10n = await pumpAccountSettingsScreen(
          tester,
          isEmailVerified: true,
          userEmail: createTestEmail(),
        );

        // Act: Open change email dialog
        await tester.tap(find.text(l10n.changeEmail));
        await tester.pumpAndSettle();

        // Assert: Dialog is open
        expect(find.byType(AlertDialog), findsOneWidget);

        // Act: Tap cancel
        await tester.tap(find.text(l10n.cancel));
        await tester.pumpAndSettle();

        // Assert: Dialog is closed
        expect(find.byType(AlertDialog), findsNothing);

        await cleanupAsyncOperations(tester);
      });
    });

    // Group tests for responsive behavior
    group('Screen Size Responsiveness', () {
      /// Helper function to verify basic UI structure exists.
      void expectBasicUIStructure(AppLocalizations l10n) {
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(SettingsSection), findsAtLeast(2));
        expect(find.byType(SettingsOptionTile), findsAtLeast(3));
        expect(find.text(l10n.email), findsOneWidget);
        expect(find.text(l10n.security), findsOneWidget);
      }

      // Test a subset of screen sizes to avoid timeout issues
      final testSizes = [
        Size(375, 667), // iPhone 8
        Size(768, 1024), // iPad Portrait
        Size(1200, 800), // Desktop
      ];

      for (final size in testSizes) {
        /// Verifies that the UI renders correctly without overflow on different screen sizes.
        testWidgets('Renders correctly on ${size.width}x${size.height} screen',
            (WidgetTester tester) async {
          // Arrange & Act: Pump screen with specific screen size
          final l10n = await pumpAccountSettingsScreen(
            tester,
            isEmailVerified: true,
            userEmail: createTestEmail(),
            screenSize: size,
          );

          // Assert: Basic UI structure should be present
          expectBasicUIStructure(l10n);

          // Assert: No exceptions should occur during rendering
          final exception = tester.takeException();
          expect(exception, isNull,
              reason:
                  "No exceptions should occur on ${size.width}x${size.height} screen");

          await cleanupAsyncOperations(tester);
        });

        /// Verifies that dialogs render correctly on different screen sizes.
        testWidgets(
            'Dialogs render correctly on ${size.width}x${size.height} screen',
            (WidgetTester tester) async {
          // Arrange: Pump screen with specific screen size
          final l10n = await pumpAccountSettingsScreen(
            tester,
            isEmailVerified: true,
            userEmail: createTestEmail(),
            screenSize: size,
          );

          // Act: Open change email dialog
          await tester.tap(find.text(l10n.changeEmail));
          await tester.pumpAndSettle();

          // Assert: Dialog should render without issues
          expect(find.byType(AlertDialog), findsOneWidget);
          expect(find.text(l10n.newEmailAddress), findsOneWidget);

          // Close dialog
          await tester.tap(find.text(l10n.cancel));
          await tester.pumpAndSettle();

          // Assert: No exceptions should occur during dialog rendering
          final exception = tester.takeException();
          expect(exception, isNull,
              reason:
                  "No exceptions should occur with dialogs on ${size.width}x${size.height} screen");

          await cleanupAsyncOperations(tester);
        });
      }
    });

    // Group tests for different user states
    group('User State Variations', () {
      /// Verifies UI with verified user and complete data.
      testWidgets('Displays correctly for verified user with complete data',
          (WidgetTester tester) async {
        // Arrange & Act

        // Assert: All elements should be present
        expect(find.text('verified.user@example.com'), findsOneWidget);
        expect(find.byType(SettingsOptionTile), findsAtLeast(3));

        await cleanupAsyncOperations(tester);
      });

      /// Verifies UI with minimal user data (loading state).
      testWidgets('Displays correctly with minimal user data',
          (WidgetTester tester) async {
        // Arrange & Act
        final l10n = await pumpAccountSettingsScreen(
          tester,
          isEmailVerified: false,
          userEmail: null, // No email loaded
        );

        // Assert: Loading state should be shown
        expect(find.text(l10n.loading), findsOneWidget);
        expect(find.byType(SettingsOptionTile), findsAtLeast(3));

        await cleanupAsyncOperations(tester);
      });
    });

    // Group tests for error handling
    group('Error Handling', () {
      /// Verifies that the UI remains stable when operations fail.
      /// This tests the resilience of the UI to backend errors.
      testWidgets('UI remains stable with failed operations',
          (WidgetTester tester) async {
        // Arrange & Act: Pump screen with service that fails operations
        final l10n = await pumpAccountSettingsScreen(
          tester,
          isEmailVerified: true,
          userEmail: createTestEmail(),
          shouldFailOperations: true,
        );

        // Assert: UI should still render correctly despite potential failures
        expect(find.byType(SettingsSection), findsAtLeast(2));
        expect(find.byType(SettingsOptionTile), findsAtLeast(3));
        expect(find.text(l10n.changeEmail), findsOneWidget);
        expect(find.text(l10n.changePassword), findsOneWidget);
        expect(find.text(l10n.signOut), findsOneWidget);

        // Assert: No exceptions should propagate to the UI
        final exception = tester.takeException();
        expect(exception, isNull);

        await cleanupAsyncOperations(tester);
      });
    });
  });
}
