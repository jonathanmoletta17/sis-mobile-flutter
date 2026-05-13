import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_radius.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';
import 'package:sis_mobile_flutter/theme/app_status.dart';
import 'package:sis_mobile_flutter/widgets/ui/glpi_app_navigation.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_action_badge.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_empty_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_loading_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_page_scaffold.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_section_header.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_status_chip.dart';

import '../workbench_surface.dart';
import 'workbench_fixtures.dart';

enum MyTicketsSurfaceVariant { populated, empty, loading }

class MyTicketsSurfacePreview extends StatelessWidget {
  final MyTicketsSurfaceVariant variant;
  final bool filterActive;

  const MyTicketsSurfacePreview({
    super.key,
    required this.variant,
    this.filterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Meus Chamados',
        subtitle: 'Fila agrupada por status e contexto de sincronizacao',
        bottomNavigationBar: GlpiAppNavigationBar(
          current: GlpiAppSection.tickets,
          destinations: sisShellDestinations(pendingCount: 1),
          onDestinationSelected: (_) {},
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              filterActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: filterActive ? AppColors.accent : Colors.white,
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.cloud_upload_outlined),
              ),
              const Positioned(
                right: 6,
                top: 8,
                child: SisActionBadge(count: 1),
              ),
            ],
          ),
        ],
        body: switch (variant) {
          MyTicketsSurfaceVariant.loading => const SisLoadingState(
            title: 'Carregando chamados',
            message: 'Agrupando tickets por prioridade e status operacional.',
          ),
          MyTicketsSurfaceVariant.empty => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: const [
              SizedBox(
                height: 560,
                child: SisEmptyState(
                  icon: Icons.list_alt_outlined,
                  title: 'Nenhum chamado encontrado',
                  message:
                      'As solicitacoes abertas aparecerao aqui assim que entrarem na sua fila.',
                ),
              ),
            ],
          ),
          MyTicketsSurfaceVariant.populated => _MyTicketsPopulatedBody(
            filterActive: filterActive,
          ),
        },
      ),
    );
  }
}

class _MyTicketsPopulatedBody extends StatelessWidget {
  final bool filterActive;

  const _MyTicketsPopulatedBody({required this.filterActive});

  int _groupSortWeight(String key) {
    if (key == 'offline') return 0;
    if (key.startsWith('status_')) {
      return int.tryParse(key.replaceFirst('status_', '')) ?? 999;
    }
    return 999;
  }

  String _groupKey(dynamic rawStatus) {
    if (GlpiStatusMapper.isOffline(rawStatus)) return 'offline';
    final code = GlpiStatusMapper.code(rawStatus);
    if (code != null) return 'status_$code';
    return 'other_${GlpiStatusMapper.label(rawStatus)}';
  }

  @override
  Widget build(BuildContext context) {
    final groupedTickets = <String, List<Map<String, dynamic>>>{};
    final groupLabels = <String, String>{};

    for (final ticket in workbenchTickets) {
      final key = _groupKey(ticket['status']);
      groupedTickets.putIfAbsent(key, () => []);
      groupedTickets[key]!.add(ticket);
      groupLabels[key] = GlpiStatusMapper.label(ticket['status']);
    }

    final sortedKeys = groupedTickets.keys.toList()
      ..sort((a, b) => _groupSortWeight(a).compareTo(_groupSortWeight(b)));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        const SisSectionHeader(
          title: 'Fila operacional',
          subtitle:
              'A visualizacao agrupa o trabalho por status e evidencia pendencias de sincronizacao.',
        ),
        const SizedBox(height: AppSpacing.md),
        const _MyTicketsSummaryRow(),
        if (filterActive) ...[
          const SizedBox(height: AppSpacing.md),
          const Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              SisStatusChip(label: 'Eletrica', tone: AppStatusTone.info),
              SisStatusChip(label: 'ID 8090', tone: AppStatusTone.neutral),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ...sortedKeys.map((key) {
          final tickets = groupedTickets[key]!;
          return _TicketGroupCard(
            title: groupLabels[key] ?? key,
            tickets: tickets,
            initiallyExpanded: key == sortedKeys.first,
          );
        }),
      ],
    );
  }
}

class _MyTicketsSummaryRow extends StatelessWidget {
  const _MyTicketsSummaryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _SummaryCard(
            icon: Icons.confirmation_number_outlined,
            label: 'Fila ativa',
            value: '5',
            tone: AppStatusTone.brand,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(
            icon: Icons.cloud_upload_outlined,
            label: 'Pendentes',
            value: '1',
            tone: AppStatusTone.warning,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppStatusTone tone;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = AppStatusPalette.resolve(tone);

    return Card(
      color: visuals.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: visuals.background,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: visuals.foreground),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                  Text(value, style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketGroupCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> tickets;
  final bool initiallyExpanded;

  const _TicketGroupCard({
    required this.title,
    required this.tickets,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final tone = AppStatusPalette.fromGlpiStatus(tickets.first['status']);
    final visuals = AppStatusPalette.resolve(tone);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            iconColor: visuals.foreground,
            collapsedIconColor: AppColors.textMuted,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            title: Row(
              children: [
                Expanded(child: Text(title)),
                SisStatusChip(label: '${tickets.length}', tone: tone),
              ],
            ),
            children: tickets.map((ticket) {
              final id = ticket['id']?.toString() ?? '??';
              final displayId = id.contains('OFFLINE') ? 'OFF' : id;

              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Material(
                  color: visuals.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: visuals.foreground,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              displayId,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      ticket['name']?.toString() ?? 'Sem assunto',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Servico: ${ticket['serviceName']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          ticket['lastUpdateLabel']?.toString() ?? '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                    ),
                    onTap: () {},
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
