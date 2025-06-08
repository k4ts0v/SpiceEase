import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys for SharedPreferences
const String _themeModePrefKey = 'theme_mode';
const String _accentColorPrefKey = 'accent_color';

// Theme mode provider
final themeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModePrefKey);

      if (themeModeString != null) {
        if (themeModeString == 'ThemeMode.dark') {
          state = ThemeMode.dark;
        } else if (themeModeString == 'ThemeMode.light') {
          state = ThemeMode.light;
        } else {
          state = ThemeMode.system;
        }
      }
    } catch (e) {
      print('Error loading saved theme mode: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModePrefKey, mode.toString());
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }
}

// Accent color provider
final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  return AccentColorNotifier();
});

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(Colors.blue) {
    _loadSavedAccentColor();
  }

  Future<void> _loadSavedAccentColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_accentColorPrefKey);
      if (colorValue != null) {
        state = Color(colorValue);
      }
    } catch (e) {
      print('Error loading saved accent color: $e');
    }
  }

  Future<void> setColor(Color color) async {
    state = color;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_accentColorPrefKey, color.value);
    } catch (e) {
      print('Error saving accent color: $e');
    }
  }
}

// Combined theme state provider to trigger rebuilds
final themeStateProvider = Provider<ThemeState>((ref) {
  final themeMode = ref.watch(themeProvider);
  final accentColor = ref.watch(accentColorProvider);
  return ThemeState(themeMode: themeMode, accentColor: accentColor);
});

class ThemeState {
  final ThemeMode themeMode;
  final Color accentColor;

  const ThemeState({required this.themeMode, required this.accentColor});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.accentColor == accentColor;
  }

  @override
  int get hashCode => themeMode.hashCode ^ accentColor.hashCode;
}
