import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spiceease/features/time_management/flowmodoro/flowmodoro_page.dart';
import 'package:spiceease/features/time_management/kanban/kanban_page.dart';
import 'package:spiceease/features/time_management/time_blocks/time_blocks_page.dart';
import 'package:spiceease/features/tracker/presentation/widgets/tracker_header.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class TimeManagementPage extends ConsumerWidget {
  const TimeManagementPage({Key? key}) : super(key: key);

// TODO: In screens bigger than a phone, the cards are too big. Fix this.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 16,
                  children: [
                    _TimeManagementCard(
                      title: localizations.flowmodoro,
                      description: localizations.flowmodoroDescription,
                      icon: Icons.timelapse,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => FlowmodoroPage()),
                        );
                      },
                    ),
                    _TimeManagementCard(
                      title: localizations.kanban,
                      description: localizations.kanbanDescription,
                      icon: Icons.view_kanban,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => KanbanPage()),
                        );
                      },
                    ),
                    _TimeManagementCard(
                      title: localizations.timeBlocks,
                      description: localizations.timeBlocksDescription,
                      icon: Icons.calendar_view_day,
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => TimeBlocksPage()),
                        );
                      },
                    ),
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
                              color: Colors.black.withAlpha(104),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                "Coming soon!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              color: Colors.black.withAlpha(104),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                "Coming soon!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
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
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 40,
                    color: color,
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
