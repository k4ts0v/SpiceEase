import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/settings/about_screen.dart';
import 'package:spiceease/features/settings/account_settings_screen.dart';
import 'package:spiceease/features/settings/help_screen.dart';
import 'package:spiceease/features/settings/language_settings.dart';
import 'package:spiceease/features/settings/theme_settings_screen.dart';
import 'package:spiceease/l10n/locale_provider.dart';
import 'package:spiceease/app/theme/theme_provider.dart';

final settingsControllerProvider = Provider((ref) => SettingsController(ref));

class SettingsController {
  final Ref ref;

  SettingsController(this.ref);

  // Theme management
  ThemeMode get currentThemeMode => ref.read(themeProvider);
  Color get currentAccentColor => ref.read(accentColorProvider);

  Future<void> setThemeMode(ThemeMode themeMode) async {
    ref.read(themeProvider.notifier).setThemeMode(themeMode);
  }

  Future<void> setAccentColor(Color color) async {
    ref.read(accentColorProvider.notifier).setColor(color);
  }

  // Locale management
  Locale? get currentLocale => ref.read(localeProvider);

  Future<void> setLocale(Locale locale) async {
    ref.read(localeProvider.notifier).setLocale(locale);
  }

  // Navigation helpers - using direct navigation like in navigation_bar.dart
  void navigateToThemeSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ThemeSettingsScreen(),
      ),
    );
  }

  void navigateToLanguageSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LanguageSettingsScreen(),
      ),
    );
  }

  void navigateToAbout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }

  void navigateToAccountSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccountSettingsScreen(),
      ),
    );
  }

  void navigateToHelp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HelpScreen(),
      ),
    );
  }

  // Quick actions (for settings that don't need dedicated screens)
  void toggleDarkMode() {
    final currentMode = ref.read(themeProvider);
    final newMode = currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    ref.read(themeProvider.notifier).setThemeMode(newMode);
  }

  bool get isDarkMode => ref.read(themeProvider) == ThemeMode.dark;
}