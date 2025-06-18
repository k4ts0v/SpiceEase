// ===== FLOWMODORO TIME DATA MODEL =====
/// Immutable data model for representing Flowmodoro session time breakdown in charts
///
/// This model encapsulates time-based analytics data for Flowmodoro sessions, specifically
/// designed for doughnut and pie chart visualizations. It provides both human-readable
/// display values and numeric values for chart calculations.
///
/// Used primarily for:
/// - Focus time vs break time breakdown charts
/// - Time distribution analytics in reports
/// - Chart data preparation with formatted labels
/// - Dual representation of the same data (display + numeric)
class FlowTimeData {
  // ===== PRIVATE FIELDS =====
  /// Human-readable label for the time category
  /// Examples: "Focus Time", "Break Time", "Total Session Time"
  final String _label;

  /// Formatted display value with units for user presentation
  /// Examples: "2.5 hours", "45 minutes", "1 hour 30 minutes"
  /// This value is pre-formatted and localized for direct UI display
  final String _displayValue;

  /// Raw numeric value in consistent units (typically hours) for chart calculations
  /// Used by chart libraries for proportional calculations and visual rendering
  /// Always represents the same unit type for mathematical operations
  final double _numericValue;

  // ===== GETTER METHODS =====

  /// Gets the category label for chart legends and data identification
  /// Returns the human-readable category name for this time data point
  String get label => _label;

  /// Gets the pre-formatted display string with appropriate units
  /// Returns localized, user-friendly time representation ready for UI display
  String get displayValue => _displayValue;

  /// Gets the raw numeric value for chart calculations and comparisons
  /// Returns the underlying numeric data used for proportional chart rendering
  double get numericValue => _numericValue;

  // ===== CONSTRUCTOR =====

  /// Creates a FlowTimeData instance with label, display value, and numeric value
  ///
  /// Parameters:
  /// - [_label]: Category identifier (e.g., "Focus Time", "Break Time")
  /// - [_displayValue]: Pre-formatted, localized display string with units
  /// - [_numericValue]: Raw numeric value in consistent units for calculations
  ///
  /// Example usage:
  /// ```dart
  /// FlowTimeData(
  ///   "Focus Time",
  ///   "2.5 hours",
  ///   2.5
  /// )
  /// ```
  FlowTimeData(this._label, this._displayValue, this._numericValue);
}
