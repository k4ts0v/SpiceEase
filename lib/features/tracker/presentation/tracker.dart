// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:spiceease/data/models/energy_model.dart';
// import 'package:spiceease/data/models/habit_model.dart';
// import 'package:spiceease/data/models/medication_model.dart';
// import 'package:spiceease/data/models/mood_model.dart';
// import 'package:spiceease/data/models/symptom_model.dart';
// import 'package:spiceease/data/models/task_model.dart';
// import 'package:spiceease/data/providers/energy_provider.dart';
// import 'package:spiceease/data/providers/habit_provider.dart';
// import 'package:spiceease/data/providers/medication_provider.dart';
// import 'package:spiceease/data/providers/mood_provider.dart';
// import 'package:spiceease/data/providers/selected_date_provider.dart';
// import 'package:spiceease/data/providers/symptom_provider.dart';
// import 'package:spiceease/data/providers/task_provider.dart';
// import 'package:spiceease/data/providers/viewmode_provider.dart';
// import 'package:spiceease/data/state_notifiers/habit_state_notifier.dart';
// import 'package:spiceease/data/state_notifiers/symptom_state_notifier.dart';
// import 'package:spiceease/data/state_notifiers/task_state_notifier.dart';
// import 'package:spiceease/features/tracker/presentation/calendar_widget.dart';
// import 'package:spiceease/features/tracker/presentation/entity_section.dart';
// import 'package:spiceease/features/tracker/presentation/kanban_widget.dart';
// import 'package:spiceease/features/tracker/presentation/modals.dart';
// import 'package:spiceease/features/tracker/presentation/tracker_controller.dart';

// const _backgroundGradient = LinearGradient(
//   begin: Alignment.topCenter,
//   end: Alignment.bottomCenter,
//   colors: [
//     Color(0xFFF8F9FA),
//     Colors.white,
//   ],
// );

// class TrackerScreen extends ConsumerWidget {
//   const TrackerScreen({Key? key}) : super(key: key);

//   void _showModal(BuildContext context, Widget modal) =>
//       showDialog(context: context, builder: (_) => modal);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedDate = ref.watch(selectedDateProvider);
//     final energy = ref.watch(energyStateNotifierProvider(selectedDate));
//     final moods = ref.watch(moodStateNotifierProvider(selectedDate));
//     final symptoms = ref.watch(symptomStateNotifierProvider(selectedDate));
//     final tasks = ref.watch(taskStateNotifierProvider(selectedDate));
//     final habits = ref.watch(habitStateNotifierProvider(selectedDate));
//     final medication = ref.watch(medicationStateNotifierProvider(selectedDate));
//     final symptomCtl =
//         ref.watch(symptomStateNotifierProvider(selectedDate).notifier);
//     final taskCtl = ref.watch(taskStateNotifierProvider(selectedDate).notifier);
//     final habitCtl =
//         ref.watch(habitStateNotifierProvider(selectedDate).notifier);

//     return Container(
//         decoration: const BoxDecoration(gradient: _backgroundGradient),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.settings_outlined),
//                       onPressed: () {}, // TODO: Add settings functionality
//                     ),
//                     const Text(
//                       'SpiceEase',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: -0.5,
//                       ),
//                     ),
//                     const SizedBox(width: 48), // Balance for settings button
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const CalendarWidget(),
//               const SizedBox(height: 12),

//               // Main Content
//               Expanded(
//                 child: _buildMainContent(
//                   context,
//                   ref,
//                   selectedDate,
//                   energy,
//                   moods,
//                   symptoms,
//                   tasks,
//                   habits,
//                   medication,
//                   symptomCtl,
//                   taskCtl,
//                   habitCtl,
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }

//   Widget _buildMainContent(
//     BuildContext context,
//     WidgetRef ref,
//     DateTime selectedDate,
//     List<EnergyModel> energy,
//     List<MoodModel> moods,
//     List<SymptomModel> symptoms,
//     List<TaskModel> tasks,
//     List<HabitModel> habits,
//     List<MedicationModel> medication,
//     SymptomStateNotifier symptomCtl,
//     TaskStateNotifier taskCtl,
//     HabitStateNotifier habitCtl,
//   ) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Icon Grid Container
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   spreadRadius: 0,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Wrap(
//                 spacing: 16, // Horizontal spacing between items
//                 runSpacing: 16, // Vertical spacing between rows
//                 alignment: WrapAlignment.start,
//                 children: [
//                   _iconListLauncher<EnergyModel>(
//                     context: context,
//                     title: 'Energy',
//                     icon: const Icon(Icons.bolt),
//                     items: energy,
//                     onAdd: () =>
//                         _showModal(context, EnergyLevelEditorModal(ref: ref)),
//                     onTap: (energy) => _showModal(context,
//                         EnergyLevelEditorModal(ref: ref, existing: energy)),
//                     itemBuilder: (e) => '${e.energyLevel}',
//                     additionalTextBuilder: (e) =>
//                         'Additional notes: ${e.notes}',
//                     onDelete: (e) => ref
//                         .read(trackerControllerProvider)
//                         .deleteEnergy(e.id, ref),
//                     onEdit: (e) => _showModal(
//                         context, EnergyLevelEditorModal(ref: ref, existing: e)),
//                   ),
//                   _iconListLauncher<MoodModel>(
//                     context: context,
//                     title: 'Mood',
//                     icon: const Icon(Icons.face),
//                     items: moods,
//                     onAdd: () =>
//                         _showModal(context, MoodLevelEditorModal(ref: ref)),
//                     onTap: (mood) => _showModal(context,
//                         MoodLevelEditorModal(ref: ref, existing: mood)),
//                     itemBuilder: (e) => '${e.moodLevel}',
//                     additionalTextBuilder: (e) =>
//                         'Additional notes: ${e.notes}',
//                     onDelete: (e) => ref
//                         .read(trackerControllerProvider)
//                         .deleteMood(e.id, ref),
//                     onEdit: (e) => _showModal(
//                         context, MoodLevelEditorModal(ref: ref, existing: e)),
//                   ),
//                   _iconListLauncher<MedicationModel>(
//                     context: context,
//                     title: 'Medication',
//                     icon: const Icon(Icons.medication),
//                     items: medication,
//                     onAdd: () =>
//                         _showModal(context, MedicationEditorModal(ref: ref)),
//                     onTap: (med) => _showModal(context,
//                         MedicationEditorModal(ref: ref, existing: med)),
//                     itemBuilder: (m) => m.name,
//                     additionalTextBuilder: (m) => 'Dose: ${m.dose} ${m.unit}',
//                     onDelete: (m) => ref
//                         .read(trackerControllerProvider)
//                         .deleteMedication(m.id, ref),
//                     onEdit: (m) => _showModal(
//                         context, MedicationEditorModal(ref: ref, existing: m)),
//                   ),
//                   _iconListLauncher<SymptomModel>(
//                     context: context,
//                     title: 'Symptoms',
//                     icon: const Icon(Icons.healing),
//                     items: symptoms,
//                     onAdd: () =>
//                         _showModal(context, SymptomEditorModal(ref: ref)),
//                     onTap: (symptom) => _showModal(context,
//                         SymptomEditorModal(ref: ref, existing: symptom)),
//                     itemBuilder: (s) => s.name,
//                     additionalTextBuilder: (s) =>
//                         'Category: ${s.category}\nSeverity: ${s.severity}',
//                     onDelete: (s) => ref
//                         .read(trackerControllerProvider)
//                         .deleteSymptom(s.id, ref),
//                     onEdit: (s) => _showModal(
//                         context, SymptomEditorModal(ref: ref, existing: s)),
//                   ),
//                   _iconListLauncher<TaskModel>(
//                     context: context,
//                     title: 'Tasks',
//                     icon: const Icon(Icons.task_alt),
//                     items: tasks,
//                     onAdd: () => _showModal(context, TaskEditorModal(ref: ref)),
//                     onTap: (task) => _showModal(
//                         context, TaskEditorModal(ref: ref, existing: task)),
//                     itemBuilder: (t) => t.title,
//                     additionalTextBuilder: (t) =>
//                         '${t.dueDate != null ? "Due: ${DateFormat('EEE, d MMMM').format(t.dueDate!.toLocal())}" : "No due date"} | Status: ${t.status}',
//                     onDelete: (s) =>
//                         ref.read(trackerControllerProvider).deleteTask(s.id),
//                     onEdit: (s) => _showModal(
//                         context, TaskEditorModal(ref: ref, existing: s)),
//                   ),
//                   _iconListLauncher<HabitModel>(
//                     context: context,
//                     title: 'Habits',
//                     icon: const Icon(Icons.sync_rounded),
//                     items: habits,
//                     onAdd: () =>
//                         _showModal(context, HabitEditorModal(ref: ref)),
//                     onTap: (habit) => _showModal(
//                         context, HabitEditorModal(ref: ref, existing: habit)),
//                     itemBuilder: (h) => h.title,
//                     additionalTextBuilder: (h) =>
//                         'Due: ${DateFormat('EEE, d MMMM').format(h.nextDueDate!.toLocal())} | Description: ${h.description}',
//                     onDelete: (s) =>
//                         ref.read(trackerControllerProvider).deleteHabit(s.id),
//                     onEdit: (s) => _showModal(
//                         context, HabitEditorModal(ref: ref, existing: s)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           const SizedBox(height: 20),
//           EntitySection<SymptomModel>(
//             title: 'Symptoms',
//             items: symptoms,
//             isLoading: symptomCtl.isLoading,
//             error: symptomCtl.error,
//             onTap: (symptom) => _showModal(
//                 context, SymptomEditorModal(ref: ref, existing: symptom)),
//             onAdd: () => _showModal(context, SymptomEditorModal(ref: ref)),
//             itemBuilder: (s) => ListTile(
//               leading: Icon(Icons.circle,
//                   color: _severityColor(s.severity), size: 14),
//               title: Text(s.name),
//             ),
//           ),
//           const SizedBox(height: 20),
//           EntitySection<TaskModel>(
//             title: 'Tasks',
//             items: tasks,
//             isLoading: taskCtl.isLoading,
//             error: taskCtl.error,
//             onTap: (task) =>
//                 _showModal(context, TaskEditorModal(ref: ref, existing: task)),
//             onAdd: () => _showModal(context, TaskEditorModal(ref: ref)),
//             itemBuilder: (task) {
//               final today = DateTime.now();
//               final isCompleted = task.completedAt != null &&
//                   task.completedAt!.year == today.year &&
//                   task.completedAt!.month == today.month &&
//                   task.completedAt!.day == today.day;

//               return ListTile(
//                 leading: const Icon(Icons.task_alt),
//                 title: Text(
//                   task.title,
//                   style: TextStyle(
//                     decoration: isCompleted ? TextDecoration.lineThrough : null,
//                     color: isCompleted ? Colors.grey : Colors.black,
//                   ),
//                 ),
//                 subtitle: Text(
//                   task.dueDate != null
//                       ? 'Due: ${DateFormat('EEE, d MMMM').format(task.dueDate!.toLocal())}'
//                       : 'No due date',
//                   style: TextStyle(
//                     color: isCompleted ? Colors.grey : Colors.black,
//                   ),
//                 ),
//                 trailing: Checkbox(
//                   value: isCompleted,
//                   onChanged: (value) async {
//                     final newStatus = value == true ? 'Done' : 'Pending';
//                     final newCompletedAt =
//                         value == true ? DateTime.now() : null;

//                     await ref.read(trackerControllerProvider).updateTask(
//                           task.id,
//                           task.title,
//                           task.description,
//                           newStatus, // Update the status
//                           task.dueDate,
//                           newCompletedAt, // Update completedAt
//                           task.estimatedTime,
//                           task.priority,
//                         );
//                   },
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 40),
//           EntitySection<HabitModel>(
//             title: 'Habits',
//             items: habits,
//             isLoading: habitCtl.isLoading,
//             error: habitCtl.error,
//             onTap: (habit) => _showModal(
//                 context, HabitEditorModal(ref: ref, existing: habit)),
//             onAdd: () => _showModal(context, HabitEditorModal(ref: ref)),
//             itemBuilder: (habit) {
//               final today = DateTime.now();
//               final isCompleted = habit.lastCompleted != null &&
//                   habit.lastCompleted!.year == today.year &&
//                   habit.lastCompleted!.month == today.month &&
//                   habit.lastCompleted!.day == today.day;

//               return ListTile(
//                 leading: const Icon(Icons.sync_rounded),
//                 title: Text(
//                   habit.title,
//                   style: TextStyle(
//                     decoration: isCompleted ? TextDecoration.lineThrough : null,
//                     color: isCompleted ? Colors.grey : Colors.black,
//                   ),
//                 ),
//                 subtitle: Text(
//                   habit.description.isNotEmpty
//                       ? habit.description
//                       : 'No description',
//                   style: TextStyle(
//                     color: isCompleted ? Colors.grey : Colors.black,
//                   ),
//                 ),
//                 trailing: Checkbox(
//                   value: isCompleted,
//                   onChanged: (value) async {
//                     if (value == true) {
//                       await ref.read(trackerControllerProvider).updateHabit(
//                             habit.id,
//                             habit.title,
//                             habit.description,
//                             habit.frequency,
//                             habit.customDays,
//                             markAsCompleted: true,
//                           );
//                     }
//                   },
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }

//   Color _severityColor(int s) {
//     if (s <= 3) return const Color.fromARGB(255, 213, 255, 59);
//     if (s <= 6) return const Color.fromARGB(255, 255, 193, 59);
//     if (s <= 8) return Colors.orange;
//     return Colors.red;
//   }

//   Widget _iconListLauncher<T>({
//     required BuildContext context,
//     required String title,
//     required List<T> items,
//     required VoidCallback onAdd,
//     required String Function(T) itemBuilder,
//     required String Function(T)? additionalTextBuilder,
//     required void Function(T) onDelete,
//     required void Function(T) onEdit,
//     required Icon icon,
//     required void Function(T) onTap,
//   }) {
//     // Generate statistics label based on type
//     String getStatsLabel() {
//       if (items.isEmpty) return '—';

//       if (T == EnergyModel) {
//         final lastEnergy = (items as List<EnergyModel>).last;
//         return '${lastEnergy.energyLevel}/10';
//       }

//       if (T == MoodModel) {
//         final lastMood = (items as List<MoodModel>).last;
//         return '${lastMood.moodLevel}/10';
//       }

//       if (T == MedicationModel) {
//         final meds = items as List<MedicationModel>;
//         final takenToday = meds.where((m) {
//           final today = DateTime.now();
//           return m.lastTaken != null &&
//               m.lastTaken!.year == today.year &&
//               m.lastTaken!.month == today.month &&
//               m.lastTaken!.day == today.day;
//         }).length;
//         return '$takenToday/${meds.length}';
//       }

//       if (T == TaskModel) {
//         final tasks = items as List<TaskModel>;
//         final completedToday = tasks.where((t) {
//           final today = DateTime.now();
//           return t.completedAt != null &&
//               t.completedAt!.year == today.year &&
//               t.completedAt!.month == today.month &&
//               t.completedAt!.day == today.day;
//         }).length;
//         return '$completedToday/${tasks.length}';
//       }

//       if (T == HabitModel) {
//         final habits = items as List<HabitModel>;
//         final completedToday = habits.where((h) {
//           final today = DateTime.now();
//           return h.lastCompleted != null &&
//               h.lastCompleted!.year == today.year &&
//               h.lastCompleted!.month == today.month &&
//               h.lastCompleted!.day == today.day;
//         }).length;
//         return '$completedToday/${habits.length}';
//       }

//       if (T == SymptomModel) {
//         return '${items.length}';
//       }

//       return '';
//     }

//     return Container(
//       width: 100,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.grey.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: IconButton(
//               icon: icon,
//               style: IconButton.styleFrom(
//                 padding: const EdgeInsets.all(12),
//               ),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (_) => ListModal<T>(
//                     title: title,
//                     additionalText: '',
//                     items: items,
//                     onAdd: () {
//                       Navigator.of(context).pop();
//                       onAdd();
//                     },
//                     itemBuilder: (ctx, item) => _buildListItem(
//                       item,
//                       itemBuilder,
//                       additionalTextBuilder,
//                       onDelete,
//                       onEdit,
//                       ctx,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               getStatsLabel(),
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildListItem<T>(
//     T item,
//     String Function(T) itemBuilder,
//     String Function(T)? additionalTextBuilder,
//     void Function(T) onDelete,
//     void Function(T) onEdit,
//     BuildContext context,
//   ) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       child: ListTile(
//         title: Text(
//           itemBuilder(item),
//           style: const TextStyle(fontWeight: FontWeight.w500),
//         ),
//         subtitle: additionalTextBuilder != null
//             ? Text(
//                 additionalTextBuilder(item),
//                 style: const TextStyle(fontSize: 12),
//               )
//             : null,
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit_outlined),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 onEdit(item);
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete_outline, color: Colors.red),
//               onPressed: () => showDialog(
//                 context: context,
//                 builder: (_) => ConfirmDeleteModal(
//                   label: itemBuilder(item),
//                   onConfirm: () {
//                     onDelete(item);
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
