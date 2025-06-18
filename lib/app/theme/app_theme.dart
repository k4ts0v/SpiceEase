// ===== CORE FLUTTER/DART IMPORTS =====
// Material Design theming system and color management
import 'package:flutter/material.dart';

/// Generates a consistent app theme based on the provided accent color and brightness
/// This function creates a [ThemeData] object that applies Material 3 design principles
/// and adapts to both light and dark modes. It includes:
/// - Color scheme generation from the accent color
/// - Text styles for various UI elements
/// - App bar, chip, card, and button themes
/// @param accentColor The primary color used for accents throughout the app
/// @param brightness The brightness mode (light or dark) for the theme
/// Returns a [ThemeData] object configured with the specified colors and styles.
ThemeData generateAppTheme(
    {required Color accentColor, required Brightness brightness}) {
  final isDark = brightness == Brightness.dark;

  // Base colors
  final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
  final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final cardColor = isDark ? const Color(0xFF252525) : Colors.white;
  final dividerColor = isDark ? Colors.white24 : Colors.black12;
  final textColor = isDark ? Colors.white : Colors.black87;
  final textSecondaryColor = isDark ? Colors.white70 : Colors.black54;

  // Generate color scheme from accent color
  final colorScheme = ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: brightness,
    primary: accentColor,
    secondary: accentColor,
    background: backgroundColor,
    surface: surfaceColor,
    onPrimary: isDark ? Colors.black : Colors.white,
    onSecondary: isDark ? Colors.black : Colors.white,
    onBackground: textColor,
    onSurface: textColor,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    brightness: brightness,
    primaryColor: accentColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    dividerColor: dividerColor,

    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(color: textColor),
      displayMedium: TextStyle(color: textColor),
      displaySmall: TextStyle(color: textColor),
      headlineMedium: TextStyle(color: textColor),
      headlineSmall: TextStyle(color: textColor),
      titleLarge: TextStyle(color: textColor),
      titleMedium: TextStyle(color: textColor),
      titleSmall: TextStyle(color: textColor),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: textSecondaryColor),
      labelLarge: TextStyle(color: textColor),
      labelMedium: TextStyle(color: textSecondaryColor),
      labelSmall: TextStyle(color: textSecondaryColor),
    ),

    // App Bar Theme - Always white with appropriate text color
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: isDark ? accentColor : Colors.black87,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: isDark ? accentColor : Colors.black87,
      ),
    ),

    // Chip Theme - Light accent background with accent text when selected
    chipTheme: ChipThemeData(
      backgroundColor: accentColor.withOpacity(isDark ? 0.15 : 0.05),
      disabledColor: accentColor.withOpacity(isDark ? 0.05 : 0.02),
      selectedColor: accentColor.withOpacity(0.25),
      secondarySelectedColor: accentColor.withOpacity(0.25),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: TextStyle(color: textColor),
      secondaryLabelStyle: TextStyle(color: accentColor),
      brightness: brightness,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: accentColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      selectedShadowColor: accentColor.withOpacity(0.4),
      showCheckmark: true,
      checkmarkColor: accentColor,
      side: BorderSide(
        color: accentColor.withOpacity(0.2),
        width: 1,
      ),
      surfaceTintColor: accentColor,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: isDark ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF303030) : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: isDark ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: BorderSide(color: accentColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor;
        }
        return surfaceColor;
      }),
      checkColor: MaterialStateProperty.all(
        isDark ? Colors.black : Colors.white,
      ),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor;
        }
        return isDark ? Colors.grey.shade400 : Colors.grey.shade50;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentColor.withOpacity(0.5);
        }
        return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      }),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? cardColor : Colors.white,
      selectedItemColor: accentColor,
      unselectedItemColor: isDark ? Colors.white60 : Colors.black54,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: isDark ? Colors.black : Colors.white,
      elevation: 6,
    ),

    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: accentColor,
      inactiveTrackColor: accentColor.withOpacity(0.3),
      thumbColor: accentColor,
      overlayColor: accentColor.withOpacity(0.3),
      valueIndicatorColor: accentColor,
      valueIndicatorTextStyle: TextStyle(
        color: isDark ? Colors.black : Colors.white,
      ),
    ),

    // Icon Theme
    iconTheme: IconThemeData(
      color: textColor,
    ),

    // Tooltip Theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[700],
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: TextStyle(color: Colors.white),
      padding: const EdgeInsets.all(8),
    ),
  );
}
