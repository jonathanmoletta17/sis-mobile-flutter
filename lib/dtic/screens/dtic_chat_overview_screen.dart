import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/glpi_status.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_status.dart';
import '../../widgets/ui/glpi_app_navigation.dart';
import '../../widgets/ui/sis_empty_state.dart';
import '../../widgets/ui/sis_loading_state.dart';
import '../../widgets/ui/sis_page_scaffold.dart';
import '../../widgets/ui/sis_status_chip.dart';
import '../models/dtic_ticket_models.dart';
import '../state/dtic_app_state.dart';
import 'dtic_catalog_screen.dart';
import 'dtic_my_tickets_screen.dart';
import 'dtic_ticket_detail_screen.dart';

class DticChatOverviewScreen extends StatefulWidget {
  const DticChatOverviewScreen({super.key});

  @override
  State<DticChatOverviewScreen> createState() => _DticChatOverviewScreenState();
}

class _DticChatOverviewScreenState extends State<DticChatOverviewScreen> {
  late Future<void> _future;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = context.read<DticAppState>().loadTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final future = context.read<DticAppState>().loadTickets();
    setState(() => _future = future);
    await future;
  }

  void _openShellDestination(GlpiAppSection destination) {
    switch (destination) {
      case GlpiAppSection.services:
        replaceAppRoot(context, const DticCatalogScreen());
      case GlpiAppSection.tickets:
        replaceAppRoot(context, const DticMyTicketsScreen());
      case GlpiAppSection.conversations:
        return;
      case GlpiAppSection.offline:
        return;
    }
  }

  List<DticTicketSummary> _filteredOpenTickets(
    List<DticTicketSummary> tickets,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return tickets.where((ticket) {
      if (!GlpiStatusMapper.isOpenForInteraction(ticket.status)) return false;
      if (query.isEmpty) return true;
      final haystack = [
        ticket.id,
        ticket.title,
        ticket.category,
        ticket.requester,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DticAppState>();

    return SisPageScaffold(
      title: 'Conversas DTIC',
      subtitle: 'Chamados em andamento e novas atividades',
      bottomNavigationBar: GlpiAppNavigationBar(
        current: GlpiAppSection.conversations,
        destinations: dticShellDestinations(),
        onDestinationSelected: _openShellDestination,
      ),
      actions: [
        IconButton(
          tooltip: 'Atualizar',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SisLoadingState(
              title: 'Carregando conversas',
              message: 'Consultando chamados em andamento.',
            );
          }

          if (snapshot.hasError) {
            return SisEmptyState(
              icon: Icons.error_outline,
              title: 'Falha ao carregar conversas',
              message: snapshot.error.toString(),
              actionLabel: 'Tentar novamente',
              onAction: _refresh,
            );
          }

          final tickets = _filteredOpenTickets(state.tickets);
          final hasSearch = _searchController.text.trim().isNotEmpty;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar conversa',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: hasSearch
                        ? IconButton(
                            tooltip: 'Limpar busca',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (tickets.isEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.58,
                    child: SisEmptyState(
                      icon: hasSearch
                          ? Icons.search_off_outlined
                          : Icons.chat_bubble_outline,
                      title: hasSearch
                          ? 'Nenhuma conversa com esta busca'
                          : 'Nenhuma conversa ativa',
                      message: hasSearch
                          ? 'Ajuste a busca para ver outros chamados.'
                          : 'Chamados abertos e em atendimento aparecerão aqui.',
                    ),
                  )
                else
                  for (final ticket in tickets)
                    _DticConversationCard(ticket: ticket, appState: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DticConversationCard extends StatelessWidget {
  const _DticConversationCard({required this.ticket, required this.appState});

  final DticTicketSummary ticket;
  final DticAppState appState;

  @override
  Widget build(BuildContext context) {
    final isUnread = appState.hasUnreadContent(ticket.id, ticket.updatedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: isUnread ? AppColors.brandSoft : AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.brandDark,
              ),
            ),
            if (isUnread)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.4),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          ticket.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: ${ticket.id}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (ticket.category.isNotEmpty)
                Text(
                  ticket.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              if (isUnread)
                Text(
                  'Nova atividade',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        trailing: SisStatusChip(
          label: ticket.statusLabel,
          tone: AppStatusPalette.fromGlpiStatus(ticket.status),
        ),
        onTap: () async {
          await context.read<DticAppState>().markTicketAsRead(ticket.id);
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DticTicketDetailScreen(ticketId: ticket.id),
            ),
          );
        },
      ),
    );
  }
}
