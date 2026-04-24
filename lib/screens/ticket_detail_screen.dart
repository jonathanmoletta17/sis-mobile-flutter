import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/glpi_status.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_status.dart';
import '../widgets/ui/sis_empty_state.dart';
import '../widgets/ui/sis_page_scaffold.dart';
import '../widgets/ui/sis_section_header.dart';
import '../widgets/ui/sis_status_chip.dart';
import 'ticket_message_screen.dart';

class TicketDetailScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late Map<String, dynamic> _ticketData;

  bool _isUpdating = false;
  bool _isLoadingTicket = false;

  final List<Map<String, dynamic>> _remoteDocs = [];
  final Map<String, Uint8List> _remoteImageBytesByDocId = {};
  bool _isLoadingRemoteAttachments = false;
  String? _remoteAttachmentsError;

  @override
  void initState() {
    super.initState();
    _ticketData = Map<String, dynamic>.from(widget.ticket);
    _normalizeTicketFields();
    _rehydrateTicket();
  }

  void _normalizeTicketFields() {
    if (_ticketData['status'] != null && _ticketData['status'] is! String) {
      _ticketData['status'] = _ticketData['status'].toString();
    }
    if (_ticketData['id'] != null && _ticketData['id'] is! String) {
      _ticketData['id'] = _ticketData['id'].toString();
    }
  }

  String get _ticketId => _ticketData['id']?.toString() ?? '';
  bool get _isOfflineTicket => _ticketId.contains('OFFLINE');
  String get _statusLabel => GlpiStatusMapper.label(_ticketData['status']);
  int? get _statusCode => GlpiStatusMapper.code(_ticketData['status']);
  bool get _isClosedTicket => GlpiStatusMapper.isClosed(_ticketData['status']);

  Future<void> _rehydrateTicket() async {
    if (_isOfflineTicket || _isLoadingTicket) {
      if (!_isOfflineTicket) {
        await _loadRemoteAttachments(_ticketId);
      }
      return;
    }

    setState(() {
      _isLoadingTicket = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final fetched = await appState.fetchTicketById(_ticketId);

      if (!mounted) return;

      if (fetched != null) {
        final oldServiceName = _ticketData['serviceName'];
        _ticketData = {
          ..._ticketData,
          ...fetched,
          if ((fetched['serviceName'] ?? '').toString().trim().isEmpty &&
              oldServiceName != null)
            'serviceName': oldServiceName,
        };
        _normalizeTicketFields();
      }

      await _loadRemoteAttachments(_ticketId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao atualizar dados do ticket: $e'),
          backgroundColor: AppColors.warning,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTicket = false;
        });
      }
    }
  }

  static String _decodeEntities(String input) {
    var decoded = input;

    decoded = decoded
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ');

    decoded = decoded.replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
      final codePoint = int.tryParse(m.group(1) ?? '');
      return codePoint == null
          ? (m.group(0) ?? '')
          : String.fromCharCode(codePoint);
    });

    decoded = decoded.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) {
      final codePoint = int.tryParse(m.group(1) ?? '', radix: 16);
      return codePoint == null
          ? (m.group(0) ?? '')
          : String.fromCharCode(codePoint);
    });

    return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _decodeEntitiesPreserveLines(String input) {
    final flat = _decodeEntities(
      input,
    ).replaceAll(' • ', '\n• ').replaceAll(' - ', '\n- ');

    return flat.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  }

  Widget _buildResumoFormularioWidget(String rawValue) {
    final value = _decodeEntitiesPreserveLines(rawValue);

    final lines = value
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return Text(
        '-',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final isBullet = line.startsWith('•') || line.startsWith('-');

        if (!isBullet) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              line,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                height: 1.3,
              ),
            ),
          );
        }

        final text = line.replaceFirst(RegExp(r'^[•-]\s*'), '');
        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•  ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _loadRemoteAttachments(String ticketId) async {
    if (_isOfflineTicket || _isLoadingRemoteAttachments || ticketId.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingRemoteAttachments = true;
      _remoteAttachmentsError = null;
      _remoteDocs.clear();
      _remoteImageBytesByDocId.clear();
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final docs = await appState.fetchTicketDocuments(ticketId);

      if (!mounted) return;

      docs.sort((a, b) => b['id'].toString().compareTo(a['id'].toString()));
      _remoteDocs.addAll(docs);

      for (final doc in docs) {
        final mime = (doc['mime'] ?? '').toString().toLowerCase();
        if (!mime.startsWith('image/')) continue;

        final docId = (doc['id'] ?? '').toString();
        final downloadUrl = (doc['download_url'] ?? '').toString();
        if (docId.isEmpty || downloadUrl.isEmpty) continue;

        try {
          final bytes = await appState.downloadImage(downloadUrl);
          if (!mounted) return;
          if (bytes != null && bytes.isNotEmpty) {
            _remoteImageBytesByDocId[docId] = bytes;
          }
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;
      _remoteAttachmentsError = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRemoteAttachments = false;
        });
      }
    }
  }

  Widget _buildRemoteAttachmentsList() {
    if (_isLoadingRemoteAttachments) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_remoteAttachmentsError != null) {
      return SisEmptyState(
        icon: Icons.attachment_outlined,
        title: 'Falha ao carregar anexos',
        message: _remoteAttachmentsError!,
      );
    }

    if (_remoteDocs.isEmpty) {
      return const SisEmptyState(
        icon: Icons.attachment_outlined,
        title: 'Nenhum anexo encontrado',
        message: 'Os anexos do chamado aparecerao aqui quando existirem.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _remoteDocs.map((doc) {
        final docId = (doc['id'] ?? '').toString();
        final filename = (doc['name'] ?? 'Anexo').toString();
        final mime = (doc['mime'] ?? '').toString().toLowerCase();

        final isImage = mime.startsWith('image/');
        final bytes = _remoteImageBytesByDocId[docId];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isImage
                          ? Icons.image_outlined
                          : Icons.insert_drive_file_outlined,
                      color: AppColors.brandDark,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        filename,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: bytes != null
                          ? Image.memory(bytes, fit: BoxFit.cover)
                          : Container(
                              color: AppColors.neutralSoft,
                              child: Center(
                                child: Text(
                                  'Carregando imagem...',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      filename,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required Color color,
    required GlpiStatus targetStatus,
  }) {
    final currentCode = _statusCode;
    final isCurrentStatus = currentCode == targetStatus.code;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: (_isUpdating || isCurrentStatus)
              ? null
              : () async {
                  if (targetStatus == GlpiStatus.solucionado) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TicketMessageScreen(
                          ticketId: _ticketId,
                          startInSolutionMode: true,
                          ticketOwner: _ticketData['users_id_recipient']
                              ?.toString()
                              .toLowerCase()
                              .trim(),
                          isClosed: _isClosedTicket,
                        ),
                      ),
                    );
                    if (!mounted) return;
                    await _rehydrateTicket();
                    return;
                  }

                  await _updateStatus(targetStatus);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentStatus
                ? color.withValues(alpha: 0.45)
                : color,
            foregroundColor: isCurrentStatus
                ? AppColors.textStrong
                : AppColors.textInverse,
          ),
          child: _isUpdating && !isCurrentStatus
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }

  Future<void> _updateStatus(GlpiStatus newStatus) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final result = await appState.updateTicketStatus(
      _ticketId,
      newStatus.label,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Falha ao atualizar status.',
          ),
          backgroundColor: result['success'] == true
              ? AppColors.success
              : AppColors.danger,
        ),
      );
    }

    if (result['success'] == true) {
      await _rehydrateTicket();
    }

    if (!mounted) return;
    setState(() {
      _isUpdating = false;
    });
  }

  String _translateMatrixLevel(dynamic value, String fieldType) {
    if (value == null || value.toString().isEmpty) return '-';

    final valStr = value.toString();
    if (!RegExp(r'^[0-9]+$').hasMatch(valStr)) return valStr;

    final level = int.tryParse(valStr) ?? 3;

    if (fieldType == 'Prioridade') {
      switch (level) {
        case 1:
          return 'Muito Baixa';
        case 2:
          return 'Baixa';
        case 3:
          return 'Media';
        case 4:
          return 'Alta';
        case 5:
          return 'Muito Alta';
        case 6:
          return 'Critica';
        default:
          return 'Media';
      }
    }

    switch (level) {
      case 1:
        return 'Muito Baixa';
      case 2:
        return 'Baixa';
      case 3:
        return 'Media';
      case 4:
        return 'Alta';
      case 5:
        return 'Muito Alta';
      default:
        return 'Media';
    }
  }

  Widget _buildDetailRow(String label, String value, {bool rich = false}) {
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
          if (rich)
            _buildResumoFormularioWidget(value)
          else
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assunto = _ticketData['assunto'] ?? _ticketData['name'] ?? 'Chamado';
    final descricao = (_ticketData['descricao'] ?? '').toString();
    final anexoPath = _ticketData['anexoPath'] as String?;

    final appState = Provider.of<AppState>(context);
    final activeProfile = appState.activeProfile?.toLowerCase() ?? '';
    final isRequesterOnly =
        activeProfile.contains('self-service') ||
        activeProfile.contains('solicitante') ||
        activeProfile.contains('requerente');

    final friendlyDetails = <MapEntry<String, String>>[];

    void addDetail(String label, dynamic rawValue) {
      if (rawValue == null) return;

      if (label == 'Resumo do Formulario') {
        final value = _decodeEntitiesPreserveLines(rawValue.toString());
        if (value.isEmpty) return;
        friendlyDetails.add(MapEntry(label, value));
        return;
      }

      final value = _decodeEntities(rawValue.toString());
      if (value.isEmpty) return;
      friendlyDetails.add(MapEntry(label, value));
    }

    addDetail('ID do Chamado', _ticketData['id']);
    addDetail('Assunto', _ticketData['assunto'] ?? _ticketData['name']);
    addDetail('Servico Solicitado', _ticketData['serviceName']);
    addDetail('Categoria', _ticketData['categoria_completa']);
    addDetail(
      'Solicitante',
      _ticketData['Users_id_recipient'] ?? _ticketData['users_id_recipient'],
    );
    addDetail(
      'Tecnico Responsavel',
      _ticketData['Users_id_assign'] ??
          _ticketData['users_id_assign'] ??
          _ticketData['assignee_user_id'] ??
          'Nao atribuido',
    );
    addDetail(
      'Tipo de Solicitacao',
      _ticketData['Requesttypes_id'] ?? _ticketData['requesttypes_id'],
    );
    addDetail('Localizacao', _ticketData['localizacao']);
    addDetail('Telefone', _ticketData['telefone']);
    addDetail(
      'Urgencia',
      _translateMatrixLevel(
        _ticketData['urgencia'] ??
            _ticketData['Urgency'] ??
            _ticketData['urgency'],
        'Urgencia',
      ),
    );
    addDetail(
      'Impacto',
      _translateMatrixLevel(
        _ticketData['impact'] ??
            _ticketData['Impact'] ??
            _ticketData['Impacto'],
        'Impacto',
      ),
    );
    addDetail(
      'Prioridade',
      _translateMatrixLevel(
        _ticketData['prioridade'] ??
            _ticketData['Priority'] ??
            _ticketData['priority'],
        'Prioridade',
      ),
    );
    addDetail(
      'Criado em',
      _ticketData['criado_em'] ??
          _ticketData['date_creation'] ??
          _ticketData['Date'],
    );
    addDetail(
      'Ultima Atualizacao',
      _ticketData['atualizado_em'] ??
          _ticketData['date_mod'] ??
          _ticketData['Date_mod'],
    );
    addDetail('Resumo do Formulario', _ticketData['content']);

    if (friendlyDetails.isEmpty) {
      addDetail('Status', _statusLabel);
    }

    return SisPageScaffold(
      title: 'Chamado $_ticketId',
      subtitle: _ticketData['serviceName']?.toString(),
      actions: [
        IconButton(
          onPressed: _isLoadingTicket ? null : _rehydrateTicket,
          icon: const Icon(Icons.refresh),
          tooltip: 'Recarregar',
        ),
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
                              assunto,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _ticketData['serviceName']?.toString() ??
                                  'Servico nao identificado',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      SisStatusChip(
                        label: _statusLabel,
                        tone: AppStatusPalette.fromGlpiStatus(
                          _ticketData['status'],
                        ),
                      ),
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
                      if ((_ticketData['categoria_completa'] ?? '')
                          .toString()
                          .isNotEmpty)
                        _MetaPill(
                          icon: Icons.category_outlined,
                          label: _ticketData['categoria_completa'].toString(),
                        ),
                    ],
                  ),
                  if (_isLoadingTicket) ...[
                    const SizedBox(height: AppSpacing.md),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TicketMessageScreen(
                            ticketId: _ticketId,
                            ticketOwner: _ticketData['users_id_recipient']
                                ?.toString()
                                .toLowerCase()
                                .trim(),
                            isClosed: _isClosedTicket,
                          ),
                        ),
                      );

                      if (!mounted) return;
                      await _rehydrateTicket();
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Abrir conversa'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!isRequesterOnly && !_isOfflineTicket) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SisSectionHeader(
                      title: 'Acoes de Status',
                      subtitle:
                          'Atualize o andamento do chamado ou encaminhe para solucao.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _buildStatusButton(
                          label: GlpiStatus.emAtendimento.label,
                          color: AppColors.info,
                          targetStatus: GlpiStatus.emAtendimento,
                        ),
                        _buildStatusButton(
                          label: GlpiStatus.solucionado.label,
                          color: AppColors.brand,
                          targetStatus: GlpiStatus.solucionado,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (descricao.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SisSectionHeader(title: 'Descricao Detalhada'),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      descricao,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.45),
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
                  SisSectionHeader(
                    title: anexoPath != null
                        ? 'Imagem Anexada'
                        : 'Anexos do Chamado',
                    subtitle: anexoPath != null
                        ? 'Anexo local associado a este chamado.'
                        : 'Documentos e imagens vinculados ao ticket.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (anexoPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: Image.file(
                          File(anexoPath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.neutralSoft,
                            child: const Center(
                              child: Text(
                                'Erro ao carregar imagem ou caminho invalido.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (_isOfflineTicket)
                    const SisEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'Chamado offline',
                      message:
                          'Anexos remotos ficam disponiveis apenas para chamados sincronizados.',
                    )
                  else
                    _buildRemoteAttachmentsList(),
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
                    title: 'Outros Detalhes',
                    subtitle: 'Resumo operacional e metadados do chamado.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...friendlyDetails.map((item) {
                    final isResumo = item.key == 'Resumo do Formulario';
                    return _buildDetailRow(
                      item.key,
                      item.value,
                      rich: isResumo,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
