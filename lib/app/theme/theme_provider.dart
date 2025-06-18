// ===== CORE FLUTTER/DART IMPORTS =====
// Material Design theming system and color management
import 'package:flutter/material.dart';
// State management and provider framework for reactive theme changes
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Local storage for theme preference persistence across app sessions
import 'package:shared_preferences/shared_preferences.dart';

// ===== THEME PERSISTENCE CONFIGURATION =====

/// SharedPreferences key for storing user's preferred theme mode
/// Used to persist dark/light/system theme selection across app restarts
const String _themeModePrefKey = 'theme_mode';

/// SharedPreferences key for storing user's custom accent color
/// Allows preservation of personalized color schemes between sessions
const String _accentColorPrefKey = 'accent_color';

// ===== THEME MODE MANAGEMENT =====

/// Global theme mode provider for application-wide theme state management
///
/// Manages the user's theme preference (light, dark, or system) with automatic
/// persistence to local storage. The provider handles loading saved preferences
/// on app startup and synchronizing changes across the entire application.
///
/// Features:
/// - Automatic persistence of theme mode changes
/// - System theme detection and following
/// - Error-resistant preference loading with fallback defaults
/// - Real-time theme switching without app restart
///
/// Default behavior: Falls back to system theme if no preference is saved
final themeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// State notifier for managing theme mode with persistent storage
///
/// Handles the complete lifecycle of theme mode management including:
/// - Loading saved preferences from local storage on initialization
/// - Updating theme mode state with immediate UI reflection
/// - Persisting changes to SharedPreferences for future sessions
/// - Error handling for storage operations with graceful degradation
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  /// Initializes with system theme mode and triggers async preference loading
  ///
  /// The system theme mode ensures the app respects the user's device-level
  /// theme preference while the saved preference is being loaded asynchronously.
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  /// Asynchronously loads the user's saved theme preference from local storage
  ///
  /// Attempts to retrieve and parse the previously saved theme mode from
  /// SharedPreferences. If no preference exists or parsing fails, the current
  /// state (system theme) is maintained as a safe fallback.
  ///
  /// Error handling ensures the app continues to function even if storage
  /// operations fail, with appropriate logging for debugging purposes.
  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModePrefKey);

      if (themeModeString != null) {
        // ===== THEME MODE STRING PARSING =====
        // Convert stored string representation back to ThemeMode enum
        if (themeModeString == 'ThemeMode.dark') {
          state = ThemeMode.dark;
        } else if (themeModeString == 'ThemeMode.light') {
          state = ThemeMode.light;
        } else {
          state = ThemeMode.system;
        }
      }
    } catch (e) {
      // ===== STORAGE ERROR HANDLING =====
      // Log error but continue with current state to ensure app stability
      print('Error loading saved theme mode: $e');
    }
  }

  /// Updates the theme mode and persists the change to local storage
  ///
  /// Immediately updates the UI by changing the state, then asynchronously
  /// saves the preference to SharedPreferences for persistence across sessions.
  ///
  /// Parameters:
  /// - [mode]: The new theme mode to apply (light, dark, or system)
  ///
  /// The method prioritizes UI responsiveness by updating state first,
  /// then handling persistence in the background.
  Future<void> setThemeMode(ThemeMode mode) async {
    // ===== IMMEDIATE STATE UPDATE =====
    // Update UI immediately for responsive user experience
    state = mode;

    try {
      // ===== PERSISTENT STORAGE =====
      // Save preference for future app sessions
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModePrefKey, mode.toString());
    } catch (e) {
      // ===== PERSISTENCE ERROR HANDLING =====
      // Log error but don't revert state - UI change should persist for current session
      print('Error saving theme mode: $e');
    }
  }
}

// ===== ACCENT COLOR MANAGEMENT =====

/// Global accent color provider for customizable color theme management
///
/// Manages the user's accent color preference with automatic persistence
/// to local storage. Allows users to personalize their app experience
/// with custom color schemes while maintaining consistency across sessions.
///
/// Features:
/// - Custom color selection and application
/// - Automatic persistence of color preferences
/// - Real-time color theme updates
/// - Default color fallback for new installations
///
/// Default behavior: Uses Material Design blue as the default accent color
final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  return AccentColorNotifier();
});

/// State notifier for managing accent color with persistent storage
///
/// Provides comprehensive accent color management including loading saved
/// preferences, updating colors with immediate visual feedback, and persisting
/// changes for future app sessions. Handles color serialization and storage
/// operations with appropriate error handling.
class AccentColorNotifier extends StateNotifier<Color> {
  /// Initializes with default blue color and triggers async preference loading
  ///
  /// The default blue color ensures a consistent visual experience while
  /// the user's saved color preference is being loaded from storage.
  AccentColorNotifier() : super(Colors.blue) {
    _loadSavedAccentColor();
  }

  /// Asynchronously loads the user's saved accent color from local storage
  ///
  /// Retrieves the color value stored as an integer representation and
  /// reconstructs the Color object. If no saved color exists or loading
  /// fails, the default blue color is maintained.
  ///
  /// Color storage uses the integer value representation for efficient
  /// serialization and cross-platform compatibility.
  Future<void> _loadSavedAccentColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_accentColorPrefKey);
      if (colorValue != null) {
        // ===== COLOR RECONSTRUCTION =====
        // Convert stored integer back to Color object
        state = Color(colorValue);
      }
    } catch (e) {
      // ===== STORAGE ERROR HANDLING =====
      // Log error but maintain current state for app stability
      print('Error loading saved accent color: $e');
    }
  }

  /// Updates the accent color and persists the change to local storage
  ///
  /// Immediately applies the new color to update the UI, then asynchronously
  /// saves the color value to SharedPreferences for persistence across sessions.
  ///
  /// Parameters:
  /// - [color]: The new accent color to apply throughout the app
  ///
  /// Color persistence uses the integer value representation which includes
  /// alpha, red, green, and blue components in a single 32-bit value.
  Future<void> setColor(Color color) async {
    // ===== IMMEDIATE STATE UPDATE =====
    // Apply new color immediately for responsive user experience
    state = color;

    try {
      // ===== PERSISTENT STORAGE =====
      // Save color value for future app sessions
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_accentColorPrefKey, color.value);
    } catch (e) {
      // ===== PERSISTENCE ERROR HANDLING =====
      // Log error but maintain UI change for current session
      print('Error saving accent color: $e');
    }
  }
}

// ===== COMBINED THEME STATE MANAGEMENT =====

/// Combined theme state provider for coordinated theme and color management
///
/// Aggregates both theme mode and accent color into a single state object
/// to ensure synchronized updates and efficient rebuild triggering. This
/// provider enables widgets to watch both theme aspects simultaneously
/// without managing multiple provider subscriptions.
///
/// Features:
/// - Consolidated theme state management
/// - Efficient rebuild optimization through value equality
/// - Single subscription point for complete theme information
/// - Automatic updates when either theme mode or accent color changes
///
/// Usage: Watch this provider when both theme mode and accent color are
/// needed, or when implementing theme-dependent UI components.
final themeStateProvider = Provider<ThemeState>((ref) {
  final themeMode = ref.watch(themeProvider);
  final accentColor = ref.watch(accentColorProvider);
  return ThemeState(themeMode: themeMode, accentColor: accentColor);
});

/// Immutable theme state container for coordinated theme management
///
/// Encapsulates both theme mode and accent color preferences in a single
/// value object with proper equality implementation. This enables efficient
/// widget rebuilding by preventing unnecessary updates when theme state
/// hasn't actually changed.
///
/// The class implements value equality to ensure provider consumers only
/// rebuild when theme properties actually change, optimizing performance
/// in theme-dependent widgets.
class ThemeState {
  /// Current theme mode (light, dark, or system)
  final ThemeMode themeMode;

  /// Current accent color for UI theming
  final Color accentColor;

  /// Creates a new theme state with the specified mode and accent color
  const ThemeState({required this.themeMode, required this.accentColor});

  /// Implements value equality for efficient provider rebuild optimization
  ///
  /// Two ThemeState objects are considered equal if both their theme mode
  /// and accent color are identical. This prevents unnecessary widget rebuilds
  /// when the theme state hasn't actually changed.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.accentColor == accentColor;
  }

  /// Generates hash code based on theme mode and accent color
  ///
  /// Combines the hash codes of both theme properties to create a unique
  /// identifier for this theme state, supporting efficient equality comparisons
  /// and collection operations.
  @override
  int get hashCode => themeMode.hashCode ^ accentColor.hashCode;
}
