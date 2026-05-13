import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_radius.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';
import 'package:sis_mobile_flutter/theme/app_status.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_empty_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_page_scaffold.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_section_header.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_status_chip.dart';
import 'package:sis_mobile_flutter/utils/ticket_form_summary.dart';

import '../workbench_surface.dart';
import 'workbench_fixtures.dart';

enum TicketDetailSurfaceVariant {
  operatorView,
  requesterView,
  offline,
  attachmentsLoading,
  attachmentsError,
}

class TicketDetailSurfacePreview extends StatelessWidget {
  final TicketDetailSurfaceVariant variant;

  const TicketDetailSurfacePreview({super.key, required this.variant});

  bool get _showStatusActions =>
      variant == TicketDetailSurfaceVariant.operatorView ||
      variant == TicketDetailSurfaceVariant.attachmentsLoading ||
      variant == TicketDetailSurfaceVariant.attachmentsError;

  bool get _showLinearLoading =>
      variant == TicketDetailSurfaceVariant.attachmentsLoading;

  bool get _isOffline => variant == TicketDetailSurfaceVariant.offline;

  String get _ticketId =>
      _isOffline ? 'OFFLINE-2' : workbenchDetailTicket['id'].toString();

  String get _serviceName => _isOffline
      ? 'Marcenaria'
      : workbenchDetailTicket['serviceName'].toString();

  String get _statusLabel => _isOffline ? 'Offline' : 'Em Atendimento';

  AppStatusTone get _statusTone =>
      _isOffline ? AppStatusTone.danger : AppStatusTone.info;

  String get _categoryLabel => _isOffline
      ? 'Predial > Marcenaria > Ajustes'
      : 'Predial > Eletrica > Iluminacao';

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Chamado $_ticketId',
        subtitle: _serviceName,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isOffline
                                    ? 'Ajuste de fechadura no almoxarifado'
                                    : workbenchDetailTicket['assunto']
                                          .toString(),
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _isOffline
                                    ? 'Fila local • aguardando sincronizacao'
                                    : 'Fila Predial • atendimento presencial',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        SisStatusChip(label: _statusLabel, tone: _statusTone),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _MetaPill(
                          icon: Icons.confirmation_number_outlined,
                          label: 'ID $_ticketId',
                        ),
                        _MetaPill(
                          icon: Icons.category_outlined,
                          label: _categoryLabel,
                        ),
                      ],
                    ),
                    if (_showLinearLoading) ...[
                      const SizedBox(height: AppSpacing.md),
                      const LinearProgressIndicator(minHeight: 3),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Abrir conversa'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_showStatusActions) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SisSectionHeader(
                        title: 'Acoes de status',
                        subtitle:
                            'Atualize o andamento ou encaminhe o chamado para solucao formal.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.info,
                              ),
                              child: const Text('Em Atendimento'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brand,
                              ),
                              child: const Text('Solucionado'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SisSectionHeader(title: 'Descricao detalhada'),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _isOffline
                          ? 'Solicitacao salva no dispositivo para ajuste de fechadura no almoxarifado. Abertura sera enviada ao GLPI assim que houver conectividade.'
                          : workbenchDetailTicket['descricao'].toString(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SisSectionHeader(
                      title: _isOffline
                          ? 'Anexos do chamado'
                          : 'Anexos do chamado',
                      subtitle: _isOffline
                          ? 'Documentos remotos ficam disponiveis somente apos sincronizacao.'
                          : 'Superficie pensada para imagens, comprovantes e documentos de apoio.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AttachmentState(variant: variant),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SisSectionHeader(
                      title: 'Outros detalhes',
                      subtitle:
                          'Resumo operacional e metadados persistentes do chamado.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...workbenchDetailRows.map(
                      (entry) => _DetailRow(
                        label: entry.key,
                        value: entry.value,
                        rich: entry.key == 'Resumo do Atendimento',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        title: Text(
                          'Metadados GLPI',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        children: workbenchMetadataRows
                            .map(
                              (entry) => _DetailRow(
                                label: entry.key,
                                value: entry.value,
                                rich: false,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentState extends StatelessWidget {
  final TicketDetailSurfaceVariant variant;

  const _AttachmentState({required this.variant});

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case TicketDetailSurfaceVariant.offline:
        return const SisEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Chamado offline',
          message:
              'Anexos remotos ficam disponiveis apenas para chamados sincronizados.',
        );
      case TicketDetailSurfaceVariant.attachmentsLoading:
        return const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        );
      case TicketDetailSurfaceVariant.attachmentsError:
        return const SisEmptyState(
          icon: Icons.attachment_outlined,
          title: 'Falha ao carregar anexos',
          message:
              'Nao foi possivel consultar os documentos do chamado agora. Tente novamente apos atualizar a tela.',
        );
      case TicketDetailSurfaceVariant.operatorView:
      case TicketDetailSurfaceVariant.requesterView:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.brandSoft, AppColors.surfaceMuted],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: AppColors.brandDark,
                      size: 40,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Preview de imagem vinculada ao chamado',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file_outlined,
                    color: AppColors.brandDark,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'laudo-iluminacao-corredor-norte.pdf',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Abrir')),
                ],
              ),
            ),
          ],
        );
    }
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.brandDark),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool rich;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.rich,
  });

  @override
  Widget build(BuildContext context) {
    final summary = TicketFormSummary.parse(value);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xxs),
          if (!rich)
            Text(value, style: Theme.of(context).textTheme.bodyLarge)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (summary.description.isNotEmpty) ...[
                  Text(
                    summary.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textStrong,
                      height: 1.4,
                    ),
                  ),
                  if (summary.fields.isNotEmpty)
                    const SizedBox(height: AppSpacing.sm),
                ],
                ...summary.fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 128,
                          child: Text(
                            field.label,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            field.value,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textStrong,
                                  height: 1.3,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}
