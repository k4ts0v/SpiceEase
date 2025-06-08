import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code');
      if (languageCode != null) {
        state = Locale(languageCode);
      } else {
        // Default to English if no saved preference
        state = const Locale('en');
      }
    } catch (e) {
      print('Error loading saved locale: $e');
      state = const Locale('en');
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      state = locale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      print('Locale changed to: ${locale.languageCode}');
    } catch (e) {
      print('Error saving locale: $e');
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});