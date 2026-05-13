import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/glpi_status.dart';
import '../config/dtic_config.dart';
import '../models/dtic_formcreator_models.dart';
import '../models/dtic_ticket_models.dart';
import '../services/dtic_glpi_client.dart';
import '../utils/dtic_text.dart';
import 'dtic_app_state_storage.dart';

class DticAppState extends ChangeNotifier {
  DticAppState(this._client);

  final DticGlpiClient _client;

  bool _isAuthenticated = false;
  bool _isBusy = false;
  bool _isRestoringSession = false;
  String? _sessionToken;
  String? _username;
  String? _profile;
  int? _activeEntityId;
  String? _activeEntityName;
  String? _errorMessage;
  DticFormCatalog? _catalog;
  List<DticTicketSummary> _tickets = const [];
  DticPreparedSubmission? _lastPreparedSubmission;
  final Map<String, String> _lastReadDates = {};

  bool get isAuthenticated => _isAuthenticated;
  bool get isBusy => _isBusy;
  bool get isRestoringSession => _isRestoringSession;
  String? get username => _username;
  String? get profile => _profile;
  int? get activeEntityId => _activeEntityId;
  String? get activeEntityName => _activeEntityName;
  String? get errorMessage => _errorMessage;
  DticFormCatalog? get catalog => _catalog;
  List<DticTicketSummary> get tickets => List.unmodifiable(_tickets);
  DticPreparedSubmission? get lastPreparedSubmission => _lastPreparedSubmission;

  Future<void> restoreSession() async {
    _isRestoringSession = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await DticAppStateStorage.loadSessionSnapshot();
      final token = snapshot.sessionToken;
      if (token == null || token.isEmpty) {
        _client.clearSession();
        return;
      }

      _client.hydrateSession(token);
      final context = await _client.getSessionContext(token);
      _sessionToken = token;
      _applySessionContext(
        context,
        fallbackUsername: snapshot.username,
        fallbackProfile: snapshot.profile,
        fallbackEntityId: snapshot.activeEntityId,
        fallbackEntityName: snapshot.activeEntityName,
      );
      _isAuthenticated = true;
      await _loadReadDates();
      await loadCatalog();
      await loadTickets();
    } catch (_) {
      await _clearLocalSession();
    } finally {
      _isRestoringSession = false;
      notifyListeners();
    }
  }

  Future<bool> authenticate(String username, String password) async {
    return _runBusy(() async {
      final token = await _client.authenticate(username, password);
      final context = await _client.getSessionContext(token);
      _sessionToken = token;
      _applySessionContext(context, fallbackUsername: username);
      _isAuthenticated = true;
      _errorMessage = null;
      await _loadReadDates();
      await _saveSessionSnapshot();
      await loadCatalog();
      await loadTickets();
      return true;
    }, fallback: false);
  }

  Future<void> logout() async {
    await _client.killSession();
    await _clearLocalSession();
    notifyListeners();
  }

  Future<void> loadCatalog() async {
    final token = _requireSession();
    final catalog = await _client.fetchFormCatalog(token);
    _catalog = catalog;
    notifyListeners();
  }

  Future<void> loadTickets() async {
    final token = _requireSession();
    final username = _username;
    if (username == null || username.trim().isEmpty) {
      _tickets = const [];
      notifyListeners();
      return;
    }
    _tickets = await _client.fetchMyTickets(
      sessionToken: token,
      requesterUsername: username,
    );
    notifyListeners();
  }

  Future<DticTicketDetail> fetchTicketDetail(String ticketId) {
    return _client.fetchTicketDetail(
      sessionToken: _requireSession(),
      ticketId: ticketId,
    );
  }

  Future<List<DticTicketInteraction>> fetchTicketInteractions(String ticketId) {
    return _client.fetchTicketInteractions(
      sessionToken: _requireSession(),
      ticketId: ticketId,
    );
  }

  Future<List<DticTicketDocument>> fetchTicketDocuments(
    String ticketId, {
    List<DticTicketInteraction> interactions = const [],
  }) {
    return _client.fetchTicketDocuments(
      sessionToken: _requireSession(),
      ticketId: ticketId,
      interactions: interactions,
    );
  }

  Future<List<int>> downloadDocument(DticTicketDocument document) {
    return _client.downloadDocumentBytes(
      sessionToken: _requireSession(),
      document: document,
    );
  }

  Future<Map<String, dynamic>> sendTicketMessage({
    required String ticketId,
    required String message,
    List<String> attachmentPaths = const [],
  }) async {
    if (!DticConfig.ticketActionsEnabled) {
      return {
        'success': false,
        'error': 'Acoes de chamado DTIC nao estao habilitadas neste build.',
      };
    }

    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty && attachmentPaths.isEmpty) {
      return {'success': false, 'error': 'Informe uma mensagem ou anexo.'};
    }

    return _sendTicketInteractionWithAttachments(
      ticketId: ticketId,
      message: normalizedMessage,
      attachmentPaths: attachmentPaths,
      isSolution: false,
    );
  }

  Future<Map<String, dynamic>> sendTicketSolution({
    required String ticketId,
    required String message,
    List<String> attachmentPaths = const [],
  }) async {
    if (!DticConfig.ticketActionsEnabled) {
      return {
        'success': false,
        'error': 'Acoes de chamado DTIC nao estao habilitadas neste build.',
      };
    }

    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty && attachmentPaths.isEmpty) {
      return {'success': false, 'error': 'Informe uma solucao ou anexo.'};
    }

    return _sendTicketInteractionWithAttachments(
      ticketId: ticketId,
      message: normalizedMessage,
      attachmentPaths: attachmentPaths,
      isSolution: true,
    );
  }

  Future<Map<String, dynamic>> updateTicketStatus({
    required String ticketId,
    required String status,
  }) async {
    if (!DticConfig.ticketActionsEnabled) {
      return {
        'success': false,
        'error': 'Acoes de chamado DTIC nao estao habilitadas neste build.',
      };
    }

    return _guardedTicketAction(ticketId, () {
      return _client.updateTicketStatus(
        sessionToken: _requireSession(),
        ticketId: ticketId,
        status: status,
      );
    });
  }

  Future<Map<String, dynamic>> updateSolutionStatus({
    required String ticketId,
    required String solutionId,
    required int status,
  }) async {
    if (!DticConfig.ticketActionsEnabled) {
      return {
        'success': false,
        'error': 'Acoes de chamado DTIC nao estao habilitadas neste build.',
      };
    }

    return _guardedTicketAction(ticketId, () {
      return _client.updateSolutionStatus(
        sessionToken: _requireSession(),
        solutionId: solutionId,
        status: status,
      );
    });
  }

  Future<void> markTicketAsRead(String ticketId) async {
    final normalizedId = ticketId.trim();
    if (normalizedId.isEmpty) return;

    final now = DateTime.now().toIso8601String();
    _lastReadDates[normalizedId] = now;
    await DticAppStateStorage.saveReadDate(normalizedId, now);
    notifyListeners();
  }

  bool hasUnreadContent(String ticketId, String? serverLastUpdate) {
    final normalizedId = ticketId.trim();
    if (normalizedId.isEmpty) return false;

    final serverDate = _parseDate(serverLastUpdate);
    if (serverDate == null) return false;

    final localDate = _parseDate(_lastReadDates[normalizedId]);
    if (localDate == null) return true;

    return serverDate.isAfter(localDate);
  }

  Future<Map<String, dynamic>> _guardedTicketAction(
    String ticketId,
    Future<Map<String, dynamic>> Function() action,
  ) async {
    final token = _requireSession();
    final current = await _client.fetchTicketDetail(
      sessionToken: token,
      ticketId: ticketId,
    );
    if (!GlpiStatusMapper.isOpenForInteraction(current.status)) {
      return {
        'success': false,
        'error': 'Chamado ja esta solucionado ou fechado. Recarregue a tela.',
      };
    }

    final result = await action();
    if (result['success'] == true) {
      await loadTickets();
    }
    return result;
  }

  Future<Map<String, dynamic>> _sendTicketInteractionWithAttachments({
    required String ticketId,
    required String message,
    required List<String> attachmentPaths,
    required bool isSolution,
  }) {
    return _guardedTicketAction(ticketId, () async {
      final token = _requireSession();
      final effectiveMessage = message.isNotEmpty
          ? message
          : '[Anexo enviado pelo aplicativo]';

      final interaction = isSolution
          ? await _client.addTicketSolution(
              sessionToken: token,
              ticketId: ticketId,
              message: effectiveMessage,
            )
          : await _client.addTicketMessage(
              sessionToken: token,
              ticketId: ticketId,
              message: effectiveMessage,
            );

      if (interaction['success'] != true) return interaction;

      final interactionId = interaction['entity_id']?.toString();
      final targetType = isSolution ? 'ITILSolution' : 'ITILFollowup';
      var attachmentsSuccess = 0;
      var attachmentsFail = 0;
      final errors = <String>[];

      for (final path in attachmentPaths) {
        final result = await _uploadAttachment(
          sessionToken: token,
          ticketId: ticketId,
          path: path,
          targetType: targetType,
          targetId: interactionId,
        );
        if (result['success'] == true) {
          attachmentsSuccess++;
        } else {
          attachmentsFail++;
          errors.add(result['error']?.toString() ?? 'Falha no anexo.');
        }
      }

      return {
        'success': true,
        'entity_id': interactionId,
        'messageSent': message.isNotEmpty,
        'attachmentsSuccess': attachmentsSuccess,
        'attachmentsFail': attachmentsFail,
        'errors': errors,
      };
    });
  }

  Future<Map<String, dynamic>> _uploadAttachment({
    required String sessionToken,
    required String ticketId,
    required String path,
    required String targetType,
    required String? targetId,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return {'success': false, 'error': 'Arquivo nao encontrado: $path'};
    }

    final bytes = await file.readAsBytes();
    final filename = file.path.split(Platform.pathSeparator).last;
    if (targetId != null && targetId.isNotEmpty) {
      final result = await _client.uploadAndAttachToItem(
        sessionToken: sessionToken,
        itemType: targetType,
        itemId: targetId,
        bytes: bytes,
        filename: filename,
      );
      if (result['success'] == true) return result;
    }

    return _client.uploadAndAttachToTicket(
      sessionToken: sessionToken,
      ticketId: ticketId,
      bytes: bytes,
      filename: filename,
    );
  }

  DticPreparedSubmission validateFormAnswers(
    DticForm form,
    List<DticFormQuestion> questions,
    Map<int, dynamic> rawAnswers,
  ) {
    final answers = <String, dynamic>{};
    final missing = <int>[];
    var hasUnsupported = false;

    for (final question in questions) {
      if (!question.isSupported) {
        hasUnsupported = true;
        continue;
      }
      final answer = rawAnswers[question.id];
      final normalized = _normalizeAnswer(answer);
      if (question.required && normalized == null) {
        missing.add(question.id);
      }
      if (normalized != null) {
        answers['${question.id}'] = normalized;
      }
    }

    final prepared = DticPreparedSubmission(
      formId: form.id,
      answers: answers,
      missingRequiredQuestionIds: missing,
      hasUnsupportedQuestions: hasUnsupported,
    );
    _lastPreparedSubmission = prepared;
    notifyListeners();
    return prepared;
  }

  String _requireSession() {
    final token = _sessionToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sessao DTIC expirada.');
    }
    return token;
  }

  dynamic _normalizeAnswer(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      final entries = value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
      return entries.isEmpty ? null : entries;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  DateTime? _parseDate(String? value) {
    final text = DticText.cleanPlainText(value);
    if (text.isEmpty) return null;
    return DateTime.tryParse(text) ??
        DateTime.tryParse(text.replaceFirst(' ', 'T'));
  }

  Future<void> _loadReadDates() async {
    _lastReadDates
      ..clear()
      ..addAll(await DticAppStateStorage.loadReadDates());
  }

  Future<T> _runBusy<T>(
    Future<T> Function() action, {
    required T fallback,
  }) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await action();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return fallback;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void _applySessionContext(
    Map<String, dynamic> context, {
    String? fallbackUsername,
    String? fallbackProfile,
    int? fallbackEntityId,
    String? fallbackEntityName,
  }) {
    _username = _contextString(context['username'], fallbackUsername);
    _profile = _contextString(context['profile'], fallbackProfile);
    _activeEntityId = context['activeEntityId'] as int? ?? fallbackEntityId;
    _activeEntityName = _contextString(
      context['activeEntityName'],
      fallbackEntityName,
    );
  }

  String? _contextString(dynamic value, String? fallback) {
    final primary = DticText.cleanPlainText(value);
    if (primary.isNotEmpty) return primary;
    final secondary = DticText.cleanPlainText(fallback);
    return secondary.isEmpty ? null : secondary;
  }

  Future<void> _saveSessionSnapshot() async {
    final token = _sessionToken;
    final username = _username;
    if (token == null ||
        token.isEmpty ||
        username == null ||
        username.trim().isEmpty) {
      return;
    }

    await DticAppStateStorage.saveSessionSnapshot(
      sessionToken: token,
      username: username,
      profile: _profile,
      activeEntityId: _activeEntityId,
      activeEntityName: _activeEntityName,
    );
  }

  Future<void> _clearLocalSession() async {
    _client.clearSession();
    _isAuthenticated = false;
    _sessionToken = null;
    _username = null;
    _profile = null;
    _activeEntityId = null;
    _activeEntityName = null;
    _catalog = null;
    _tickets = const [];
    _lastPreparedSubmission = null;
    await DticAppStateStorage.clearSessionSnapshot();
  }
}
