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
import 'dtic_chat_overview_screen.dart';
import 'dtic_ticket_detail_screen.dart';

class DticMyTicketsScreen extends StatefulWidget {
  const DticMyTicketsScreen({super.key});

  @override
  State<DticMyTicketsScreen> createState() => _DticMyTicketsScreenState();
}

class _DticMyTicketsScreenState extends State<DticMyTicketsScreen> {
  late Future<void> _future;
  final _searchController = TextEditingController();
  String? _statusFilter;
  String? _categoryFilter;

  void _openShellDestination(GlpiAppSection destination) {
    switch (destination) {
      case GlpiAppSection.services:
        replaceAppRoot(context, const DticCatalogScreen());
      case GlpiAppSection.tickets:
        return;
      case GlpiAppSection.conversations:
        replaceAppRoot(context, const DticChatOverviewScreen());
      case GlpiAppSection.offline:
        return;
    }
  }

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

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _statusFilter = null;
      _categoryFilter = null;
    });
  }

  List<String> _statusOptions(List<DticTicketSummary> tickets) {
    final statuses =
        tickets
            .map((ticket) => ticket.statusLabel)
            .where((status) => status.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return statuses;
  }

  List<String> _categoryOptions(List<DticTicketSummary> tickets) {
    final categories =
        tickets
            .map((ticket) => ticket.category)
            .where((category) => category.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return categories;
  }

  List<DticTicketSummary> _filteredTickets(List<DticTicketSummary> tickets) {
    final query = _normalize(_searchController.text);
    final status = _statusFilter;
    final category = _categoryFilter;

    return tickets.where((ticket) {
      if (status != null && ticket.statusLabel != status) return false;
      if (category != null && ticket.category != category) return false;
      if (query.isEmpty) return true;

      final haystack = _normalize(
        [
          ticket.id,
          ticket.title,
          ticket.statusLabel,
          ticket.openedAt,
          ticket.updatedAt,
          ticket.category,
          ticket.requester,
        ].join(' '),
      );
      return haystack.contains(query);
    }).toList();
  }

  Map<String, List<DticTicketSummary>> _groupTicketsByStatus(
    List<DticTicketSummary> tickets,
  ) {
    final groups = <String, List<DticTicketSummary>>{};
    for (final ticket in tickets) {
      final key = _groupKey(ticket.status);
      groups.putIfAbsent(key, () => <DticTicketSummary>[]).add(ticket);
    }
    return groups;
  }

  List<String> _sortedGroupKeys(Map<String, List<DticTicketSummary>> groups) {
    return groups.keys.toList()..sort((a, b) {
      final wa = _groupSortWeight(a);
      final wb = _groupSortWeight(b);
      if (wa != wb) return wa.compareTo(wb);

      final la = _groupLabel(groups[a]!.first);
      final lb = _groupLabel(groups[b]!.first);
      return la.compareTo(lb);
    });
  }

  String _groupKey(String rawStatus) {
    final code = GlpiStatusMapper.code(rawStatus);
    if (code != null) return 'status_$code';
    final label = GlpiStatusMapper.label(rawStatus);
    return 'other_${_normalize(label)}';
  }

  int _groupSortWeight(String key) {
    if (key.startsWith('status_')) {
      final code = int.tryParse(key.replaceFirst('status_', ''));
      if (code != null) return code;
    }
    return 999;
  }

  String _groupLabel(DticTicketSummary ticket) => ticket.statusLabel;

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DticAppState>();

    return SisPageScaffold(
      title: 'Meus chamados DTIC',
      subtitle: state.username,
      bottomNavigationBar: GlpiAppNavigationBar(
        current: GlpiAppSection.tickets,
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
              title: 'Carregando chamados',
              message: 'Consultando tickets do usuario logado.',
            );
          }

          if (snapshot.hasError) {
            return SisEmptyState(
              icon: Icons.error_outline,
              title: 'Falha ao carregar chamados',
              message: snapshot.error.toString(),
              actionLabel: 'Tentar novamente',
              onAction: _refresh,
            );
          }

          if (state.tickets.isEmpty) {
            return SisEmptyState(
              icon: Icons.inbox_outlined,
              title: 'Nenhum chamado encontrado',
              message:
                  'A consulta DTIC nao retornou chamados para este usuario.',
              actionLabel: 'Atualizar',
              onAction: _refresh,
            );
          }

          final filteredTickets = _filteredTickets(state.tickets);
          final statusOptions = _statusOptions(state.tickets);
          final categoryOptions = _categoryOptions(state.tickets);
          final hasActiveFilters =
              _searchController.text.trim().isNotEmpty ||
              _statusFilter != null ||
              _categoryFilter != null;
          final groupedTickets = _groupTicketsByStatus(filteredTickets);
          final sortedGroupKeys = _sortedGroupKeys(groupedTickets);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _TicketFilters(
                  controller: _searchController,
                  statusFilter: _statusFilter,
                  categoryFilter: _categoryFilter,
                  statusOptions: statusOptions,
                  categoryOptions: categoryOptions,
                  filteredCount: filteredTickets.length,
                  totalCount: state.tickets.length,
                  hasActiveFilters: hasActiveFilters,
                  onSearchChanged: (_) => setState(() {}),
                  onStatusSelected: (status) {
                    setState(() => _statusFilter = status);
                  },
                  onCategorySelected: (category) {
                    setState(() => _categoryFilter = category);
                  },
                  onClear: _clearFilters,
                ),
                const SizedBox(height: AppSpacing.md),
                if (filteredTickets.isEmpty)
                  SisEmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'Nenhum chamado nos filtros',
                    message:
                        'Ajuste a busca ou limpe os filtros para ver a lista completa.',
                    actionLabel: 'Limpar filtros',
                    onAction: _clearFilters,
                  )
                else
                  for (final groupKey in sortedGroupKeys) ...[
                    _TicketGroup(
                      label: _groupLabel(groupedTickets[groupKey]!.first),
                      tickets: groupedTickets[groupKey]!,
                      appState: state,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TicketFilters extends StatelessWidget {
  const _TicketFilters({
    required this.controller,
    required this.statusFilter,
    required this.categoryFilter,
    required this.statusOptions,
    required this.categoryOptions,
    required this.filteredCount,
    required this.totalCount,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onStatusSelected,
    required this.onCategorySelected,
    required this.onClear,
  });

  final TextEditingController controller;
  final String? statusFilter;
  final String? categoryFilter;
  final List<String> statusOptions;
  final List<String> categoryOptions;
  final int filteredCount;
  final int totalCount;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onStatusSelected;
  final ValueChanged<String?> onCategorySelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar chamado, categoria ou requerente',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar busca',
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PopupMenuButton<String?>(
                tooltip: 'Filtrar por status',
                initialValue: statusFilter,
                onSelected: onStatusSelected,
                itemBuilder: (context) => [
                  const PopupMenuItem<String?>(
                    value: null,
                    child: Text('Todos os status'),
                  ),
                  for (final status in statusOptions)
                    PopupMenuItem<String?>(value: status, child: Text(status)),
                ],
                child: _FilterButton(
                  icon: Icons.filter_alt_outlined,
                  label: statusFilter ?? 'Todos os status',
                  active: statusFilter != null,
                ),
              ),
              PopupMenuButton<String?>(
                tooltip: 'Filtrar por categoria',
                initialValue: categoryFilter,
                onSelected: onCategorySelected,
                itemBuilder: (context) => [
                  const PopupMenuItem<String?>(
                    value: null,
                    child: Text('Todas as categorias'),
                  ),
                  for (final category in categoryOptions)
                    PopupMenuItem<String?>(
                      value: category,
                      child: Text(category),
                    ),
                ],
                child: _FilterButton(
                  icon: Icons.category_outlined,
                  label: categoryFilter ?? 'Todas as categorias',
                  active: categoryFilter != null,
                ),
              ),
              if (hasActiveFilters)
                IconButton(
                  tooltip: 'Limpar filtros',
                  onPressed: onClear,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                ),
              _ResultCount(
                filteredCount: filteredCount,
                totalCount: totalCount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.infoSoft : AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: active ? AppColors.info : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.filteredCount, required this.totalCount});

  final int filteredCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        '$filteredCount/$totalCount',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

class _TicketGroup extends StatelessWidget {
  const _TicketGroup({
    required this.label,
    required this.tickets,
    required this.appState,
  });

  final String label;
  final List<DticTicketSummary> tickets;
  final DticAppState appState;

  @override
  Widget build(BuildContext context) {
    final tone = AppStatusPalette.fromGlpiStatus(tickets.first.status);
    final visuals = AppStatusPalette.resolve(tone);

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          iconColor: visuals.foreground,
          collapsedIconColor: AppColors.textMuted,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textStrong,
                  ),
                ),
              ),
              SisStatusChip(label: '${tickets.length}', tone: tone),
            ],
          ),
          children: [
            for (final ticket in tickets)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: _TicketCard(
                  ticket: ticket,
                  surfaceColor: visuals.surface,
                  accentColor: visuals.foreground,
                  isUnread: appState.hasUnreadContent(
                    ticket.id,
                    ticket.updatedAt,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.surfaceColor,
    required this.accentColor,
    required this.isUnread,
  });

  final DticTicketSummary ticket;
  final Color surfaceColor;
  final Color accentColor;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final idLabel = ticket.id.length > 5
        ? ticket.id.substring(0, 5)
        : ticket.id;

    return Material(
      color: isUnread ? AppColors.brandSoft : surfaceColor,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      idLabel,
                      style: const TextStyle(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isUnread)
              Positioned(
                right: -2,
                top: -2,
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
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  if (ticket.status.isNotEmpty)
                    SisStatusChip(
                      label: ticket.statusLabel,
                      tone: AppStatusPalette.fromGlpiStatus(ticket.status),
                    ),
                  if (ticket.openedAt.isNotEmpty)
                    _MetaPill(
                      icon: Icons.schedule_outlined,
                      label: ticket.openedAt,
                    ),
                ],
              ),
              if (ticket.category.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ticket.category,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
              if (isUnread) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Nova atividade',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
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

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
