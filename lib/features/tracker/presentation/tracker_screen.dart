// Standard Flutter imports for UI components and state management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Custom app components
import 'package:spiceease/components/app_header.dart';

// Data providers that manage state for different tracking entities
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/mood_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';

// Custom widgets for the tracker interface
import 'package:spiceease/features/tracker/presentation/widgets/icon_grid.dart';
import 'package:spiceease/features/tracker/presentation/widgets/entity_sections.dart';
import 'package:spiceease/features/tracker/presentation/widgets/calendar_widget.dart';

// Internationalization for multi-language support
import 'package:spiceease/l10n/app_localizations.dart';

/// TrackerScreen is the main screen for health and productivity tracking
///
/// This screen provides a comprehensive dashboard where users can:
/// 1. Select dates using a calendar widget
/// 2. Add new tracking entries via an icon grid
/// 3. View and manage existing entries in organized sections
/// 4. Navigate between different days to see historical data
class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  // ===== STATE MANAGEMENT =====

  /// Tracks whether we've already initialized the data providers
  /// This prevents unnecessary duplicate API calls on widget rebuilds
  bool _hasInitialized = false;

  // ===== HELPER METHODS =====

  /// Shows a modal dialog with the provided widget
  /// This is a centralized way to display all add/edit dialogs
  /// @param context: Build context for showing the dialog
  /// @param modal: The widget to display in the modal
  void _showModal(BuildContext context, Widget modal) =>
      showDialog(context: context, builder: (_) => modal);

  /// Initializes all data providers for a specific date
  /// This method fetches fresh data from the backend for the selected date
  /// @param selectedDate: The date for which to load data
  void _initializeProviders(DateTime selectedDate) {
    // Fetch data for all tracking categories
    // Each provider handles its own loading state and error handling

    // Task management data (to-do items, projects, etc.)
    ref.read(taskStateNotifierProvider(selectedDate).notifier).fetchTasks();

    // Habit tracking data (daily/weekly routines)
    ref.read(habitStateNotifierProvider(selectedDate).notifier).fetchHabits();

    // Health symptom tracking data
    ref
        .read(symptomStateNotifierProvider(selectedDate).notifier)
        .fetchSymptoms();

    // Medication adherence tracking data
    ref
        .read(medicationStateNotifierProvider(selectedDate).notifier)
        .fetchMedications();

    // Mood tracking data (emotional state)
    ref.read(moodStateNotifierProvider(selectedDate).notifier).fetchMoods();

    // Energy level tracking data
    ref
        .read(energyStateNotifierProvider(selectedDate).notifier)
        .fetchEnergies();
  }

  // ===== WIDGET LIFECYCLE METHODS =====

  /// Called when the widget is first created
  /// Sets up initial data loading after the widget is fully built
  @override
  void initState() {
    super.initState();

    // Schedule initialization for after the widget tree is built
    // This ensures all providers are ready before we try to use them
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        // Get the currently selected date from the provider
        final selectedDate = ref.read(selectedDateProvider);
        // Load data for that date
        _initializeProviders(selectedDate);
        // Mark as initialized to prevent duplicate calls
        _hasInitialized = true;
      }
    });
  }

  /// Builds the main UI for the tracker screen
  @override
  Widget build(BuildContext context) {
    // ===== STATE AND THEME ACCESS =====

    // Watch the selected date for changes (this will rebuild when date changes)
    final selectedDate = ref.watch(selectedDateProvider);

    // Get current theme for consistent styling
    final theme = Theme.of(context);

    // Get localized text strings for the current language
    final localizations = AppLocalizations.of(context)!;

    // ===== DATE CHANGE LISTENER =====

    // Listen for date changes and refresh data when the date changes
    // This ensures we always show data for the currently selected date
    ref.listen<DateTime?>(selectedDateProvider, (previous, next) {
      // Only refresh if the date actually changed and we've already initialized
      if (previous != next && next != null && _hasInitialized) {
        // Load fresh data for the new date
        _initializeProviders(next);
      }
    });

    // ===== UI CONSTRUCTION =====

    return Scaffold(
      // Use theme background color for consistency
      backgroundColor: theme.colorScheme.surface,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== APP HEADER =====
              // Shows the section title and potentially navigation elements
              AppHeader(sectionName: localizations.tracker),

              const SizedBox(height: 12),

              // ===== CALENDAR WIDGET =====
              // Allows users to select different dates to view/edit data
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2, // Subtle shadow for depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: CalendarWidget(), // Custom calendar component
                ),
              ),

              const SizedBox(height: 12),

              // ===== MAIN CONTENT AREA =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ===== ICON GRID SECTION =====
                    // Quick-add buttons for creating new entries
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: IconGrid(
                          showModal: _showModal, // Function to show dialogs
                          selectedDate: selectedDate, // Current date context
                          ref: ref, // Provider reference
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== ENTITY SECTIONS =====
                    // Displays organized lists of all tracking data
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: EntitySections(
                          showModal: _showModal, // Function to show dialogs
                          selectedDate: selectedDate, // Current date context
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
