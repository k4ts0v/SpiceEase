import 'package:flutter/material.dart';

/// Global app theme and modal decoration

const Color kAccentColor = Colors.blue;
const Color kBackgroundColor = Colors.white;

/// Use this for modal containers
final BoxDecoration modalBoxDecoration = BoxDecoration(
  color: kBackgroundColor,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ],
);

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: kAccentColor,
    primary: kAccentColor,
    secondary: kAccentColor,
    background: kBackgroundColor,
    surface: kBackgroundColor,
    brightness: Brightness.light,
  ),
  primaryColor: kAccentColor,
  scaffoldBackgroundColor: kBackgroundColor,
  // TextField
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kAccentColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  // Chip
  chipTheme: ChipThemeData(
    backgroundColor: kAccentColor.withOpacity(0.1),
    selectedColor: kAccentColor.withOpacity(0.2),
    deleteIconColor: kAccentColor,
    labelStyle: TextStyle(color: Colors.blue.shade700),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  // Slider
  sliderTheme: SliderThemeData(
    activeTrackColor: kAccentColor,
    inactiveTrackColor: kAccentColor.withOpacity(0.2),
    thumbColor: kAccentColor,
    overlayColor: kAccentColor.withOpacity(0.1),
    valueIndicatorColor: kAccentColor,
  ),
  // Dropdown
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kAccentColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kAccentColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kAccentColor, width: 2),
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccentColor,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  // You can add more theme customizations here if needed
);