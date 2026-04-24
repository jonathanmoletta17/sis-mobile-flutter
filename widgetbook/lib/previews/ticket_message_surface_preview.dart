import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/models/ticket_message.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_radius.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';
import 'package:sis_mobile_flutter/theme/app_status.dart';
import 'package:sis_mobile_flutter/utils/avatar_colors.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_empty_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_loading_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_page_scaffold.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_status_chip.dart';

import '../workbench_surface.dart';
import 'workbench_fixtures.dart';

enum TicketMessageSurfaceVariant {
  active,
  solutionPending,
  closed,
  empty,
  loading,
  error,
}

class TicketMessageSurfacePreview extends StatelessWidget {
  final TicketMessageSurfaceVariant variant;

  const TicketMessageSurfacePreview({super.key, required this.variant});

  bool get _isClosed => variant == TicketMessageSurfaceVariant.closed;
  bool get _showError => variant == TicketMessageSurfaceVariant.error;
  bool get _showLoading => variant == TicketMessageSurfaceVariant.loading;
  bool get _showEmpty => variant == TicketMessageSurfaceVariant.empty;
  bool get _showPendingSolution =>
      variant == TicketMessageSurfaceVariant.solutionPending;

  List<TicketMessage> get _messages => _showPendingSolution
      ? workbenchPendingSolutionMessages
      : _isClosed
          ? workbenchConversationMessages
          : workbenchConversationMessages;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Chamado 8090',
        subtitle: _showPendingSolution
            ? 'Validacao de solucao pendente'
            : _isClosed
                ? 'Chamado fechado'
                : 'Conversa e anexos',
        floatingActionButton: (_showLoading || _showEmpty || _showError)
            ? null
            : FloatingActionButton.small(
                backgroundColor: AppColors.brand,
                onPressed: () {},
                child: const Icon(
                  Icons.arrow_downward,
                  color: AppColors.textInverse,
                ),
              ),
        body: Column(
          children: [
            Expanded(
              child: switch (variant) {
                TicketMessageSurfaceVariant.loading => const SizedBox(
                    height: 420,
                    child: SisLoadingState(
                      title: 'Carregando conversa',
                      message:
                          'Buscando followups, solucoes e anexos do ticket.',
                    ),
                  ),
                TicketMessageSurfaceVariant.error => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      SizedBox(
                        height: 420,
                        child: SisEmptyState(
                          icon: Icons.chat_bubble_outline,
                          title: 'Falha ao carregar a conversa',
                          message:
                              'Nao foi possivel buscar o historico do ticket agora. Revise a conexao e tente novamente.',
                          actionLabel: 'Tentar novamente',
                          onAction: () {},
                        ),
                      ),
                    ],
                  ),
                TicketMessageSurfaceVariant.empty => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: const [
                      SizedBox(
                        height: 420,
                        child: SisEmptyState(
                          icon: Icons.chat_bubble_outline,
                          title: 'Nenhuma mensagem ainda',
                          message:
                              'O historico da conversa aparecera aqui assim que houver interacoes no ticket.',
                        ),
                      ),
                    ],
                  ),
                _ => ListView.builder(
                    itemCount: _messages.length,
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.md,
                      bottom: 60,
                    ),
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      if (message.type == 'solution') {
                        return _SolutionCard(message: message);
                      }
                      if (message.type == 'attachment') {
                        return _AttachmentMessage(message: message);
                      }
                      return _TextMessage(message: message);
                    },
                  ),
              },
            ),
            if (_showPendingSolution) const _AttachmentPreview(),
            _InputArea(
              isClosed: _isClosed,
              isSending: false,
              solutionMode: false,
              pendingSolution: _showPendingSolution,
              disabled: _showLoading || _showError,
            ),
          ],
        ),
      ),
    );
  }
}

class _TextMessage extends StatelessWidget {
  final TicketMessage message;

  const _TextMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final avatarColor = AvatarColors.getColor(message.senderColorHash);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: avatarColor,
            child: Text(
              message.initials,
              style: const TextStyle(color: AppColors.textInverse),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.sender,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textStrong,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDateTime(message.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentMessage extends StatelessWidget {
  final TicketMessage message;

  const _AttachmentMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.brandSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.brandSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        color: AppColors.brandDark,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          message.content,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.open_in_new,
                          color: AppColors.brandDark,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Abrir anexo',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.brandDark,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDateTime(message.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolutionCard extends StatelessWidget {
  final TicketMessage message;

  const _SolutionCard({required this.message});

  @override
  Widget build(BuildContext context) {
    const tone = AppStatusTone.warning;
    final visuals = AppStatusPalette.resolve(tone);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Card(
        color: visuals.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: visuals.foreground.withValues(alpha: 0.16),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  topRight: Radius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: visuals.foreground,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Aguardando aprovacao',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: visuals.foreground,
                          ),
                    ),
                  ),
                  const SisStatusChip(
                    label: 'Pendente',
                    tone: AppStatusTone.warning,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tecnico: ${message.sender}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDateTime(message.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: AppColors.textInverse,
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Recusar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.textInverse,
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Aprovar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputArea extends StatelessWidget {
  final bool isClosed;
  final bool isSending;
  final bool solutionMode;
  final bool pendingSolution;
  final bool disabled;

  const _InputArea({
    required this.isClosed,
    required this.isSending,
    required this.solutionMode,
    required this.pendingSolution,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    if (isClosed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        color: AppColors.surfaceMuted,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              color: AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                'Chamado fechado. Novas interacoes desabilitadas.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            if (!pendingSolution)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: solutionMode
                        ? AppColors.brandSoft
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    solutionMode ? 'Solucionar chamado' : 'Acompanhamento',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: disabled ? null : () {},
                  icon: const Icon(Icons.add_circle_outline),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      enabled: !disabled,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: solutionMode
                            ? 'Descreva a solucao aplicada...'
                            : 'Mensagem...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                isSending
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton.filled(
                        onPressed: disabled ? null : () {},
                        style: IconButton.styleFrom(
                          backgroundColor:
                              solutionMode ? AppColors.brand : AppColors.info,
                          foregroundColor: AppColors.textInverse,
                        ),
                        icon: const Icon(Icons.send),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      color: AppColors.surfaceMuted,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Anexando:', style: Theme.of(context).textTheme.labelLarge),
          InputChip(
            avatar: const Icon(Icons.image_outlined, size: 16),
            label: const Text('Imagem'),
            onDeleted: () {},
          ),
          InputChip(
            avatar: const Icon(Icons.insert_drive_file_outlined, size: 16),
            label: const Text('Arquivo 1'),
            onDeleted: () {},
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime d) {
  return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
