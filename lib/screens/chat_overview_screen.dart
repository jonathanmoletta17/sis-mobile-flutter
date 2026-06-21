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
import '../widgets/ui/sis_empty_state.dart';
import '../widgets/ui/sis_loading_state.dart';
import '../widgets/ui/sis_page_scaffold.dart';
import '../widgets/ui/sis_status_chip.dart';
import 'my_tickets_screen.dart';
import 'offline_queue_screen.dart';
import 'service_catalog_screen.dart';
import 'ticket_message_screen.dart';

class ChatOverviewScreen extends StatefulWidget {
  const ChatOverviewScreen({super.key});

  @override
  State<ChatOverviewScreen> createState() => _ChatOverviewScreenState();
}

class _ChatOverviewScreenState extends State<ChatOverviewScreen> {
  String? _filterTicketId;
  String? _filterCategory;

  late final List<String> _categoryOptions;
  late Future<List<Map<String, dynamic>>> _futureTickets;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void _openShellDestination(GlpiAppSection destination) {
    switch (destination) {
      case GlpiAppSection.services:
        replaceAppRoot(context, const ServiceCatalogScreen());
      case GlpiAppSection.tickets:
        replaceAppRoot(context, const MyTicketsScreen());
      case GlpiAppSection.conversations:
        return;
      case GlpiAppSection.offline:
        replaceAppRoot(context, const OfflineQueueScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    _categoryOptions =
        ['Todos'] +
        serviceCatalogRepository.services.map((s) => s.name).toList();
    _loadInitialData();
  }

  void _loadInitialData() {
    final appState = Provider.of<AppState>(context, listen: false);
    _futureTickets = appState.fetchTickets();
  }

  Future<void> _refreshTickets() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final tickets = await appState.fetchTickets();
    if (!mounted) return;
    setState(() {
      _futureTickets = Future.value(tickets);
    });
  }

  bool _isTicketOpen(dynamic rawStatus) {
    return GlpiStatusMapper.isOpenForInteraction(rawStatus);
  }

  Widget _buildStatusIndicator(dynamic rawStatus) {
    return SisStatusChip(
      label: GlpiStatusMapper.label(rawStatus),
      tone: AppStatusPalette.fromGlpiStatus(rawStatus),
    );
  }

  void _showFilterDialog() {
    String? tempTicketId = _filterTicketId;
    String? tempCategory = _filterCategory;

    final idController = TextEditingController(text: tempTicketId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar Conversas'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Número do Chamado:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
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
                    const SizedBox(height: AppSpacing.xs),
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
              child: const Text('Limpar Tudo'),
              onPressed: () {
                idController.clear();
                setState(() {
                  _filterTicketId = null;
                  _filterCategory = null;
                });
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Pesquisar'),
              onPressed: () {
                setState(() {
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
    final isFilterActive = _filterTicketId != null || _filterCategory != null;

    return SisPageScaffold(
      title: 'Conversas',
      subtitle: 'Monitore atividade recente e acompanhe tickets abertos',
      bottomNavigationBar: GlpiAppNavigationBar(
        current: GlpiAppSection.conversations,
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
      ],
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshTickets,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureTickets,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 420,
                    child: SisLoadingState(
                      title: 'Carregando conversas',
                      message: 'Buscando tickets com interação em andamento.',
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: SisEmptyState(
                      icon: Icons.chat_outlined,
                      title: 'Erro ao carregar conversas',
                      message: '${snapshot.error}',
                      actionLabel: 'Tentar novamente',
                      onAction: _refreshTickets,
                    ),
                  ),
                ],
              );
            }

            final allTickets = snapshot.data ?? [];

            Iterable<Map<String, dynamic>> filtered = allTickets.where(
              (t) =>
                  _isTicketOpen(t['status']) ||
                  GlpiStatusMapper.isSolved(t['status']),
            );

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

            final openChats = filtered.toList();

            if (openChats.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: SisEmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: isFilterActive
                          ? 'Nenhuma conversa com estes filtros'
                          : 'Nenhuma conversa ativa',
                      message: isFilterActive
                          ? 'Revise os filtros para encontrar a conversa desejada.'
                          : 'As conversas abertas aparecerão aqui assim que houver tickets em andamento.',
                      actionLabel: isFilterActive ? 'Limpar filtros' : null,
                      onAction: isFilterActive
                          ? () {
                              setState(() {
                                _filterTicketId = null;
                                _filterCategory = null;
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              itemCount: openChats.length,
              itemBuilder: (context, index) {
                final ticket = openChats[index];
                final ticketId = ticket['id']?.toString() ?? 'N/A';
                final assunto =
                    ticket['name']?.toString() ??
                    ticket['assunto']?.toString() ??
                    'Sem Assunto';

                final dateMod = ticket['date_mod']?.toString();

                final isUnread = appState.hasUnreadContent(ticketId, dateMod);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  color: isUnread ? AppColors.brandSoft : AppColors.surface,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    leading: Stack(
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
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      assunto,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: isUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'ID: $ticketId - ${ticket['serviceName'] ?? ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (isUnread)
                          Text(
                            'Nova atividade',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                      ],
                    ),
                    trailing: _buildStatusIndicator(ticket['status']),
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await appState.markTicketAsRead(ticketId);

                      if (!mounted) return;
                      await navigator.push(
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketMessageScreen(ticketId: ticketId),
                        ),
                      );

                      if (!mounted) return;
                      _refreshTickets();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
