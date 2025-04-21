// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:spiceease/app/home_screen.dart';
// import 'package:spiceease/features/auth/presentation/auth_controller.dart';
// import 'package:spiceease/features/auth/presentation/auth_screen.dart';
// import 'package:spiceease/l10n/app_localizations.dart';
// import 'package:spiceease/l10n/locale_provider.dart';
// import 'package:spiceease/l10n/l10n.dart';


// // Mock classes
// class MockAuthController extends Mock implements AuthController {}

// class MockAuthState extends Mock implements AuthState {}

// void main() {
//   // setUpAll(() {
//   //   registerFallbackValue<AuthState>(MockAuthState());
//   //   registerFallbackValue<Locale>(const Locale('en'));
//   // });

//   group('AuthScreen Widget Tests', () {
//     late MockAuthController mockController;
//     late StateNotifierProvider<AuthController, AuthState> provider;

//     setUp(() {
//       mockController = MockAuthController();
//       provider = StateNotifierProvider<AuthController, AuthState>(
//           (ref) => mockController);

//       when(() => mockController.state).thenReturn(AuthState.initial());
//     });

//     Future<void> pumpAuthScreen(
//       WidgetTester tester, {
//       required AuthState state,
//     }) async {
//       when(() => mockController.state).thenReturn(state);
//       whenListen<AuthState>(
//         mockController,
//         Stream.value(state),
//         initialState: state,
//       );

//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [authControllerProvider.overrideWithProvider(provider)],
//           child: MaterialApp(
//             localizationsDelegates: const [
//               AppLocalizations.delegate,
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               DefaultCupertinoLocalizations.delegate,
//             ],
//             supportedLocales: L10n.all,
//             home: const AuthScreen(),
//           ),
//         ),
//       );
//       await tester.pumpAndSettle();
//     }

//     testWidgets('shows logo and form fields', (tester) async {
//       final state = AuthState.initial();
//       await pumpAuthScreen(tester, state: state);

//       expect(find.byType(Image), findsOneWidget);
//       expect(find.byType(TextFormField), findsNWidgets(state.isLogin ? 2 : 3));
//     });

//     testWidgets('toggles password visibility', (tester) async {
//       final state = AuthState.initial().copyWith(isPasswordVisible: false);
//       await pumpAuthScreen(tester, state: state);

//       final visibilityIcon = find.byIcon(Icons.visibility);
//       expect(visibilityIcon, findsOneWidget);

//       await tester.tap(visibilityIcon);
//       verify(() => mockController.togglePasswordVisibility()).called(1);
//     });

//     testWidgets('shows confirm password field when registering',
//         (tester) async {
//       final state = AuthState.initial()
//           .copyWith(isLogin: false, isConfirmPasswordVisible: true);
//       await pumpAuthScreen(tester, state: state);

//       expect(find.widgetWithText(TextFormField, 'Confirm Password'),
//           findsOneWidget);
//     });

//     testWidgets('navigates to HomeScreen on successful login', (tester) async {
//       final prevState = AuthState.initial().copyWith(user: null);
//       final nextState = AuthState.initial().copyWith(user: 'userId');

//       whenListen<AuthState>(
//           mockController, Stream.fromIterable([prevState, nextState]));
//       when(() => mockController.state).thenReturn(nextState);

//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [authControllerProvider.overrideWithProvider(provider)],
//           child: MaterialApp(
//             localizationsDelegates: const [
//               AppLocalizations.delegate,
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               DefaultCupertinoLocalizations.delegate,
//             ],
//             supportedLocales: L10n.all,
//             home: const AuthScreen(),
//           ),
//         ),
//       );
//       await tester.pumpAndSettle();

//       expect(find.byType(HomeScreen), findsOneWidget);
//     });

//     testWidgets('reset password dialog appears', (tester) async {
//       final state = AuthState.initial();
//       await pumpAuthScreen(tester, state: state);

//       // Trigger forgot password
//       final forgotButton = find.text(
//           AppLocalizations.of(tester.element(find.byType(AuthScreen)))
//                   ?.forgotPassword ??
//               'Forgot Password');
//       await tester.tap(forgotButton);
//       await tester.pumpAndSettle();

//       expect(find.byType(AlertDialog), findsOneWidget);
//       expect(
//           find.text(
//               AppLocalizations.of(tester.element(find.byType(AlertDialog)))
//                       ?.passwordReset ??
//                   'Password Reset'),
//           findsOneWidget);
//     });
//   });
// }
