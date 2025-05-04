import 'package:flutter/material.dart';
import 'package:spiceease/features/tracker/presentation/tracker_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TrackerScreen(),
    PlaceholderScreen(label: "Time management"),
    PlaceholderScreen(label: "Insights"),
    PlaceholderScreen(label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navBarItems.length, (index) {
              final item = _navBarItems[index];
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
                          color: isSelected ? Colors.blueAccent : Colors.black54,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blueAccent : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

const _navBarItems = [
  _NavBarItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Home',
  ),
  _NavBarItem(
    icon: Icons.hourglass_empty,
    selectedIcon: Icons.hourglass_full,
    label: 'Time management',
  ),
  _NavBarItem(
    icon: Icons.area_chart_outlined,
    selectedIcon: Icons.area_chart,
    label: 'Insights',
  ),
  _NavBarItem(
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    label: 'Profile',
  ),
];

class PlaceholderScreen extends StatelessWidget {
  final String label;

  const PlaceholderScreen({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label Page',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}