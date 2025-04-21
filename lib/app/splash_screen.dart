import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/app/app_initializer.dart';
import 'package:spiceease/app/app_wrapper.dart';
import 'package:spiceease/app/home_screen.dart';
import 'package:spiceease/features/auth/presentation/auth_controller.dart';
import 'package:spiceease/features/auth/presentation/auth_screen.dart';

/// The SplashScreen widget determines the initial state of the app and
/// navigates the user to the appropriate page depending on the state.
// class SplashScreen extends ConsumerWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final initState = ref.watch(appInitializerProvider);

//     /// Fetches the authentication state using [authControllerProvider].
//     final authState = ref.watch(authControllerProvider);

//     /// Displays different UI states based on the initialization state.
//     return initState.when(
//       loading: () => _buildLoading(),

//       error: (error, stack) => _buildError(error.toString()),

//       data: (_) => _handleAuthStateWithDelay(context, ref, authState),
//     );
//   }

class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Fetches the app's initialization state using [appInitializerProvider].
    final init = ref.watch(appInitializerProvider);

    return init.when(
      /// Shows a loading screen while the app initializes.
      loading: () => _buildLoading(),

      /// Displays an error screen if the initialization fails.
      error: (e, st) => _buildError(e.toString()),
      data: (_) {
        /// Navigates to the appropriate screen based on the authentication state.
        final authState = ref.watch(authControllerProvider);
        return _handleAuthStateWithDelay(context, ref, authState);
      },
    );
  }

  /// Builds the loading screen with a spinner and a logo.
  ///
  /// - Returns: A loading UI widget.
  Widget _buildLoading() => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Displays the app logo from the assets folder.
              Image(
                image: AssetImage('assets/images/logo_transparent.png'),
                width: 150.0,
                height: 150.0,
              ),

              /// Adds spacing between logo and spinner.
              SizedBox(height: 20.0),

              /// Displays a circular progress indicator.
              CircularProgressIndicator(),

              /// Adds spacing between spinner and loading text.
              SizedBox(height: 10.0),

              /// Displays the loading message.
              Text(
                'Loading app...',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      );

  /// Builds an error screen to display error messages during initialization.
  ///
  /// - Parameter [error]: The error message as a string.
  /// - Returns: A widget displaying the error message.
  Widget _buildError(String error) => Scaffold(
        body: Center(
          child: Card(
            elevation: 4, // Adds shadow to the error card.
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Initialization Error: $error',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ),
        ),
      );

  /// Introduces a delay before handling the authentication state and navigation.
  ///
  /// - Parameters:
  ///   - [context]: The [BuildContext] of the widget.
  ///   - [ref]: The [WidgetRef] to watch providers.
  ///   - [state]: The current [AuthState] of the user.
  /// - Returns: A loading UI while transitioning between states.
  Widget _handleAuthStateWithDelay(
      BuildContext context, WidgetRef ref, AuthState state) {
    Future.delayed(const Duration(milliseconds: 500), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNavigation(context, ref, state);
      });
    });
    return _buildLoading();
  }

  /// Handles navigation based on the user's authentication state.
  ///
  /// - Parameters:
  ///   - [context]: The [BuildContext] of the widget.
  ///   - [ref]: The [WidgetRef] to watch providers.
  ///   - [state]: The current [AuthState] of the user.
  void _handleNavigation(BuildContext context, WidgetRef ref, AuthState state) {
    if (state.error?.contains('AuthException') == true) {
      /// Navigates to the authentication page if there is an authentication error.
      Navigator.of(context).pushReplacementNamed('/authPage');
    } else {
      /// Navigates to the main app if the user is authenticated successfully.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppWrapper()),
      );
    }
  }
}
