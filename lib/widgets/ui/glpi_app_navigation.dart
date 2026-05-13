import 'package:flutter/material.dart';

import 'sis_action_badge.dart';

enum GlpiAppSection { services, tickets, conversations, offline }

class GlpiNavDestination {
  const GlpiNavDestination({
    required this.section,
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount = 0,
  });

  final GlpiAppSection section;
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int badgeCount;
}

class GlpiAppNavigationBar extends StatelessWidget {
  const GlpiAppNavigationBar({
    super.key,
    required this.current,
    required this.destinations,
    required this.onDestinationSelected,
  });

  final GlpiAppSection current;
  final List<GlpiNavDestination> destinations;
  final ValueChanged<GlpiAppSection> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = destinations.indexWhere(
      (destination) => destination.section == current,
    );

    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (index) {
        final destination = destinations[index].section;
        if (destination == current) return;
        onDestinationSelected(destination);
      },
      destinations: [
        for (final destination in destinations)
          NavigationDestination(
            icon: _NavigationIcon(
              icon: destination.icon,
              badgeCount: destination.badgeCount,
            ),
            selectedIcon: _NavigationIcon(
              icon: destination.selectedIcon ?? destination.icon,
              badgeCount: destination.badgeCount,
            ),
            label: destination.label,
          ),
      ],
    );
  }
}

List<GlpiNavDestination> sisShellDestinations({required int pendingCount}) {
  return [
    const GlpiNavDestination(
      section: GlpiAppSection.services,
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
      label: 'Serviços',
    ),
    const GlpiNavDestination(
      section: GlpiAppSection.tickets,
      icon: Icons.list_alt_outlined,
      selectedIcon: Icons.list_alt,
      label: 'Chamados',
    ),
    const GlpiNavDestination(
      section: GlpiAppSection.conversations,
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
      label: 'Conversas',
    ),
    GlpiNavDestination(
      section: GlpiAppSection.offline,
      icon: Icons.cloud_upload_outlined,
      selectedIcon: Icons.cloud_upload,
      label: 'Offline',
      badgeCount: pendingCount,
    ),
  ];
}

List<GlpiNavDestination> dticShellDestinations() {
  return const [
    GlpiNavDestination(
      section: GlpiAppSection.services,
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
      label: 'Serviços',
    ),
    GlpiNavDestination(
      section: GlpiAppSection.tickets,
      icon: Icons.list_alt_outlined,
      selectedIcon: Icons.list_alt,
      label: 'Chamados',
    ),
    GlpiNavDestination(
      section: GlpiAppSection.conversations,
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
      label: 'Conversas',
    ),
  ];
}

void replaceAppRoot(BuildContext context, Widget screen) {
  Navigator.of(
    context,
  ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => screen), (_) => false);
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({required this.icon, required this.badgeCount});

  final IconData icon;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    if (badgeCount <= 0) return Icon(icon);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -10,
          top: -8,
          child: SisActionBadge(count: badgeCount),
        ),
      ],
    );
  }
}
