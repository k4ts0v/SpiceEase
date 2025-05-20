import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/reports/metrics_data.dart';
import 'package:spiceease/features/reports/pie_data.dart';
import 'package:spiceease/features/reports/reports_controller.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedDate = ref.read(selectedDateProvider);
      ref
          .read(reportsControllerProvider.notifier)
          .fetchReportsForTimeRange(_selectedRange, selectedDate);
    });
  }

  // Widget to show when there's no data
  Widget _buildNoDataMessage() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No data for this period',
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Method to create a modified data source for day view to show fewer markers
  List<MetricsData> _getModifiedDataSource(List<MetricsData> originalData) {
    if (_selectedRange != 'day') {
      // For non-day views, show all markers
      return originalData;
    }

    // For day view, create a filtered data source
    List<MetricsData> modifiedData = [];
    for (int i = 0; i < originalData.length; i++) {
      if (i % 3 == 0) {
        // Keep data points at every 3rd position
        modifiedData.add(originalData[i]);
      } else {
        // For other positions, retain the line but not the marker
        modifiedData.add(MetricsData(
          originalData[i].day,
          originalData[i].mood,
          originalData[i].energy,
          originalData[i].symptoms,
          originalData[i].tasks,
          originalData[i].habits,
        ));
      }
    }
    return modifiedData;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final localizations = AppLocalizations.of(context)!;
    final reportsState = ref.watch(reportsControllerProvider);

    // Create a modified data source for displaying markers
    final modifiedData = _getModifiedDataSource(reportsState.lineChartData);

    // Listen for changes to the selected date and update reports
    ref.listen(selectedDateProvider, (previous, next) {
      if (previous != next) {
        // Date changed, refresh the reports
        _updateReports(_selectedRange);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reports",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CalendarWeekSelector(
                selectedDate: selectedDate,
                locale: Localizations.localeOf(context),
                theme: theme,
              ),
            ),
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['day', 'week', 'month', 'year'].map((range) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _selectedRange == range
                          ? theme.colorScheme.primary
                          : Colors.grey[300],
                      foregroundColor: _selectedRange == range
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onPressed: () => _updateReports(range),
                    child: Text(range.toUpperCase()),
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
                      'Metrics over time',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        reportsState.lineChartData.isEmpty
                            ? _buildNoDataMessage()
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
                                    textStyle: const TextStyle(
                                        color: Colors.black54, fontSize: 12),
                                  ),
                                  palette: const [
                                    Color(0xFF90CAF9),
                                    Color(0xFFEF9A9A),
                                    Color(0xFFFFF176),
                                    Color(0xFFA5D6A7),
                                    Color(0xFFFFCC80),
                                  ],
                                  primaryXAxis: CategoryAxis(
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
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
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    axisLine: const AxisLine(
                                        color: Colors.transparent),
                                    majorTickLines: const MajorTickLines(
                                        color: Colors.transparent),
                                    majorGridLines: const MajorGridLines(
                                      color: Color(0xFFE0E0E0),
                                      dashArray: [5, 5],
                                    ),
                                  ),
                                  series: <CartesianSeries>[
                                    LineSeries<MetricsData, String>(
                                      name: 'Mood',
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) => data.mood,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: const Color(0xFF90CAF9),
                                      ),
                                      enableTooltip: true,
                                    ),
                                    LineSeries<MetricsData, String>(
                                      name: 'Energy',
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) => data.energy,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: const Color(0xFFEF9A9A),
                                      ),
                                      enableTooltip: true,
                                    ),
                                    LineSeries<MetricsData, String>(
                                      name: 'Symptoms',
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) => data.symptoms,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: const Color(0xFFFFF176),
                                      ),
                                      enableTooltip: true,
                                    ),
                                    LineSeries<MetricsData, String>(
                                      name: 'Tasks',
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) => data.tasks,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: const Color(0xFFA5D6A7),
                                      ),
                                      enableTooltip: true,
                                    ),
                                    LineSeries<MetricsData, String>(
                                      name: 'Habits',
                                      dataSource: reportsState.lineChartData,
                                      xValueMapper: (data, _) => data.day,
                                      yValueMapper: (data, _) => data.habits,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        width: 6,
                                        height: 6,
                                        borderWidth: 2,
                                        borderColor: const Color(0xFFFFCC80),
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
                              color: Colors.white,
                              shadowColor: Colors.black54,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _zoomPanBehavior.reset(),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.zoom_out_map,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Streaks',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Longest tasks streak: ${reportsState.tasksLongestStreak} days'),
                    Text(
                        'Longest habits streak: ${reportsState.habitsLongestStreak} days'),
                    const SizedBox(height: 24),
                    Text(
                      'Time Management Techniques',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 250,
                      child: SfCircularChart(
                        tooltipBehavior: TooltipBehavior(enable: true),
                        legend: Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                          alignment: ChartAlignment.center,
                          textStyle: const TextStyle(color: Colors.black54),
                        ),
                        palette: const [
                          Color(0xFF90CAF9),
                          Color(0xFFEF9A9A),
                        ],
                        series: <CircularSeries>[
                          PieSeries<PieData, String>(
                            dataSource: [
                              PieData('Flowmodoro',
                                  reportsState.flowmodoroCount.toDouble()),
                              PieData('Time Blocking',
                                  reportsState.timeBlocks.toDouble()),
                            ],
                            xValueMapper: (data, _) => data.technique,
                            yValueMapper: (data, _) => data.usage,
                            dataLabelMapper: (data, _) => data.technique,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(color: Colors.black54),
                            ),
                            enableTooltip: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Flowmodoro Insights',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: SfCircularChart(
                        palette: const [
                          Color(0xFF90CAF9),
                          Color(0xFFEF9A9A),
                        ],
                        tooltipBehavior: TooltipBehavior(enable: true),
                        legend: Legend(
                          isVisible: true,
                          alignment: ChartAlignment.center,
                        ),
                        series: <CircularSeries>[
                          DoughnutSeries<_FlowTimeData, String>(
                            dataSource: [
                              _FlowTimeData(
                                  'Focus', reportsState.totalFlowFocusTime),
                              _FlowTimeData(
                                  'Break', reportsState.totalFlowBreakTime),
                            ],
                            xValueMapper: (data, _) => data.label,
                            yValueMapper: (data, _) => data.value,
                            dataLabelMapper: (data, _) => data.label,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                          ),
                        ],
                      ),
                    ),
                    Text('Sessions: ${reportsState.flowmodoroCount}'),
                    Text(
                        'Combined Time: ${ref.read(reportsControllerProvider.notifier).formatTimeDisplay(reportsState.totalFlowTime)}'),
                    const SizedBox(height: 24),
                    const Text(
                      'Time-Block Insights',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 250,
                      child: SfCartesianChart(
                        legend: Legend(
                            isVisible: true, alignment: ChartAlignment.center),
                        palette: const [
                          Color(0xFF90CAF9), // Pastel Blue
                          Color(0xFFEF9A9A), // Pastel Red
                        ],
                        primaryXAxis: CategoryAxis(
                            labelStyle: const TextStyle(color: Colors.grey)),
                        primaryYAxis: NumericAxis(
                          labelStyle: const TextStyle(color: Colors.grey),
                          axisLine: const AxisLine(color: Colors.transparent),
                          majorTickLines:
                              const MajorTickLines(color: Colors.transparent),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <CartesianSeries>[
                          // Side-by-side bar for time block counts
                          ColumnSeries<_TimeBlockData, String>(
                            name: 'Time Blocks',
                            dataSource: [
                              _TimeBlockData(
                                  'Blocks', reportsState.timeBlocks.toDouble()),
                            ],
                            xValueMapper: (data, _) => data.label,
                            yValueMapper: (data, _) => data.value,
                            width: 0.4,
                          ),
                          // Another bar for hours
                          ColumnSeries<_TimeBlockData, String>(
                            name: 'Hours',
                            dataSource: [
                              _TimeBlockData(
                                  'Time', reportsState.totalTimeSpentInHours),
                            ],
                            xValueMapper: (data, _) => data.label,
                            yValueMapper: (data, _) => data.value,
                            dataLabelMapper: (data, _) => ref
                                .read(reportsControllerProvider.notifier)
                                .formatTimeDisplay(data.value),
                            width: 0.4,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
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
}

class _FlowTimeData {
  final String label;
  final double value;
  _FlowTimeData(this.label, this.value);
}

class _TimeBlockData {
  final String label;
  final double value;
  _TimeBlockData(this.label, this.value);
}
