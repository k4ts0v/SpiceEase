// Standard Flutter imports for UI components and state management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// External package for additional icons
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Time management feature screens
import 'package:spiceease/features/time_management/flowmodoro/flowmodoro_page.dart';
import 'package:spiceease/features/time_management/kanban/kanban_page.dart';
import 'package:spiceease/features/time_management/time_blocks/time_blocks_page.dart';

// Shared UI components
import 'package:spiceease/components/app_header.dart';

// Internationalization for multi-language support
import 'package:spiceease/l10n/app_localizations.dart';

// ===== TIME MANAGEMENT HUB SCREEN =====
// This section provides the main navigation hub for time management features

/// Main time management screen that serves as a navigation hub
///
/// This screen provides access to various time management techniques and tools:
/// - Flowmodoro: Flow-state based productivity technique
/// - Kanban: Visual task management boards
/// - Time Blocks: Calendar-based time scheduling
/// - Speedrun: Gamified task completion (coming soon)
/// - Dice Roller: Random task selection tool (coming soon)
///
/// The screen uses a card-based layout to present each feature with:
/// - Clear visual icons and branding colors
/// - Descriptive titles and explanations
/// - Intuitive navigation to individual features
/// - Coming soon overlays for features in development
/// - Responsive design that adapts to screen sizes
class TimeManagementPage extends ConsumerWidget {
  const TimeManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ===== THEME AND LOCALIZATION =====
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ===== SCREEN HEADER =====
            AppHeader(sectionName: localizations.timeManagement),
            const SizedBox(height: 24),

            // ===== MAIN CONTENT AREA =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    // ===== FLOWMODORO FEATURE CARD =====
                    _TimeManagementCard(
                      title: localizations.flowmodoro,
                      description: localizations.flowmodoroDescription,
                      icon: Icons.timelapse,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FlowmodoroPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ===== KANBAN FEATURE CARD =====
                    _TimeManagementCard(
                      title: localizations.kanban,
                      description: localizations.kanbanDescription,
                      icon: Icons.view_kanban,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const KanbanPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ===== TIME BLOCKS FEATURE CARD =====
                    _TimeManagementCard(
                      title: localizations.timeBlocks,
                      description: localizations.timeBlocksDescription,
                      icon: Icons.calendar_view_day,
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TimeBlocksPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                        height: 18), // Reduce this to 16px when implemented.

                    // ===== SPEEDRUN FEATURE CARD (COMING SOON) =====
                    Stack(
                      children: [
                        _TimeManagementCard(
                          title: localizations.speedrun,
                          description: localizations.speedrunDescription,
                          icon: FontAwesomeIcons.stopwatch,
                          color: const Color.fromARGB(255, 139, 76, 175),
                          onTap: () {}, // Disabled tap for coming soon features
                        ),
                        // Coming soon overlay
                        _buildComingSoonOverlay(context, theme),
                      ],
                    ),
                    const SizedBox(
                        height: 24), // Reduce this to 16px when implemented.

                    // ===== DICE ROLLER FEATURE CARD (COMING SOON) =====
                    Stack(
                      children: [
                        _TimeManagementCard(
                          title: localizations.diceRoller,
                          description: localizations.diceRollerDescription,
                          icon: FontAwesomeIcons.diceD20,
                          color: const Color.fromARGB(255, 175, 76, 76),
                          onTap: () {}, // Disabled tap for coming soon features
                        ),
                        // Coming soon overlay
                        _buildComingSoonOverlay(context, theme),
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

  /// Builds the "Coming Soon" overlay for features in development
  Widget _buildComingSoonOverlay(BuildContext context, ThemeData theme) {
    final localizations = AppLocalizations.of(context)!;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
    );
  }
}

// ===== REUSABLE FEATURE CARD COMPONENT =====
// This section provides the card component used for each time management feature

/// Reusable card component for time management features
///
/// This widget provides a consistent visual design for each time management
/// feature with:
/// - Icon container with feature-specific color theming
/// - Title and description text with proper typography
/// - Responsive layout that adapts to content height
/// - Interactive tap handling with visual feedback
/// - Support for both light and dark themes
/// - Overflow handling for long text content
///
/// The card uses Material Design principles with:
/// - Elevation for depth perception
/// - Rounded corners for modern aesthetics
/// - Proper color contrast for accessibility
/// - Consistent spacing and padding
class _TimeManagementCard extends StatelessWidget {
  /// Display title for the feature
  final String title;

  /// Descriptive text explaining the feature
  final String description;

  /// Icon representing the feature visually
  final IconData icon;

  /// Brand color for the feature
  final Color color;

  /// Callback function when the card is tapped
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
            // Ensure row adapts to content height
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch to fill height
              children: [
                // ===== FEATURE ICON CONTAINER =====
                _buildIconContainer(theme),
                const SizedBox(width: 16),

                // ===== FEATURE TEXT CONTENT =====
                _buildTextContent(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the circular icon container with feature branding
  Widget _buildIconContainer(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.15 : 0.1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 40,
          color: color.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.85 : 1.0,
          ),
        ),
      ),
    );
  }

  /// Builds the text content area with title and description
  Widget _buildTextContent(ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ===== FEATURE TITLE =====
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

          // ===== FEATURE DESCRIPTION =====
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
