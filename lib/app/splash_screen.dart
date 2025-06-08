import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/app/app_initializer.dart';
import 'package:spiceease/app/app_wrapper.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/features/auth/presentation/auth_controller.dart';
import 'package:spiceease/features/auth/presentation/auth_screen.dart';
import 'package:spiceease/l10n/app_localizations.dart';

/// The SplashScreen widget determines the initial state of the app and
/// navigates the user to the appropriate page depending on the state.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    /// Fetches the app's initialization state using [appInitializerProvider].
    final init = ref.watch(appInitializerProvider);
    debugPrint('SplashScreen build - init state: $init');

    return init.when(
      /// Shows a loading screen while the app initializes.
      loading: () {
        debugPrint('SplashScreen - showing loading state');
        return _buildLoading(context);
      },
      error: (e, st) {
        debugPrint('SplashScreen - error state: $e');
        return _buildError(e.toString(), ref, context);
      },
      data: (_) {
        final authState = ref.watch(authControllerProvider);
        debugPrint(
            'SplashScreen - auth state: ${authState.user != null ? 'logged in' : 'not logged in'}');
        return _handleAuthStateWithDelay(context, ref, authState);
      },
    );
  }

  /// Builds the loading screen with a spinner and a logo.
  ///
  /// - Returns: A loading UI widget.
  Widget _buildLoading(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Displays the app logo from the assets folder.
            const Image(
              image: AssetImage('assets/icons/spiceease_logo.png'),
              width: 150.0,
              height: 150.0,
            ),

            /// Adds spacing between logo and spinner.
            const SizedBox(height: 20.0),

            /// Displays a circular progress indicator.
            const CircularProgressIndicator(),

            /// Adds spacing between spinner and loading text.
            const SizedBox(height: 10.0),

            /// Displays the loading message.
            Text(
              localizations.loading,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an error screen to display error messages during initialization.
  ///
  /// - Parameter [error]: The error message as a string.
  /// - Returns: A widget displaying the error message.
  Widget _buildError(String error, WidgetRef ref, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
            title: Text(localizations.initializationError),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text(localizations.close),
              ),
            ],
          ),
        );
      }
    });
    return const Scaffold();
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
        debugPrint("context is not mounted");
      }
    });
    return _buildLoading(context);
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
        debugPrint("navigating to auth screen");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    } else if (state.user != null) {
      debugPrint("navigating to app wrapper");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppWrapper()),
      );
    } else {
      debugPrint("navigating to auth screen");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }
}
