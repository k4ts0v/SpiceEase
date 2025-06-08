import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/settings/settings_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// Data models
class ThemeModeOption {
  final ThemeMode mode;
  final String title;
  final String subtitle;

  const ThemeModeOption({
    required this.mode,
    required this.title,
    required this.subtitle,
  });
}

class AccentColorOption {
  final Color color;
  final String name;

  const AccentColorOption({
    required this.color,
    required this.name,
  });
}

// Controller state
class ThemeSettingsState {
  final List<AccentColorOption> availableColors;
  final List<ThemeModeOption> themeModes;
  final ThemeMode currentThemeMode;
  final Color currentAccentColor;

  const ThemeSettingsState({
    required this.availableColors,
    required this.themeModes,
    required this.currentThemeMode,
    required this.currentAccentColor,
  });

  ThemeSettingsState copyWith({
    List<AccentColorOption>? availableColors,
    List<ThemeModeOption>? themeModes,
    ThemeMode? currentThemeMode,
    Color? currentAccentColor,
  }) {
    return ThemeSettingsState(
      availableColors: availableColors ?? this.availableColors,
      themeModes: themeModes ?? this.themeModes,
      currentThemeMode: currentThemeMode ?? this.currentThemeMode,
      currentAccentColor: currentAccentColor ?? this.currentAccentColor,
    );
  }
}

// Controller
class ThemeSettingsController extends StateNotifier<ThemeSettingsState> {
  final SettingsController _settingsController;

  ThemeSettingsController(this._settingsController)
      : super(ThemeSettingsState(
          availableColors: _createAvailableColors(),
          themeModes: _createThemeModes(),
          currentThemeMode: _settingsController.currentThemeMode,
          currentAccentColor: _settingsController.currentAccentColor,
        ));

  static List<AccentColorOption> _createAvailableColors() {
    return [
      const AccentColorOption(color: Colors.blue, name: 'Blue'),
      const AccentColorOption(color: Colors.purple, name: 'Purple'),
      const AccentColorOption(color: Colors.green, name: 'Green'),
      const AccentColorOption(color: Colors.orange, name: 'Orange'),
      const AccentColorOption(color: Colors.red, name: 'Red'),
      const AccentColorOption(color: Colors.teal, name: 'Teal'),
      const AccentColorOption(color: Colors.indigo, name: 'Indigo'),
      const AccentColorOption(color: Colors.pink, name: 'Pink'),
    ];
  }

  static List<ThemeModeOption> _createThemeModes() {
    return [
      const ThemeModeOption(
        mode: ThemeMode.light,
        title: 'Light',
        subtitle: 'Always use light theme',
      ),
      const ThemeModeOption(
        mode: ThemeMode.dark,
        title: 'Dark',
        subtitle: 'Always use dark theme',
      ),
      const ThemeModeOption(
        mode: ThemeMode.system,
        title: 'System',
        subtitle: 'Follow system setting',
      ),
    ];
  }

  void setThemeMode(ThemeMode mode) {
    _settingsController.setThemeMode(mode);
    state = state.copyWith(currentThemeMode: mode);
  }

  void setAccentColor(Color color) {
    _settingsController.setAccentColor(color);
    state = state.copyWith(currentAccentColor: color);
  }

  bool isThemeModeSelected(ThemeMode mode) {
    return state.currentThemeMode == mode;
  }

  bool isAccentColorSelected(Color color) {
    return state.currentAccentColor == color;
  }

  String getThemeModeTitle(ThemeMode mode, AppLocalizations localizations) {
    switch (mode) {
      case ThemeMode.light:
        return localizations.lightTheme;
      case ThemeMode.dark:
        return localizations.darkTheme;
      case ThemeMode.system:
        return localizations.systemTheme;
    }
  }

  String getThemeModeSubtitle(ThemeMode mode, AppLocalizations localizations) {
    switch (mode) {
      case ThemeMode.light:
        return localizations.lightThemeDesc;
      case ThemeMode.dark:
        return localizations.darkThemeDesc;
      case ThemeMode.system:
        return localizations.systemThemeDesc;
    }
  }

  Color getIconColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  List<Color> get availableColorsOnly =>
      state.availableColors.map((option) => option.color).toList();

  ThemeMode get currentThemeMode => state.currentThemeMode;
  Color get currentAccentColor => state.currentAccentColor;
}

// Provider
final themeSettingsControllerProvider =
    StateNotifierProvider<ThemeSettingsController, ThemeSettingsState>((ref) {
  final settingsController = ref.read(settingsControllerProvider);
  return ThemeSettingsController(settingsController);
});