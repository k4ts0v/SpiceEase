// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:spiceease/core/auth/firebase_auth_service.dart';

// // Generate mocks
// @GenerateMocks([
//   FirebaseAuth,
// ], customMocks: [
//   MockSpec<UserCredential>(as: #MockUserCredential),
//   MockSpec<User>(as: #MockUser),
// ])
// import 'firebase_auth_service_test.mocks.dart';

// void main() {
//   // Initialize binding once at the start
//   TestWidgetsFlutterBinding.ensureInitialized();

//   late FirebaseAuthService authService;
//   late MockFirebaseAuth mockFirebaseAuth;

//   setUp(() {
//     mockFirebaseAuth = MockFirebaseAuth();
//     authService = FirebaseAuthService();
//     authService.configureForTest(auth: mockFirebaseAuth);
//   });

//   tearDown(() {
//     authService.resetForTest();
//   });

//   group('Singleton', () {
//     test('returns same instance', () {
//       final instance1 = FirebaseAuthService();
//       final instance2 = FirebaseAuthService();
//       expect(instance1, same(instance2));
//     });
//   });

//   group('Initialization', () {
//     test('sets FirebaseAuth via test configuration', () {
//       expect(authService.auth, mockFirebaseAuth);
//     });
//   });

//   group('Configuration', () {
//     test('configureForTest sets FirebaseAuth instance', () {
//       final service = FirebaseAuthService();
//       authService.configureForTest(auth: mockFirebaseAuth);

//       expect(service.auth, mockFirebaseAuth);
//     });

//     test('resetForTest clears FirebaseAuth instance', () {
//       authService.resetForTest();
//       expect(() => authService.auth, throwsStateError);
//     });
//   });

//   group('Authentication Methods', () {
//     const email = 'test@example.com';
//     const password = 'securePassword123';

//     test('signIn delegates to FirebaseAuth', () async {
//       when(mockFirebaseAuth.signInWithEmailAndPassword(
//         email: anyNamed('email'),
//         password: anyNamed('password'),
//       )).thenAnswer((_) async => MockUserCredential());

//       await authService.signIn(email, password);

//       verify(mockFirebaseAuth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       )).called(1);
//     });

//     test('register delegates to FirebaseAuth', () async {
//       when(mockFirebaseAuth.createUserWithEmailAndPassword(
//         email: anyNamed('email'),
//         password: anyNamed('password'),
//       )).thenAnswer((_) async => MockUserCredential());

//       await authService.register(email, password);

//       verify(mockFirebaseAuth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       )).called(1);
//     });

//     test('signOut delegates to FirebaseAuth', () async {
//       when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

//       await authService.signOut();

//       verify(mockFirebaseAuth.signOut()).called(1);
//     });

//     test('isSignedIn returns correct value', () async {
//       when(mockFirebaseAuth.currentUser).thenReturn(MockUser());
//       expect(await authService.isSignedIn(), true);

//       when(mockFirebaseAuth.currentUser).thenReturn(null);
//       expect(await authService.isSignedIn(), false);
//     });
//   });

//   group('Streams', () {
//     test('authStateChanges returns correct UID', () async {
//       final mockUser = MockUser();
//       when(mockUser.uid).thenReturn('12345');
//       when(mockFirebaseAuth.authStateChanges())
//           .thenAnswer((_) => Stream.value(mockUser));

//       final stream = authService.authStateChanges();
//       final result = await stream.first;

//       expect(result, '12345');
//     });

//     test('authStateChanges emits null if user is not signed in', () async {
//       when(mockFirebaseAuth.authStateChanges())
//           .thenAnswer((_) => Stream.value(null));

//       final stream = authService.authStateChanges();
//       final result = await stream.first;

//       expect(result, null);
//     });
//   });

//   group('Error Handling', () {
//     const email = 'test@example.com';
//     const password = 'securePassword123';

//     test('signIn throws FirebaseAuthException', () async {
//       when(mockFirebaseAuth.signInWithEmailAndPassword(
//         email: anyNamed('email'),
//         password: anyNamed('password'),
//       )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

//       expect(() => authService.signIn(email, password),
//           throwsA(isA<FirebaseAuthException>()));
//     });

//     test('register throws FirebaseAuthException', () async {
//       when(mockFirebaseAuth.createUserWithEmailAndPassword(
//         email: anyNamed('email'),
//         password: anyNamed('password'),
//       )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

//       expect(() => authService.register(email, password),
//           throwsA(isA<FirebaseAuthException>()));
//     });

//     test('signOut throws FirebaseAuthException', () async {
//       when(mockFirebaseAuth.signOut())
//           .thenThrow(FirebaseAuthException(code: 'sign-out-error'));

//       expect(
//           () => authService.signOut(), throwsA(isA<FirebaseAuthException>()));
//     });

//     test('authStateChanges propagates errors', () async {
//       when(mockFirebaseAuth.authStateChanges()).thenAnswer(
//           (_) => Stream.error(FirebaseAuthException(code: 'stream-error')));

//       final stream = authService.authStateChanges();
//       expect(stream, emitsError(isA<FirebaseAuthException>()));
//     });
//   });

//   group('Concurrency', () {
//     test('handles concurrent authentication requests', () async {
//       when(mockFirebaseAuth.signInWithEmailAndPassword(
//         email: anyNamed('email'),
//         password: anyNamed('password'),
//       )).thenAnswer((_) async => MockUserCredential());

//       final futures = [
//         Future(() => authService.signIn('test1@example.com', 'password1')),
//         Future(() => authService.signIn('test2@example.com', 'password2')),
//       ];

//       await expectLater(Future.wait(futures), completes);
//       verify(mockFirebaseAuth.signInWithEmailAndPassword(
//         email: anyNamed('email'),
//         password: anyNamed('password'),
//       )).called(2);
//     });

//     test('handles concurrent stream access', () async {
//       final mockUser = MockUser();
//       when(mockUser.uid).thenReturn('123');
//       when(mockFirebaseAuth.authStateChanges())
//           .thenAnswer((_) => Stream.value(mockUser));

//       final futures = [
//         Future(() => authService.authStateChanges().first),
//         Future(() => authService.authStateChanges().first),
//       ];

//       final results = await Future.wait(futures);
//       expect(results, ['123', '123']);
//     });
//   });

//   group('Type Safety', () {
//     test('authStateChanges returns correct type', () {
//       when(mockFirebaseAuth.authStateChanges())
//           .thenAnswer((_) => Stream.value(null));

//       expect(authService.authStateChanges(), isA<Stream<String?>>());
//     });
//   });
// }
