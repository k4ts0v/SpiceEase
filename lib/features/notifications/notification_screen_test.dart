// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:spiceease/data/models/notification_model.dart';
// import 'package:spiceease/data/services/notification_service.dart';
// import 'package:spiceease/data/providers/energy_provider.dart';
// import 'package:spiceease/data/providers/symptom_provider.dart';
// import 'package:spiceease/l10n/app_localizations.dart';

// import 'notification_test.dart';

// final notificationTesterProvider = Provider<NotificationTester>((ref) {
//   final notificationService = ref.watch(notificationServiceProvider);
//   return NotificationTester(notificationService);
// });

// class NotificationTestScreen extends ConsumerWidget {
//   const NotificationTestScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     final localizations = AppLocalizations.of(context)!;
//     final tester = ref.watch(notificationTesterProvider);

//     // Get actual context data
//     final today = DateTime.now();
//     final todayDate = DateTime(today.year, today.month, today.day);

//     // Get current energy level from today's data - fix property access
//     final energyData = ref.watch(energyStateNotifierProvider(todayDate));
//     final currentEnergy = energyData.isNotEmpty
//         ? energyData.last.energyLevel
//         : 5; // Changed from energyLevel to level

//     // Get current symptom impact - fix property access
//     final symptoms = ref.watch(symptomStateNotifierProvider(todayDate));
//     final maxSymptomSeverity = symptoms.isNotEmpty
//         ? symptoms
//             .map((s) => s.severity.clamp(1, 10)) // Changed from 5 to 10
//             .reduce((a, b) => a > b ? a : b)
//         : 0;
//     final totalSymptoms = symptoms.length;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Test Notifications",
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
//           _buildCurrentContextCard(
//               theme, currentEnergy, maxSymptomSeverity, totalSymptoms),
//           const SizedBox(height: 16),
//           _buildContextTestButton(context, ref, theme),
//           const SizedBox(height: 16),
//           _buildBasicTestsCard(context, tester, theme),
//           const SizedBox(height: 16),
//           _buildScheduledTestsCard(context, tester, theme),
//           const SizedBox(height: 16),
//           _buildContextAwareTestsCard(
//               context, tester, theme, currentEnergy, maxSymptomSeverity),
//         ],
//       ),
//     );
//   }

//   Widget _buildCurrentContextCard(
//       ThemeData theme, int energy, int maxSymptoms, int totalSymptoms) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Current Context',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Column(
//                   children: [
//                     Text(
//                       'Energy Level',
//                       style: theme.textTheme.bodySmall,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '$energy / 10',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         color: _getEnergyColor(energy, theme),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text(
//                       'Max Symptom',
//                       style: theme.textTheme.bodySmall,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '$maxSymptoms / 10', // Fixed to show /10
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         color: _getSymptomColor(maxSymptoms, theme),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text(
//                       'Total Symptoms',
//                       style: theme.textTheme.bodySmall,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '$totalSymptoms',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         color: _getSymptomCountColor(totalSymptoms, theme),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContextTestButton(
//       BuildContext context, WidgetRef ref, ThemeData theme) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Context Evaluation Test',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Test the current context rules and see what notifications would be blocked',
//               style: theme.textTheme.bodySmall,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.analytics),
//               label: const Text('Run Context Evaluation Test'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () async {
//                 final service = ref.read(notificationServiceProvider);
//                 await service.testContextEvaluation();
//                 _showSuccessSnackbar(context,
//                     'Context evaluation test completed - check console logs');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBasicTestsCard(
//       BuildContext context, NotificationTester tester, ThemeData theme) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Basic Tests (No Context Rules)',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.notifications_active),
//               label: const Text('Test All Priority Levels'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () async {
//                 await tester.testAllPriorities();
//                 _showSuccessSnackbar(context,
//                     'Four notifications sent with different priorities');
//               },
//             ),
//             const SizedBox(height: 12),
//             _buildPriorityButtons(tester, theme, context),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.push_pin),
//               label: const Text('Test Persistent Notification'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () async {
//                 await tester
//                     .testPersistentNotification(NotificationPriority.high);
//                 _showSuccessSnackbar(context, 'Persistent notification sent');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPriorityButtons(
//       NotificationTester tester, ThemeData theme, BuildContext context) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       alignment: WrapAlignment.center,
//       children: [
//         OutlinedButton(
//           child: const Text('Low Priority'),
//           onPressed: () async {
//             await tester.testImmediateNotification(NotificationPriority.low);
//             _showSuccessSnackbar(context, 'Low priority notification sent');
//           },
//         ),
//         OutlinedButton(
//           child: const Text('Medium Priority'),
//           onPressed: () async {
//             await tester.testImmediateNotification(NotificationPriority.medium);
//             _showSuccessSnackbar(context, 'Medium priority notification sent');
//           },
//         ),
//         OutlinedButton(
//           child: const Text('High Priority'),
//           onPressed: () async {
//             await tester.testImmediateNotification(NotificationPriority.high);
//             _showSuccessSnackbar(context, 'High priority notification sent');
//           },
//         ),
//         OutlinedButton(
//           child: const Text('Critical Priority'),
//           onPressed: () async {
//             await tester
//                 .testImmediateNotification(NotificationPriority.critical);
//             _showSuccessSnackbar(context, 'Critical notification sent');
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildScheduledTestsCard(
//       BuildContext context, NotificationTester tester, ThemeData theme) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Scheduled Notifications',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.timer),
//               label: const Text('Schedule in 10 seconds'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () async {
//                 await tester.testScheduledNotification(
//                   NotificationPriority.high,
//                   const Duration(seconds: 10),
//                 );
//                 _showSuccessSnackbar(
//                     context, 'Notification scheduled for 10 seconds from now');
//               },
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.timer),
//               label: const Text('Schedule in 30 seconds'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () async {
//                 await tester.testScheduledNotification(
//                   NotificationPriority.medium,
//                   const Duration(seconds: 30),
//                 );
//                 _showSuccessSnackbar(
//                     context, 'Notification scheduled for 30 seconds from now');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContextAwareTestsCard(BuildContext context,
//       NotificationTester tester, ThemeData theme, int energy, int maxSymptoms) {
//     // Calculate dynamic test values
//     final energyTestPass = (energy - 1).clamp(0, 10);
//     final energyTestFail = (energy + 1).clamp(0, 10);
//     final symptomTestPass = (maxSymptoms + 1).clamp(0, 10);
//     final symptomTestFail = (maxSymptoms - 1).clamp(0, 10);

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Context-Aware Tests',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'These notifications have rules based on your current context',
//               style: theme.textTheme.bodySmall,
//             ),
//             const SizedBox(height: 16),

//             // Test with context rules that should work
//             Consumer(
//               builder: (context, ref, _) => ElevatedButton.icon(
//                 icon: const Icon(Icons.check_circle, color: Colors.green),
//                 label: Text('Test Context-Aware (Should Show)'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 onPressed: () async {
//                   final service = ref.read(notificationServiceProvider);
//                   await service.testImmediateNotificationWithContext(
//                       NotificationPriority.medium);
//                   _showSuccessSnackbar(context,
//                       'Context-aware notification sent - should appear if context allows');
//                 },
//               ),
//             ),
//             const SizedBox(height: 12),

//             // Energy threshold tests - dynamic based on current energy
//             ElevatedButton.icon(
//               icon: const Icon(Icons.energy_savings_leaf, color: Colors.red),
//               label: Text('Energy ≥ $energyTestFail (Should Fail)'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () async {
//                 await tester.testContextAwareNotification(
//                   NotificationPriority.medium,
//                   minEnergy: energyTestFail,
//                 );
//                 _showSuccessSnackbar(context,
//                     'Notification sent - should NOT appear (energy too low: $energy < $energyTestFail)');
//               },
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.energy_savings_leaf, color: Colors.green),
//               label: Text('Energy ≥ $energyTestPass (Should Show)'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () async {
//                 await tester.testContextAwareNotification(
//                   NotificationPriority.medium,
//                   minEnergy: energyTestPass,
//                 );
//                 _showSuccessSnackbar(context,
//                     'Notification sent - should appear (energy sufficient: $energy ≥ $energyTestPass)');
//               },
//             ),
//             const SizedBox(height: 16),

//             // Symptom threshold tests - dynamic based on current symptoms
//             ElevatedButton.icon(
//               icon: const Icon(Icons.medical_information, color: Colors.red),
//               label: Text('Symptoms ≤ $symptomTestFail (Should Fail)'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () async {
//                 await tester.testContextAwareNotification(
//                   NotificationPriority.medium,
//                   maxSymptomLevel: symptomTestFail,
//                 );
//                 _showSuccessSnackbar(context,
//                     'Notification sent - should NOT appear (symptoms too high: $maxSymptoms > $symptomTestFail)');
//               },
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.medical_information, color: Colors.green),
//               label: Text('Symptoms ≤ $symptomTestPass (Should Show)'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               onPressed: () async {
//                 await tester.testContextAwareNotification(
//                   NotificationPriority.medium,
//                   maxSymptomLevel: symptomTestPass,
//                 );
//                 _showSuccessSnackbar(context,
//                     'Notification sent - should appear (symptoms acceptable: $maxSymptoms ≤ $symptomTestPass)');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getEnergyColor(int energy, ThemeData theme) {
//     if (energy <= 3) {
//       return Colors.red;
//     } else if (energy <= 6) {
//       return Colors.orange;
//     } else {
//       return Colors.green;
//     }
//   }

//   Color _getSymptomColor(int symptoms, ThemeData theme) {
//     if (symptoms >= 8) {
//       // Fixed thresholds for 1-10 scale
//       return Colors.red;
//     } else if (symptoms >= 5) {
//       return Colors.orange;
//     } else {
//       return Colors.green;
//     }
//   }

//   Color _getSymptomCountColor(int count, ThemeData theme) {
//     if (count >= 3) {
//       return Colors.red;
//     } else if (count >= 1) {
//       return Colors.orange;
//     } else {
//       return Colors.green;
//     }
//   }

//   void _showSuccessSnackbar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
// }
