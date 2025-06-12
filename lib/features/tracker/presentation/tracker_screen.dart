import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/components/app_header.dart';
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/mood_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/features/tracker/presentation/widgets/icon_grid.dart';
import 'package:spiceease/features/tracker/presentation/widgets/entity_sections.dart';
import 'package:spiceease/features/tracker/presentation/widgets/calendar_widget.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  bool _hasInitialized = false;

  void _showModal(BuildContext context, Widget modal) =>
      showDialog(context: context, builder: (_) => modal);

  void _initializeProviders(DateTime selectedDate) {
    // Removed print statement
    ref.read(taskStateNotifierProvider(selectedDate).notifier).fetchTasks();
    ref.read(habitStateNotifierProvider(selectedDate).notifier).fetchHabits();
    ref
        .read(symptomStateNotifierProvider(selectedDate).notifier)
        .fetchSymptoms();
    ref
        .read(medicationStateNotifierProvider(selectedDate).notifier)
        .fetchMedications();
    ref.read(moodStateNotifierProvider(selectedDate).notifier).fetchMoods();
    ref
        .read(energyStateNotifierProvider(selectedDate).notifier)
        .fetchEnergies();
  }

  @override
  void initState() {
    super.initState();

    // Initialize providers after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        final selectedDate = ref.read(selectedDateProvider);
        _initializeProviders(selectedDate);
        _hasInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    // Listen for date changes and refresh data
    ref.listen<DateTime?>(selectedDateProvider, (previous, next) {
      // Removed print statement
      if (previous != next && next != null && _hasInitialized) {
        _initializeProviders(next);
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppHeader(sectionName: localizations.tracker),
              const SizedBox(height: 12),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: CalendarWidget(),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: IconGrid(
                          showModal: _showModal,
                          selectedDate: selectedDate,
                          ref: ref,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: EntitySections(
                          showModal: _showModal,
                          selectedDate: selectedDate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
