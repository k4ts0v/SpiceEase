import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/settings/settings_controller.dart';

// Data models
class LanguageOption {
  final Locale locale;
  final String englishName;
  final String nativeName;

  const LanguageOption({
    required this.locale,
    required this.englishName,
    required this.nativeName,
  });
}

// Controller state
class LanguageSettingsState {
  final List<LanguageOption> availableLanguages;
  final Locale? currentLocale;

  const LanguageSettingsState({
    required this.availableLanguages,
    this.currentLocale,
  });

  LanguageSettingsState copyWith({
    List<LanguageOption>? availableLanguages,
    Locale? currentLocale,
  }) {
    return LanguageSettingsState(
      availableLanguages: availableLanguages ?? this.availableLanguages,
      currentLocale: currentLocale ?? this.currentLocale,
    );
  }
}

// Controller
class LanguageSettingsController extends StateNotifier<LanguageSettingsState> {
  final SettingsController _settingsController;

  LanguageSettingsController(this._settingsController)
      : super(LanguageSettingsState(
          availableLanguages: _createAvailableLanguages(),
          currentLocale: _settingsController.currentLocale,
        ));

  static List<LanguageOption> _createAvailableLanguages() {
    return [
      const LanguageOption(
        locale: Locale('en'),
        englishName: 'English',
        nativeName: 'English',
      ),
      const LanguageOption(
        locale: Locale('es'),
        englishName: 'Spanish',
        nativeName: 'Español',
      ),
    ];
  }

  void setLanguage(Locale locale) {
    _settingsController.setLocale(locale);
    state = state.copyWith(currentLocale: locale);
  }

  bool isLanguageSelected(Locale locale) {
    return state.currentLocale?.languageCode == locale.languageCode;
  }

  String getLanguageDisplayName(Locale locale) {
    final languageOption = state.availableLanguages
        .firstWhere((option) => option.locale.languageCode == locale.languageCode);
    return languageOption.englishName;
  }

  String getLanguageNativeName(Locale locale) {
    final languageOption = state.availableLanguages
        .firstWhere((option) => option.locale.languageCode == locale.languageCode);
    return languageOption.nativeName;
  }

  List<Locale> get availableLocales =>
      state.availableLanguages.map((option) => option.locale).toList();

  Locale? get currentLocale => state.currentLocale;
}

// Provider
final languageSettingsControllerProvider =
    StateNotifierProvider<LanguageSettingsController, LanguageSettingsState>((ref) {
  final settingsController = ref.read(settingsControllerProvider);
  return LanguageSettingsController(settingsController);
});