import 'package:flutter/material.dart';
import '../services/glpi_client.dart';
import '../models/glpi_ticket.dart';
import '../models/glpi_status.dart';
import '../models/ticket_message.dart';
import 'dart:io';
import 'dart:typed_data';

import 'app_state_attachment_support.dart';
import 'app_state_message_support.dart';
import 'app_state_solution_support.dart';
import 'app_state_storage.dart';
import 'app_state_ticket_support.dart';

class AppState extends ChangeNotifier {
  // --- Dependências ---
  final GlpiClient _apiService;

  // --- Estado de Autenticação ---
  bool _isAuthenticated = false;
  String? _sessionToken; // Token de sessão GLPI

  // ✅ ALTERAÇÃO:
  // Onde: estado de sessão do AppState
  // Por quê: unir tua branch com a main
  // O que faz: guarda usuário logado, cache do ID e perfil ativo
  String? _loggedUsername;
  int? _loggedUserId;
  String? _activeProfile;
  int? _activeEntityId;
  String? _activeEntityName;
  int? _defaultEntityId;
  int? _selectedTicketEntityId;
  String? _selectedTicketEntityName;
  List<Map<String, dynamic>> _availableEntities = const [];

  // --- Estado de Tickets Offline ---
  List<GlpiTicket> _pendingTickets = [];

  // --- Memória de Leitura de Tickets ---
  final Map<String, String> _lastReadDates =
      {}; // Armazena quando cada ticket foi lido

  bool get isAuthenticated => _isAuthenticated;
  String? get loggedUsername => _loggedUsername;
  int? get loggedUserId => _loggedUserId;
  String? get activeProfile => _activeProfile;
  int? get activeEntityId => _activeEntityId;
  String? get activeEntityName => _activeEntityName;
  int? get selectedTicketEntityId => _selectedTicketEntityId;
  String? get selectedTicketEntityName => _selectedTicketEntityName;
  List<Map<String, dynamic>> get availableEntities =>
      List.unmodifiable(_availableEntities);
  List<GlpiTicket> get pendingTickets => _pendingTickets;

  // Construtor: Carrega estado e tickets ao iniciar
  AppState(this._apiService) {
    _loadState();
    _loadPendingTickets(); // CARREGA TICKETS PENDENTES AO INICIAR
  }

  // Método para salvar a fila de tickets pendentes no storage local
  Future<void> _savePendingTickets() async {
    await AppStateStorage.savePendingTickets(_pendingTickets);
  }

  // Método para carregar a fila de tickets pendentes do storage local
  Future<void> _loadPendingTickets() async {
    _pendingTickets = await AppStateStorage.loadPendingTickets();
    notifyListeners();
  }

  // Método para carregar o estado salvo localmente (Requisito Offline)
  Future<void> _loadState() async {
    final snapshot = await AppStateStorage.loadSessionSnapshot();
    final storedToken = snapshot.sessionToken;
    _loggedUsername = snapshot.loggedUsername;
    _activeProfile = snapshot.activeProfile;
    _activeEntityId = snapshot.activeEntityId;
    _activeEntityName = snapshot.activeEntityName;
    _defaultEntityId = snapshot.defaultEntityId;
    _selectedTicketEntityId = snapshot.selectedTicketEntityId;
    _selectedTicketEntityName = snapshot.selectedTicketEntityName;
    _sessionToken = null;
    _isAuthenticated = false;

    if (storedToken != null && storedToken.isNotEmpty) {
      _apiService.hydrateSession(storedToken);
      try {
        final sessionContext = await _apiService.getSessionContext(storedToken);
        _sessionToken = storedToken;
        _isAuthenticated = true;
        _applySessionContext(sessionContext, fallbackUsername: _loggedUsername);
        _reconcileSelectedTicketEntity(
          preferredId: snapshot.selectedTicketEntityId,
          preferredName: snapshot.selectedTicketEntityName,
        );

        if (_loggedUsername != null && _loggedUsername!.trim().isNotEmpty) {
          await AppStateStorage.saveSessionSnapshot(
            sessionToken: storedToken,
            loggedUsername: _loggedUsername!,
            activeProfile: _activeProfile,
            activeEntityId: _activeEntityId,
            activeEntityName: _activeEntityName,
            defaultEntityId: _defaultEntityId,
            selectedTicketEntityId: _selectedTicketEntityId,
            selectedTicketEntityName: _selectedTicketEntityName,
          );
        }
      } catch (e) {
        debugPrint('⚠️ Sessão salva inválida/expirada: $e');
        await _clearLocalSessionData();
      }
    } else {
      _apiService.clearSession();
    }

    _lastReadDates.clear();
    _lastReadDates.addAll(await AppStateStorage.loadReadDates());

    notifyListeners();
  }

  bool _isSessionInvalidError(Object error) {
    final detail = error.toString();
    return detail.contains('SESSION_INVALID_OR_EXPIRED') &&
        !detail.contains('ERROR_RIGHT_MISSING') &&
        !detail.contains('GLPI_PERMISSION_DENIED');
  }

  bool _isPermissionDeniedError(Object error) {
    final detail = error.toString();
    return detail.contains('GLPI_PERMISSION_DENIED') ||
        detail.contains('ERROR_RIGHT_MISSING') ||
        detail.contains('permissão') ||
        detail.contains('permissao');
  }

  Future<void> _clearLocalSessionData() async {
    _apiService.clearSession();
    _isAuthenticated = false;
    _sessionToken = null;
    _loggedUsername = null;
    _loggedUserId = null;
    _activeProfile = null;
    _activeEntityId = null;
    _activeEntityName = null;
    _defaultEntityId = null;
    _selectedTicketEntityId = null;
    _selectedTicketEntityName = null;
    _availableEntities = const [];
    await AppStateStorage.clearSessionSnapshot();
  }

  Future<void> _handleSessionInvalid(Object error) async {
    debugPrint('⚠️ Sessão inválida detectada: $error');
    await _clearLocalSessionData();
    notifyListeners();
  }

  Future<void> selectTicketEntity({
    required int entityId,
    required String entityName,
  }) async {
    _selectedTicketEntityId = entityId;
    _selectedTicketEntityName = entityName.trim();

    if (_sessionToken != null &&
        _loggedUsername != null &&
        _loggedUsername!.trim().isNotEmpty) {
      await AppStateStorage.saveSessionSnapshot(
        sessionToken: _sessionToken!,
        loggedUsername: _loggedUsername!,
        activeProfile: _activeProfile,
        activeEntityId: _activeEntityId,
        activeEntityName: _activeEntityName,
        defaultEntityId: _defaultEntityId,
        selectedTicketEntityId: _selectedTicketEntityId,
        selectedTicketEntityName: _selectedTicketEntityName,
      );
    }

    notifyListeners();
  }

  /// Marca um ticket como lido, salvando a data/hora atual
  Future<void> markTicketAsRead(String ticketId) async {
    final now = DateTime.now().toIso8601String();
    _lastReadDates[ticketId] = now;

    await AppStateStorage.saveReadDate(ticketId, now);

    notifyListeners();
  }

  /// Verifica se um ticket tem novo conteúdo (unread)
  bool hasUnreadContent(String ticketId, String? serverLastUpdate) {
    if (serverLastUpdate == null) return false;

    if (!_lastReadDates.containsKey(ticketId)) return true;

    try {
      final lastRead = DateTime.parse(_lastReadDates[ticketId]!);
      final serverUpdate = DateTime.parse(serverLastUpdate);
      return serverUpdate.isAfter(lastRead);
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate(String user, String password) async {
    final token = await _apiService.authenticate(user, password);

    if (token != null) {
      try {
        final sessionContext = await _apiService.getSessionContext(token);
        _sessionToken = token;
        _applySessionContext(sessionContext, fallbackUsername: user);
        _reconcileSelectedTicketEntity();
        _isAuthenticated = true;

        await AppStateStorage.saveSessionSnapshot(
          sessionToken: token,
          loggedUsername: _loggedUsername ?? user,
          activeProfile: _activeProfile,
          activeEntityId: _activeEntityId,
          activeEntityName: _activeEntityName,
          defaultEntityId: _defaultEntityId,
          selectedTicketEntityId: _selectedTicketEntityId,
          selectedTicketEntityName: _selectedTicketEntityName,
        );

        notifyListeners();
        synchronizeTickets();
        return true;
      } catch (e) {
        debugPrint('❌ Falha ao validar sessão após login: $e');
        await _clearLocalSessionData();
        notifyListeners();
        return false;
      }
    } else {
      await _clearLocalSessionData();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_sessionToken != null) {
      _apiService.hydrateSession(_sessionToken!);
      await _apiService.killSession();
    } else {
      _apiService.clearSession();
    }

    _isAuthenticated = false;
    _sessionToken = null;
    _loggedUsername = null;
    _loggedUserId = null;
    _activeProfile = null;
    _activeEntityId = null;
    _activeEntityName = null;
    _defaultEntityId = null;
    _selectedTicketEntityId = null;
    _selectedTicketEntityName = null;
    _availableEntities = const [];
    await AppStateStorage.clearSessionSnapshot();
    notifyListeners();
  }

  // --- Lógica de Criação e Sincronização de Tickets (Requisito: Offline) ---

  Future<String> submitTicket(Map<String, dynamic> formData) async {
    final stampedFormData = _stampEntityContext(formData);
    try {
      if (_isAuthenticated && _sessionToken != null) {
        debugPrint('📤 Tentando enviar ticket ONLINE ao GLPI...');

        final result = await _apiService.createTicket(
          stampedFormData,
          _sessionToken!,
        );

        if (result['success'] == true) {
          debugPrint(
            '✅ Ticket enviado com sucesso! ID: ${result['ticket_id']}',
          );
          notifyListeners();
          return "✅ Chamado enviado com sucesso! ID: ${result['ticket_id']}";
        } else {
          throw Exception(result['error_message'] ?? 'Erro desconhecido');
        }
      } else {
        throw Exception('Usuário não autenticado');
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao enviar online: $e. Salvando offline...');

      final newTicket = GlpiTicket.fromMap(stampedFormData);
      _pendingTickets.add(newTicket);
      await _savePendingTickets();

      notifyListeners();
      return "⚠️ Chamado salvo localmente (offline). Será sincronizado quando houver conexão.";
    }
  }

  bool _ticketBelongsToLoggedUser(Map<String, dynamic> ticket) {
    return AppStateTicketSupport.ticketBelongsToLoggedUser(
      ticket,
      loggedUsername: _loggedUsername,
      loggedUserId: _loggedUserId,
    );
  }

  // Método para buscar a lista de tickets (online + offline)
  Future<List<Map<String, dynamic>>> fetchTickets() async {
    List<Map<String, dynamic>> onlineTickets = [];

    if (_isAuthenticated && _sessionToken != null) {
      try {
        final rawTickets = await _apiService.getTickets(
          _sessionToken!,
          requesterUsername: _loggedUsername,
        );
        final personalTickets = rawTickets
            .where(_ticketBelongsToLoggedUser)
            .toList();

        final onlineById = <String, Map<String, dynamic>>{};
        for (final ticket in personalTickets) {
          final id = ticket['id']?.toString();
          if (id == null || id.isEmpty) continue;
          onlineById[id] = ticket;
        }

        if (rawTickets.length != personalTickets.length) {
          debugPrint(
            'Filtrando chamados por solicitante autenticado: ${personalTickets.length}/${rawTickets.length} permanecem em "Meus Chamados".',
          );
        }

        if (AppStateTicketSupport.isTechnicianProfile(_activeProfile)) {
          try {
            final newTickets = await _apiService.getTicketsByStatus(
              _sessionToken!,
              status: GlpiStatus.novo.code,
            );
            for (final ticket in newTickets) {
              final id = ticket['id']?.toString();
              if (id == null || id.isEmpty) continue;
              onlineById[id] = ticket;
            }
          } catch (e) {
            debugPrint('⚠️ Erro ao buscar fila operacional de Novos: $e');
            if (_isSessionInvalidError(e)) {
              await _handleSessionInvalid(e);
              rethrow;
            }
          }
        }

        onlineTickets = AppStateTicketSupport.decorateOnlineTickets(
          onlineById.values.toList(),
        );
      } catch (e) {
        debugPrint('❌ Erro ao buscar tickets online: $e');
        if (_isSessionInvalidError(e)) {
          await _handleSessionInvalid(e);
          rethrow;
        }
      }
    }

    final offlineTickets = AppStateTicketSupport.buildOfflineTickets(
      _pendingTickets,
    );

    return [...offlineTickets, ...onlineTickets];
  }

  Future<Map<String, dynamic>?> fetchTicketById(String ticketId) async {
    if (!_isAuthenticated || _sessionToken == null) {
      return null;
    }

    if (ticketId.isEmpty || ticketId.contains('OFFLINE')) {
      return null;
    }

    try {
      final ticket = await _apiService.getTicketById(ticketId, _sessionToken!);
      return ticket;
    } catch (e) {
      if (_isSessionInvalidError(e)) {
        await _handleSessionInvalid(e);
      }
      rethrow;
    }
  }

  // Método para alterar o status de um ticket (Retorna um Map para UI dar feedback completo)
  Future<Map<String, dynamic>> updateTicketStatus(
    String ticketId,
    String newStatus,
  ) async {
    if (_sessionToken == null || !_isAuthenticated) {
      return {'success': false, 'message': 'Usuário não autenticado.'};
    }

    // ✅ ALTERAÇÃO:
    // Onde: updateTicketStatus
    // Por quê: proteger tickets offline e manter a lógica nova de atribuição
    // O que faz: bloqueia offline, altera status e tenta autoatribuir em "Em andamento"
    if (ticketId.contains('OFFLINE')) {
      return {
        'success': false,
        'message':
            'Não é possível alterar status de chamados Offline. Sincronize primeiro.',
      };
    }

    try {
      final currentTicket = await _apiService.getTicketById(
        ticketId,
        _sessionToken!,
      );
      if (!GlpiStatusMapper.isOpenForInteraction(currentTicket['status'])) {
        return {
          'success': false,
          'message':
              'Chamado já está solucionado ou fechado. Recarregue a tela.',
        };
      }
    } catch (e) {
      if (_isSessionInvalidError(e)) {
        await _handleSessionInvalid(e);
      }
      if (_isPermissionDeniedError(e)) {
        return {
          'success': false,
          'permissionDenied': true,
          'message':
              'Seu perfil GLPI não tem permissão para alterar este chamado.',
        };
      }
      return {
        'success': false,
        'message': 'Falha ao confirmar o status atual do chamado.',
      };
    }

    final result = await _apiService.updateTicketStatus(
      ticketId,
      newStatus,
      _sessionToken!,
    );

    if (result['success'] != true) {
      final err = result['error_message']?.toString() ?? '';
      if (_isSessionInvalidError(err)) {
        await _handleSessionInvalid(err);
      }
      if (_isPermissionDeniedError(err)) {
        return {
          'success': false,
          'permissionDenied': true,
          'message':
              'Seu perfil GLPI não tem permissão para alterar este chamado.',
        };
      }
      return {
        'success': false,
        'message': result['error_message'] ?? 'Falha ao alterar status',
      };
    }

    bool isAssigned = false;

    final targetStatusCode = GlpiStatusMapper.code(newStatus);
    if (targetStatusCode == GlpiStatus.emAtendimento.code) {
      debugPrint('⚙️ Status alterado para Em Andamento. Assumindo a bronca...');

      try {
        _loggedUserId ??= await _apiService.getMyUserId(_sessionToken!);
      } catch (e) {
        if (_isSessionInvalidError(e)) {
          await _handleSessionInvalid(e);
        }
        rethrow;
      }

      if (_loggedUserId != null) {
        try {
          isAssigned = await _apiService.assignTicketToMe(
            ticketId,
            _loggedUserId!,
            _sessionToken!,
          );
        } catch (e) {
          if (_isSessionInvalidError(e)) {
            await _handleSessionInvalid(e);
          }
          rethrow;
        }
      }

      if (isAssigned) {
        return {
          'success': true,
          'message': 'Status alterado e Chamado assumido com sucesso!',
        };
      } else {
        return {
          'success': true,
          'message': 'Status alterado, mas FALHA ao atribuir o técnico.',
        };
      }
    }

    return {'success': true, 'message': 'Status atualizado com sucesso.'};
  }

  // Método para tentar sincronizar tickets pendentes
  Future<int> synchronizeTickets() async {
    if (_pendingTickets.isEmpty) {
      debugPrint('📝 Nenhum ticket pendente para sincronizar');
      return 0;
    }

    debugPrint(
      '🔄 Iniciando sincronização de ${_pendingTickets.length} tickets...',
    );
    int syncedCount = 0;
    List<GlpiTicket> failedTickets = [];

    for (var ticket in _pendingTickets) {
      final mapData = Map<String, dynamic>.from(ticket.toMap());

      final String? path =
          mapData['anexoPath'] ?? mapData['attachmentPath'] ?? ticket.anexoPath;

      if (path != null && path.isNotEmpty) {
        final file = File(path);

        if (await file.exists()) {
          debugPrint(
            '📎 [SYNC] Arquivo offline encontrado! Lendo bytes...: $path',
          );

          mapData['attachmentBytes'] = await file.readAsBytes();
          mapData['attachmentName'] =
              mapData['anexoName'] ?? path.split(Platform.pathSeparator).last;
        } else {
          debugPrint(
            '⚠️ [SYNC] ERRO CRÍTICO: O arquivo sumiu do celular! Caminho: $path',
          );
          mapData['content'] =
              '${mapData['content'] ?? ''}\n\n[AVISO DO APP: O anexo offline foi perdido pois o cache do sistema foi limpo]';
        }
      } else {
        debugPrint(
          'ℹ️ [SYNC] Nenhum caminho de anexo salvo neste ticket offline.',
        );
      }

      final result = await _apiService.createTicket(
        mapData,
        _sessionToken ?? '',
      );

      if (result['success'] == true) {
        debugPrint('✅ Ticket sincronizado: ${ticket.assunto}');
        syncedCount++;
      } else {
        debugPrint(
          '❌ Falha ao sincronizar: ${ticket.assunto} - ${result['error_message']}',
        );
        failedTickets.add(ticket);
      }
    }

    _pendingTickets = failedTickets;

    await _savePendingTickets();

    debugPrint(
      '✅ Sincronização concluída: $syncedCount tickets sincronizados, ${failedTickets.length} falharam',
    );

    notifyListeners();
    return syncedCount;
  }

  // === MÉTODOS PARA GERENCIAR MENSAGENS DE TICKETS ===

  /// Busca todas as mensagens E documentos (do Ticket + Followups + Solutions)
  Future<List<TicketMessage>> fetchTicketMessages(String ticketId) async {
    return AppStateMessageSupport.fetchTicketMessages(
      apiService: _apiService,
      isAuthenticated: _isAuthenticated,
      sessionToken: _sessionToken,
      ticketId: ticketId,
      isSessionInvalidError: _isSessionInvalidError,
      handleSessionInvalid: _handleSessionInvalid,
      log: debugPrint,
    );
  }

  /// Envia mensagem e processa múltiplos anexos
  /// Suporta envio de ACOMPANHAMENTO ou SOLUÇÃO formal
  Future<Map<String, dynamic>> sendTicketMessageWithAttachments({
    required String ticketId,
    required String messageContent,
    List<String> filePaths = const [],
    bool isSolution = false,
  }) async {
    return AppStateMessageSupport.sendTicketMessageWithAttachments(
      apiService: _apiService,
      isAuthenticated: _isAuthenticated,
      sessionToken: _sessionToken,
      ticketId: ticketId,
      messageContent: messageContent,
      filePaths: filePaths,
      isSolution: isSolution,
      uploadAndLinkImage: _uploadAndLinkImage,
      isSessionInvalidError: _isSessionInvalidError,
      handleSessionInvalid: _handleSessionInvalid,
      log: debugPrint,
    );
  }

  Future<Map<String, dynamic>> _uploadAndLinkImage(
    String ticketId,
    String imagePath, {
    String? targetItemType,
    String? targetItemId,
  }) async {
    return AppStateAttachmentSupport.uploadAndLinkImage(
      apiService: _apiService,
      isAuthenticated: _isAuthenticated,
      sessionToken: _sessionToken,
      ticketId: ticketId,
      imagePath: imagePath,
      targetItemType: targetItemType,
      targetItemId: targetItemId,
      isSessionInvalidError: _isSessionInvalidError,
      handleSessionInvalid: _handleSessionInvalid,
      log: debugPrint,
    );
  }

  /// Método público para baixar imagem segura (com token) para exibição no chat
  Future<Uint8List?> downloadImage(String url) async {
    return AppStateAttachmentSupport.downloadImage(
      apiService: _apiService,
      isAuthenticated: _isAuthenticated,
      sessionToken: _sessionToken,
      url: url,
      isSessionInvalidError: _isSessionInvalidError,
      handleSessionInvalid: _handleSessionInvalid,
      log: debugPrint,
    );
  }

  // ✅ ALTERAÇÃO:
  // Onde: método público para TicketDetailScreen puxar anexos do ticket
  // Por quê: TicketDetailScreen não pode acessar _apiService (private)
  // O que faz: busca documentos do ticket usando token atual
  Future<List<Map<String, dynamic>>> fetchTicketDocuments(
    String ticketId,
  ) async {
    if (!_isAuthenticated || _sessionToken == null) {
      debugPrint('⚠️ Não autenticado para buscar documentos');
      return [];
    }

    try {
      final docs = await _apiService.getTicketDocuments(
        ticketId,
        _sessionToken!,
      );
      return docs;
    } catch (e) {
      if (_isSessionInvalidError(e)) {
        await _handleSessionInvalid(e);
      }
      debugPrint('❌ Erro ao buscar documentos do ticket: $e');
      return [];
    }
  }

  // ====================================================================
  // VALIDAÇÃO DE SOLUÇÃO (STORY 4)
  // ====================================================================

  /// Aprova a solução e fecha o chamado
  Future<Map<String, dynamic>> approveSolution(
    String ticketId,
    String solutionId,
  ) async {
    return AppStateSolutionSupport.approveSolution(
      apiService: _apiService,
      isAuthenticated: _isAuthenticated,
      sessionToken: _sessionToken,
      ticketId: ticketId,
      solutionId: solutionId,
      isSessionInvalidError: _isSessionInvalidError,
      handleSessionInvalid: _handleSessionInvalid,
    );
  }

  /// Recusa a solução, exige justificativa (com múltiplos anexos) e reabre o chamado
  Future<Map<String, dynamic>> rejectSolution(
    String ticketId,
    String solutionId,
    String justification, {
    List<String> attachmentPaths = const [],
  }) async {
    return AppStateSolutionSupport.rejectSolution(
      apiService: _apiService,
      isAuthenticated: _isAuthenticated,
      sessionToken: _sessionToken,
      ticketId: ticketId,
      solutionId: solutionId,
      justification: justification,
      attachmentPaths: attachmentPaths,
      sendTicketMessageWithAttachments: sendTicketMessageWithAttachments,
      isSessionInvalidError: _isSessionInvalidError,
      handleSessionInvalid: _handleSessionInvalid,
    );
  }

  void _applySessionContext(
    Map<String, dynamic> sessionContext, {
    String? fallbackUsername,
  }) {
    _loggedUserId = sessionContext['userId'] as int?;

    final profileFromApi = sessionContext['profile']?.toString();
    if (profileFromApi != null && profileFromApi.trim().isNotEmpty) {
      _activeProfile = profileFromApi.trim();
    }

    final usernameFromApi = sessionContext['username']?.toString();
    final resolvedUsername = usernameFromApi?.trim().isNotEmpty == true
        ? usernameFromApi!.trim()
        : fallbackUsername?.trim();
    if (resolvedUsername != null && resolvedUsername.isNotEmpty) {
      _loggedUsername = resolvedUsername;
    }

    final activeEntityId = sessionContext['activeEntityId'] as int?;
    if (activeEntityId != null && activeEntityId > 0) {
      _activeEntityId = activeEntityId;
    }

    final activeEntityName = sessionContext['activeEntityName']?.toString();
    if (activeEntityName != null && activeEntityName.trim().isNotEmpty) {
      _activeEntityName = activeEntityName.trim();
    }

    final defaultEntityId = sessionContext['defaultEntityId'] as int?;
    if (defaultEntityId != null && defaultEntityId > 0) {
      _defaultEntityId = defaultEntityId;
    }

    final entities =
        (sessionContext['availableEntities'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((entity) => Map<String, dynamic>.from(entity))
            .toList();
    _availableEntities = entities;
  }

  Map<String, dynamic> _stampEntityContext(Map<String, dynamic> formData) {
    final stamped = Map<String, dynamic>.from(formData);
    final entityId =
        _parseOptionalInt(stamped['entities_id']) ??
        _selectedTicketEntityId ??
        _activeEntityId ??
        _defaultEntityId;

    if (entityId != null && entityId > 0) {
      stamped['entities_id'] = entityId;
    }

    final existingEntityName = stamped['entityName']?.toString().trim();
    if (existingEntityName != null && existingEntityName.isNotEmpty) {
      stamped['entityName'] = existingEntityName;
    } else if (_selectedTicketEntityName != null &&
        _selectedTicketEntityName!.isNotEmpty) {
      stamped['entityName'] = _selectedTicketEntityName;
    } else if (_activeEntityName != null && _activeEntityName!.isNotEmpty) {
      stamped['entityName'] = _activeEntityName;
    }

    return stamped;
  }

  void _reconcileSelectedTicketEntity({
    int? preferredId,
    String? preferredName,
  }) {
    final candidateId = preferredId ?? _selectedTicketEntityId;
    if (candidateId != null) {
      final matched = _findAvailableEntity(candidateId);
      if (matched != null) {
        _selectedTicketEntityId = matched['id'] as int;
        _selectedTicketEntityName =
            matched['name']?.toString() ?? preferredName;
        return;
      }
    }

    if (_activeEntityId != null) {
      final matched = _findAvailableEntity(_activeEntityId!);
      _selectedTicketEntityId = _activeEntityId;
      _selectedTicketEntityName =
          matched?['name']?.toString() ?? _activeEntityName ?? preferredName;
      return;
    }

    if (_availableEntities.isNotEmpty) {
      final first = _availableEntities.first;
      _selectedTicketEntityId = first['id'] as int?;
      _selectedTicketEntityName = first['name']?.toString();
      return;
    }

    _selectedTicketEntityId = null;
    _selectedTicketEntityName = preferredName;
  }

  Map<String, dynamic>? _findAvailableEntity(int entityId) {
    for (final entity in _availableEntities) {
      final id = _parseOptionalInt(entity['id']);
      if (id == entityId) {
        return entity;
      }
    }
    return null;
  }

  int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
