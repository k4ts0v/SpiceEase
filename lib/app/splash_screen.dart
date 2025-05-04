import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/app/app_initializer.dart';
import 'package:spiceease/app/app_wrapper.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/features/auth/presentation/auth_controller.dart';
import 'package:spiceease/features/auth/presentation/auth_screen.dart';

/// The SplashScreen widget determines the initial state of the app and
/// navigates the user to the appropriate page depending on the state.
class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Fetches the app's initialization state using [appInitializerProvider].
    final init = ref.watch(appInitializerProvider);
    print('SplashScreen build - init state: ${init}');

    return init.when(
      /// Shows a loading screen while the app initializes.
      // loading: () => _buildLoading(),
      loading: () {
      print('SplashScreen - showing loading state');
      return _buildLoading();
    },
    error: (e, st) {
      print('SplashScreen - error state: $e');
      return _buildError(e.toString(), ref);
    },
    data: (_) {
      final authState = ref.watch(authControllerProvider);
      print('SplashScreen - auth state: ${authState.user != null ? 'logged in' : 'not logged in'}');
      return _handleAuthStateWithDelay(context, ref, authState);
    },

      // /// Displays an error screen if the initialization fails.
      // error: (e, st) => _buildError(e.toString(), ref),
      // data: (_) {
      //   /// Navigates to the appropriate screen based on the authentication state.
      //   final authState = ref.watch(authControllerProvider);
      //   return _handleAuthStateWithDelay(context, ref, authState);
      // },
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
  // ...existing code...

  Widget _buildError(String error, WidgetRef ref) {
    return Builder(
      builder: (context) {
        Future.microtask(() async {
          final authService = ref.read(authServiceProvider);

          if (error.toLowerCase().contains('authexception')) {
            // Try to validate the session first
            final isValid = await authService.validateSession();
            if (!isValid) {
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }
              return;
            }
          }

          // Show error dialog for non-auth errors or if session is valid
          if (context.mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Initialization Error'),
                content: Text(error),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }
        });
        return const Scaffold();
      },
    );
  }

  /// Introduces a delay before handling the authentication state and navigation.
  ///
  /// - Parameters:
  ///   - [context]: The [BuildContext] of the widget.
  ///   - [ref]: The [WidgetRef] to watch providers.
  ///   - [state]: The current [AuthState] of the user.
  /// - Returns: A loading UI while transitioning between states.
    Widget _handleAuthStateWithDelay(
      BuildContext context, WidgetRef ref, AuthState state) {
    // Add a short delay to ensure proper initialization
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        _handleNavigation(context, ref, state);
      } else {
        print("context is not mounted");
      }
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
    if (state.error != null) {
      if (state.error!.contains('AuthException')) {
        print("navigating to auth screen");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    } else if (state.user != null) {
      print("navigating to app wrapper");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppWrapper()),
      );
    } else {
      print("navigating to auth screen");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }
}
