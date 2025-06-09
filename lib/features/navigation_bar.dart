import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/user_model.dart';
import 'package:spiceease/features/reports/reports_page.dart';
import 'package:spiceease/features/settings/settings_page.dart';
import 'package:spiceease/features/time_management/time_management.dart';
import 'package:spiceease/features/tracker/presentation/tracker_screen.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
  @override
  void initState() {
    super.initState();
    ref.read(navigationIndexProvider.notifier).state = 0;
    
    ref.listenManual<AsyncValue<AppUser?>>(
      unifiedAuthProvider,
      (_, next) {
        final user = next.value;
        if (user == null) {
          ref.read(navigationIndexProvider.notifier).state = 0;
        }
      },
    );
  }

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
          return const TrackerScreen();
      }
    } catch (e, stack) {
      return _ErrorScreen(
        screenName: _getScreenName(index),
        error: e.toString(),
        onRetry: () {
          setState(() {});
        },
      );
    }
  }

  String _getScreenName(int index) {
    switch (index) {
      case 0: return 'Tracker';
      case 1: return 'Time Management';
      case 2: return 'Reports';
      case 3: return 'Settings';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;

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
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _getScreen(0),
          _getScreen(1),
          _getScreen(2),
          _getScreen(3),
        ],
      ),
      bottomNavigationBar: Container(
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
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  ref.read(navigationIndexProvider.notifier).state = index;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavBarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _ErrorScreen extends StatelessWidget {
  final String screenName;
  final String error;
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.screenName,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$screenName - Error'),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Error loading $screenName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}