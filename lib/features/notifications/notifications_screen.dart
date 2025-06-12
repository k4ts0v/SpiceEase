// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:spiceease/data/providers/notification_settings_provider.dart';
// import '../../../l10n/app_localizations.dart';

// class NotificationSettingsScreen extends ConsumerWidget {
//   const NotificationSettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final settings = ref.watch(notificationSettingsProvider);
//     final notifier = ref.read(notificationSettingsProvider.notifier);
//     final theme = Theme.of(context);
//     final localizations = AppLocalizations.of(context)!;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           localizations.notificationSettings,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.5,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//         elevation: 0,
//         backgroundColor: theme.colorScheme.surface,
//         foregroundColor: theme.colorScheme.onSurface,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _buildGeneralSection(
//               context, settings, notifier, theme, localizations),
//           const SizedBox(height: 24),
//           _buildContextAwarenessSection(
//               context, settings, notifier, theme, localizations),
//           const SizedBox(height: 24),
//           _buildQuietHoursSection(
//               context, settings, notifier, theme, localizations),
//           const SizedBox(height: 24),
//           _buildNotificationCategoriesSection(
//               context, settings, notifier, theme, localizations),
//           const SizedBox(height: 24),
//           _buildRemindersSection(
//               context, settings, notifier, theme, localizations),
//         ],
//       ),
//     );
//   }

//   Widget _buildGeneralSection(
//     BuildContext context,
//     NotificationSettings settings,
//     NotificationSettingsNotifier notifier,
//     ThemeData theme,
//     AppLocalizations localizations,
//   ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               localizations.generalSettings,
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             SwitchListTile(
//               title: Text(localizations.enableNotifications),
//               value: settings.notificationsEnabled,
//               onChanged: (value) {
//                 notifier.updateSettings(
//                     settings.copyWith(notificationsEnabled: value));
//               },
//               contentPadding: EdgeInsets.zero,
//             ),
//             SwitchListTile(
//               title: Text(localizations.sound),
//               value: settings.soundEnabled,
//               onChanged: settings.notificationsEnabled
//                   ? (value) {
//                       notifier.updateSettings(
//                           settings.copyWith(soundEnabled: value));
//                     }
//                   : null,
//               contentPadding: EdgeInsets.zero,
//             ),
//             SwitchListTile(
//               title: Text(localizations.vibration),
//               value: settings.vibrationEnabled,
//               onChanged: settings.notificationsEnabled
//                   ? (value) {
//                       notifier.updateSettings(
//                           settings.copyWith(vibrationEnabled: value));
//                     }
//                   : null,
//               contentPadding: EdgeInsets.zero,
//             ),
//             const SizedBox(height: 8),
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               title: Text(localizations.historyRetention),
//               subtitle: Text(
//                 localizations
//                     .daysOfHistory(settings.historyRetentionDays.toString()),
//               ),
//               trailing: DropdownButton<int>(
//                 value: settings.historyRetentionDays,
//                 items: [1, 3, 7, 14, 30].map((days) {
//                   return DropdownMenuItem<int>(
//                     value: days,
//                     child: Text(days.toString()),
//                   );
//                 }).toList(),
//                 onChanged: settings.notificationsEnabled
//                     ? (value) {
//                         if (value != null) {
//                           notifier.updateSettings(
//                               settings.copyWith(historyRetentionDays: value));
//                         }
//                       }
//                     : null,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContextAwarenessSection(
//     BuildContext context,
//     NotificationSettings settings,
//     NotificationSettingsNotifier notifier,
//     ThemeData theme,
//     AppLocalizations localizations,
//   ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               localizations.contextAwareness,
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             SwitchListTile(
//               title: Text(localizations.alwaysShowCritical),
//               subtitle: Text(localizations.alwaysShowCriticalDescription),
//               value: settings.alwaysShowCritical,
//               onChanged: settings.notificationsEnabled
//                   ? (value) {
//                       notifier.updateSettings(
//                           settings.copyWith(alwaysShowCritical: value));
//                     }
//                   : null,
//               contentPadding: EdgeInsets.zero,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               localizations.lowEnergyThreshold,
//               style: theme.textTheme.titleSmall,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               localizations.lowEnergyDescription,
//               style: theme.textTheme.bodySmall,
//             ),
//             Slider(
//               value: settings.lowEnergyThreshold.toDouble(),
//               min: 1,
//               max: 10,
//               divisions: 9,
//               label: settings.lowEnergyThreshold.toString(),
//               onChanged: settings.notificationsEnabled
//                   ? (value) {
//                       notifier.updateSettings(
//                           settings.copyWith(lowEnergyThreshold: value.toInt()));
//                     }
//                   : null,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               localizations.highSymptomThreshold,
//               style: theme.textTheme.titleSmall,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               localizations.highSymptomDescription,
//               style: theme.textTheme.bodySmall,
//             ),
//             Slider(
//               value: settings.highSymptomThreshold.toDouble(),
//               min: 1,
//               max: 10,
//               divisions: 9,
//               label: settings.highSymptomThreshold.toString(),
//               onChanged: settings.notificationsEnabled
//                   ? (value) {
//                       notifier.updateSettings(settings.copyWith(
//                           highSymptomThreshold: value.toInt()));
//                     }
//                   : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuietHoursSection(
//     BuildContext context,
//     NotificationSettings settings,
//     NotificationSettingsNotifier notifier,
//     ThemeData theme,
//     AppLocalizations localizations,
//   ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               localizations.quietHours,
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             SwitchListTile(
//               title: Text(localizations.enableQuietHours),
//               value: settings.quietHoursEnabled,
//               onChanged: settings.notificationsEnabled
//                   ? (value) {
//                       notifier.updateSettings(
//                           settings.copyWith(quietHoursEnabled: value));
//                     }
//                   : null,
//               contentPadding: EdgeInsets.zero,
//             ),
//             if (settings.quietHoursEnabled && settings.notificationsEnabled)
//               Column(
//                 children: [
//                   ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     title: Text(localizations.quietHoursStart),
//                     trailing: TextButton(
//                       child: Text(
//                         '${settings.quietHoursStart.hour}:${settings.quietHoursStart.minute.toString().padLeft(2, '0')}',
//                         style: theme.textTheme.titleMedium,
//                       ),
//                       onPressed: () async {
//                         final time = await showTimePicker(
//                           context: context,
//                           initialTime: settings.quietHoursStart,
//                         );
//                         if (time != null) {
//                           notifier.updateSettings(
//                               settings.copyWith(quietHoursStart: time));
//                         }
//                       },
//                     ),
//                   ),
//                   ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     title: Text(localizations.quietHoursEnd),
//                     trailing: TextButton(
//                       child: Text(
//                         '${settings.quietHoursEnd.hour}:${settings.quietHoursEnd.minute.toString().padLeft(2, '0')}',
//                         style: theme.textTheme.titleMedium,
//                       ),
//                       onPressed: () async {
//                         final time = await showTimePicker(
//                           context: context,
//                           initialTime: settings.quietHoursEnd,
//                         );
//                         if (time != null) {
//                           notifier.updateSettings(
//                               settings.copyWith(quietHoursEnd: time));
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRemindersSection(
//     BuildContext context,
//     NotificationSettings settings,
//     NotificationSettingsNotifier notifier,
//     ThemeData theme,
//     AppLocalizations localizations,
//   ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               localizations.reminders,
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Master switch for logging reminders
//             SwitchListTile(
//               title: Text(localizations.loggingReminders),
//               subtitle: Text(localizations.loggingRemindersDescription),
//               value: settings.loggingRemindersEnabled,
//               onChanged: settings.notificationsEnabled
//                   ? (value) {
//                       notifier.updateSettings(
//                         settings.copyWith(loggingRemindersEnabled: value),
//                       );
//                     }
//                   : null,
//               contentPadding: EdgeInsets.zero,
//             ),

//             // Category reminders section (only shown if logging reminders are enabled)
//             if (settings.loggingRemindersEnabled &&
//                 settings.notificationsEnabled)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 16),
//                   Text(
//                     localizations.categoryReminders,
//                     style: theme.textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     localizations.categoryRemindersDescription,
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ..._buildCategoryReminderList(
//                       context, settings, notifier, theme, localizations),
//                 ],
//               ),

//             const SizedBox(height: 16),

//             // Specific item reminders section
//             SwitchListTile(
//               title: Text(localizations.specificItemReminders),
//               subtitle: Text(localizations.specificItemRemindersDescription),
//               value: settings.specificItemRemindersEnabled,
//               onChanged: settings.notificationsEnabled
//                   ? (value) {
//                       notifier.updateSettings(
//                         settings.copyWith(specificItemRemindersEnabled: value),
//                       );
//                     }
//                   : null,
//               contentPadding: EdgeInsets.zero,
//             ),

//             // Specific reminder categories (only shown if specific reminders are enabled)
//             if (settings.specificItemRemindersEnabled &&
//                 settings.notificationsEnabled)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 8),
//                   Text(
//                     localizations.enableSpecificRemindersFor,
//                     style: theme.textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ..._buildSpecificReminderToggles(
//                       context, settings, notifier, theme, localizations),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationCategoriesSection(
//   BuildContext context,
//   NotificationSettings settings,
//   NotificationSettingsNotifier notifier,
//   ThemeData theme,
//   AppLocalizations localizations,
// ) {
//   final categories = {
//     'appointment': localizations.appointments,
//     'system': localizations.system,
//   };

//   return Card(
//     elevation: 2,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     child: Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             localizations.notificationCategories,
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             localizations.notificationCategoriesDescription,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.colorScheme.onSurface.withOpacity(0.7),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...categories.entries.map((entry) {
//             final isEnabled = settings.enabledCategories.contains(entry.key);

//             return CheckboxListTile(
//               title: Text(entry.value),
//               value: isEnabled,
//               onChanged: settings.notificationsEnabled
//                   ? (value) {
//                       final newCategories = Set<String>.from(settings.enabledCategories);
//                       if (value!) {
//                         newCategories.add(entry.key);
//                       } else {
//                         newCategories.remove(entry.key);
//                       }
//                       notifier.updateSettings(settings.copyWith(enabledCategories: newCategories));
//                     }
//                   : null,
//               contentPadding: EdgeInsets.zero,
//             );
//           }),
//         ],
//       ),
//     ),
//   );
// }

//   List<Widget> _buildCategoryReminderList(
//     BuildContext context,
//     NotificationSettings settings,
//     NotificationSettingsNotifier notifier,
//     ThemeData theme,
//     AppLocalizations localizations,
//   ) {
//     final categories = {
//       'task': localizations.tasks,
//       'habit': localizations.habits,
//       'medication': localizations.medication,
//       'symptom': localizations.symptoms,
//       'energy': localizations.energy,
//     };

//     return categories.entries
//         .where((entry) => settings.enabledCategories.contains(entry.key))
//         .map((entry) {
//       return Column(
//         children: [
//           _buildCategoryReminderSettings(
//             context,
//             entry.key,
//             entry.value,
//             settings,
//             notifier,
//             theme,
//             localizations,
//           ),
//           const SizedBox(height: 16),
//         ],
//       );
//     }).toList();
//   }

//   List<Widget> _buildSpecificReminderToggles(
//     BuildContext context,
//     NotificationSettings settings,
//     NotificationSettingsNotifier notifier,
//     ThemeData theme,
//     AppLocalizations localizations,
//   ) {
//     final specificCategories = {
//       'task': localizations.tasks,
//       'habit': localizations.habits,
//       'medication': localizations.medication,
//     };

//     return specificCategories.entries.map((entry) {
//       final isEnabled =
//           settings.enabledCategorySpecificReminders[entry.key] ?? true;

//       return CheckboxListTile(
//         title: Text(entry.value),
//         subtitle:
//             Text(_getSpecificReminderDescription(entry.key, localizations)),
//         value: isEnabled,
//         onChanged: (value) {
//           final newSpecificReminders =
//               Map<String, bool>.from(settings.enabledCategorySpecificReminders);
//           newSpecificReminders[entry.key] = value!;
//           notifier.updateSettings(settings.copyWith(
//               enabledCategorySpecificReminders: newSpecificReminders));
//         },
//         contentPadding: EdgeInsets.zero,
//       );
//     }).toList();
//   }

//   String _getSpecificReminderDescription(
//       String category, AppLocalizations localizations) {
//     switch (category) {
//       case 'task':
//         return localizations.taskSpecificRemindersDescription ??
//             'Set reminders for individual tasks';
//       case 'habit':
//         return localizations.habitSpecificRemindersDescription ??
//             'Set reminders for individual habits';
//       case 'medication':
//         return localizations.medicationSpecificRemindersDescription ??
//             'Set reminders for individual medications';
//       default:
//         return localizations.specificRemindersDescription ??
//             'Set individual reminders';
//     }
//   }

//   Widget _buildCategoryReminderSettings(
//     BuildContext context,
//     String categoryKey,
//     String categoryName,
//     NotificationSettings settings,
//     NotificationSettingsNotifier notifier,
//     ThemeData theme,
//     AppLocalizations localizations,
//   ) {
//     final reminderTime = settings.categoryReminderTimes[categoryKey] ??
//         const TimeOfDay(hour: 9, minute: 0);
//     final reminderDays =
//         settings.categoryReminderDays[categoryKey] ?? [1, 2, 3, 4, 5];

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             localizations.reminderSettings,
//             style: theme.textTheme.titleSmall?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),

//           // Reminder time setting
//           ListTile(
//             contentPadding: EdgeInsets.zero,
//             title: Text(localizations.reminderTime),
//             subtitle: Text(
//                 _getCategoryReminderDescription(categoryKey, localizations)),
//             trailing: TextButton(
//               child: Text(
//                 '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}',
//                 style: theme.textTheme.titleMedium,
//               ),
//               onPressed: () async {
//                 final time = await showTimePicker(
//                   context: context,
//                   initialTime: reminderTime,
//                 );
//                 if (time != null) {
//                   final newTimes = Map<String, TimeOfDay>.from(
//                       settings.categoryReminderTimes);
//                   newTimes[categoryKey] = time;
//                   notifier.updateSettings(
//                       settings.copyWith(categoryReminderTimes: newTimes));
//                 }
//               },
//             ),
//           ),

//           const SizedBox(height: 8),

//           // Days of week selection
//           Text(
//             localizations.reminderDays,
//             style: theme.textTheme.titleSmall,
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 4,
//             children: List.generate(7, (index) {
//               final dayNumber = index + 1;
//               final isSelected = reminderDays.contains(dayNumber);
//               final dayName = _getDayName(dayNumber, localizations);

//               return FilterChip(
//                 label: Text(dayName),
//                 selected: isSelected,
//                 onSelected: (selected) {
//                   final newDays = List<int>.from(reminderDays);
//                   if (selected) {
//                     newDays.add(dayNumber);
//                   } else {
//                     newDays.remove(dayNumber);
//                   }
//                   newDays.sort();

//                   final newReminderDays = Map<String, List<int>>.from(
//                       settings.categoryReminderDays);
//                   newReminderDays[categoryKey] = newDays;
//                   notifier.updateSettings(
//                       settings.copyWith(categoryReminderDays: newReminderDays));
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getCategoryReminderDescription(
//       String category, AppLocalizations localizations) {
//     switch (category) {
//       case 'task':
//         return localizations.taskReminderDescription ??
//             'Daily reminder to review pending tasks';
//       case 'habit':
//         return localizations.habitReminderDescription ??
//             'Daily reminder to check habit progress';
//       case 'medication':
//         return localizations.medicationReminderDescription ??
//             'Daily reminder to take medications';
//       case 'symptom':
//         return localizations.symptomReminderDescription ??
//             'Daily reminder to log symptoms';
//       case 'energy':
//         return localizations.energyReminderDescription ??
//             'Daily reminder to log energy levels';
//       default:
//         return localizations.dailyReminder ?? 'Daily reminder';
//     }
//   }

//   String _getDayName(int dayNumber, AppLocalizations localizations) {
//     switch (dayNumber) {
//       case 1:
//         return localizations.monday ?? 'Mon';
//       case 2:
//         return localizations.tuesday ?? 'Tue';
//       case 3:
//         return localizations.wednesday ?? 'Wed';
//       case 4:
//         return localizations.thursday ?? 'Thu';
//       case 5:
//         return localizations.friday ?? 'Fri';
//       case 6:
//         return localizations.saturday ?? 'Sat';
//       case 7:
//         return localizations.sunday ?? 'Sun';
//       default:
//         return 'Day';
//     }
//   }
// }
