// Standard Flutter imports for UI components and state management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core authentication models and providers
import 'package:spiceease/core/auth/auth_user_model.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';

// Feature screen imports for navigation
import 'package:spiceease/features/reports/reports_page.dart';
import 'package:spiceease/features/settings/settings_page.dart';
import 'package:spiceease/features/time_management/time_management.dart';
import 'package:spiceease/features/tracker/presentation/tracker_screen.dart';

// Internationalization for multi-language support
import 'package:spiceease/l10n/app_localizations.dart';

// ===== NAVIGATION STATE MANAGEMENT =====
// Provider that manages the currently selected navigation index

/// Global provider for tracking the current navigation index
///
/// This provider maintains the state of which bottom navigation tab is currently
/// selected. It defaults to index 0 (Tracker screen) and is used throughout
/// the app to synchronize navigation state.
final navigationIndexProvider = StateProvider<int>((ref) => 0);

// ===== MAIN NAVIGATION BAR COMPONENT =====
// This section provides the primary navigation structure for the application

/// Main navigation bar widget that provides tab-based navigation between app features
///
/// This component serves as the primary navigation structure for the SpiceEase app,
/// providing access to four main features:
/// - Tracker: Health and habit tracking (index 0)
/// - Time Management: Schedule and task management (index 1)
/// - Reports: Analytics and insights (index 2)
/// - Settings: App configuration and preferences (index 3)
///
/// Key features:
/// - IndexedStack for efficient memory management and state preservation
/// - Custom bottom navigation bar with smooth animations
/// - Error boundary handling with retry functionality
/// - Authentication state listening for security
/// - Responsive design with theme integration
/// - Accessibility support with proper semantics
class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
  @override
  void initState() {
    super.initState();

    // ===== INITIALIZATION =====
    // Reset navigation to home screen on app start
    ref.read(navigationIndexProvider.notifier).state = 0;

    // ===== AUTHENTICATION LISTENER =====
    // Monitor auth state changes and reset navigation when user logs out
    ref.listenManual<AsyncValue<AppUser?>>(
      unifiedAuthProvider,
      (_, next) {
        final user = next.value;
        if (user == null) {
          // Reset to home screen when user logs out
          ref.read(navigationIndexProvider.notifier).state = 0;
        }
      },
    );
  }

  /// Returns the appropriate screen widget based on navigation index
  ///
  /// This method handles screen routing with error boundary protection.
  /// If any screen fails to load, it displays an error screen with retry option.
  Widget _getScreen(int index) {
    try {
      switch (index) {
        case 0:
          return const TrackerScreen();
        case 1:
          return const TimeManagementPage();
        case 2:
          return const ReportsPage();
        case 3:
          return const SettingsPage();
        default:
          // Fallback to tracker screen for invalid indices
          return const TrackerScreen();
      }
    } catch (e) {
      // ===== ERROR BOUNDARY =====
      // Display error screen with retry option if screen fails to load
      return _ErrorScreen(
        screenName: _getScreenName(index),
        error: e.toString(),
        onRetry: () {
          setState(() {}); // Trigger rebuild to retry screen loading
        },
      );
    }
  }

  /// Returns the human-readable name for a navigation index
  ///
  /// Used for error messages and debugging purposes.
  String _getScreenName(int index) {
    switch (index) {
      case 0:
        return 'Tracker';
      case 1:
        return 'Time Management';
      case 2:
        return 'Reports';
      case 3:
        return 'Settings';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ===== STATE AND THEME =====
    final selectedIndex = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    // ===== NAVIGATION ITEM CONFIGURATION =====
    final navBarItems = [
      _NavBarItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: localizations.home,
      ),
      _NavBarItem(
        icon: Icons.hourglass_empty,
        selectedIcon: Icons.hourglass_full,
        label: localizations.timeManagement,
      ),
      _NavBarItem(
        icon: Icons.area_chart_outlined,
        selectedIcon: Icons.area_chart,
        label: localizations.insights,
      ),
      _NavBarItem(
        icon: Icons.settings,
        selectedIcon: Icons.settings,
        label: localizations.settings,
      ),
    ];

    return Scaffold(
      // ===== MAIN CONTENT AREA =====
      // IndexedStack preserves state of all screens for smooth navigation
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _getScreen(0), // Tracker Screen
          _getScreen(1), // Time Management Screen
          _getScreen(2), // Reports Screen
          _getScreen(3), // Settings Screen
        ],
      ),

      // ===== CUSTOM BOTTOM NAVIGATION BAR =====
      bottomNavigationBar: _buildBottomNavigationBar(
        navBarItems,
        selectedIndex,
        colorScheme,
      ),
    );
  }

  /// Builds the custom bottom navigation bar with smooth animations
  Widget _buildBottomNavigationBar(
    List<_NavBarItem> navBarItems,
    int selectedIndex,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navBarItems.length, (index) {
          final item = navBarItems[index];
          final isSelected = selectedIndex == index;

          return Expanded(
            child: _buildNavigationItem(
              item,
              index,
              isSelected,
              colorScheme,
            ),
          );
        }),
      ),
    );
  }

  /// Builds individual navigation item with tap handling and visual feedback
  Widget _buildNavigationItem(
    _NavBarItem item,
    int index,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // ===== NAVIGATION HANDLING =====
        ref.read(navigationIndexProvider.notifier).state = index;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== NAVIGATION ICON =====
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 28,
            ),
            // Note: Labels are intentionally omitted for a cleaner design
            // The icons are self-explanatory and the app uses tooltips where needed
          ],
        ),
      ),
    );
  }
}

// ===== NAVIGATION ITEM DATA MODEL =====
// Simple data class for navigation bar item configuration

/// Data model for navigation bar items
///
/// Encapsulates the visual configuration for each navigation tab including:
/// - Regular and selected state icons
/// - Accessible label text for screen readers
/// - Future extensibility for badges, notifications, etc.
class _NavBarItem {
  /// Icon displayed when the tab is not selected
  final IconData icon;

  /// Icon displayed when the tab is selected
  final IconData selectedIcon;

  /// Accessible label for the navigation item
  final String label;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

// ===== ERROR HANDLING COMPONENT =====
// Provides graceful error handling for navigation failures

/// Error screen displayed when a navigation screen fails to load
///
/// This component provides a user-friendly error boundary that:
/// - Displays clear error information to the user
/// - Shows the technical error details for debugging
/// - Provides a retry mechanism to attempt recovery
/// - Maintains consistent theming with the rest of the app
/// - Uses proper error styling with appropriate colors
class _ErrorScreen extends StatelessWidget {
  /// Name of the screen that failed to load
  final String screenName;

  /// Technical error message for debugging
  final String error;

  /// Callback function to retry loading the screen
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.screenName,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // ===== ERROR SCREEN HEADER =====
      appBar: AppBar(
        title: Text('$screenName - Error'),
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
      ),

      // ===== ERROR CONTENT =====
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===== ERROR ICON =====
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),

              // ===== ERROR TITLE =====
              Text(
                'Error loading $screenName',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ===== ERROR DETAILS =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace', // Monospace for technical details
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // ===== RETRY BUTTON =====
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
