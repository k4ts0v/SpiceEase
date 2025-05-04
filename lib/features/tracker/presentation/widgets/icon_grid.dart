import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            title: 'Energy',
            icon: const Icon(Icons.bolt),
            items: energy,
            onAdd: () => showModal(context, EnergyLevelEditorModal(ref: ref)),
            onTap: (e) => showModal(
                context, EnergyLevelEditorModal(ref: ref, existing: e)),
            itemBuilder: (e) => '${e.energyLevel}',
            additionalTextBuilder: (e) => 'Additional notes: ${e.notes}',
            onDelete: (e) =>
                ref.read(trackerControllerProvider).deleteEnergy(e.id, ref),
            onEdit: (e) => showModal(
                context, EnergyLevelEditorModal(ref: ref, existing: e)),
            statsLabelBuilder: () =>
                energy.isEmpty ? '—' : '${energy.last.energyLevel}/10',
          ),
          IconListLauncher<MoodModel>(
            title: 'Mood',
            icon: const Icon(Icons.face),
            items: moods,
            onAdd: () => showModal(context, MoodLevelEditorModal(ref: ref)),
            onTap: (mood) => showModal(
                context, MoodLevelEditorModal(ref: ref, existing: mood)),
            itemBuilder: (e) => '${e.moodLevel}',
            additionalTextBuilder: (e) => 'Additional notes: ${e.notes}',
            onDelete: (e) =>
                ref.read(trackerControllerProvider).deleteMood(e.id, ref),
            onEdit: (e) =>
                showModal(context, MoodLevelEditorModal(ref: ref, existing: e)),
            statsLabelBuilder: () =>
                moods.isEmpty ? '—' : '${moods.last.moodLevel}/10',
          ),
          IconListLauncher<MedicationModel>(
            title: 'Medication',
            icon: const Icon(Icons.medication),
            items: medication,
            onAdd: () => showModal(context, MedicationEditorModal(ref: ref)),
            onTap: (med) => showModal(
                context, MedicationEditorModal(ref: ref, existing: med)),
            itemBuilder: (m) => m.name,
            additionalTextBuilder: (m) => 'Dose: ${m.dose} ${m.unit}',
            onDelete: (m) =>
                ref.read(trackerControllerProvider).deleteMedication(m.id, ref),
            onEdit: (m) => showModal(
                context, MedicationEditorModal(ref: ref, existing: m)),
            statsLabelBuilder: () {
              if (medication.isEmpty) return '—';
              final takenToday = medication.where((m) {
                final today = DateTime.now();
                return m.lastTaken != null &&
                    m.lastTaken!.year == today.year &&
                    m.lastTaken!.month == today.month &&
                    m.lastTaken!.day == today.day;
              }).length;
              return '$takenToday/${medication.length}';
            },
          ),
          IconListLauncher<SymptomModel>(
            title: 'Symptoms',
            icon: const Icon(Icons.healing),
            items: symptoms,
            onAdd: () => showModal(context, SymptomEditorModal(ref: ref)),
            onTap: (symptom) => showModal(
                context, SymptomEditorModal(ref: ref, existing: symptom)),
            itemBuilder: (s) => s.name,
            additionalTextBuilder: (s) =>
                'Category: ${s.category}\nSeverity: ${s.severity}',
            onDelete: (s) =>
                ref.read(trackerControllerProvider).deleteSymptom(s.id, ref),
            onEdit: (s) =>
                showModal(context, SymptomEditorModal(ref: ref, existing: s)),
            statsLabelBuilder: () => '${symptoms.length}',
          ),
          IconListLauncher<TaskModel>(
            title: 'Tasks',
            icon: const Icon(Icons.task_alt),
            items: tasks,
            onAdd: () => showModal(context, TaskEditorModal(ref: ref)),
            onTap: (task) =>
                showModal(context, TaskEditorModal(ref: ref, existing: task)),
            itemBuilder: (t) => t.title,
            additionalTextBuilder: (t) =>
                '${t.dueDate != null ? "Due: ${DateFormat('EEE, d MMMM').format(t.dueDate!.toLocal())}" : "No due date"} | Status: ${t.status}',
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
            title: 'Habits',
            icon: const Icon(Icons.sync_rounded),
            items: habits,
            onAdd: () => showModal(context, HabitEditorModal(ref: ref)),
            onTap: (habit) =>
                showModal(context, HabitEditorModal(ref: ref, existing: habit)),
            itemBuilder: (h) => h.title,
            additionalTextBuilder: (h) =>
                'Due: ${DateFormat('EEE, d MMMM').format(h.nextDueDate!.toLocal())} | Description: ${h.description}',
            onDelete: (s) =>
                ref.read(trackerControllerProvider).deleteHabit(s.id),
            onEdit: (s) =>
                showModal(context, HabitEditorModal(ref: ref, existing: s)),
            statsLabelBuilder: () {
              if (habits.isEmpty) return '—';
              final completedToday = habits.where((h) {
                final today = DateTime.now();
                return h.lastCompleted != null &&
                    h.lastCompleted!.year == today.year &&
                    h.lastCompleted!.month == today.month &&
                    h.lastCompleted!.day == today.day;
              }).length;
              return '$completedToday/${habits.length}';
            },
          ),
        ],
      ),
    );
  }
}
