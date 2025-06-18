// ===== MULTI-METRIC DATA MODEL =====
/// Immutable data model representing comprehensive health and productivity metrics for a time period
///
/// This model aggregates data from multiple tracking categories into a single data point
/// for multi-series line chart visualization. Each instance represents one time segment
/// (hour, day, week, month) with all associated metric values.
///
/// Used primarily for:
/// - Multi-line chart data in reports showing trends over time
/// - Correlation analysis between different health/productivity metrics
/// - Time-series data aggregation from multiple data sources
/// - Chart data preparation for trend visualization
class MetricsData {
  // ===== TIME IDENTIFIER =====
  /// Time period label for this data point
  /// Format varies by time range:
  /// - Day view: "09:00", "14:30" (hourly timestamps)
  /// - Week view: "12/25", "1/1" (month/day format)
  /// - Month view: "W1", "W2" (week numbers)
  /// - Year view: "Jan", "Feb" (month abbreviations)
  final String day;

  // ===== HEALTH METRICS =====

  /// Average mood level for this time period (typically 1-10 scale)
  /// Calculated from all mood entries within the time segment
  /// 0 indicates no mood data available for this period
  final double mood;

  /// Average energy level for this time period (typically 1-10 scale)
  /// Calculated from all energy entries within the time segment
  /// 0 indicates no energy data available for this period
  final double energy;

  /// Total count of symptom entries recorded during this time period
  /// Represents discrete symptom logging events, not averaged values
  /// Higher numbers indicate more symptom activity
  final double symptoms;

  // ===== PRODUCTIVITY METRICS =====

  /// Total count of tasks completed during this time period
  /// Includes both regular tasks and completed subtasks
  /// Represents actual completion events within the time segment
  final double tasks;

  /// Total count of habits completed during this time period
  /// Based on habit lastCompleted timestamps falling within the segment
  /// Measures consistency of habit execution over time
  final double habits;

  // ===== MEDICATION TRACKING =====

  /// Count of medications with doses taken during this time period
  /// Each medication is counted once if any doses were taken in the segment
  /// Tracks medication adherence patterns over time
  final double medications;

  // ===== CONSTRUCTOR =====

  /// Creates an immutable MetricsData instance with all metric values
  ///
  /// Parameters:
  /// - [day]: Time period identifier/label for chart x-axis
  /// - [mood]: Average mood value (0 if no data)
  /// - [energy]: Average energy value (0 if no data)
  /// - [symptoms]: Count of symptom entries
  /// - [tasks]: Count of completed tasks + subtasks
  /// - [habits]: Count of completed habits
  /// - [medications]: Count of medications with doses taken
  ///
  /// All numeric values use double type for chart library compatibility
  /// and to support averaging calculations that may result in decimals.
  const MetricsData(this.day, this.mood, this.energy, this.symptoms, this.tasks,
      this.habits, this.medications);
}
