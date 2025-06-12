// Import core Flutter packages and third-party dependencies
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spiceease/core/database/firebase_options.dart';
import 'package:spiceease/app/app_wrapper.dart';
import 'package:spiceease/app/theme/app_theme.dart';
import 'package:spiceease/app/theme/theme_provider.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/l10n/l10n.dart';
import 'package:spiceease/l10n/locale_provider.dart';

/// Create a global navigator key to allow navigation from anywhere
final navigatorKey = GlobalKey<NavigatorState>();

/// Main entry point for the application with environment initialization
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file before initializing the app
  await dotenv.load(fileName: ".env");

  // Initialize Firebase FIRST
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialized successfully");
  } catch (e) {
    debugPrint("❌ Firebase initialization failed: $e");
  }

  debugPrint("🚀 Starting SpiceEase app...");

  // Wrap the root widget with ProviderScope to enable Riverpod state management
  runApp(const ProviderScope(child: MyApp()));
}

/// Root application widget that configures basic app structure and localization
class MyApp extends ConsumerWidget {
  final Locale? localeForTest;
  const MyApp({super.key, this.localeForTest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for locale changes using Riverpod's locale provider
    final currentLocale = ref.watch(localeProvider);

    // Watch the combined theme state to ensure rebuilds happen when either theme mode or accent color change
    final themeState = ref.watch(themeStateProvider);

    // Generate themes based on current theme state
    final lightTheme = generateAppTheme(
      accentColor: themeState.accentColor,
      brightness: Brightness.light,
    );

    final darkTheme = generateAppTheme(
      accentColor: themeState.accentColor,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'SpiceEase',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeState.themeMode,
      debugShowCheckedModeBanner: false,

      // Add the navigator key to enable navigation from anywhere
      navigatorKey: navigatorKey,

      locale: currentLocale,

      // Configure localization delegates for multilingual support
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Define all supported locales from the L10n class
      supportedLocales: L10n.all,

      // Start with AppWrapper which handles the splash screen and navigation
      home: const AppWrapper(),
    );
  }
}
