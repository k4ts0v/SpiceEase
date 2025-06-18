// ===== CORE DART/FLUTTER IMPORTS =====
// Standard library and framework imports for UI components and state management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===== APPLICATION IMPORTS =====
// App initialization and core components
import 'package:spiceease/app/app_initializer.dart';
import 'package:spiceease/components/app_header.dart';
import 'package:spiceease/components/calendar_week_selector.dart';

// State providers for authentication and date management
import 'package:spiceease/data/providers/unified_auth_provider.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';

// Reports-specific data models and controller
import 'package:spiceease/features/reports/data_models/flow_time_data.dart';
import 'package:spiceease/features/reports/data_models/metrics_data.dart';
import 'package:spiceease/features/reports/data_models/pie_data.dart';
import 'package:spiceease/features/reports/data_models/time_block_data.dart';
import 'package:spiceease/features/reports/reports_controller.dart';

// Localization support
import 'package:spiceease/l10n/app_localizations.dart';

// External chart library for data visualization
import 'package:syncfusion_flutter_charts/charts.dart';

// ===== REPORTS PAGE =====
/// Main analytics and insights page displaying user data across multiple time ranges
///
/// This page provides comprehensive reporting functionality including:
/// - Multi-metric line charts (mood, energy, symptoms, tasks, habits, medications)
/// - Time management technique usage analytics (Flowmodoro vs Time Blocks)
/// - Detailed Flowmodoro session insights with focus/break time breakdown
/// - Time block analytics showing usage patterns and total time spent
/// - Streak tracking for tasks and habits completion
/// - Interactive time range selection (day, week, month, year)
/// - Responsive chart interactions with zoom, pan, and tooltip capabilities
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

/// State class managing reports page UI and chart interactions
/// Handles time range selection, chart zoom behavior, and data visualization
class _ReportsPageState extends ConsumerState<ReportsPage> {
  // ===== CHART INTERACTION STATE =====
  /// Zoom and pan behavior controller for line charts
  /// Enables interactive chart exploration with pinch, pan, and zoom gestures
  late final ZoomPanBehavior _zoomPanBehavior;

  /// Tooltip behavior for all charts
  /// Provides contextual data display on hover/touch
  late TooltipBehavior _tooltipBehavior;

  // ===== TIME RANGE SELECTION STATE =====
  /// Currently selected time range for data aggregation
  /// Options: 'day', 'week', 'month', 'year'
  /// Default: 'week' for optimal data granularity
  String _selectedRange = 'week';

  // ===== UI INTERACTION STATE =====
  /// Tracks whether line chart is currently zoomed
  /// Controls visibility of reset zoom button
  bool _isZoomed = false;

  // ===== TIME RANGE UPDATE METHODS =====

  /// Updates the selected time range and triggers data refresh
  /// Fetches new analytics data based on selected date and range
  void _updateReports(String range) {
    setState(() => _selectedRange = range);
    final selectedDate = ref.read(selectedDateProvider);

    // ===== TRIGGER DATA FETCH =====
    // Fetch analytics data for the new time range using current selected date
    ref
        .read(reportsControllerProvider.notifier)
        .fetchReportsForTimeRange(range, selectedDate);
  }

  // ===== CHART INTERACTION METHODS =====

  /// Callback triggered when line chart zoom state changes
  /// Updates UI to show/hide zoom reset button
  void _checkZoomState() {
    setState(() {
      _isZoomed = true;
    });
  }

  @override
  void initState() {
    super.initState();

    // ===== CHART BEHAVIOR INITIALIZATION =====
    // Configure interactive chart behaviors for optimal user experience
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true, // Pinch to zoom gesture
      enablePanning: true, // Pan gesture for navigation
      enableDoubleTapZooming: true, // Double-tap zoom functionality
      enableMouseWheelZooming: true, // Mouse wheel zoom (desktop)
      enableSelectionZooming: true, // Selection rectangle zoom
      zoomMode: ZoomMode.xy, // Allow zoom in both X and Y axes
    );

    _tooltipBehavior = TooltipBehavior(enable: true);

    final selectedDate = ref.read(selectedDateProvider);

    // ===== ASYNC INITIALIZATION =====
    // Wait for app initialization before fetching data to ensure all services are ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // ===== ENSURE APP INITIALIZATION =====
        // Wait for core app services (database, auth, etc.) to be ready
        await ref.read(appInitializerProvider.future);

        // ===== AUTHENTICATED DATA FETCH =====
        // Only fetch reports if user is authenticated and widget is still mounted
        final isAuthenticated = await ref.read(isAuthenticatedProvider);
        if (isAuthenticated && mounted) {
          final controller = ref.read(reportsControllerProvider.notifier);
          await controller.fetchReportsForTimeRange(
              _selectedRange, selectedDate);
        }
      } catch (e) {
        // ===== ERROR HANDLING =====
        // Log initialization errors for debugging
        debugPrint('Error in reports page initialization: $e');
        // Error is logged but doesn't prevent page from loading
      }
    });
  }

  // ===== EMPTY STATE UI METHODS =====

  /// Builds a consistent "no data" message widget for empty charts
  /// Provides visual feedback when no data is available for the selected period
  Widget _buildNoDataMessage(AppLocalizations localizations, ThemeData theme) {
    // ===== THEME-AWARE COLORS =====
    // Adapt text and icon colors based on current theme brightness
    final Color textColor = theme.brightness == Brightness.dark
        ? Colors.grey[300]!
        : Colors.grey[600]!;
    final Color iconColor = theme.brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[400]!;

    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ===== EMPTY STATE ICON =====
          Icon(Icons.bar_chart_outlined, size: 48, color: iconColor),
          const SizedBox(height: 16),

          // ===== EMPTY STATE MESSAGE =====
          Text(
            localizations.noDataForPeriod,
            style: TextStyle(
                fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ===== THEME AND COLOR METHODS =====

  /// Returns theme-appropriate color palette for charts
  /// Provides distinct colors optimized for both light and dark themes
  List<Color> _getChartPalette(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      // ===== DARK MODE PALETTE =====
      // Deeper, more saturated colors that stand out on dark backgrounds
      return const [
        Color(0xFF0D47A1), // Deep blue
        Color(0xFF1B5E20), // Forest green
        Color(0xFFF57F17), // Amber gold
        Color(0xFFE65100), // Burnt orange
        Color(0xFFB71C1C), // Crimson red
        Color(0xFF4A148C), // Deep purple
      ];
    } else {
      // ===== LIGHT MODE PALETTE =====
      // Softer, pastel colors that work well on light backgrounds
      return const [
        Color(0xFF90CAF9), // Pastel blue
        Color(0xFFEF9A9A), // Pastel red
        Color(0xFFFFF176), // Pastel yellow
        Color(0xFFA5D6A7), // Pastel green
        Color(0xFFFFCC80), // Pastel orange
        Color(0xFFC680FF), // Pastel purple
      ];
    }
  }

  // ===== MAIN BUILD METHOD =====

  @override
  Widget build(BuildContext context) {
    // ===== THEME AND STATE SETUP =====
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final localizations = AppLocalizations.of(context)!;
    final reportsState = ref.watch(reportsControllerProvider);

    // ===== THEME-AWARE STYLING =====
    final chartPalette = _getChartPalette(theme);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define consistent colors based on theme
    final backgroundColor = theme.colorScheme.surface;
    final surfaceColor = theme.colorScheme.surface;
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;
    final gridLineColor =
        isDarkMode ? Colors.grey[700] : const Color(0xFFE0E0E0);

    // ===== REACTIVE DATE CHANGES =====
    // Listen for date changes and automatically refresh reports
    ref.listen(selectedDateProvider, (previous, next) {
      if (previous != next) {
        // Date changed, refresh the reports with current time range
        _updateReports(_selectedRange);
      }
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ===== PAGE HEADER =====
            // Standard app header with insights title
            AppHeader(sectionName: localizations.insights),

            // ===== CALENDAR SELECTOR =====
            // Week-based date selection with visual calendar interface
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CalendarWeekSelector(
                selectedDate: selectedDate,
                locale: Localizations.localeOf(context),
              ),
            ),

            // ===== TIME RANGE SELECTOR =====
            // Horizontal button row for selecting day/week/month/year views
            Container(
              color: surfaceColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['day', 'week', 'month', 'year'].map((range) {
                  // ===== LOCALIZED RANGE TEXT =====
                  String rangeText;
                  switch (range) {
                    case 'day':
                      rangeText = localizations.day;
                      break;
                    case 'week':
                      rangeText = localizations.week;
                      break;
                    case 'month':
                      rangeText = localizations.month;
                      break;
                    case 'year':
                      rangeText = localizations.year;
                      break;
                    default:
                      rangeText = range.toUpperCase();
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          // ===== SELECTED STATE STYLING =====
                          backgroundColor: _selectedRange == range
                              ? primaryColor
                              : theme.colorScheme.surfaceContainerHighest,
                          foregroundColor: _selectedRange == range
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                        ),
                        onPressed: () => _updateReports(range),
                        child: Text(
                          rangeText.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ===== MAIN CONTENT AREA =====
            // Scrollable container with all charts and analytics
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ===== METRICS OVER TIME SECTION =====
                    Text(
                      localizations.metricsOverTime,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== LINE CHART WITH ZOOM CONTROLS =====
                    Stack(
                      children: [
                        reportsState.lineChartData.isEmpty
                            ? // ===== EMPTY STATE =====
                            _buildNoDataMessage(localizations, theme)
                            : // ===== MULTI-SERIES LINE CHART =====
                            SizedBox(
                                height: 300,
                                child: SfCartesianChart(
                                  zoomPanBehavior: _zoomPanBehavior,
                                  tooltipBehavior: _tooltipBehavior,
                                  onZooming: (args) => _checkZoomState(),
                                  onZoomReset: (args) {
                                    setState(() {
                                      _isZoomed = false;
                                    });
                                  },
                                  legend: Legend(
                                    isVisible: true,
                                    overflowMode: LegendItemOverflowMode.wrap,
                                    alignment: ChartAlignment.center,
                                    textStyle: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                  palette: chartPalette,

                                  // ===== X-AXIS CONFIGURATION =====
                                  primaryXAxis: CategoryAxis(
                                    labelStyle: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    axisLine: const AxisLine(
                                        color: Colors.transparent),
                                    majorTickLines: const MajorTickLines(
                                        color: Colors.transparent),
                                    // ===== RESPONSIVE LABEL INTERVALS =====
                                    // Day view: show fewer labels for 24-hour data
                                    // Other views: show all available data points
                                    interval:
                                        _selectedRange == 'day' ? 3.0 : 1.0,
                                    maximumLabels:
                                        _selectedRange == 'day' ? 24 : 8,
                                  ),

                                  // ===== Y-AXIS CONFIGURATION =====
                                  primaryYAxis: NumericAxis(
                                    labelStyle: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    axisLine: const AxisLine(
                                        color: Colors.transparent),
                                    majorTickLines: const MajorTickLines(
                                        color: Colors.transparent),
                                    majorGridLines: MajorGridLines(
                                      color: gridLineColor,
                                      dashArray: const [5, 5],
                                    ),
                                  ),

                                  // ===== DATA SERIES DEFINITIONS =====
                                  series: <CartesianSeries>[
                                    // ===== MOOD TRACKING SERIES =====
                                    LineSeries<MetricsData, String>(
                                      name: localizations.mood,
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) => data.mood,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: chartPalette[0],
                                      ),
                                      enableTooltip: true,
                                    ),

                                    // ===== ENERGY TRACKING SERIES =====
                                    LineSeries<MetricsData, String>(
                                      name: localizations.energy,
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) => data.energy,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: chartPalette[1],
                                      ),
                                      enableTooltip: true,
                                    ),

                                    // ===== SYMPTOMS TRACKING SERIES =====
                                    LineSeries<MetricsData, String>(
                                      name: localizations.symptoms,
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) => data.symptoms,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: chartPalette[2],
                                      ),
                                      enableTooltip: true,
                                    ),

                                    // ===== TASKS COMPLETION SERIES =====
                                    LineSeries<MetricsData, String>(
                                      name: localizations.tasks,
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) => data.tasks,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: chartPalette[3],
                                      ),
                                      enableTooltip: true,
                                    ),

                                    // ===== HABITS COMPLETION SERIES =====
                                    LineSeries<MetricsData, String>(
                                      name: localizations.habits,
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) => data.habits,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: chartPalette[4],
                                      ),
                                      enableTooltip: true,
                                    ),

                                    // ===== MEDICATION TRACKING SERIES =====
                                    LineSeries<MetricsData, String>(
                                      name: localizations.medication,
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) =>
                                          data.medications,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: chartPalette[5],
                                      ),
                                      enableTooltip: true,
                                    ),
                                  ],
                                ),
                              ),

                        // ===== ZOOM RESET BUTTON =====
                        // Floating action button that appears when chart is zoomed
                        Positioned(
                          right: 10,
                          top: 10,
                          child: AnimatedOpacity(
                            opacity: _isZoomed ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(20),
                              color: theme.colorScheme.surface,
                              shadowColor: theme.colorScheme.shadow,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _zoomPanBehavior.reset(),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.zoom_out_map,
                                    size: 20,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ===== STREAKS SECTION =====
                    // Display longest completion streaks for tasks and habits
                    Text(
                      localizations.streaks,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.longestTasksStreak(
                          reportsState.tasksLongestStreak.toString()),
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      localizations.longestHabitsStreak(
                          reportsState.habitsLongestStreak.toString()),
                      style: TextStyle(color: textColor),
                    ),

                    const SizedBox(height: 24),

                    // ===== TIME MANAGEMENT TECHNIQUES SECTION =====
                    Text(
                      localizations.timeManagementTechniques,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== TECHNIQUE USAGE PIE CHART =====
                    // Compares Flowmodoro vs Time Blocks usage
                    SizedBox(
                      height: 250,
                      child: (reportsState.flowmodoroCount == 0 &&
                              reportsState.timeBlocks == 0)
                          ? // ===== EMPTY STATE =====
                          _buildNoDataMessage(localizations, theme)
                          : // ===== PIE CHART =====
                          SfCircularChart(
                              tooltipBehavior: TooltipBehavior(enable: true),
                              legend: Legend(
                                isVisible: true,
                                overflowMode: LegendItemOverflowMode.wrap,
                                alignment: ChartAlignment.center,
                                textStyle: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              palette: [chartPalette[0], chartPalette[1]],
                              series: <CircularSeries>[
                                PieSeries<PieData, String>(
                                  dataSource: [
                                    PieData(
                                        localizations.flowmodoro,
                                        reportsState.flowmodoroCount
                                            .toDouble()),
                                    PieData(localizations.timeBlocks,
                                        reportsState.timeBlocks.toDouble()),
                                  ],
                                  xValueMapper: (data, _) => data.technique,
                                  yValueMapper: (data, _) => data.usage,
                                  dataLabelMapper: (data, _) => data.technique,
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: false,
                                    textStyle: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  enableTooltip: true,
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 24),

                    // ===== FLOWMODORO INSIGHTS SECTION =====
                    Text(
                      localizations.flowmodoroInsights,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== FLOWMODORO TIME BREAKDOWN DOUGHNUT CHART =====
                    // Shows focus time vs break time distribution
                    SizedBox(
                      height: 200,
                      child: (reportsState.totalFlowFocusTime == 0 &&
                              reportsState.totalFlowBreakTime == 0)
                          ? // ===== EMPTY STATE =====
                          _buildNoDataMessage(localizations, theme)
                          : // ===== DOUGHNUT CHART =====
                          SfCircularChart(
                              palette: [chartPalette[0], chartPalette[1]],
                              tooltipBehavior: TooltipBehavior(enable: false),
                              legend: Legend(
                                isVisible: true,
                                alignment: ChartAlignment.center,
                                textStyle: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.2,
                                ),
                                itemPadding: 8,
                                overflowMode: LegendItemOverflowMode.wrap,
                              ),
                              series: <CircularSeries>[
                                DoughnutSeries<FlowTimeData, String>(
                                  dataSource: [
                                    FlowTimeData(
                                        localizations.breakTime,
                                        ref
                                            .read(reportsControllerProvider
                                                .notifier)
                                            .formatTimeDisplay(
                                                reportsState.totalFlowBreakTime,
                                                localizations),
                                        reportsState.totalFlowBreakTime
                                            .toDouble()),
                                    FlowTimeData(
                                        localizations.focusTime,
                                        ref
                                            .read(reportsControllerProvider
                                                .notifier)
                                            .formatTimeDisplay(
                                                reportsState.totalFlowFocusTime,
                                                localizations),
                                        reportsState.totalFlowFocusTime
                                            .toDouble()),
                                  ],
                                  xValueMapper: (data, _) => data.label,
                                  yValueMapper: (data, _) => data.numericValue,

                                  // ===== MULTI-LINE DATA LABELS =====
                                  // Format labels with intelligent line breaking
                                  dataLabelMapper: (data, _) =>
                                      _formatDataLabel(
                                          data.label, data.displayValue),
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    labelPosition:
                                        ChartDataLabelPosition.outside,
                                    textStyle: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 11,
                                    ),
                                    useSeriesColor: true,
                                    overflowMode: OverflowMode.trim,
                                  ),
                                ),
                              ],
                            ),
                    ),

                    // ===== FLOWMODORO SUMMARY STATISTICS =====
                    Text(
                      localizations.sessions('${reportsState.flowmodoroCount}'),
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      localizations.combinedTime(ref
                          .read(reportsControllerProvider.notifier)
                          .formatTimeDisplay(
                              reportsState.totalFlowTime, localizations)),
                      style: TextStyle(color: textColor),
                    ),

                    const SizedBox(height: 24),

                    // ===== TIME BLOCK INSIGHTS SECTION =====
                    Text(
                      localizations.timeBlockInsights,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== TIME BLOCK USAGE BAR CHART =====
                    // Shows time block count vs total hours spent
                    SizedBox(
                      height: 250,
                      child: (reportsState.timeBlocks == 0 &&
                              reportsState.totalTimeSpentInHours == 0)
                          ? // ===== EMPTY STATE =====
                          _buildNoDataMessage(localizations, theme)
                          : // ===== COLUMN CHART =====
                          SfCartesianChart(
                              legend: Legend(
                                isVisible: true,
                                alignment: ChartAlignment.center,
                                textStyle: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              palette: [chartPalette[0], chartPalette[1]],
                              primaryXAxis: CategoryAxis(
                                labelStyle: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              primaryYAxis: NumericAxis(
                                labelStyle: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                axisLine:
                                    const AxisLine(color: Colors.transparent),
                                majorTickLines: const MajorTickLines(
                                    color: Colors.transparent),
                                majorGridLines: MajorGridLines(
                                  color: gridLineColor,
                                  dashArray: const [5, 5],
                                ),
                              ),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <CartesianSeries>[
                                // ===== TIME BLOCK COUNT COLUMN =====
                                ColumnSeries<TimeBlockData, String>(
                                  name: localizations.timeBlocks,
                                  dataSource: [
                                    TimeBlockData(localizations.blocks,
                                        reportsState.timeBlocks.toDouble()),
                                  ],
                                  xValueMapper: (data, _) => data.label,
                                  yValueMapper: (data, _) => data.value,
                                  width: 0.4,
                                ),

                                // ===== HOURS SPENT COLUMN =====
                                ColumnSeries<TimeBlockData, String>(
                                  name:
                                      '${localizations.hours[0].toUpperCase()}${localizations.hours.substring(1)}',
                                  dataSource: [
                                    TimeBlockData(localizations.time,
                                        reportsState.totalTimeSpentInHours),
                                  ],
                                  xValueMapper: (data, _) => data.label,
                                  yValueMapper: (data, _) => data.value,
                                  dataLabelMapper: (data, _) => ref
                                      .read(reportsControllerProvider.notifier)
                                      .formatTimeDisplay(
                                          data.value, localizations),
                                  width: 0.4,
                                  dataLabelSettings:
                                      const DataLabelSettings(isVisible: false),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== CHART LABEL FORMATTING METHODS =====

  /// Formats data labels with intelligent line breaking for better readability
  /// Analyzes text length and word boundaries to create optimal multi-line labels
  String _formatDataLabel(String label, String value) {
    // ===== LONG LABEL HANDLING =====
    // For labels longer than 12 characters, attempt intelligent word breaking
    if (label.length > 12) {
      final words = label.split(' ');
      if (words.length >= 2) {
        // ===== OPTIMAL BREAK POINT DETECTION =====
        // Find the best place to break text by comparing word lengths
        for (int i = 1; i < words.length; i++) {
          final previousWords = words.sublist(0, i);
          final remainingWords = words.sublist(i);

          final previousCombined = previousWords.join(' ');
          final nextWord = remainingWords.first;

          // ===== BREAK STRATEGY =====
          // If the next word is longer than previous words combined,
          // break here to keep shorter parts together for balance
          if (nextWord.length > previousCombined.length) {
            final firstPart = previousCombined;
            final secondPart = remainingWords.join(' ');
            return '$firstPart\n$secondPart\n$value';
          }
        }

        // ===== FALLBACK: MIDDLE SPLIT =====
        // If no optimal break point found, split at middle
        final mid = words.length ~/ 2;
        final firstPart = words.sublist(0, mid).join(' ');
        final secondPart = words.sublist(mid).join(' ');
        return '$firstPart\n$secondPart\n$value';
      }
    }

    // ===== DEFAULT FORMAT =====
    // For short labels or single words, use simple label + value format
    return '$label\n$value';
  }
}
