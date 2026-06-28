import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/chat_overview_screen.dart';
import '../../screens/my_tickets_screen.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

enum SisShellDestination { catalog, tickets, conversations }

class SisShellDrawer extends StatelessWidget {
  final SisShellDestination activeDestination;
  final Future<void> Function(BuildContext context, AppState appState)
  onOpenEntitySelector;

  const SisShellDrawer({
    super.key,
    required this.activeDestination,
    required this.onOpenEntitySelector,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  gradient: const LinearGradient(
                    colors: [AppColors.brandDark, AppColors.brand],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.overlayOnBrandStrong,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: AppColors.textInverse,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'SIS Mobile',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Atendimento operacional SIS',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textOnBrandMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unidade de atendimento',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      appState.selectedTicketEntityName ??
                          appState.activeEntityName ??
                          'Não definida',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await onOpenEntitySelector(context, appState);
                      },
                      icon: const Icon(Icons.account_tree_outlined),
                      label: const Text('Trocar unidade'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perfil ativo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      appState.activeProfile ?? 'Não definido',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (appState.canSwitchProfile)
                      OutlinedButton.icon(
                        onPressed: appState.isSwitchingProfile
                            ? null
                            : () => _showProfileSelector(context, appState),
                        icon: const Icon(Icons.badge_outlined),
                        label: Text(
                          appState.isSwitchingProfile
                              ? 'Trocando…'
                              : 'Trocar perfil',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: [
                  _DrawerTile(
                    active: activeDestination == SisShellDestination.catalog,
                    icon: Icons.home_outlined,
                    label: 'Serviços',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerTile(
                    active: activeDestination == SisShellDestination.tickets,
                    icon: Icons.list_alt_outlined,
                    label: 'Meus Chamados',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MyTicketsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerTile(
                    active:
                        activeDestination == SisShellDestination.conversations,
                    icon: Icons.chat_bubble_outline,
                    label: 'Conversas',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChatOverviewScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProfileSelector(
    BuildContext context,
    AppState appState,
  ) async {
    final selectedId = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) {
        final profiles = appState.availableProfiles;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Selecionar perfil',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              ...profiles.map((profile) {
                final id = profile['id'] as int;
                final name = profile['name']?.toString() ?? 'Perfil $id';
                final isActive = id == appState.activeProfileId;
                return ListTile(
                  leading: Icon(
                    isActive
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isActive ? AppColors.brandDark : AppColors.textMuted,
                  ),
                  title: Text(name),
                  enabled: !isActive,
                  onTap: () => Navigator.pop(sheetContext, id),
                );
              }),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );

    if (selectedId == null) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context); // fecha o drawer
    final ok = await appState.switchActiveProfile(selectedId);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Perfil ativo alterado para ${appState.activeProfile ?? ''}.'
              : 'Não foi possível trocar de perfil.',
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        tileColor: active ? AppColors.brandSoft : AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        leading: Icon(
          icon,
          color: active ? AppColors.brandDark : AppColors.textMuted,
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: active ? AppColors.brandDark : AppColors.textStrong,
          ),
        ),
      ),
    );
  }
}
