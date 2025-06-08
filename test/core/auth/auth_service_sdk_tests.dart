/// This file contains contract tests for the FirebaseAuthService (SDK version),
/// using the Mockito package to mock the FirebaseAuth SDK and related dependencies.
///
/// These tests verify that the service:
/// - Calls the correct FirebaseAuth SDK methods with the expected arguments
/// - Correctly handles and returns user data from the SDK
/// - Handles error cases (like invalid credentials or email already in use)
///
/// # How these tests work
/// - All FirebaseAuth SDK calls are intercepted using mock classes.
/// - No real Firebase backend or network is used; everything is simulated.
///
/// # Why use these tests?
/// - To ensure your SDK service correctly calls FirebaseAuth methods.
/// - To catch regressions if you change authentication logic.
/// - To verify integration with authentication and error handling.
///
/// # How to run
/// - Run with `flutter test` as usual.
/// - No external dependencies or network required.
///
/// # See also
/// - https://docs.flutter.dev/testing
/// - https://pub.dev/packages/mockito

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spiceease/core/auth/firebase_auth_service.dart';
import 'package:spiceease/core/auth/auth_exception.dart';

import 'auth_service_tests.mocks.dart'; // Generated mock file

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Group related tests together for clarity and organization.
  group('FirebaseAuthService SDK Tests', () {
    // Declare variables for the service and its dependencies.
    late FirebaseAuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    // The setUp() function runs before every test in this group.
    // It prepares a fresh instance of the service and mocks for each test.
    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();

      // Use the real service but inject the mock FirebaseAuth
      authService = FirebaseAuthService();
      authService.setTestAuth(mockFirebaseAuth);

      // Set up mock user properties
      when(mockUser.uid).thenReturn('test_uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.emailVerified).thenReturn(true);
      when(mockUserCredential.user).thenReturn(mockUser);
    });

    /// Verifies that signIn calls the correct FirebaseAuth method and returns the expected user.
    test('should sign in successfully', () async {
      // Arrange: Set up the mock to return a user credential
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act: Call the signIn method
      await authService.signIn('test@example.com', 'password123');

      // Assert: Verify the correct method was called and user is as expected
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
      expect(mockFirebaseAuth.currentUser?.uid, 'test_uid');
      expect(mockFirebaseAuth.currentUser?.email, 'test@example.com');
    });

    /// Verifies that signIn throws an AuthException on invalid credentials.
    test('should throw AuthException on invalid credentials', () async {
      // Arrange: Set up the mock to throw an exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      // Act & Assert: The signIn call should throw an AuthException
      expect(
        () => authService.signIn('test@example.com', 'wrong_password'),
        throwsA(isA<AuthException>()),
      );
    });

    /// Verifies that register calls the correct FirebaseAuth method.
    test('should register successfully', () async {
      // Arrange: Set up the mock to return a user credential
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      // Act: Call the register method
      await authService.register('newuser@example.com', 'password123');

      // Assert: Verify the correct method was called
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'newuser@example.com',
        password: 'password123',
      )).called(1);
    });

    /// Verifies that register throws an AuthException if the email is already in use.
    test('should throw AuthException on email already in use', () async {
      // Arrange: Set up the mock to throw an exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      // Act & Assert: The register call should throw an AuthException
      expect(
        () => authService.register('existing@example.com', 'password123'),
        throwsA(isA<AuthException>()),
      );
    });

    /// Verifies that resetPassword calls the correct FirebaseAuth method.
    test('should send password reset email successfully', () async {
      // Arrange: Set up the mock to complete successfully
      when(mockFirebaseAuth.sendPasswordResetEmail(
        email: anyNamed('email'),
      )).thenAnswer((_) async {});

      // Act: Call the resetPassword method
      await authService.resetPassword('test@example.com');

      // Assert: Verify the correct method was called
      verify(mockFirebaseAuth.sendPasswordResetEmail(
        email: 'test@example.com',
      )).called(1);
    });

    /// Verifies that resetPassword throws an AuthException on invalid email.
    test('should throw AuthException on invalid email for password reset', () async {
      // Arrange: Set up the mock to throw an exception
      when(mockFirebaseAuth.sendPasswordResetEmail(
        email: anyNamed('email'),
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // Act & Assert: The resetPassword call should throw an AuthException
      expect(
        () => authService.resetPassword('invalid@example.com'),
        throwsA(isA<AuthException>()),
      );
    });

    /// Verifies that signOut calls the correct FirebaseAuth method.
    test('should sign out successfully', () async {
      // Arrange: Set up the mock to complete successfully
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act: Call the signOut method
      await authService.signOut();

      // Assert: Verify the correct method was called
      verify(mockFirebaseAuth.signOut()).called(1);
    });
  });
}