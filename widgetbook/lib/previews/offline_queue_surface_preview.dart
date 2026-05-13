import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_radius.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';
import 'package:sis_mobile_flutter/theme/app_status.dart';
import 'package:sis_mobile_flutter/widgets/ui/glpi_app_navigation.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_empty_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_loading_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_page_scaffold.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_section_header.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_status_chip.dart';

import '../workbench_surface.dart';
import 'workbench_fixtures.dart';

enum OfflineQueueSurfaceVariant { pending, syncing, error, empty }

class OfflineQueueSurfacePreview extends StatelessWidget {
  final OfflineQueueSurfaceVariant variant;

  const OfflineQueueSurfacePreview({super.key, required this.variant});

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Fila offline',
        subtitle: 'Pendencias locais e sincronizacao com o GLPI',
        bottomNavigationBar: GlpiAppNavigationBar(
          current: GlpiAppSection.offline,
          destinations: sisShellDestinations(
            pendingCount: variant == OfflineQueueSurfaceVariant.empty ? 0 : 2,
          ),
          onDestinationSelected: (_) {},
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
        body: switch (variant) {
          OfflineQueueSurfaceVariant.empty => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: const [
              SizedBox(
                height: 560,
                child: SisEmptyState(
                  icon: Icons.cloud_done_outlined,
                  title: 'Nenhuma pendencia offline',
                  message:
                      'Os chamados salvos localmente aparecerao aqui quando houver necessidade de sincronizacao.',
                ),
              ),
            ],
          ),
          OfflineQueueSurfaceVariant.syncing => const SisLoadingState(
            title: 'Sincronizando fila offline',
            message:
                'Enviando chamados locais e conciliando identificadores remotos.',
          ),
          _ => _OfflineQueueContent(variant: variant),
        },
      ),
    );
  }
}

class _OfflineQueueContent extends StatelessWidget {
  final OfflineQueueSurfaceVariant variant;

  const _OfflineQueueContent({required this.variant});

  @override
  Widget build(BuildContext context) {
    final hasError = variant == OfflineQueueSurfaceVariant.error;

    return ListView(
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
                      'Chamados aguardando envio remoto, contexto de entidade e situacao da ultima tentativa.',
                ),
                const SizedBox(height: AppSpacing.md),
                const Row(
                  children: [
                    Expanded(
                      child: _OfflineMetric(
                        label: 'Pendentes',
                        value: '2',
                        tone: AppStatusTone.warning,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _OfflineMetric(
                        label: 'Entidade ativa',
                        value: 'SIS',
                        tone: AppStatusTone.brand,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    const SisStatusChip(
                      label: 'Ultima tentativa ha 8 min',
                      tone: AppStatusTone.neutral,
                    ),
                    SisStatusChip(
                      label: hasError
                          ? 'Falha no ultimo envio'
                          : 'Pronto para sincronizar',
                      tone: hasError
                          ? AppStatusTone.danger
                          : AppStatusTone.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (hasError) ...[
          const _OfflineErrorBanner(),
          const SizedBox(height: AppSpacing.md),
        ],
        ...workbenchTickets
            .where((ticket) => ticket['pendingSync'] == true)
            .map((ticket) => _OfflineTicketCard(ticket: ticket)),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Sincronizar agora'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.list_alt_outlined),
                label: const Text('Ver meus chamados'),
              ),
            ),
          ],
        ),
      ],
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

class _OfflineErrorBanner extends StatelessWidget {
  const _OfflineErrorBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Falha na ultima sincronizacao',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'O GLPI rejeitou o envio por indisponibilidade momentanea. O chamado continua preservado no dispositivo.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineTicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const _OfflineTicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
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
                        ticket['name']?.toString() ?? 'Sem assunto',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'ID local: ${ticket['id']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
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
                _MiniPill(
                  label: ticket['serviceName']?.toString() ?? 'Servico',
                ),
                const _MiniPill(label: 'Entidade: Casa Civil RS'),
                Text(
                  ticket['lastUpdateLabel']?.toString() ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ],
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
