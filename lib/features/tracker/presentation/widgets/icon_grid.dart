// Standard Flutter imports for UI components and state management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Third-party packages for icons and date formatting
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// Data models that define the structure of different tracking entities
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';

// Providers that manage state for different tracking entities
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/mood_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

// Editor modals for different tracking types
import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';

// Controller that handles business logic
import 'package:spiceease/features/tracker/presentation/controllers/tracker_controller.dart';

// Reusable icon launcher component
import 'package:spiceease/features/tracker/presentation/widgets/icon_list_launcher.dart';

// Internationalization for multi-language support
import 'package:spiceease/l10n/app_localizations.dart';

// ===== TRACKER ICON GRID COMPONENT =====
// This section provides the main grid of tracker icons for the dashboard

/// A grid widget that displays all available tracking categories as interactive icons
///
/// This widget serves as the main interface for accessing different tracking features.
/// It creates a responsive grid of IconListLauncher widgets, each representing a
/// different tracking category (mood, energy, habits, tasks, etc.).
///
/// Key Features:
/// - Displays all tracking categories in a visually appealing grid
/// - Each icon shows current stats and provides quick access to add/view items
/// - Responsive layout that adapts to different screen sizes
/// - Consistent styling with theme-aware colors and shadows
/// - Localized labels and content
///
/// The grid includes trackers for:
/// - Energy levels (1-10 scale with notes)
/// - Mood levels (1-10 scale with notes)
/// - Medications (dosage tracking and adherence)
/// - Symptoms (categorized health issues with severity)
/// - Tasks (project management with subtasks and priorities)
/// - Habits (recurring activities with custom frequencies)
class IconGrid extends ConsumerWidget {
  /// Function to display modal dialogs for different tracker types
  final Function(BuildContext, Widget) showModal;

  /// The currently selected date for filtering data
  final DateTime selectedDate;

  /// Riverpod reference for accessing providers
  final WidgetRef ref;

  const IconGrid({
    super.key,
    required this.showModal,
    required this.selectedDate,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ===== DATA PROVIDERS =====
    // Watch all tracking data providers for the selected date
    final energy = ref.watch(energyStateNotifierProvider(selectedDate));
    final moods = ref.watch(moodStateNotifierProvider(selectedDate));
    final symptoms = ref.watch(symptomStateNotifierProvider(selectedDate));
    final tasks = ref.watch(taskStateNotifierProvider(selectedDate));
    final habits = ref.watch(habitStateNotifierProvider(selectedDate));
    final medication = ref.watch(medicationStateNotifierProvider(selectedDate));

    // ===== THEME AND LOCALIZATION =====
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16, // Horizontal spacing between icons
        runSpacing: 16, // Vertical spacing between rows
        alignment: WrapAlignment.center, // Center-align the grid
        children: [
          // ===== ENERGY LEVEL TRACKER =====
          // Tracks daily energy levels on a 1-10 scale
          IconListLauncher<EnergyModel>(
            title: localizations.energy,
            icon: Icon(Icons.bolt, color: theme.colorScheme.primary),
            items: energy,
            // Open energy editor modal when adding new entry
            onAdd: () => showModal(context, EnergyLevelEditorModal(ref: ref)),
            // Open energy editor with existing data when tapping item
            onTap: (e) => showModal(
                context, EnergyLevelEditorModal(ref: ref, existing: e)),
            // Display energy level as primary text
            itemBuilder: (e) => '${e.energyLevel}',
            // Show notes as additional context
            additionalTextBuilder: (e) =>
                '${localizations.additionalNotes}: ${e.notes}',
            // Handle energy entry deletion
            onDelete: (e) =>
                ref.read(trackerControllerProvider).deleteEnergy(e.id, ref),
            // Open editor for existing energy entry
            onEdit: (e) => showModal(
                context, EnergyLevelEditorModal(ref: ref, existing: e)),
            // Show current energy level or placeholder
            statsLabelBuilder: () =>
                energy.isEmpty ? '—' : '${energy.last.energyLevel}/10',
          ),

          // ===== MOOD TRACKER =====
          // Tracks daily mood levels on a 1-10 scale with notes
          IconListLauncher<MoodModel>(
            title: localizations.mood,
            icon: Icon(FontAwesomeIcons.faceSmile,
                color: theme.colorScheme.primary),
            items: moods,
            // Open mood editor modal when adding new entry
            onAdd: () => showModal(context, MoodLevelEditorModal(ref: ref)),
            // Open mood editor with existing data when tapping item
            onTap: (mood) => showModal(
                context, MoodLevelEditorModal(ref: ref, existing: mood)),
            // Display mood level as primary text
            itemBuilder: (e) => '${e.moodLevel}',
            // Show notes as additional context
            additionalTextBuilder: (e) =>
                '${localizations.additionalNotes}: ${e.notes}',
            // Handle mood entry deletion
            onDelete: (e) =>
                ref.read(trackerControllerProvider).deleteMood(e.id, ref),
            // Open editor for existing mood entry
            onEdit: (e) =>
                showModal(context, MoodLevelEditorModal(ref: ref, existing: e)),
            // Show current mood level or placeholder
            statsLabelBuilder: () =>
                moods.isEmpty ? '—' : '${moods.last.moodLevel}/10',
          ),

          // ===== MEDICATION TRACKER =====
          // Tracks medication adherence with dosage and frequency management
          IconListLauncher<MedicationModel>(
            title: localizations.medication,
            icon: Icon(Icons.medication, color: theme.colorScheme.primary),
            items: medication,
            // Open medication editor modal when adding new entry
            onAdd: () => showModal(context, MedicationEditorModal(ref: ref)),
            // Open medication editor with existing data when tapping item
            onTap: (med) => showModal(
                context, MedicationEditorModal(ref: ref, existing: med)),
            // Display medication name as primary text
            itemBuilder: (m) => m.name,
            // Show dosage information as additional context
            additionalTextBuilder: (m) =>
                '${localizations.dose}: ${m.dose} ${m.unit}',
            // Handle medication deletion
            onDelete: (m) =>
                ref.read(trackerControllerProvider).deleteMedication(m.id),
            // Open editor for existing medication
            onEdit: (m) => showModal(
                context, MedicationEditorModal(ref: ref, existing: m)),
            // Calculate and display medication adherence stats
            statsLabelBuilder: () {
              if (medication.isEmpty) return '—';

              final today = DateTime.now();
              int takenCount = 0;

              // Count medications taken today vs. total medications
              for (final med in medication) {
                final countToday = med.getTakenCountForDate(today);

                bool isCounted = false;
                if (med.timesPerDay == 1) {
                  // Single-dose: count if taken at least once today
                  isCounted = countToday > 0;
                } else {
                  // Multi-dose: count if all required doses are taken
                  isCounted = countToday >= med.timesPerDay;
                }

                if (isCounted) {
                  takenCount++;
                }
              }

              return '$takenCount/${medication.length}';
            },
          ),

          // ===== SYMPTOM TRACKER =====
          // Tracks health symptoms with categories and severity levels
          IconListLauncher<SymptomModel>(
            title: localizations.symptoms,
            icon: Icon(Icons.healing, color: theme.colorScheme.primary),
            items: symptoms,
            // Open symptom editor modal when adding new entry
            onAdd: () => showModal(context, SymptomEditorModal(ref: ref)),
            // Open symptom editor with existing data when tapping item
            onTap: (symptom) => showModal(
                context, SymptomEditorModal(ref: ref, existing: symptom)),
            // Display symptom name as primary text
            itemBuilder: (s) => s.name,
            // Show category and severity as additional context
            additionalTextBuilder: (s) =>
                '${localizations.category}: ${s.category}\n${localizations.severity}: ${s.severity}',
            // Handle symptom deletion
            onDelete: (s) =>
                ref.read(trackerControllerProvider).deleteSymptom(s.id, ref),
            // Open editor for existing symptom
            onEdit: (s) =>
                showModal(context, SymptomEditorModal(ref: ref, existing: s)),
            // Show total count of symptoms tracked today
            statsLabelBuilder: () => '${symptoms.length}',
          ),

          // ===== TASK TRACKER =====
          // Manages tasks with priorities, due dates, and subtask support
          IconListLauncher<TaskModel>(
            title: localizations.tasks,
            icon: Icon(Icons.task_alt, color: theme.colorScheme.primary),
            items: tasks,
            // Open task editor modal when adding new entry
            onAdd: () => showModal(context, TaskEditorModal(ref: ref)),
            // Open task editor with existing data when tapping item
            onTap: (task) =>
                showModal(context, TaskEditorModal(ref: ref, existing: task)),
            // Display task title as primary text
            itemBuilder: (t) => t.title,
            // Show due date and status as additional context
            additionalTextBuilder: (t) =>
                '${t.dueDate != null ? "${localizations.due}: ${DateFormat('EEE, d MMMM', localizations.localeName).format(t.dueDate!.toLocal())}" : localizations.noDueDate} | ${localizations.status}: ${t.status}',
            // Handle task deletion
            onDelete: (s) =>
                ref.read(trackerControllerProvider).deleteTask(s.id),
            // Open editor for existing task
            onEdit: (s) =>
                showModal(context, TaskEditorModal(ref: ref, existing: s)),
            // Calculate and display task completion stats for today
            statsLabelBuilder: () {
              if (tasks.isEmpty) return '—';

              // Count tasks completed today
              final completedToday = tasks.where((t) {
                final today = DateTime.now();
                return t.completedAt != null &&
                    t.completedAt!.year == today.year &&
                    t.completedAt!.month == today.month &&
                    t.completedAt!.day == today.day;
              }).length;

              return '$completedToday/${tasks.length}';
            },
          ),

          // ===== HABIT TRACKER =====
          // Manages recurring habits with custom frequencies and completion tracking
          IconListLauncher<HabitModel>(
            title: localizations.habits,
            icon: Icon(Icons.sync_rounded, color: theme.colorScheme.primary),
            items: habits,
            // Open habit editor modal when adding new entry
            onAdd: () => showModal(context, HabitEditorModal(ref: ref)),
            // Open habit editor with existing data when tapping item
            onTap: (habit) =>
                showModal(context, HabitEditorModal(ref: ref, existing: habit)),
            // Display habit title as primary text
            itemBuilder: (h) => h.title,
            // Show due date and description as additional context
            additionalTextBuilder: (h) {
              final dueDate = h.nextDueDate;
              final duePart = (dueDate == null)
                  ? localizations.noDueDate
                  : '${localizations.due}: ${DateFormat('EEE, d MMMM', localizations.localeName).format(dueDate.toLocal())}';
              return '$duePart | ${localizations.description}: ${h.description}';
            },
            // Handle habit deletion
            onDelete: (s) =>
                ref.read(trackerControllerProvider).deleteHabit(s.id),
            // Open editor for existing habit
            onEdit: (s) =>
                showModal(context, HabitEditorModal(ref: ref, existing: s)),
            // Calculate and display habit completion stats for today
            statsLabelBuilder: () {
              if (habits.isEmpty) return '—';

              final today = DateTime.now();
              // Count habits completed today
              final completedToday = habits
                  .where((h) =>
                      h.lastCompleted != null &&
                      h.lastCompleted!.year == today.year &&
                      h.lastCompleted!.month == today.month &&
                      h.lastCompleted!.day == today.day)
                  .length;

              return '$completedToday/${habits.length}';
            },
          ),
        ],
      ),
    );
  }
}
