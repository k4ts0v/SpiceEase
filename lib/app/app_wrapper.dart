import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiceease/app/app_initializer.dart';
import 'package:spiceease/data/providers/current_user_provider.dart';
import 'package:spiceease/features/auth/presentation/auth_screen.dart';
import 'package:spiceease/features/navigation_bar.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class AppWrapper extends ConsumerWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // First ensure app is initialized
    final appInitAsync = ref.watch(appInitializerProvider);
    final localizations = AppLocalizations.of(context)!;

    return appInitAsync.when(
      data: (_) {
        // App is initialized, now check user authentication status
        final isUserSignedInAsync = ref.watch(isUserSignedInProvider);

        return isUserSignedInAsync.when(
          data: (isSignedIn) {
            if (isSignedIn) {
              // User is authenticated and database is initialized
              return const NavBar();
            } else {
              // User not authenticated
              return const AuthScreen();
            }
          },
          loading: () =>
              _buildLoadingScreen(context, 'Checking authentication...'),
          error: (error, stackTrace) {
            debugPrint('Authentication check error: $error');
            _clearStoredTokensOnError(ref);
            return const AuthScreen();
          },
        );
      },
      loading: () => _buildLoadingScreen(context, localizations.loading),
      error: (error, stackTrace) {
        debugPrint('App initialization error: $error');
        return _buildErrorScreen(context, error.toString());
      },
    );
  }

  // TODO: do not build this here.
  /// Builds the loading screen with a spinner and a logo.
  Widget _buildLoadingScreen(BuildContext context, String message) {
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
              message,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an error screen
  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              'Initialization Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Restart the app initialization
                WidgetsBinding.instance.performReassemble();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Clear stored tokens when there's an error to force re-authentication
  void _clearStoredTokensOnError(WidgetRef ref) {
    Future.microtask(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          prefs.remove('auth_token'),
          prefs.remove('access_token'),
          prefs.remove('refresh_token'),
          prefs.remove('user_data'),
        ]);
        debugPrint('Cleared stored tokens due to error');
      } catch (e) {
        debugPrint('Error clearing tokens: $e');
      }
    });
  }
}
