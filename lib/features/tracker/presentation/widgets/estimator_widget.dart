import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/services/estimator_service.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// ===== AI-POWERED TIME ESTIMATION WIDGET =====
// This widget provides intelligent time estimation for tasks using external APIs

/// A widget that provides AI-powered time estimation for tasks and subtasks
///
/// This widget integrates with external estimation services (like Goblin Tools API)
/// to provide intelligent time estimates for user tasks. It includes:
/// - API-based estimation with fallback to local heuristics
/// - User-friendly interface with loading states and error handling
/// - Localized time unit display
/// - One-click integration with task/subtask forms
///
/// The estimation process:
/// 1. First attempts to use external API for intelligent estimation
/// 2. Falls back to local heuristics if API fails
/// 3. Allows users to accept and use the estimate in their task
class EstimatorWidget extends StatefulWidget {
  /// The main title/name of the task to estimate
  final String title;

  /// Optional description providing additional context for estimation
  final String? description;

  /// Riverpod reference for accessing estimation services
  final WidgetRef ref;

  /// Callback function triggered when user accepts an estimate
  /// The estimated time string is passed to this function
  final Function(String) onEstimated;

  /// Optional initial value to pre-populate the estimate
  final String? initialValue;

  const EstimatorWidget({
    super.key,
    required this.title,
    this.description,
    required this.ref,
    required this.onEstimated,
    this.initialValue,
  });

  @override
  State<EstimatorWidget> createState() => _EstimatorWidgetState();
}

/// State management for the EstimatorWidget
/// Handles the estimation process, loading states, and user interactions
class _EstimatorWidgetState extends State<EstimatorWidget> {
  // ===== STATE VARIABLES =====
  String? _estimatedTime; // Current estimated time result
  bool _isLoading = false; // Whether estimation is in progress
  String? _error; // Error message if estimation fails

  @override
  void initState() {
    super.initState();
    // Pre-populate with initial value if provided
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _estimatedTime = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== ESTIMATION BUTTON SECTION =====
        // Main button to trigger the estimation process
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _estimateTime(),
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 16),
              label: Text(
                _isLoading
                    ? localizations.estimating
                    : localizations.estimateTime,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
              ),
            ),
          ],
        ),

        // ===== ESTIMATION RESULT SECTION =====
        // Displays the estimated time and allows user to accept it
        if (_estimatedTime != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Time icon indicator
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                // Estimated time text
                Expanded(
                  child: Text(
                    _estimatedTime!,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // Use estimate button
                TextButton(
                  onPressed: () {
                    // Pass the estimate to the parent and clear the display
                    widget.onEstimated(_estimatedTime!);
                    setState(() {
                      _estimatedTime = null;
                      _error = null;
                    });
                  },
                  child: Text(
                    localizations.use,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // ===== ERROR MESSAGE SECTION =====
        // Shows error information if estimation fails
        if (_error != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Warning icon
                Icon(
                  Icons.warning_outlined,
                  size: 16,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                // Error message text
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Performs intelligent time estimation with API fallback
  ///
  /// This method implements a two-tier estimation strategy:
  /// 1. Primary: Uses external API (Goblin Tools) for AI-powered estimation
  /// 2. Fallback: Uses local heuristics if API fails or returns invalid data
  ///
  /// The process includes proper error handling, timeouts, and user feedback
  Future<void> _estimateTime() async {
    // Safety check to prevent operations on disposed widgets
    if (!mounted) return;

    // Reset state and show loading indicator
    setState(() {
      _isLoading = true;
      _error = null;
      _estimatedTime = null;
    });

    try {
      final service = widget.ref.read(estimatorServiceProvider);
      final localizations = AppLocalizations.of(context)!;

      print('Starting estimation process...');

      // ===== PRIMARY ESTIMATION: API-BASED =====
      String? finalEstimate;
      bool usedFallback = false;

      try {
        print('Attempting API estimation...');

        // Condition to guide the API response format
        final condition =
            "Give the estimate in numbers. For ranges, separate them using 'to'.";

        // Make API request with timeout protection
        final response = await service
            .estimateTask(
          widget.title,
          widget.description ?? '',
          condition,
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('API estimation timed out');
            throw Exception('Request timed out');
          },
        );

        print('API response received: $response');

        // Validate and parse API response
        if (response != null && response.toString().trim().isNotEmpty) {
          try {
            // Parse the response using the service's localization-aware parser
            final parsed = await service.parseResponseWithLocale(
              response.toString(),
              context,
            );

            // Validate parsed data structure
            if (parsed != null &&
                parsed['estimate'] != null &&
                parsed['unit'] != null &&
                mounted) {
              finalEstimate = "${parsed['estimate']} ${parsed['unit']}";
              print('Successfully parsed API response: $finalEstimate');
            } else {
              print('Failed to parse API response - null or invalid data');
              throw Exception('Invalid response format');
            }
          } catch (parseError) {
            print('Error parsing API response: $parseError');
            throw parseError;
          }
        } else {
          print('Empty or null API response');
          throw Exception('Empty response from API');
        }
      } catch (apiError) {
        print('API estimation failed: $apiError');
        usedFallback = true;
      }

      // ===== FALLBACK ESTIMATION: LOCAL HEURISTICS =====
      // Use local estimation if API failed or returned unusable data
      if (finalEstimate == null) {
        print('Using fallback estimation...');
        usedFallback = true;

        // Additional safety check before proceeding with fallback
        if (!mounted) return;

        try {
          // Generate estimate using local heuristic algorithms
          final fallback = service.getFallbackEstimation(
            widget.title,
            widget.description ?? '',
            context,
          );

          // Validate fallback data
          if (fallback['estimate'] != null && fallback['unit'] != null) {
            finalEstimate = "${fallback['estimate']} ${fallback['unit']}";
            print('Fallback estimation: $finalEstimate');
          } else {
            throw Exception('Fallback estimation failed');
          }
        } catch (fallbackError) {
          print('Fallback estimation failed: $fallbackError');
          throw Exception('Both API and fallback estimation failed');
        }
      }

      // ===== UPDATE UI WITH RESULTS =====
      // Display the final estimate with appropriate labeling
      if (mounted && finalEstimate != null) {
        setState(() {
          // Add "(estimated)" suffix for fallback estimates to indicate lower confidence
          _estimatedTime = usedFallback
              ? "$finalEstimate (${localizations.estimated})"
              : finalEstimate;
          _isLoading = false;
          _error = null;
        });

        print('Estimation completed successfully: $_estimatedTime');
      }
    } catch (e) {
      print('Estimation failed completely: $e');

      // ===== ERROR HANDLING =====
      // Show user-friendly error message if all estimation methods fail
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context)!.estimationFailed;
          _isLoading = false;
          _estimatedTime = null;
        });
      }
    }
  }
}
