import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/app/app_initializer.dart';
import 'package:spiceease/components/app_header.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';
import 'package:spiceease/features/reports/data_models/flow_time_data.dart';
import 'package:spiceease/features/reports/data_models/metrics_data.dart';
import 'package:spiceease/features/reports/data_models/pie_data.dart';
import 'package:spiceease/features/reports/reports_controller.dart';
import 'package:spiceease/features/reports/data_models/time_block_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/components/calendar_week_selector.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  late final ZoomPanBehavior _zoomPanBehavior;
  late TooltipBehavior _tooltipBehavior;
  // Track the selected time range: day, week, month, or year
  String _selectedRange = 'week';
  // Track zoom state
  bool _isZoomed = false;

  // Method to update calendar selection and fetch reports
  void _updateReports(String range) {
    setState(() => _selectedRange = range);
    final selectedDate = ref.read(selectedDateProvider);

    // Fetch data for the selected range using the selected date
    ref
        .read(reportsControllerProvider.notifier)
        .fetchReportsForTimeRange(range, selectedDate);
  }

  void _checkZoomState() {
    setState(() {
      _isZoomed = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: true,
      enableMouseWheelZooming: true,
      enableSelectionZooming: true,
      zoomMode: ZoomMode.xy,
    );
    _tooltipBehavior = TooltipBehavior(enable: true);

    final selectedDate = ref.read(selectedDateProvider);
    // Wait for app initialization before fetching data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure app is fully initialized first
      try {
        await ref.read(appInitializerProvider.future);

        // Only then fetch reports if user is authenticated
        final isAuthenticated = await ref.read(isAuthenticatedProvider);
        if (isAuthenticated && mounted) {
          final controller = ref.read(reportsControllerProvider.notifier);
          await controller.fetchReportsForTimeRange(
              _selectedRange, selectedDate);
        }
      } catch (e) {
        print('Error in reports page initialization: $e');
        // Handle error appropriately
      }
    });
  }

  // Widget to show when there's no data
  Widget _buildNoDataMessage(AppLocalizations localizations, ThemeData theme) {
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
          Icon(Icons.bar_chart_outlined, size: 48, color: iconColor),
          const SizedBox(height: 16),
          Text(
            localizations.noDataForPeriod,
            style: TextStyle(
                fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Get chart palette based on theme brightness
  List<Color> _getChartPalette(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const [
        Color(0xFF0D47A1), // Deep blue
        Color(0xFF1B5E20), // Forest green
        Color(0xFFF57F17), // Amber gold
        Color(0xFFE65100), // Burnt orange
        Color(0xFFB71C1C), // Crimson red
        Color(0xFF4A148C), // Deep purple
      ];
    } else {
      return const [
        Color(0xFF90CAF9), // Pastel blue for light mode
        Color(0xFFEF9A9A), // Pastel red for light mode
        Color(0xFFFFF176), // Pastel yellow for light mode
        Color(0xFFA5D6A7), // Pastel green for light mode
        Color(0xFFFFCC80), // Pastel orange for light mode
        Color(0xFFC680FF), // Pastel purple for light mode
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final localizations = AppLocalizations.of(context)!;
    final reportsState = ref.watch(reportsControllerProvider);

    final chartPalette = _getChartPalette(theme);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define theme-adaptable colors
    final backgroundColor = theme.colorScheme.background;
    final surfaceColor = theme.colorScheme.surface;
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;
    final gridLineColor =
        isDarkMode ? Colors.grey[700] : const Color(0xFFE0E0E0);

    // Listen for changes to the selected date and update reports
    ref.listen(selectedDateProvider, (previous, next) {
      if (previous != next) {
        // Date changed, refresh the reports
        _updateReports(_selectedRange);
      }
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(sectionName: localizations.insights),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
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
            Container(
              color: surfaceColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['day', 'week', 'month', 'year'].map((range) {
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
                          backgroundColor: _selectedRange == range
                              ? primaryColor
                              : theme.colorScheme.surfaceVariant,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      localizations.metricsOverTime,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        reportsState.lineChartData.isEmpty
                            ? _buildNoDataMessage(localizations, theme)
                            : SizedBox(
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
                                  primaryXAxis: CategoryAxis(
                                    labelStyle: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    axisLine: const AxisLine(
                                        color: Colors.transparent),
                                    majorTickLines: const MajorTickLines(
                                        color: Colors.transparent),
                                    // For day view, show fewer labels but ensure we include all hours
                                    interval:
                                        _selectedRange == 'day' ? 3.0 : 1.0,
                                    // Ensure the maximum label index includes all hours (0-23)
                                    maximumLabels:
                                        _selectedRange == 'day' ? 24 : 8,
                                  ),
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
                                      dashArray: [5, 5],
                                    ),
                                  ),
                                  series: <CartesianSeries>[
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
                                        borderColor: chartPalette[
                                            5], // Use the 6th color from your palette
                                      ),
                                      enableTooltip: true,
                                    ),
                                  ],
                                ),
                              ),
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
                    Text(
                      localizations.timeManagementTechniques,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 250,
                      child: (reportsState.flowmodoroCount == 0 &&
                              reportsState.timeBlocks == 0)
                          ? _buildNoDataMessage(localizations, theme)
                          : SfCircularChart(
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
                    Text(
                      localizations.flowmodoroInsights,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: (reportsState.totalFlowFocusTime == 0 &&
                              reportsState.totalFlowBreakTime == 0)
                          ? _buildNoDataMessage(localizations, theme)
                          : SfCircularChart(
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
                                  // Use a function to create multi-line labels
                                  dataLabelMapper: (data, _) =>
                                      _formatDataLabel(
                                          data.label, data.displayValue),
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    labelPosition:
                                        ChartDataLabelPosition.outside,
                                    textStyle: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 11, // Slightly smaller font
                                    ),
                                    useSeriesColor: true,
                                    // Allow text wrapping
                                    overflowMode: OverflowMode.trim,
                                  ),
                                ),
                              ],
                            ),
                    ),
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
                    Text(
                      localizations.timeBlockInsights,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 250,
                      child: (reportsState.timeBlocks == 0 &&
                              reportsState.totalTimeSpentInHours == 0)
                          ? _buildNoDataMessage(localizations, theme)
                          : SfCartesianChart(
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
                                  dashArray: [5, 5],
                                ),
                              ),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <CartesianSeries>[
                                // Side-by-side bar for time block counts
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
                                // Another bar for hours
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

// Helper method to format data labels with line breaks
  String _formatDataLabel(String label, String value) {
    // If the label is longer than 12 characters, try to break it intelligently
    if (label.length > 12) {
      final words = label.split(' ');
      if (words.length >= 2) {
        // Find the best break point by comparing combined length of previous words
        // with the length of the next word
        for (int i = 1; i < words.length; i++) {
          final previousWords = words.sublist(0, i);
          final remainingWords = words.sublist(i);

          final previousCombined = previousWords.join(' ');
          final nextWord = remainingWords.first;

          // If the next word is longer than the combination of previous words,
          // break here to keep the shorter parts together
          if (nextWord.length > previousCombined.length) {
            final firstPart = previousCombined;
            final secondPart = remainingWords.join(' ');
            return '$firstPart\n$secondPart\n$value';
          }
        }

        // If no good break point found, fall back to middle split
        final mid = words.length ~/ 2;
        final firstPart = words.sublist(0, mid).join(' ');
        final secondPart = words.sublist(mid).join(' ');
        return '$firstPart\n$secondPart\n$value';
      }
    }

    // Default: label and value on separate lines
    return '$label\n$value';
  }
}
