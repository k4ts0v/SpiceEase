import 'package:flutter/material.dart';

/// A utility class for managing supported languages and locales in the app.
class L10n {
  /// A list of all supported locales.
  ///
  /// Includes:
  /// - `Locale('en')` for English.
  /// - `Locale('es')` for Spanish.
  static final all = [
    const Locale('en'), // English locale.
    const Locale('es'), // Spanish locale.
  ];

  /// Returns the flag emoji corresponding to the given language code.
  ///
  /// The function currently supports the following language codes:
  /// - `'es'` (Spanish): Returns the Spanish flag emoji 🇪🇸.
  /// - `'en'` (English): Returns the UK flag emoji 🇬🇧 (default).
  ///
  /// If an unsupported code is passed, the default is the UK flag emoji 🇬🇧.
  ///
  /// Example:
  /// ```dart
  /// String flag = L10n.getFlag('es'); // Returns '🇪🇸'
  /// ```
  ///
  /// - Parameter:
  ///   - `code`: The language code as a string (e.g., 'en', 'es').
  /// - Returns: A string containing the corresponding flag emoji.
  static String getFlag(String code) {
    switch (code) {
      case 'es':
        return '🇪🇸';
      case 'en':
      default:
        return '🇬🇧';
    }
  }

  /// Returns the native name of the language based on the given language code.
  ///
  /// The function currently supports the following language codes:
  /// - `'es'` (Spanish): Returns 'Español'.
  /// - `'en'` (English): Returns 'English' (default).
  ///
  /// If an unsupported code is passed, the default is 'English'.
  ///
  /// Example:
  /// ```dart
  /// String language = L10n.getLanguageName('es'); // Returns 'Español'
  /// ```
  ///
  /// - Parameter:
  ///   - `code`: The language code as a string (e.g., 'en', 'es').
  /// - Returns: A string containing the native name of the language.
  static String getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
      default:
        return 'English';
    }
  }
}
