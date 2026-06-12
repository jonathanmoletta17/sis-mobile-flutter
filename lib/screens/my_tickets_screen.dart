import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../catalog/service_catalog_provider.dart';
import '../models/glpi_status.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_status.dart';
import '../widgets/ui/glpi_app_navigation.dart';
import '../widgets/ui/sis_action_badge.dart';
import '../widgets/ui/sis_empty_state.dart';
import '../widgets/ui/sis_loading_state.dart';
import '../widgets/ui/sis_page_scaffold.dart';
import '../widgets/ui/sis_status_chip.dart';
import 'chat_overview_screen.dart';
import 'offline_queue_screen.dart';
import 'service_catalog_screen.dart';
import 'ticket_detail_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  Future<List<Map<String, dynamic>>>? _ticketsFuture;

  String? _selectedStatusFilter;
  String? _filterTicketId;
  String? _filterCategory;

  late final List<String> _statusOptions;
  late final List<String> _categoryOptions;

  void _openShellDestination(GlpiAppSection destination) {
    switch (destination) {
      case GlpiAppSection.services:
        replaceAppRoot(context, const ServiceCatalogScreen());
      case GlpiAppSection.tickets:
        return;
      case GlpiAppSection.conversations:
        replaceAppRoot(context, const ChatOverviewScreen());
      case GlpiAppSection.offline:
        replaceAppRoot(context, const OfflineQueueScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    _statusOptions = [
      'Todos',
      GlpiStatusMapper.offlineLabel,
      ...GlpiStatusMapper.ordered.map((s) => s.label),
    ];
    _categoryOptions =
        ['Todos'] +
        serviceCatalogRepository.services.map((s) => s.name).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTickets();
    });
  }

  void _loadTickets() {
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() {
      _ticketsFuture = appState.fetchTickets();
    });
  }

  Future<void> _handleRefresh() async {
    _loadTickets();
    if (_ticketsFuture != null) {
      await _ticketsFuture;
    }
  }

  String _statusLabel(dynamic rawStatus) {
    return GlpiStatusMapper.label(rawStatus);
  }

  int _groupSortWeight(String key) {
    if (key == 'offline') return 0;
    if (key == 'operational') return 1;
    if (key.startsWith('status_')) {
      final code = int.tryParse(key.replaceFirst('status_', ''));
      if (code != null) return code + 10;
    }
    return 999;
  }

  String _groupKey(Map<String, dynamic> ticket) {
    if (ticket['_source'] == 'operational') return 'operational';
    final rawStatus = ticket['status'];
    if (GlpiStatusMapper.isOffline(rawStatus)) return 'offline';
    final code = GlpiStatusMapper.code(rawStatus);
    if (code != null) return 'status_$code';
    return 'other_${_statusLabel(rawStatus)}';
  }

  bool _matchesStatusFilter(Map<String, dynamic> ticket) {
    if (_selectedStatusFilter == null) return true;
    return _statusLabel(ticket['status']) == _selectedStatusFilter;
  }

  String _operationalSubtitle(Map<String, dynamic> ticket) {
    final requester = ticket['users_id_recipient']?.toString().trim();
    final service = ticket['serviceName']?.toString().trim();
    if (requester != null && requester.isNotEmpty && service != null && service.isNotEmpty) {
      return '$requester • $service';
    }
    return requester ?? service ?? 'N/A';
  }

  void _showFilterDialog() {
    String? tempStatus = _selectedStatusFilter;
    String? tempTicketId = _filterTicketId;
    String? tempCategory = _filterCategory;

    final idController = TextEditingController(text: tempTicketId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar Chamados'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: tempStatus ?? 'Todos',
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      items: _statusOptions
                          .map(
                            (String status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          tempStatus = newValue == 'Todos' ? null : newValue;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Número do Chamado:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: idController,
                      decoration: const InputDecoration(
                        hintText: 'ID, OFFLINE-1...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) {
                        tempTicketId = value.isEmpty ? null : value;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Categoria:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: tempCategory ?? 'Todos',
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      items: _categoryOptions
                          .map(
                            (String category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          tempCategory = newValue == 'Todos' ? null : newValue;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Limpar tudo'),
              onPressed: () {
                idController.clear();
                setState(() {
                  _filterTicketId = null;
                  _filterCategory = null;
                  _selectedStatusFilter = null;
                });
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Pesquisar'),
              onPressed: () {
                setState(() {
                  _selectedStatusFilter = tempStatus;
                  _filterTicketId = tempTicketId;
                  _filterCategory = tempCategory;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isFilterActive =
        _selectedStatusFilter != null ||
        _filterTicketId != null ||
        _filterCategory != null;

    return SisPageScaffold(
      title: 'Meus Chamados',
      subtitle: 'Acompanhe status, filtros e pendências de sincronização',
      bottomNavigationBar: GlpiAppNavigationBar(
        current: GlpiAppSection.tickets,
        destinations: sisShellDestinations(
          pendingCount: appState.pendingTickets.length,
        ),
        onDestinationSelected: _openShellDestination,
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFilterActive ? Icons.filter_alt : Icons.filter_alt_outlined,
            color: isFilterActive ? AppColors.accent : Colors.white,
          ),
          onPressed: _showFilterDialog,
        ),
        if (appState.pendingTickets.isNotEmpty)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.cloud_upload_outlined),
                tooltip: 'Abrir fila offline',
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => const OfflineQueueScreen(),
                        ),
                      )
                      .then((_) => _loadTickets());
                },
              ),
              Positioned(
                right: 6,
                top: 8,
                child: SisActionBadge(count: appState.pendingTickets.length),
              ),
            ],
          ),
      ],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SisLoadingState(
              title: 'Carregando chamados',
              message: 'Sincronizando sua fila e agrupando por status.',
            );
          }

          if (snapshot.hasError) {
            return SisEmptyState(
              icon: Icons.error_outline,
              title: 'Falha ao carregar chamados',
              message: '${snapshot.error}',
              actionLabel: 'Tentar novamente',
              onAction: _loadTickets,
            );
          }

          final tickets = snapshot.data ?? [];
          Iterable<Map<String, dynamic>> filtered = tickets;

          filtered = filtered.where(_matchesStatusFilter);

          if (_filterTicketId != null && _filterTicketId!.isNotEmpty) {
            final filterId = _filterTicketId!.toLowerCase();
            filtered = filtered.where(
              (t) => t['id'].toString().toLowerCase().contains(filterId),
            );
          }

          if (_filterCategory != null) {
            final filterCategory = _filterCategory!;
            filtered = filtered.where(
              (t) => t['serviceName'].toString() == filterCategory,
            );
          }

          final filteredList = filtered.toList();
          final groupedTickets = <String, List<Map<String, dynamic>>>{};
          final groupLabelByKey = <String, String>{};

          for (final ticket in filteredList) {
            final key = _groupKey(ticket);
            groupedTickets.putIfAbsent(key, () => []);
            groupedTickets[key]!.add(ticket);
            groupLabelByKey[key] = key == 'operational'
                ? 'Fila Operacional'
                : _statusLabel(ticket['status']);
          }

          final sortedGroupKeys = groupedTickets.keys.toList()
            ..sort((a, b) {
              final wa = _groupSortWeight(a);
              final wb = _groupSortWeight(b);
              if (wa != wb) return wa.compareTo(wb);
              final la = groupLabelByKey[a] ?? a;
              final lb = groupLabelByKey[b] ?? b;
              return la.compareTo(lb);
            });

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.brand,
            child: filteredList.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: SisEmptyState(
                          icon: isFilterActive
                              ? Icons.search_off_outlined
                              : Icons.list_alt_outlined,
                          title: isFilterActive
                              ? 'Nenhum chamado com estes filtros'
                              : 'Nenhum chamado encontrado',
                          message: isFilterActive
                              ? 'Revise os filtros aplicados para continuar.'
                              : 'Abra um novo chamado a partir do catálogo principal.',
                          actionLabel: isFilterActive ? 'Limpar filtros' : null,
                          onAction: isFilterActive
                              ? () {
                                  setState(() {
                                    _selectedStatusFilter = null;
                                    _filterTicketId = null;
                                    _filterCategory = null;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    itemCount: sortedGroupKeys.length,
                    itemBuilder: (context, index) {
                      final groupKey = sortedGroupKeys[index];
                      final ticketsInGroup = groupedTickets[groupKey]!;
                      final statusGroup = groupLabelByKey[groupKey] ?? groupKey;
                      final isOperational = groupKey == 'operational';
                      final tone = isOperational
                          ? AppStatusTone.brand
                          : AppStatusPalette.fromGlpiStatus(
                              ticketsInGroup.first['status'],
                            );
                      final visuals = AppStatusPalette.resolve(tone);
                      final baseColor = isOperational
                          ? AppColors.accentSoft
                          : visuals.surface;
                      final badgeColor = isOperational
                          ? AppColors.catalogOperational
                          : visuals.foreground;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Card(
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: badgeColor,
                              collapsedIconColor: AppColors.textMuted,
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      statusGroup,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.textStrong,
                                          ),
                                    ),
                                  ),
                                  SisStatusChip(
                                    label: '${ticketsInGroup.length}',
                                    tone: tone,
                                  ),
                                ],
                              ),
                              children: ticketsInGroup.map((ticket) {
                                final idString =
                                    ticket['id']?.toString() ?? '??';
                                final displayId = idString.contains('OFFLINE')
                                    ? 'OFF'
                                    : idString;
                                final titulo =
                                    ticket['name'] ??
                                    ticket['assunto'] ??
                                    'Sem Assunto';

                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.md,
                                    0,
                                    AppSpacing.md,
                                    AppSpacing.sm,
                                  ),
                                  child: Material(
                                    color: baseColor,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: AppSpacing.xs,
                                          ),
                                      leading: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: badgeColor,
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.sm,
                                          ),
                                        ),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                4.0,
                                              ),
                                              child: Text(
                                                displayId,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        titulo,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: AppColors.textStrong,
                                            ),
                                      ),
                                      subtitle: Text(
                                        isOperational
                                            ? _operationalSubtitle(ticket)
                                            : 'Serviço: ${ticket['serviceName'] ?? 'N/A'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textMuted,
                                            ),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                        color: AppColors.textMuted,
                                      ),
                                      onTap: () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TicketDetailScreen(
                                                  ticket: ticket,
                                                ),
                                          ),
                                        );
                                        _loadTickets();
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
