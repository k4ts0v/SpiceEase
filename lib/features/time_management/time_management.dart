import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spiceease/features/time_management/flowmodoro/flowmodoro_page.dart';
import 'package:spiceease/features/time_management/kanban/kanban_page.dart';
import 'package:spiceease/features/time_management/time_blocks/time_blocks_page.dart';
import 'package:spiceease/components/app_header.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class TimeManagementPage extends ConsumerWidget {
  const TimeManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(sectionName: localizations.timeManagement),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    _TimeManagementCard(
                      title: localizations.flowmodoro,
                      description: localizations.flowmodoroDescription,
                      icon: Icons.timelapse,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const FlowmodoroPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _TimeManagementCard(
                      title: localizations.kanban,
                      description: localizations.kanbanDescription,
                      icon: Icons.view_kanban,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const KanbanPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _TimeManagementCard(
                      title: localizations.timeBlocks,
                      description: localizations.timeBlocksDescription,
                      icon: Icons.calendar_view_day,
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const TimeBlocksPage()),
                        );
                      },
                    ),
                    const SizedBox(
                        height: 18), // Reduce this to 16px when implemented.
                    Stack(
                      children: [
                        _TimeManagementCard(
                          title: localizations.speedrun,
                          description: localizations.speedrunDescription,
                          icon: FontAwesomeIcons.stopwatch,
                          color: const Color.fromARGB(255, 139, 76, 175),
                          onTap: () {}, // Disabled tap
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                localizations.comingSoon,
                                style: TextStyle(
                                  color: theme.colorScheme.surface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 24), // Reduce this to 16px when implemented.
                    Stack(
                      children: [
                        _TimeManagementCard(
                          title: localizations.diceRoller,
                          description: localizations.diceRollerDescription,
                          icon: FontAwesomeIcons.diceD20,
                          color: const Color.fromARGB(255, 175, 76, 76),
                          onTap: () {}, // Disabled tap
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                localizations.comingSoon,
                                style: TextStyle(
                                  color: theme.colorScheme.surface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeManagementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TimeManagementCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: IntrinsicHeight(
            // Add this to make the row adapt to content height
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch to fill height
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withOpacity(
                        theme.brightness == Brightness.dark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 40,
                      color: color.withOpacity(
                          theme.brightness == Brightness.dark ? 0.85 : 1.0),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}