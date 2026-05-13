import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/service_data.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/service_card.dart';
import '../widgets/ui/glpi_app_navigation.dart';
import '../widgets/ui/sis_action_badge.dart';
import '../widgets/ui/sis_page_scaffold.dart';
import '../widgets/ui/sis_section_header.dart';
import '../widgets/ui/sis_shell_drawer.dart';
import 'chat_overview_screen.dart';
import 'my_tickets_screen.dart';
import 'offline_queue_screen.dart';

class ServiceCatalogScreen extends StatelessWidget {
  const ServiceCatalogScreen({super.key});

  void _openShellDestination(BuildContext context, GlpiAppSection destination) {
    switch (destination) {
      case GlpiAppSection.services:
        return;
      case GlpiAppSection.tickets:
        replaceAppRoot(context, const MyTicketsScreen());
      case GlpiAppSection.conversations:
        replaceAppRoot(context, const ChatOverviewScreen());
      case GlpiAppSection.offline:
        replaceAppRoot(context, const OfflineQueueScreen());
    }
  }

  Future<void> _openEntitySelector(
    BuildContext context,
    AppState appState,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final entities = appState.availableEntities;
    if (entities.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Nenhuma entidade disponivel no perfil atual.'),
        ),
      );
      return;
    }

    if (entities.length == 1) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Este perfil possui apenas uma entidade para chamados.',
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text(
                  'Entidade para novos chamados',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              for (final entity in entities)
                ListTile(
                  leading: Icon(
                    appState.selectedTicketEntityId == entity['id']
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  title: Text(entity['name']?.toString() ?? 'Sem nome'),
                  onTap: () async {
                    await appState.selectTicketEntity(
                      entityId: entity['id'] as int,
                      entityName: entity['name']?.toString() ?? '',
                    );
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Novos chamados serao abertos em ${entity['name']}.',
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final pendingCount = appState.pendingTickets.length;

    return SisPageScaffold(
      title: 'Serviços',
      subtitle: 'Atendimento operacional SIS',
      drawer: SisShellDrawer(
        activeDestination: SisShellDestination.catalog,
        onOpenEntitySelector: _openEntitySelector,
      ),
      bottomNavigationBar: GlpiAppNavigationBar(
        current: GlpiAppSection.services,
        destinations: sisShellDestinations(pendingCount: pendingCount),
        onDestinationSelected: (destination) {
          _openShellDestination(context, destination);
        },
      ),
      actions: [
        if (pendingCount > 0)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.cloud_upload_outlined),
                tooltip: 'Abrir fila offline',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OfflineQueueScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 6,
                top: 8,
                child: SisActionBadge(count: pendingCount),
              ),
            ],
          ),
        IconButton(onPressed: appState.logout, icon: const Icon(Icons.logout)),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 1100
              ? 4
              : constraints.maxWidth >= 760
              ? 3
              : constraints.maxWidth >= 460
              ? 2
              : 1;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  gradient: const LinearGradient(
                    colors: [AppColors.brandDark, AppColors.brand],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atendimento pronto para operar',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppColors.textInverse),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Abra novos chamados, acompanhe pendências e acesse as conversas ativas a partir de uma única superfície.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _InfoPill(
                          icon: Icons.account_tree_outlined,
                          label:
                              appState.selectedTicketEntityName ??
                              appState.activeEntityName ??
                              'Entidade não definida',
                        ),
                        _InfoPill(
                          icon: Icons.cloud_sync_outlined,
                          label: pendingCount > 0
                              ? '$pendingCount pendente(s) de sincronização'
                              : 'Sem pendências de sincronização',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MyTicketsScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.brandDark,
                            minimumSize: const Size(0, 48),
                          ),
                          icon: const Icon(Icons.list_alt_outlined),
                          label: const Text('Meus Chamados'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChatOverviewScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textInverse,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            minimumSize: const Size(0, 48),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Conversas'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const OfflineQueueScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textInverse,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            minimumSize: const Size(0, 48),
                          ),
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: Text(
                            pendingCount > 0
                                ? 'Fila offline ($pendingCount)'
                                : 'Fila offline',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SisSectionHeader(
                title: 'Categorias',
                subtitle:
                    'Escolha o serviço a partir do catálogo operacional da SIS.',
              ),
              const SizedBox(height: AppSpacing.md),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: crossAxisCount == 1 ? 2.25 : 0.98,
                ),
                itemCount: serviceCategories.length,
                itemBuilder: (context, index) {
                  return ServiceCard(service: serviceCategories[index]);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textInverse),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textInverse),
            ),
          ),
        ],
      ),
    );
  }
}
