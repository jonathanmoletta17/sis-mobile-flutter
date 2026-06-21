import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../models/glpi_status.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_status.dart';
import '../../utils/file_validator.dart';
import '../../utils/ticket_form_summary.dart';
import '../../widgets/ui/sis_empty_state.dart';
import '../../widgets/ui/sis_loading_state.dart';
import '../../widgets/ui/sis_page_scaffold.dart';
import '../../widgets/ui/sis_section_header.dart';
import '../../widgets/ui/sis_status_chip.dart';
import '../config/dtic_config.dart';
import '../models/dtic_ticket_models.dart';
import '../state/dtic_app_state.dart';

class DticTicketDetailScreen extends StatefulWidget {
  const DticTicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<DticTicketDetailScreen> createState() => _DticTicketDetailScreenState();
}

class _DticTicketDetailScreenState extends State<DticTicketDetailScreen> {
  late Future<_TicketDetailBundle> _future;
  final Map<String, Future<Uint8List?>> _imagePreviewFutures = {};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TicketDetailBundle> _load() async {
    final state = context.read<DticAppState>();
    final results = await Future.wait([
      state.fetchTicketDetail(widget.ticketId),
      state.fetchTicketInteractions(widget.ticketId),
    ]);
    final interactions = results[1] as List<DticTicketInteraction>;
    final documents = await state.fetchTicketDocuments(
      widget.ticketId,
      interactions: interactions,
    );
    return _TicketDetailBundle(
      detail: results[0] as DticTicketDetail,
      interactions: interactions,
      documents: documents,
    );
  }

  void _refresh() {
    _imagePreviewFutures.clear();
    setState(() => _future = _load());
  }

  Future<Uint8List?> _imagePreview(DticTicketDocument document) {
    if (!document.mime.toLowerCase().startsWith('image/')) {
      return Future<Uint8List?>.value();
    }

    return _imagePreviewFutures.putIfAbsent(document.id, () async {
      final bytes = await context.read<DticAppState>().downloadDocument(
        document,
      );
      if (bytes.isEmpty) return null;
      return Uint8List.fromList(bytes);
    });
  }

  Future<void> _openDocument(DticTicketDocument document) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        SnackBar(content: Text('Baixando ${document.name}...')),
      );
      final bytes = await context.read<DticAppState>().downloadDocument(
        document,
      );
      final tempDir = await getTemporaryDirectory();
      final safeName = document.name.replaceAll(RegExp(r'[\\/]'), '_');
      final file = File('${tempDir.path}/$safeName');
      await file.writeAsBytes(bytes, flush: true);
      final result = await OpenFilex.open(file.path);
      if (!mounted) return;
      if (result.type != ResultType.done) {
        messenger.showSnackBar(
          SnackBar(content: Text('Nao foi possivel abrir: ${result.message}')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Falha ao baixar anexo: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SisPageScaffold(
      title: 'Chamado #${widget.ticketId}',
      subtitle: DticConfig.ticketActionsEnabled
          ? 'Atendimento DTIC'
          : 'Historico e anexos',
      actions: [
        IconButton(
          tooltip: 'Atualizar',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: FutureBuilder<_TicketDetailBundle>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SisLoadingState(
              title: 'Carregando chamado',
              message: 'Buscando detalhe, mensagens, solucoes e anexos.',
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return SisEmptyState(
              icon: Icons.error_outline,
              title: 'Falha ao carregar chamado',
              message: snapshot.error?.toString() ?? 'Resposta vazia do GLPI.',
              actionLabel: 'Tentar novamente',
              onAction: _refresh,
            );
          }

          final bundle = snapshot.data!;
          final capabilities = _DtcTicketCapabilities.from(
            detail: bundle.detail,
            profile: context.read<DticAppState>().profile,
          );
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _DetailHeader(detail: bundle.detail, capabilities: capabilities),
              if (capabilities.canShowActionPanel) ...[
                const SizedBox(height: AppSpacing.md),
                _TicketActionPanel(
                  detail: bundle.detail,
                  capabilities: capabilities,
                  onChanged: _refresh,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (bundle.documents.isNotEmpty) ...[
                const SisSectionHeader(title: 'Anexos'),
                const SizedBox(height: AppSpacing.sm),
                for (final document in bundle.documents)
                  _DocumentCard(
                    document: document,
                    onOpen: () => _openDocument(document),
                    loadImagePreview: () => _imagePreview(document),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],
              const SisSectionHeader(title: 'Historico'),
              const SizedBox(height: AppSpacing.sm),
              if (bundle.interactions.isEmpty)
                const SisEmptyState(
                  icon: Icons.forum_outlined,
                  title: 'Sem interacoes',
                  message: 'Nenhuma mensagem ou solucao foi retornada.',
                )
              else
                for (final interaction in bundle.interactions)
                  _InteractionCard(interaction: interaction),
            ],
          );
        },
      ),
    );
  }
}

enum _DtcActionMode { message, solution }

class _DtcTicketCapabilities {
  const _DtcTicketCapabilities({
    required this.ticketActionsEnabled,
    required this.isOpenForInteraction,
    required this.isRequesterProfile,
  });

  final bool ticketActionsEnabled;
  final bool isOpenForInteraction;
  final bool isRequesterProfile;

  bool get canShowActionPanel => canSendMessage || canSendSolution;
  bool get canSendMessage => ticketActionsEnabled && isOpenForInteraction;
  bool get canSendSolution =>
      ticketActionsEnabled && isOpenForInteraction && !isRequesterProfile;
  bool get canUpdateStatus =>
      ticketActionsEnabled && isOpenForInteraction && !isRequesterProfile;

  String get label {
    if (!isOpenForInteraction) return 'Chamado encerrado';
    if (ticketActionsEnabled) return 'Acoes habilitadas';
    return 'Historico e anexos';
  }

  AppStatusTone get tone {
    if (!isOpenForInteraction) return AppStatusTone.neutral;
    if (ticketActionsEnabled) return AppStatusTone.info;
    return AppStatusTone.neutral;
  }

  factory _DtcTicketCapabilities.from({
    required DticTicketDetail detail,
    required String? profile,
  }) {
    final normalizedProfile = profile?.toLowerCase() ?? '';
    final isRequesterProfile =
        normalizedProfile.contains('self-service') ||
        normalizedProfile.contains('post-only') ||
        normalizedProfile.contains('requerente') ||
        normalizedProfile.contains('solicitante');

    return _DtcTicketCapabilities(
      ticketActionsEnabled: DticConfig.ticketActionsEnabled,
      isOpenForInteraction: GlpiStatusMapper.isOpenForInteraction(
        detail.status,
      ),
      isRequesterProfile: isRequesterProfile,
    );
  }
}

class _TicketActionPanel extends StatefulWidget {
  const _TicketActionPanel({
    required this.detail,
    required this.capabilities,
    required this.onChanged,
  });

  final DticTicketDetail detail;
  final _DtcTicketCapabilities capabilities;
  final VoidCallback onChanged;

  @override
  State<_TicketActionPanel> createState() => _TicketActionPanelState();
}

class _TicketActionPanelState extends State<_TicketActionPanel> {
  final _controller = TextEditingController();
  final List<PlatformFile> _attachments = [];
  _DtcActionMode _mode = _DtcActionMode.message;
  bool _sending = false;
  bool _updatingStatus = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refreshComposer);
  }

  @override
  void dispose() {
    _controller.removeListener(_refreshComposer);
    _controller.dispose();
    super.dispose();
  }

  void _refreshComposer() {
    if (mounted) setState(() {});
  }

  Future<void> _sendTextAction() async {
    final message = _controller.text.trim();
    if ((message.isEmpty && _attachments.isEmpty) || _sending) return;

    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final state = context.read<DticAppState>();
      final attachmentPaths = _attachments
          .map((file) => file.path)
          .whereType<String>()
          .where((path) => path.trim().isNotEmpty)
          .toList();
      final result = _mode == _DtcActionMode.solution
          ? await state.sendTicketSolution(
              ticketId: widget.detail.id,
              message: message,
              attachmentPaths: attachmentPaths,
            )
          : await state.sendTicketMessage(
              ticketId: widget.detail.id,
              message: message,
              attachmentPaths: attachmentPaths,
            );
      if (!mounted) return;

      if (result['success'] == true) {
        final attachmentsFail =
            int.tryParse('${result['attachmentsFail'] ?? 0}') ?? 0;
        _controller.clear();
        setState(() => _attachments.clear());
        messenger.showSnackBar(
          SnackBar(
            content: Text(_successMessage(result)),
            backgroundColor: attachmentsFail > 0 ? AppColors.warning : null,
          ),
        );
        widget.onChanged();
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result['error']?.toString() ?? 'Falha ao enviar acao.',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _successMessage(Map<String, dynamic> result) {
    final attachmentsSuccess =
        int.tryParse('${result['attachmentsSuccess'] ?? 0}') ?? 0;
    final attachmentsFail =
        int.tryParse('${result['attachmentsFail'] ?? 0}') ?? 0;
    final base = _mode == _DtcActionMode.solution
        ? 'Solucao enviada.'
        : 'Mensagem enviada.';

    if (attachmentsSuccess == 0 && attachmentsFail == 0) return base;
    if (attachmentsFail == 0) {
      return '$base Anexos enviados: $attachmentsSuccess.';
    }
    return '$base Anexos enviados: $attachmentsSuccess; falhas: $attachmentsFail.';
  }

  Future<void> _selectAttachments() async {
    if (_sending) return;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: false,
    );
    if (!mounted || result == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final rejected = <String>[];
    setState(() {
      for (final file in result.files) {
        final path = file.path;
        if (path == null || path.trim().isEmpty) {
          rejected.add('${file.name}: arquivo sem caminho local.');
          continue;
        }

        final validation = FileValidator.validate(File(path));
        if (validation != null) {
          rejected.add('${file.name}: $validation');
          continue;
        }

        final alreadySelected = _attachments.any((selected) {
          return selected.name == file.name && selected.path == file.path;
        });
        if (!alreadySelected) _attachments.add(file);
      }
    });

    if (rejected.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(rejected.join(' | ')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _removeAttachment(PlatformFile file) {
    setState(() {
      _attachments.removeWhere((selected) {
        return selected.name == file.name && selected.path == file.path;
      });
    });
  }

  Future<void> _updateStatus(GlpiStatus status) async {
    if (_updatingStatus) return;
    setState(() => _updatingStatus = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await context.read<DticAppState>().updateTicketStatus(
        ticketId: widget.detail.id,
        status: status.label,
      );
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? 'Status atualizado para ${status.label}.'
                : result['error']?.toString() ?? 'Falha ao atualizar status.',
          ),
          backgroundColor: result['success'] == true
              ? AppColors.success
              : AppColors.danger,
        ),
      );

      if (result['success'] == true) {
        widget.onChanged();
      }
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = GlpiStatusMapper.tryParse(widget.detail.status);
    final canSendSolution = widget.capabilities.canSendSolution;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Acoes do chamado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (canSendSolution) ...[
              SegmentedButton<_DtcActionMode>(
                segments: const [
                  ButtonSegment<_DtcActionMode>(
                    value: _DtcActionMode.message,
                    icon: Icon(Icons.chat_bubble_outline),
                    label: Text('Mensagem'),
                  ),
                  ButtonSegment<_DtcActionMode>(
                    value: _DtcActionMode.solution,
                    icon: Icon(Icons.task_alt_outlined),
                    label: Text('Solucao'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() => _mode = selection.first);
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            // TODO(dtic-contract): quando o contrato DTIC/CAU for gerado
            // (mesmo pipeline do SIS), substituir por GlpiRulesClient
            // com profileId do DticAppState — análogo ao SIS ticket_detail_screen.
            if (widget.capabilities.canUpdateStatus) ...[
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _StatusActionButton(
                    label: GlpiStatus.emAtendimento.label,
                    targetStatus: GlpiStatus.emAtendimento,
                    currentStatus: currentStatus,
                    busy: _updatingStatus,
                    onPressed: _updateStatus,
                  ),
                  _StatusActionButton(
                    label: GlpiStatus.pendente.label,
                    targetStatus: GlpiStatus.pendente,
                    currentStatus: currentStatus,
                    busy: _updatingStatus,
                    onPressed: _updateStatus,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: _mode == _DtcActionMode.solution
                    ? 'Solucao'
                    : 'Mensagem',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _AttachmentPicker(
              attachments: _attachments,
              sending: _sending,
              onPick: _selectAttachments,
              onRemove: _removeAttachment,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed:
                  _sending ||
                      (_controller.text.trim().isEmpty && _attachments.isEmpty)
                  ? null
                  : _sendTextAction,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _mode == _DtcActionMode.solution
                          ? Icons.task_alt_outlined
                          : Icons.send_outlined,
                    ),
              label: Text(
                _sending
                    ? 'Enviando...'
                    : _mode == _DtcActionMode.solution
                    ? 'Enviar solucao'
                    : 'Enviar mensagem',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentPicker extends StatelessWidget {
  const _AttachmentPicker({
    required this.attachments,
    required this.sending,
    required this.onPick,
    required this.onRemove,
  });

  final List<PlatformFile> attachments;
  final bool sending;
  final VoidCallback onPick;
  final ValueChanged<PlatformFile> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: sending ? null : onPick,
          icon: const Icon(Icons.attach_file),
          label: Text(
            attachments.isEmpty
                ? 'Anexar arquivo'
                : 'Anexos selecionados: ${attachments.length}',
          ),
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          ...attachments.map(
            (file) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(_formatFileSize(file.size)),
                  trailing: IconButton(
                    tooltip: 'Remover anexo',
                    onPressed: sending ? null : () => onRemove(file),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _StatusActionButton extends StatelessWidget {
  const _StatusActionButton({
    required this.label,
    required this.targetStatus,
    required this.currentStatus,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final GlpiStatus targetStatus;
  final GlpiStatus? currentStatus;
  final bool busy;
  final ValueChanged<GlpiStatus> onPressed;

  @override
  Widget build(BuildContext context) {
    final isCurrent = currentStatus == targetStatus;
    return OutlinedButton.icon(
      onPressed: busy || isCurrent ? null : () => onPressed(targetStatus),
      icon: busy && !isCurrent
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(isCurrent ? Icons.check_circle_outline : Icons.sync_outlined),
      label: Text(isCurrent ? '$label atual' : 'Marcar $label'),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.detail, required this.capabilities});

  final DticTicketDetail detail;
  final _DtcTicketCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(detail.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                SisStatusChip(
                  label: detail.statusLabel,
                  tone: AppStatusPalette.fromGlpiStatus(detail.status),
                ),
                SisStatusChip(
                  label: capabilities.label,
                  tone: capabilities.tone,
                ),
                if (detail.category.isNotEmpty) _Pill(label: detail.category),
                if (detail.requester.isNotEmpty)
                  _Pill(label: 'Requerente: ${detail.requester}'),
                if (detail.date.isNotEmpty) _Pill(label: detail.date),
              ],
            ),
            if (detail.content.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _TicketContent(content: detail.content),
            ],
          ],
        ),
      ),
    );
  }
}

class _InteractionCard extends StatelessWidget {
  const _InteractionCard({required this.interaction});

  final DticTicketInteraction interaction;

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
                SisStatusChip(
                  label: interaction.kind,
                  tone: interaction.kind == 'Solucao'
                      ? AppStatusTone.success
                      : AppStatusTone.info,
                ),
                const Spacer(),
                Text(
                  interaction.date,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (interaction.author.isNotEmpty) ...[
              Text(
                interaction.author,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(
              interaction.content.isEmpty
                  ? '(sem conteudo)'
                  : interaction.content,
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketContent extends StatelessWidget {
  const _TicketContent({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final summary = TicketFormSummary.parse(content);
    if (summary.fields.isEmpty) {
      return Text(
        content,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.description.isNotEmpty) ...[
          Text(
            summary.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        for (final field in summary.fields)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 128,
                  child: Text(
                    field.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(field.value)),
              ],
            ),
          ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.document,
    required this.onOpen,
    required this.loadImagePreview,
  });

  final DticTicketDocument document;
  final VoidCallback onOpen;
  final Future<Uint8List?> Function() loadImagePreview;

  @override
  Widget build(BuildContext context) {
    final isImage = document.mime.toLowerCase().startsWith('image/');
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: Icon(
              isImage ? Icons.image_outlined : Icons.insert_drive_file_outlined,
              color: AppColors.brandDark,
            ),
            title: Text(document.name),
            subtitle: Text(
              [
                document.contextLabel,
                if (document.date.isNotEmpty) document.date,
                if (document.mime.isNotEmpty) document.mime,
              ].join(' | '),
            ),
            trailing: IconButton(
              tooltip: 'Abrir anexo',
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new),
            ),
            onTap: onOpen,
          ),
          if (isImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: _ImagePreview(
                loadPreview: loadImagePreview,
                onOpen: onOpen,
              ),
            ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatefulWidget {
  const _ImagePreview({required this.loadPreview, required this.onOpen});

  final Future<Uint8List?> Function() loadPreview;
  final VoidCallback onOpen;

  @override
  State<_ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<_ImagePreview> {
  late final Future<Uint8List?> _future = widget.loadPreview();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _PreviewFrame(
            child: Center(
              child: Text(
                'Carregando preview...',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
          );
        }

        if (snapshot.hasError || bytes == null || bytes.isEmpty) {
          return _PreviewFrame(
            child: Center(
              child: Text(
                'Preview indisponivel',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
          );
        }

        return InkWell(
          onTap: widget.onOpen,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: _PreviewFrame(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, _, _) => Center(
                child: Text(
                  'Imagem nao renderizada',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.neutralSoft,
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _TicketDetailBundle {
  const _TicketDetailBundle({
    required this.detail,
    required this.interactions,
    required this.documents,
  });

  final DticTicketDetail detail;
  final List<DticTicketInteraction> interactions;
  final List<DticTicketDocument> documents;
}
