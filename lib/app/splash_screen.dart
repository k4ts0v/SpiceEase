import 'package:flutter/material.dart';
import 'package:spiceease/l10n/app_localizations.dart';

/// A simple splash screen that shows the app logo and loading indicator
///
/// Features:
/// - Displays app logo with fallback icon if asset is missing
/// - Shows app title with theme-appropriate styling
/// - Loading indicator with customizable message
/// - Responsive design that adapts to different screen sizes
/// - Internationalization support for loading messages
class SplashScreen extends StatelessWidget {
  /// Optional custom loading message to display
  /// Falls back to localized "Loading..." text if not provided
  final String? message;

  const SplashScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===== APP LOGO WITH FALLBACK (EXACT SAME AS AUTH SCREEN) =====
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset(
                'assets/icons/spiceease_logo.png',
                width: 150,
                height: 150,
                // Use the exact same errorBuilder as auth screen
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.restaurant_menu,
                    size: 75,
                    color: Theme.of(context).colorScheme.primary,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ===== APP TITLE =====
            Text(
              "SpiceEase",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),

            // ===== LOADING INDICATOR =====
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),

            // ===== LOADING MESSAGE =====
            Text(
              message ?? AppLocalizations.of(context)!.loading,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}