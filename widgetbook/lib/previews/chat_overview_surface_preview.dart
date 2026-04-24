import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_radius.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';
import 'package:sis_mobile_flutter/theme/app_status.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_empty_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_loading_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_page_scaffold.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_section_header.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_status_chip.dart';

import '../workbench_surface.dart';
import 'workbench_fixtures.dart';

enum ChatOverviewSurfaceVariant { populated, empty, loading }

class ChatOverviewSurfacePreview extends StatelessWidget {
  final ChatOverviewSurfaceVariant variant;
  final bool filterActive;

  const ChatOverviewSurfacePreview({
    super.key,
    required this.variant,
    this.filterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Conversas',
        subtitle: 'Tickets abertos com atividade nova e pendencias de resposta',
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              filterActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: filterActive ? AppColors.accent : Colors.white,
            ),
          ),
        ],
        body: switch (variant) {
          ChatOverviewSurfaceVariant.loading => const SisLoadingState(
            title: 'Carregando conversas',
            message:
                'Buscando tickets com interacao recente e mensagens nao lidas.',
          ),
          ChatOverviewSurfaceVariant.empty => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: const [
              SizedBox(
                height: 560,
                child: SisEmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'Nenhuma conversa ativa',
                  message:
                      'Os tickets abertos para interacao aparecerao aqui assim que houver nova atividade.',
                ),
              ),
            ],
          ),
          ChatOverviewSurfaceVariant.populated => _ChatOverviewPopulatedBody(
            filterActive: filterActive,
          ),
        },
      ),
    );
  }
}

class _ChatOverviewPopulatedBody extends StatelessWidget {
  final bool filterActive;

  const _ChatOverviewPopulatedBody({required this.filterActive});

  @override
  Widget build(BuildContext context) {
    final openChats = workbenchTickets
        .where(
          (ticket) => GlpiStatusMapper.isOpenForInteraction(ticket['status']),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        const SisSectionHeader(
          title: 'Conversas em andamento',
          subtitle:
              'Foco em tickets abertos, com destaque para atividade nova e contexto do servico.',
          trailing: SisStatusChip(label: '4 ativas', tone: AppStatusTone.info),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Expanded(
                  child: _ConversationMetric(
                    label: 'Com nova atividade',
                    value: '2',
                    tone: AppStatusTone.danger,
                  ),
                ),
                Container(
                  width: 1,
                  height: 42,
                  color: AppColors.border,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                ),
                const Expanded(
                  child: _ConversationMetric(
                    label: 'Aguardando retorno',
                    value: '1',
                    tone: AppStatusTone.warning,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (filterActive) ...[
          const SizedBox(height: AppSpacing.md),
          const Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              SisStatusChip(
                label: 'Categoria: Eletrica',
                tone: AppStatusTone.info,
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ...openChats.map((ticket) => _ConversationTile(ticket: ticket)),
      ],
    );
  }
}

class _ConversationMetric extends StatelessWidget {
  final String label;
  final String value;
  final AppStatusTone tone;

  const _ConversationMetric({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = AppStatusPalette.resolve(tone);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: visuals.foreground,
            shape: BoxShape.circle,
          ),
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
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const _ConversationTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isUnread = ticket['isUnread'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                    border: Border.all(color: AppColors.surface, width: 1.4),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          ticket['name']?.toString() ?? 'Sem assunto',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'ID: ${ticket['id']} - ${ticket['serviceName']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              ticket['lastUpdateLabel']?.toString() ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isUnread ? AppColors.danger : AppColors.textMuted,
                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: SisStatusChip(
          label: GlpiStatusMapper.label(ticket['status']),
          tone: AppStatusPalette.fromGlpiStatus(ticket['status']),
        ),
        onTap: () {},
      ),
    );
  }
}
