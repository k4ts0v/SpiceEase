/// Represents user preferences and application configuration
class SettingsModel {
  // Immutable unique identifier
  final String _id;

  // Foreign key reference to associated user
  final String _userId;

  // User-configurable properties
  String _theme;
  String _accentColor;

  // Tracking timestamp
  DateTime _updatedAt;

  /// Public accessors for private state
  String get id => _id;
  String get userId => _userId;
  String get theme => _theme;
  String get accentColor => _accentColor;
  DateTime get updatedAt => _updatedAt;

  /// Validates and sets theme mode
  set theme(String newTheme) {
    if (!['light', 'dark'].contains(newTheme)) {
      throw ArgumentError('Theme must be "light" or "dark"');
    }
    _theme = newTheme;
  }

  /// Validates and sets accent color
  set accentColor(String newColor) {
    if (!RegExp(r'^#([A-Fa-f0-9]{6})$').hasMatch(newColor)) {
      throw ArgumentError('Invalid hex color format');
    }
    _accentColor = newColor;
  }

  /// Updates modification timestamp
  set updatedAt(DateTime newTime) => _updatedAt = newTime;

  /// Main constructor with required values
  SettingsModel({
    required String id,
    required String userId,
    String theme = 'light',
    String accentColor = '#2196F3',
    required DateTime updatedAt,
  })  : _id = id,
        _userId = userId,
        _theme = theme,
        _accentColor = accentColor,
        _updatedAt = updatedAt;

  /// Factory constructor that constructs SettingsModel from generic key-value map structure
  ///
  /// Handles:
  /// - Type-safe conversions
  /// - Default values for missing fields
  /// - Both string and DateTime types for timestamps
  factory SettingsModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return SettingsModel(
      id: id ?? map['id'] as String,
      userId: map['user_id'] as String,
      theme: map['theme'] as String? ?? 'light',
      accentColor: map['accent_color'] as String? ?? '#2196F3',
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Serializes settings data to database-agnostic map format
  ///
  /// Returns:
  /// - String keys using application-level naming conventions
  /// - Native Dart types for database compatibility
  Map<String, dynamic> toMap() => {
        'user_id': _userId,
        'theme': _theme,
        'accent_color': _accentColor,
        'updated_at': _updatedAt.toIso8601String(),
      };
}
