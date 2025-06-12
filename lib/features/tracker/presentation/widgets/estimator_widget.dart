
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/services/estimator_service.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class EstimatorWidget extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final Function(String, String) onEstimateUpdated;
  final String? initialValue;

  const EstimatorWidget({
    super.key,
    required this.title,
    required this.description,
    required this.onEstimateUpdated,
    this.initialValue,
  });

  @override
  ConsumerState<EstimatorWidget> createState() => _EstimatorWidgetState();
}

class _EstimatorWidgetState extends ConsumerState<EstimatorWidget> {
  String _rawEstimate = '';
  final String _estimatedTime = '';
  final String _estimatedUnit = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial value if provided
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _rawEstimate = widget.initialValue!;

      // Only notify parent if we have a valid initial value
      if (_rawEstimate.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onEstimateUpdated(_rawEstimate, '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Display the parsed values if available, otherwise show the label
    final String displayText = (_estimatedTime.isNotEmpty)
        ? "$_estimatedTime $_estimatedUnit"
        : (_rawEstimate.isNotEmpty)
            ? _rawEstimate
            : localizations.estimatedTimeLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: localizations.estimatedTimeLabel,
                  border: const OutlineInputBorder(),
                ),
                controller: TextEditingController(text: displayText),
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      try {
                        final estimatorService =
                            ref.read(estimatorServiceProvider);
                        debugPrint("Estimating task with title: ${widget.title}");

                        // First get the raw API response
                        final result = await estimatorService.estimateTask(
                          widget.title,
                          widget.description,
                          localizations.estimateInstructions,
                        );

                        debugPrint("API estimation result: $result");

                        if (result is String && result.isNotEmpty) {
                          // Then parse the response to extract time and unit
                          final parsed = await estimatorService
                              .parseResponseWithLocale(result, context);
                          debugPrint("Parsed estimation: $parsed");

                          if (parsed != null) {
                            setState(() {
                              _rawEstimate =
                                  '${parsed['estimate']} ${parsed['unit']}';
                            });
                          }

                          // Pass the raw estimate to parent
                          widget.onEstimateUpdated(_rawEstimate, '');
                          debugPrint(_rawEstimate);
                        }
                      } catch (e) {
                        debugPrint("Error estimating task: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(localizations.estimate),
            ),
          ],
        ),
      ],
    );
  }
}