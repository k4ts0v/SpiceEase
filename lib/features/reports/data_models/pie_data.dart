// ===== PIE CHART DATA MODEL =====
/// Immutable data model for representing categorical data in pie and doughnut charts
///
/// This model encapsulates technique usage analytics for time management comparisons.
/// Each instance represents one category/technique with its usage count or percentage,
/// designed specifically for circular chart visualizations.
///
/// Used primarily for:
/// - Time management technique comparison (Flowmodoro vs Time Blocks)
/// - Usage distribution analytics in reports
/// - Pie/doughnut chart data preparation
/// - Categorical data representation with numeric values
class PieData {
  // ===== CATEGORY IDENTIFIER =====
  /// Name of the technique or category being measured
  /// Examples: "Flowmodoro", "Time Blocks", "Pomodoro", "Free Time"
  /// Used for chart legends, labels, and data identification
  final String technique;

  // ===== USAGE METRIC =====
  /// Numeric value representing usage count, duration, or percentage
  /// - For technique comparison: count of sessions (e.g., 15 Flowmodoro sessions)
  /// - For time analysis: hours spent (e.g., 8.5 hours in Time Blocks)
  /// - For percentage views: decimal percentage (e.g., 0.65 for 65%)
  /// Chart libraries use this value for proportional slice sizing
  final double usage;

  // ===== CONSTRUCTOR =====

  /// Creates an immutable PieData instance for chart visualization
  ///
  /// Parameters:
  /// - [technique]: Category/technique name for chart labeling
  /// - [usage]: Numeric value for proportional chart rendering
  ///
  /// Example usage:
  /// ```dart
  /// PieData("Flowmodoro", 12.0)  // 12 Flowmodoro sessions
  /// PieData("Time Blocks", 8.0)  // 8 Time Block sessions
  /// ```
  const PieData(this.technique, this.usage);
}
