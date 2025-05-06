import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for managing the application locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  // Default locale is English
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  // Load saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  // Change the application locale
  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    // Save the selected language code to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  // Get current language code
  String get currentLanguageCode => state.languageCode;
}