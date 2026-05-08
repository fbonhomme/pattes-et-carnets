import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (path: '/', icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Accueil'),
    (path: '/journal/all', icon: Icons.history_edu_outlined, activeIcon: Icons.history_edu, label: 'Journal'),
    (path: '/calendar', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Calendrier'),
  ];

  int _locationToIndex(String location) {
    if (location.startsWith('/journal')) return 1;
    if (location.startsWith('/calendar')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1FA3B18A),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = selectedIndex == i;
                return _NavItem(
                  icon: isActive ? tab.activeIcon : tab.icon,
                  label: tab.label,
                  isActive: isActive,
                  onTap: () => context.go(tab.path),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
