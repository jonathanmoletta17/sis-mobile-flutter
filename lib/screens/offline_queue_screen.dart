import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/glpi_ticket.dart';
import '../state/app_state.dart';
import '../state/app_state_ticket_support.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_status.dart';
import '../widgets/ui/sis_empty_state.dart';
import '../widgets/ui/sis_page_scaffold.dart';
import '../widgets/ui/sis_section_header.dart';
import '../widgets/ui/sis_status_chip.dart';
import 'my_tickets_screen.dart';
import 'ticket_detail_screen.dart';

class OfflineQueueScreen extends StatefulWidget {
  const OfflineQueueScreen({super.key});

  @override
  State<OfflineQueueScreen> createState() => _OfflineQueueScreenState();
}

class _OfflineQueueScreenState extends State<OfflineQueueScreen> {
  bool _isSynchronizing = false;
  String? _syncFeedbackMessage;
  AppStatusTone _syncFeedbackTone = AppStatusTone.neutral;

  Future<void> _synchronizeQueue() async {
    if (_isSynchronizing) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final initialCount = appState.pendingTickets.length;
    if (initialCount == 0) {
      setState(() {
        _syncFeedbackMessage = 'Nenhuma pendência offline para sincronizar.';
        _syncFeedbackTone = AppStatusTone.neutral;
      });
      return;
    }

    setState(() {
      _isSynchronizing = true;
      _syncFeedbackMessage = null;
    });

    try {
      final syncedCount = await appState.synchronizeTickets();
      final remainingCount = appState.pendingTickets.length;

      final message = remainingCount == 0
          ? '$syncedCount chamado(s) offline sincronizado(s) com sucesso.'
          : '$syncedCount chamado(s) sincronizado(s); $remainingCount ainda aguardam nova tentativa.';

      final tone = remainingCount == 0
          ? AppStatusTone.success
          : AppStatusTone.warning;

      if (!mounted) return;

      setState(() {
        _syncFeedbackMessage = message;
        _syncFeedbackTone = tone;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: remainingCount == 0
              ? AppColors.success
              : AppColors.warning,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      const message =
          'Falha ao sincronizar a fila offline. Revise a conectividade e tente novamente.';

      setState(() {
        _syncFeedbackMessage = message;
        _syncFeedbackTone = AppStatusTone.danger;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSynchronizing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final pendingTickets = appState.pendingTickets;
    final offlineViews = AppStateTicketSupport.buildOfflineTickets(
      pendingTickets,
    );
    final attachmentCount = pendingTickets
        .where((ticket) => (ticket.anexoPath ?? '').trim().isNotEmpty)
        .length;

    return SisPageScaffold(
      title: 'Fila offline',
      subtitle: 'Pendências locais e sincronização com o GLPI',
      actions: [
        IconButton(
          onPressed: _isSynchronizing ? null : _synchronizeQueue,
          tooltip: 'Sincronizar fila offline',
          icon: _isSynchronizing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textInverse,
                  ),
                )
              : const Icon(Icons.cloud_upload_outlined),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SisSectionHeader(
                    title: 'Resumo da fila local',
                    subtitle:
                        'Chamados preservados no dispositivo aguardando envio para o GLPI.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _OfflineMetric(
                          label: 'Pendentes',
                          value: '${pendingTickets.length}',
                          tone: pendingTickets.isEmpty
                              ? AppStatusTone.neutral
                              : AppStatusTone.warning,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _OfflineMetric(
                          label: 'Com anexo',
                          value: '$attachmentCount',
                          tone: attachmentCount == 0
                              ? AppStatusTone.neutral
                              : AppStatusTone.brand,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      SisStatusChip(
                        label:
                            appState.selectedTicketEntityName ??
                            appState.activeEntityName ??
                            'Entidade não definida',
                        tone: AppStatusTone.brand,
                      ),
                      SisStatusChip(
                        label: pendingTickets.isEmpty
                            ? 'Sem pendências'
                            : 'Pronto para sincronizar',
                        tone: pendingTickets.isEmpty
                            ? AppStatusTone.neutral
                            : AppStatusTone.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSynchronizing
                              ? null
                              : _synchronizeQueue,
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Sincronizar agora'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MyTicketsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.list_alt_outlined),
                          label: const Text('Meus chamados'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_syncFeedbackMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            _OfflineFeedbackBanner(
              message: _syncFeedbackMessage!,
              tone: _syncFeedbackTone,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (pendingTickets.isEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.58,
              child: SisEmptyState(
                icon: Icons.cloud_done_outlined,
                title: 'Nenhuma pendência offline',
                message:
                    'Os chamados salvos localmente aparecerão aqui quando houver necessidade de sincronização.',
                actionLabel: 'Abrir meus chamados',
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
                  );
                },
              ),
            )
          else ...[
            const SisSectionHeader(
              title: 'Chamados pendentes',
              subtitle:
                  'Revise o conteúdo local antes de disparar uma nova tentativa de sincronização.',
            ),
            const SizedBox(height: AppSpacing.md),
            for (var index = 0; index < pendingTickets.length; index++)
              _OfflineTicketCard(
                ticket: pendingTickets[index],
                ticketView: offlineViews[index],
              ),
          ],
        ],
      ),
    );
  }
}

class _OfflineMetric extends StatelessWidget {
  final String label;
  final String value;
  final AppStatusTone tone;

  const _OfflineMetric({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = AppStatusPalette.resolve(tone);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: visuals.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: visuals.foreground),
          ),
        ],
      ),
    );
  }
}

class _OfflineFeedbackBanner extends StatelessWidget {
  final String message;
  final AppStatusTone tone;

  const _OfflineFeedbackBanner({required this.message, required this.tone});

  @override
  Widget build(BuildContext context) {
    final visuals = AppStatusPalette.resolve(tone);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: visuals.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: visuals.foreground.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: visuals.foreground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textStrong),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineTicketCard extends StatelessWidget {
  final GlpiTicket ticket;
  final Map<String, dynamic> ticketView;

  const _OfflineTicketCard({required this.ticket, required this.ticketView});

  @override
  Widget build(BuildContext context) {
    final entityLabel = (ticket.entityName ?? '').trim();
    final locationLabel = ticket.localizacao.trim();
    final urgencyLabel = (ticket.urgencia ?? '').trim();
    final hasAttachment = (ticket.anexoPath ?? '').trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TicketDetailScreen(ticket: ticketView),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.assunto.trim().isEmpty
                                ? 'Sem assunto'
                                : ticket.assunto,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            ticketView['id']?.toString() ?? 'OFFLINE',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const SisStatusChip(
                      label: 'Offline',
                      tone: AppStatusTone.warning,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _MiniPill(label: ticket.serviceName),
                    if (entityLabel.isNotEmpty) _MiniPill(label: entityLabel),
                    if (locationLabel.isNotEmpty)
                      _MiniPill(label: locationLabel),
                    if (urgencyLabel.isNotEmpty)
                      _MiniPill(label: 'Urgência: $urgencyLabel'),
                    if (hasAttachment) const _MiniPill(label: 'Com anexo'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;

  const _MiniPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textStrong,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
