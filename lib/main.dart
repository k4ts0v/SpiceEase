// Import core Flutter packages and third-party dependencies
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spiceease/app/app_theme.dart';

// Import application-specific components
import 'package:spiceease/app/splash_screen.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/l10n/l10n.dart';
import 'package:spiceease/l10n/locale_provider.dart';

/// Main entry point for the application with environment initialization
void main() async {
  // Load environment variables from .env file before initializing the app
  await dotenv.load(fileName: ".env");

print("running app");
  // Wrap the root widget with ProviderScope to enable Riverpod state management
  runApp(const ProviderScope(child: MyApp()));
}

/// Root application widget that configures basic app structure and localization
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for locale changes using Riverpod's locale provider
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'SpiceEase',
      theme: appTheme, // Apply custom theme defined in app_theme.dart
      themeMode: ThemeMode.system, // Use system theme mode (light/dark)
      debugShowCheckedModeBanner: false, // Disable debug banner in release mode

      // Configure localization delegates for multilingual support
      localizationsDelegates: const [
        AppLocalizations.delegate, // Custom app translations
        GlobalMaterialLocalizations.delegate, // Material widgets translations
        GlobalWidgetsLocalizations.delegate, // Default widgets translations
        GlobalCupertinoLocalizations.delegate, // iOS-style widgets translations
      ],

      // Define all supported locales from the L10n class
      supportedLocales: L10n.all,

      // Set current locale based on provider state
      locale: currentLocale,

      // Custom logic to resolve device locale
      localeResolutionCallback: (locale, supportedLocales) {
        // Match device locale with supported locales
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // Fallback to English if no direct match found
        return const Locale('en');
      },

      // Initial screen shown while app resources are loading
      home: SplashScreen(),
    );
  }
}
