import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spiceease/features/reports/reports_page.dart';
import 'package:spiceease/features/settings/settings_page.dart';
import 'package:spiceease/features/settings/settings_page.dart';
import 'package:spiceease/features/time_management/time_management.dart';
import 'package:spiceease/features/tracker/presentation/tracker_screen.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TrackerScreen(),
    TimeManagementPage(),
    ReportsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    // Define navigation items inside build to access localizations
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

    return Material(
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navBarItems.length, (index) {
              final item = navBarItems[index];
              final isSelected = _selectedIndex == index;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
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
                              : colorScheme.onSurface.withOpacity(0.6),
                          size: 28,
                        ),
                        // Uncomment if you want to show labels
                        // const SizedBox(height: 4),
                        // Text(
                        //   item.label,
                        //   style: TextStyle(
                        //     fontSize: 12,
                        //     fontWeight: isSelected
                        //         ? FontWeight.bold
                        //         : FontWeight.normal,
                        //     color: isSelected
                        //         ? colorScheme.primary
                        //         : colorScheme.onSurface.withOpacity(0.6),
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
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
