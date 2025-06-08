import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/mood_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/features/tracker/presentation/modals.dart';
import 'package:spiceease/features/tracker/presentation/tracker_controller.dart';
import 'package:spiceease/features/tracker/presentation/widgets/icon_list_launcher.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class IconGrid extends ConsumerWidget {
  final Function(BuildContext, Widget) showModal;
  final DateTime selectedDate;
  final WidgetRef ref;

  const IconGrid({
    Key? key,
    required this.showModal,
    required this.selectedDate,
    required this.ref,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energy = ref.watch(energyStateNotifierProvider(selectedDate));
    final moods = ref.watch(moodStateNotifierProvider(selectedDate));
    final symptoms = ref.watch(symptomStateNotifierProvider(selectedDate));
    final tasks = ref.watch(taskStateNotifierProvider(selectedDate));
    final habits = ref.watch(habitStateNotifierProvider(selectedDate));
    final medication = ref.watch(medicationStateNotifierProvider(selectedDate));
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          IconListLauncher<EnergyModel>(
            title: localizations.energy,
            icon: Icon(Icons.bolt, color: theme.colorScheme.primary),
            items: energy,
            onAdd: () => showModal(context, EnergyLevelEditorModal(ref: ref)),
            onTap: (e) => showModal(
                context, EnergyLevelEditorModal(ref: ref, existing: e)),
            itemBuilder: (e) => '${e.energyLevel}',
            additionalTextBuilder: (e) =>
                '${localizations.additionalNotes}: ${e.notes}',
            onDelete: (e) =>
                ref.read(trackerControllerProvider).deleteEnergy(e.id, ref),
            onEdit: (e) => showModal(
                context, EnergyLevelEditorModal(ref: ref, existing: e)),
            statsLabelBuilder: () =>
                energy.isEmpty ? '—' : '${energy.last.energyLevel}/10',
          ),
          IconListLauncher<MoodModel>(
          title: localizations.mood,
          icon: Icon(FontAwesomeIcons.faceSmile,
              color: theme.colorScheme.primary),
          items: moods,
          onAdd: () => showModal(context, MoodLevelEditorModal(ref: ref)),
          // onAddEmpty: () => showModal(context, MoodLevelEditorModal(ref: ref)), // Consider if you need a specific onAddEmpty for mood
          onTap: (mood) => showModal(
              context, MoodLevelEditorModal(ref: ref, existing: mood)),
          itemBuilder: (e) => '${e.moodLevel}',
            additionalTextBuilder: (e) =>
                '${localizations.additionalNotes}: ${e.notes}',
            onDelete: (e) =>
                ref.read(trackerControllerProvider).deleteMood(e.id, ref),
            onEdit: (e) =>
                showModal(context, MoodLevelEditorModal(ref: ref, existing: e)),
            statsLabelBuilder: () =>
                moods.isEmpty ? '—' : '${moods.last.moodLevel}/10',
          ),
          IconListLauncher<MedicationModel>(
  title: localizations.medication,
  icon: Icon(Icons.medication, color: theme.colorScheme.primary),
  items: medication,
  onAdd: () => showModal(context, MedicationEditorModal(ref: ref)),
  onTap: (med) => showModal(
      context, MedicationEditorModal(ref: ref, existing: med)),
  itemBuilder: (m) => m.name,
  additionalTextBuilder: (m) =>
      '${localizations.dose}: ${m.dose} ${m.unit}',
  onDelete: (m) =>
      ref.read(trackerControllerProvider).deleteMedication(m.id),
  onEdit: (m) => showModal(
      context, MedicationEditorModal(ref: ref, existing: m)),
  statsLabelBuilder: () {
    if (medication.isEmpty) return '—';

    final today = DateTime.now();
    int takenCount = 0;

    for (final med in medication) {
      // Count how many times this medication was taken today
      final countToday = med.getTakenCountForDate(today);

      bool isCounted = false;
      if (med.timesPerDay == 1) {
        // For single-dose meds, count if taken at least once today
        isCounted = countToday > 0;
      } else {
        // For multi-dose meds, count if all doses are taken today
        isCounted = countToday >= med.timesPerDay;
      }

      if (isCounted) {
        takenCount++;
      }
    }

    return '$takenCount/${medication.length}';
  },
),
          IconListLauncher<SymptomModel>(
            title: localizations.symptoms,
            icon: Icon(Icons.healing, color: theme.colorScheme.primary),
            items: symptoms,
            onAdd: () => showModal(context, SymptomEditorModal(ref: ref)),
            onTap: (symptom) => showModal(
                context, SymptomEditorModal(ref: ref, existing: symptom)),
            itemBuilder: (s) => s.name,
            additionalTextBuilder: (s) =>
                '${localizations.category}: ${s.category}\n${localizations.severity}: ${s.severity}',
            onDelete: (s) =>
                ref.read(trackerControllerProvider).deleteSymptom(s.id, ref),
            onEdit: (s) =>
                showModal(context, SymptomEditorModal(ref: ref, existing: s)),
            statsLabelBuilder: () => '${symptoms.length}',
          ),
          IconListLauncher<TaskModel>(
            title: localizations.tasks,
            icon: Icon(Icons.task_alt, color: theme.colorScheme.primary),
            items: tasks,
            onAdd: () => showModal(context, TaskEditorModal(ref: ref)),
            onTap: (task) =>
                showModal(context, TaskEditorModal(ref: ref, existing: task)),
            itemBuilder: (t) => t.title,
            additionalTextBuilder: (t) =>
                '${t.dueDate != null ? "${localizations.due}: ${DateFormat('EEE, d MMMM', localizations.localeName).format(t.dueDate!.toLocal())}" : localizations.noDueDate} | ${localizations.status}: ${t.status}',
            onDelete: (s) =>
                ref.read(trackerControllerProvider).deleteTask(s.id),
            onEdit: (s) =>
                showModal(context, TaskEditorModal(ref: ref, existing: s)),
            statsLabelBuilder: () {
              if (tasks.isEmpty) return '—';
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
          IconListLauncher<HabitModel>(
            title: localizations.habits,
            icon: Icon(Icons.sync_rounded, color: theme.colorScheme.primary),
            items: habits,
            onAdd: () => showModal(context, HabitEditorModal(ref: ref)),
            onTap: (habit) =>
                showModal(context, HabitEditorModal(ref: ref, existing: habit)),
            itemBuilder: (h) => h.title,
            additionalTextBuilder: (h) {
              final dueDate = h.nextDueDate;
              final duePart = (dueDate == null)
                  ? '${localizations.noDueDate}'
                  : '${localizations.due}: ${DateFormat('EEE, d MMMM', localizations.localeName).format(dueDate.toLocal())}';
              return '$duePart | ${localizations.description}: ${h.description}';
            },
            onDelete: (s) =>
                ref.read(trackerControllerProvider).deleteHabit(s.id),
            onEdit: (s) =>
                showModal(context, HabitEditorModal(ref: ref, existing: s)),
            statsLabelBuilder: () {
              if (habits.isEmpty) return '—';
              final today = DateTime.now();
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
