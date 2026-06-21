import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import '../state/app_state.dart';
import '../state/app_state_ticket_support.dart';
import '../models/glpi_status.dart';
import '../models/ticket_message.dart';
import '../utils/avatar_colors.dart';
import '../utils/attachment_display.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:gal/gal.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_status.dart';
import '../widgets/ui/sis_empty_state.dart';
import '../widgets/ui/sis_page_scaffold.dart';
import '../widgets/ui/sis_status_chip.dart';

class TicketMessageScreen extends StatefulWidget {
  final String ticketId;
  final bool startInSolutionMode;
  final String? ticketOwner;
  final String? ticketOwnerUserId;
  final bool isClosed;
  final dynamic ticketStatus;

  const TicketMessageScreen({
    super.key,
    required this.ticketId,
    this.startInSolutionMode = false,
    this.ticketOwner,
    this.ticketOwnerUserId,
    this.isClosed = false,
    this.ticketStatus,
  });

  @override
  State<TicketMessageScreen> createState() => _TicketMessageScreenState();
}

class _TicketMessageScreenState extends State<TicketMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _selectedFiles = [];

  bool _isLoading = false;
  bool _isSending = false;
  late List<TicketMessage> _messages;
  XFile? _selectedImage;

  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;
  bool _isFetching = false;
  final Map<String, Uint8List> _imageCache = {};
  String _lastDataHash = '';
  bool _isFirstLoadComplete = false;
  bool _showScrollToBottomBtn = false;
  bool _isSolutionMode = false;
  bool _isTicketClosed = false;
  dynamic _ticketStatus;
  String? _ticketOwner;
  String? _ticketOwnerUserId;

  @override
  void initState() {
    super.initState();
    _messages = [];
    _isSolutionMode = widget.startInSolutionMode;
    _isTicketClosed = widget.isClosed;
    _ticketStatus =
        widget.ticketStatus ??
        (widget.isClosed ? GlpiStatus.fechado.code : null);
    _ticketOwner = _normalizeIdentity(widget.ticketOwner);
    _ticketOwnerUserId = _normalizeIdentity(widget.ticketOwnerUserId);
    _refreshTicketState();
    _startPolling();

    _scrollController.addListener(() {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        final showBtn = (maxScroll - currentScroll) > 300;
        if (showBtn != _showScrollToBottomBtn) {
          setState(() => _showScrollToBottomBtn = showBtn);
        }
      }
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (mounted && !_isFetching) {
        _isFetching = true;
        try {
          await _loadMessages();
          await _refreshTicketStatus();
        } finally {
          _isFetching = false;
        }
      }
    });
  }

  String? _normalizeIdentity(dynamic value) {
    final normalized = AppStateTicketSupport.normalizeIdentity(value);
    return normalized.isEmpty ? null : normalized;
  }

  Future<void> _refreshTicketState() async {
    await _refreshTicketStatus();
    await _loadMessages();
  }

  Future<void> _refreshTicketStatus() async {
    if (!mounted) return;
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final ticket = await appState.fetchTicketById(widget.ticketId);
      if (!mounted || ticket == null) return;

      final requesterId =
          ticket['requester_user_id'] ??
          ticket['users_id_recipient_id'] ??
          ticket['Users_id_recipient_id'];
      final requesterName =
          ticket['Users_id_recipient'] ?? ticket['users_id_recipient'];

      setState(() {
        _ticketStatus = ticket['status'];
        _isTicketClosed = GlpiStatusMapper.isClosed(ticket['status']);
        _ticketOwnerUserId =
            _normalizeIdentity(requesterId) ?? _ticketOwnerUserId;
        _ticketOwner = _normalizeIdentity(requesterName) ?? _ticketOwner;
      });
    } catch (_) {
      // Mantem o estado atual se a consulta pontual falhar; o proximo polling
      // tenta novamente e as acoes criticas ainda validam no AppState.
    }
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    if (!_isFirstLoadComplete && _messages.isEmpty && !_isLoading) {
      setState(() => _isLoading = true);
    }
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final messages = await appState.fetchTicketMessages(widget.ticketId);

      if (mounted) {
        final currentHash = messages
            .map((m) => '${m.id}_${m.createdAt}')
            .join('|');
        if (_lastDataHash != currentHash) {
          _lastDataHash = currentHash;
          bool shouldScroll = false;

          if (!_isFirstLoadComplete) {
            shouldScroll = true;
          } else if (_scrollController.hasClients) {
            final maxScroll = _scrollController.position.maxScrollExtent;
            final currentScroll = _scrollController.position.pixels;
            if ((maxScroll - currentScroll) <= 150) shouldScroll = true;
          }

          setState(() {
            _messages = messages;
            _isLoading = false;
          });

          if (shouldScroll) _scrollToBottom();
          if (!_isFirstLoadComplete) _isFirstLoadComplete = true;
        } else {
          // Hash igual = dados não mudaram (inclusive lista vazia na 1ª carga).
          // Garante que _isFirstLoadComplete seja marcado mesmo sem mensagens.
          if (_isLoading || !_isFirstLoadComplete) {
            setState(() {
              _isLoading = false;
              _isFirstLoadComplete = true;
            });
          }
        }
      }
    } catch (e) {
      if (mounted && !_isFirstLoadComplete) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && _scrollController.hasClients) {
          try {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } catch (_) {}
        }
      });
    }
  }

  Future<void> _downloadAndOpenFile(String url, String fileName) async {
    _showSnackBar('Baixando $fileName...', color: Colors.blueAccent);
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final bytes = await appState.downloadImage(url);

      if (bytes == null || bytes.isEmpty) {
        _showSnackBar('Erro: o arquivo falhou ao baixar.', color: Colors.red);
        return;
      }

      final safeFileName = fileName.replaceAll(RegExp(r'[\\/]'), '_');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$safeFileName');
      await file.writeAsBytes(bytes, flush: true);

      if (mounted) {
        _showSnackBar('Abrindo visualizador...', color: Colors.blueAccent);
      }
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        _showSnackBar(
          'Não foi possível abrir: ${result.message}',
          color: Colors.orange,
        );
      }
    } catch (e) {
      _showSnackBar('Erro ao processar arquivo: $e', color: Colors.red);
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (_isSolutionMode && messageText.isEmpty) {
      _showSnackBar(
        'Para enviar uma solução, você deve digitar uma mensagem.',
        color: Colors.orange,
      );
      return;
    }
    if (messageText.isEmpty &&
        _selectedImage == null &&
        _selectedFiles.isEmpty) {
      return;
    }
    if (_isSending) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final filePaths = <String>[..._selectedFiles];
      if (_selectedImage?.path != null) filePaths.add(_selectedImage!.path);

      final result = await appState.sendTicketMessageWithAttachments(
        ticketId: widget.ticketId,
        messageContent: messageText,
        filePaths: filePaths,
        isSolution: _isSolutionMode,
      );

      if (result['success'] == true) {
        _messageController.clear();
        _selectedImage = null;
        _selectedFiles.clear();
        _lastDataHash = '';
        await _refreshTicketState();
        _scrollToBottom();
      } else {
        _showSnackBar(result['error'] ?? 'Falha ao enviar', color: Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erro: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<Uint8List?> _getCachedImage(String url) async {
    if (_imageCache.containsKey(url)) return _imageCache[url];
    final appState = Provider.of<AppState>(context, listen: false);
    if (!mounted) return null;
    final bytes = await appState.downloadImage(url);
    if (bytes != null && mounted) _imageCache[url] = bytes;
    return bytes;
  }

  Future<void> _selectImage() async {
    try {
      final img = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (img != null) setState(() => _selectedImage = img);
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final img = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (img != null) setState(() => _addFileIfValid(img.path));
    } catch (e) {
      debugPrint('Erro ao capturar foto: $e');
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          for (var p in result.paths) {
            if (p != null) _addFileIfValid(p);
          }
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar arquivo: $e');
    }
  }

  void _addFileIfValid(String path) {
    if (!_selectedFiles.contains(path)) _selectedFiles.add(path);
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  void _showSnackBar(String msg, {Color color = AppColors.danger}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  //
  Widget _buildSolutionCard(TicketMessage message) {
    final isPending =
        message.solutionStatus == 2 || message.solutionStatus == 1;
    final isApproved = message.solutionStatus == 3;
    final isRejected = message.solutionStatus == 4;

    Color cardColor = AppColors.warningSoft;
    Color borderColor = AppColors.warning;
    String statusLabel = 'Aguardando aprovação';
    IconData statusIcon = Icons.hourglass_empty;
    String statusChipLabel = 'Pendente';
    AppStatusTone statusChipTone = AppStatusTone.warning;

    if (isApproved) {
      cardColor = AppColors.successSoft;
      borderColor = AppColors.success;
      statusLabel = 'Solução aprovada';
      statusIcon = Icons.check_circle;
      statusChipLabel = 'Aprovada';
      statusChipTone = AppStatusTone.success;
    } else if (isRejected) {
      cardColor = AppColors.dangerSoft;
      borderColor = AppColors.danger;
      statusLabel = 'Solução recusada';
      statusIcon = Icons.cancel;
      statusChipLabel = 'Recusada';
      statusChipTone = AppStatusTone.danger;
    }

    if (_isTicketClosed && !isApproved) {
      cardColor = AppColors.neutralSoft;
      borderColor = AppColors.neutral;
      statusLabel = 'Solução registrada';
      statusIcon = Icons.history;
      statusChipLabel = 'Histórico';
      statusChipTone = AppStatusTone.neutral;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final canApprove = AppStateTicketSupport.canValidateSolutionForTicket(
      {
        'status': _ticketStatus,
        'requester_user_id': _ticketOwnerUserId,
        'users_id_recipient': _ticketOwner,
      },
      loggedUsername: appState.loggedUsername,
      loggedUserId: appState.loggedUserId,
      solutionAuthorName: message.sender,
      solutionAuthorUserId: message.senderUserId,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Card(
        color: cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  topRight: Radius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: borderColor, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      statusLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: borderColor),
                    ),
                  ),
                  SisStatusChip(label: statusChipLabel, tone: statusChipTone),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Técnico: ${message.sender}',
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
            if (isPending && canApprove)
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: AppColors.textInverse,
                        ),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Recusar'),
                        onPressed: () =>
                            _showRejectDialog(widget.ticketId, message.id),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.textInverse,
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Aprovar'),
                        onPressed: () =>
                            _approveSolution(widget.ticketId, message.id),
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

  Future<void> _approveSolution(String ticketId, String solutionId) async {
    setState(() => _isSending = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final result = await appState.approveSolution(ticketId, solutionId);
    if (!mounted) return;

    if (result['success'] == true) {
      _showSnackBar(
        'Solução aprovada. O chamado foi fechado.',
        color: AppColors.success,
      );
      _lastDataHash = '';
      setState(() => _isTicketClosed = true);
      await _refreshTicketState();
    } else {
      _showSnackBar('Erro: ${result['error']}', color: AppColors.danger);
    }
    setState(() => _isSending = false);
  }

  void _showRejectDialog(String ticketId, String solutionId) {
    final TextEditingController justificationController =
        TextEditingController();
    List<String> localImagePaths =
        []; // AGORA É UMA LISTA (Múltiplas Imagens)

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text(
              'Recusar solução',
              style: TextStyle(color: Colors.red),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Por favor, justifique o motivo da recusa.'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: justificationController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Digite o que faltou ser feito...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Anexar imagens (opcional):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final img = await _imagePicker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                            );
                            if (img != null) {
                              setDialogState(
                                () => localImagePaths.add(img.path),
                              );
                            }
                          },
                          icon: const Icon(Icons.camera_alt, size: 14),
                          label: const Text(
                            'Câmera',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            // Seleção múltipla da galeria
                            final images = await _imagePicker.pickMultiImage(
                              imageQuality: 80,
                            );
                            if (images.isNotEmpty) {
                              setDialogState(
                                () => localImagePaths.addAll(
                                  images.map((i) => i.path),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.photo_library, size: 14),
                          label: const Text(
                            'Galeria',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (localImagePaths.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: localImagePaths.asMap().entries.map((entry) {
                        return Chip(
                          label: Text(
                            'Img ${entry.key + 1}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          onDeleted: () => setDialogState(
                            () => localImagePaths.removeAt(entry.key),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (justificationController.text.trim().isEmpty) {
                    _showSnackBar(
                      'A justificativa é obrigatória!',
                      color: Colors.orange,
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);
                  if (!mounted) return;
                  setState(() => _isSending = true);

                  final appState = Provider.of<AppState>(
                    context,
                    listen: false,
                  );
                  final result = await appState.rejectSolution(
                    ticketId,
                    solutionId,
                    justificationController.text.trim(),
                    attachmentPaths:
                        localImagePaths, // Manda as múltiplas imagens
                  );

                  if (!mounted) return;
                  if (result['success'] == true) {
                    _showSnackBar(
                      'Solução recusada e chamado reaberto.',
                      color: Colors.orange,
                    );
                    _lastDataHash = '';
                    await _refreshTicketState();
                    _scrollToBottom();
                  } else {
                    _showSnackBar(
                      'Erro: ${result['error']}',
                      color: Colors.red,
                    );
                  }
                  setState(() => _isSending = false);
                },
                child: const Text('Confirmar recusa'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Constrói o balão de mensagem para ANEXOS (Imagens ou Arquivos)
  Widget _buildAttachmentMessage(TicketMessage message) {
    final isImage = AttachmentDisplay.isImageDocument(
      filename: message.content,
      mime: message.mimeType,
    );

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
                      Icon(
                        isImage ? Icons.image : Icons.insert_drive_file,
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
                  const SizedBox(height: AppSpacing.xs),
                  if (isImage && message.documentUrl != null)
                    FutureBuilder<Uint8List?>(
                      key: ValueKey(message.documentUrl),
                      future: _getCachedImage(message.documentUrl!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 150,
                            color: AppColors.neutralSoft,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return GestureDetector(
                            onTap: () => _showImagePreviewBytes(snapshot.data!),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                height: 150,
                                width: double.infinity,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    )
                  else
                    InkWell(
                      onTap: () => message.documentUrl != null
                          ? _downloadAndOpenFile(
                              message.documentUrl!,
                              message.content,
                            )
                          : null,
                      child: Container(
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
                            Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: AppColors.brand,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Abrir arquivo',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: AppColors.brand),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxs),
                    child: Text(
                      '${message.sender} - ${_formatDateTime(message.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }

  /// Exibe preview de imagem em tela cheia com opção de salvar na galeria
  void _showImagePreviewBytes(Uint8List bytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(child: Image.memory(bytes)),

            // Botão Fechar (Canto Superior Direito)
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: CircleAvatar(
                backgroundColor: AppColors.brandDark,
                child: IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: () async {
                    try {
                      final hasAccess = await Gal.hasAccess();
                      if (!hasAccess) {
                        await Gal.requestAccess();
                      }
                      final fileName =
                          'glpi_anexo_${DateTime.now().millisecondsSinceEpoch}';
                      await Gal.putImageBytes(bytes, name: fileName);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Imagem salva na galeria.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao salvar: $e'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SisPageScaffold(
      title: 'Chamado: ${widget.ticketId}',
      subtitle: _isSolutionMode ? 'Modo solução ativo' : 'Conversa e anexos',
      floatingActionButton: _showScrollToBottomBtn
          ? FloatingActionButton.small(
              backgroundColor: AppColors.brand,
              child: const Icon(Icons.arrow_downward, color: Colors.white),
              onPressed: () {
                _scrollToBottom();
                setState(() => _showScrollToBottomBtn = false);
              },
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: const [
                      SizedBox(
                        height: 420,
                        child: SisEmptyState(
                          icon: Icons.chat_bubble_outline,
                          title: 'Nenhuma mensagem ainda',
                          message:
                              'O histórico da conversa aparecerá aqui assim que houver interações no ticket.',
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.md,
                      bottom: 60,
                    ),
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      if (msg.type == 'solution') {
                        return _buildSolutionCard(msg);
                      }
                      if (msg.type == 'attachment') {
                        return _buildAttachmentMessage(msg);
                      }
                      return _buildTextMessage(msg);
                    },
                  ),
          ),

          if (_selectedImage != null || _selectedFiles.isNotEmpty)
            _buildAttachmentPreview(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTextMessage(TicketMessage message) {
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
              style: const TextStyle(color: Colors.white),
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

  Widget _buildInputArea() {
    final canSendCommonInteraction =
        AppStateTicketSupport.canSendCommonInteraction(_ticketStatus);

    if (!canSendCommonInteraction) {
      final isSolved = GlpiStatusMapper.isSolved(_ticketStatus);
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
                isSolved
                    ? 'Chamado solucionado. Use aprovar ou recusar solução quando disponível.'
                    : 'Chamado fechado. Novas interações desabilitadas.',
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

    final appState = Provider.of<AppState>(context);
    final canProposeSolution = AppStateTicketSupport.canProposeSolution(
      {
        'status': _ticketStatus,
        'requester_user_id': _ticketOwnerUserId,
        'users_id_recipient': _ticketOwner,
      },
      activeProfile: appState.activeProfile,
      loggedUsername: appState.loggedUsername,
      loggedUserId: appState.loggedUserId,
    );

    final hasPendingSolution = _messages.any(
      (m) =>
          m.type == 'solution' &&
          (m.solutionStatus == 1 || m.solutionStatus == 2),
    );

    if (hasPendingSolution && _isSolutionMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isSolutionMode = false);
      });
    }
    if (!canProposeSolution && _isSolutionMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isSolutionMode = false);
      });
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
            if (canProposeSolution && !hasPendingSolution)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: _isSolutionMode
                        ? AppColors.brandSoft
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<bool>(
                      isDense: true,
                      value: _isSolutionMode,
                      items: const [
                        DropdownMenuItem(
                          value: false,
                          child: Text('Acompanhamento'),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text('Solucionar chamado'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _isSolutionMode = val);
                      },
                    ),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.add_circle_outline),
                  onSelected: (value) {
                    if (value == 'camera') _takePhoto();
                    if (value == 'gallery') _selectImage();
                    if (value == 'files') _pickFiles();
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'camera',
                          child: ListTile(
                            leading: Icon(Icons.camera_alt_outlined),
                            title: Text('Câmera'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'gallery',
                          child: ListTile(
                            leading: Icon(Icons.photo_outlined),
                            title: Text('Galeria'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'files',
                          child: ListTile(
                            leading: Icon(Icons.insert_drive_file_outlined),
                            title: Text('Arquivos'),
                          ),
                        ),
                      ],
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: _isSolutionMode
                            ? 'Descreva a solução aplicada...'
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
                _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: _isSolutionMode
                              ? AppColors.brand
                              : AppColors.info,
                          foregroundColor: AppColors.textInverse,
                        ),
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    if (_selectedFiles.isEmpty && _selectedImage == null) {
      return const SizedBox.shrink();
    }

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
          if (_selectedImage != null)
            InputChip(
              avatar: const Icon(Icons.image_outlined, size: 16),
              label: const Text('Imagem'),
              onDeleted: () => setState(() => _selectedImage = null),
            ),
          ..._selectedFiles.asMap().entries.map((entry) {
            return InputChip(
              avatar: const Icon(Icons.insert_drive_file_outlined, size: 16),
              label: Text('Arquivo ${entry.key + 1}'),
              onDeleted: () => _removeFile(entry.key),
            );
          }),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime d) {
    return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
