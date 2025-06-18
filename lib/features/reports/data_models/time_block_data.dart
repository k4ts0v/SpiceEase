// ===== TIME BLOCK ANALYTICS DATA MODEL =====
/// Immutable data model for representing time block usage analytics in bar charts
///
/// This model encapsulates time block statistics for productivity analysis visualizations.
/// Each instance represents a single metric (count or duration) related to time block
/// usage patterns, designed specifically for column/bar chart comparisons.
///
/// Used primarily for:
/// - Time block count vs hours spent comparison charts
/// - Productivity analytics in reports dashboard
/// - Bar chart data preparation for time management insights
/// - Dual metric visualization (blocks count + time duration)
class TimeBlockData {
  // ===== PRIVATE FIELDS =====

  /// Category label for the time block metric being measured
  /// Examples: "Blocks", "Time", "Sessions", "Hours"
  /// Used for chart x-axis labels and data identification
  final String _label;

  /// Numeric value representing the measurement for this category
  /// - For block count: number of time block sessions (e.g., 15.0)
  /// - For time duration: total hours spent (e.g., 8.5)
  /// - For other metrics: relevant numeric measurement
  /// Chart libraries use this value for bar height/length calculations
  final double _value;

  // ===== GETTER METHODS =====

  /// Gets the category label for chart axes and legends
  /// Returns the human-readable category name for this data point
  String get label => _label;

  /// Gets the numeric value for chart rendering and calculations
  /// Returns the underlying measurement used for bar chart visualization
  double get value => _value;

  // ===== CONSTRUCTOR =====

  /// Creates an immutable TimeBlockData instance for chart visualization
  ///
  /// Parameters:
  /// - [_label]: Category identifier for chart labeling
  /// - [_value]: Numeric measurement for bar chart rendering
  ///
  /// Example usage:
  /// ```dart
  /// TimeBlockData("Blocks", 12.0)  // 12 time block sessions
  /// TimeBlockData("Hours", 8.5)   // 8.5 total hours spent
  /// ```
  TimeBlockData(this._label, this._value);
}
