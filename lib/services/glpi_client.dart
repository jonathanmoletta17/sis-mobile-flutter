import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../catalog/governed_service_catalog.dart';
import '../checklists/checklist_catalog.dart';
import '../checklists/checklist_submission.dart';
import '../config/glpi_config.dart';
import '../models/glpi_status.dart';
import '../models/glpi_user_ref.dart';
import '../utils/glpi_name_formatter.dart';
import 'glpi_client_support.dart';
import 'glpi_ticket_support.dart';

/// Cliente GLPI para o Flutter
/// ============================
/// Responsável pela comunicação com a API REST do GLPI.
/// Suporta autenticação, gerenciamento de sessão e operações CRUD.
///
/// Melhorias deste arquivo:
/// - Log consistente (status + body)
/// - Detecção clara de sessão inválida (401/403) para o AppState decidir logout/relogin
/// - Helpers para reduzir repetição
/// - Upload de anexo e vínculo ao Ticket (quando disponível)
class GlpiClient {
  String? _sessionToken;
  final Map<String, String> _userDisplayNameCache = <String, String>{};

  /// Obter status da sessão
  bool get isAuthenticated => _sessionToken != null;
  String? get sessionToken => _sessionToken;

  /// Reidrata o token de sessão no cliente (ex.: após restore local no app).
  void hydrateSession(String token) {
    _sessionToken = token;
  }

  /// Limpa o token local do cliente.
  void clearSession() {
    _sessionToken = null;
    _userDisplayNameCache.clear();
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_sessionToken != null) 'Session-Token': _sessionToken!,
  };

  // ====================================================================
  // LOG
  // ====================================================================

  void _debugLog(String message) => GlpiClientSupport.debugLog(message);

  void _logResponse(String label, http.Response response) =>
      GlpiClientSupport.logResponse(label, response);

  bool _isAuthError(int statusCode) =>
      GlpiClientSupport.isAuthError(statusCode);

  Exception _authException(http.Response response) =>
      GlpiClientSupport.authException(response);

  bool _isSessionInvalidException(Object error) =>
      GlpiClientSupport.isSessionInvalidException(error);

  String? _extractEntityIdFromBody(String body) =>
      GlpiClientSupport.extractEntityIdFromBody(body);

  String? _extractApiErrorMessage(String body) =>
      GlpiClientSupport.extractApiErrorMessage(body);

  Map<String, dynamic> _mapSearchTicketRow(Map<String, dynamic> row) =>
      GlpiClientSupport.mapSearchTicketRow(row);

  // ====================================================================
  // AUTH
  // ====================================================================

  Future<void> initSessionWithCredentials(
    String username,
    String password,
  ) async {
    final url = Uri.parse('${GlpiConfig.baseUrl}/initSession');

    _debugLog('Autenticando em: $url');
    _debugLog('Iniciando autenticação...');

    try {
      final response = await http
          .get(
            url,
            headers: {
              ..._headers,
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            },
          )
          .timeout(GlpiConfig.requestTimeout);

      _logResponse('AUTH', response);

      if (response.statusCode != 200) {
        throw GlpiClientSupport.mapAuthenticationFailure(
          Exception('AUTH_HTTP_${response.statusCode}'),
          statusCode: response.statusCode,
          body: response.body,
        );
      }

      final data = jsonDecode(response.body);
      _sessionToken = data['session_token'];
      _debugLog('Sessão iniciada com sucesso');
    } catch (e) {
      _debugLog('Falha durante autenticacao GLPI: $e');
      rethrow;
    }
  }

  Future<void> killSession() async {
    if (_sessionToken == null) return;

    final url = Uri.parse('${GlpiConfig.baseUrl}/killSession');
    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(GlpiConfig.requestTimeout);
      _logResponse('KILL_SESSION', response);
    } catch (e) {
      _debugLog('Erro ao encerrar sessão: $e');
    } finally {
      _sessionToken = null;
    }
  }

  /// Alias de autenticação usado pelo AppState
  Future<String?> authenticate(String username, String password) async {
    try {
      await initSessionWithCredentials(username, password);
      return _sessionToken;
    } catch (e) {
      _debugLog('Falha durante autenticacao GLPI: $e');
      if (e is GlpiAuthFailure) {
        rethrow;
      }
      throw GlpiClientSupport.mapAuthenticationFailure(e);
    }
  }

  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
    };

    final uri = Uri.parse('${GlpiConfig.baseUrl}/getFullSession');
    final response = await http
        .get(uri, headers: headers)
        .timeout(
          GlpiConfig.requestTimeout,
          onTimeout: () => throw Exception('Timeout ao validar sessão'),
        );

    _logResponse('GET_FULL_SESSION', response);

    if (_isAuthError(response.statusCode)) {
      throw _authException(response);
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao validar sessão: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    final session = data['session'] as Map<String, dynamic>? ?? {};
    final profile = session['glpiactiveprofile'] as Map<String, dynamic>?;
    final profileName = profile?['name']?.toString();
    final profileId = int.tryParse('${profile?['id'] ?? ''}');
    final userIdRaw = session['glpiID'];
    final username = session['glpiname']?.toString();
    final activeEntityIdRaw = session['glpiactive_entity'];
    final activeEntityName = session['glpiactive_entity_name']?.toString();
    final defaultEntityIdRaw = session['glpidefault_entity'];
    final rawProfileEntities =
        session['glpiactiveprofile']?['entities'] as Map<String, dynamic>? ??
        {};
    final availableEntities = rawProfileEntities.values
        .whereType<Map>()
        .map((dynamic entity) {
          final map = Map<String, dynamic>.from(entity as Map);
          final entityId = int.tryParse('${map['id'] ?? ''}');
          final entityName = map['name']?.toString();
          if (entityId == null || entityName == null || entityName.isEmpty) {
            return null;
          }
          return {'id': entityId, 'name': entityName};
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    final groups = <Map<String, dynamic>>[];
    final rawGroups = session['glpigroups'];
    void addGroup(dynamic rawId, dynamic rawName) {
      final id = int.tryParse('${rawId ?? ''}');
      final name = rawName?.toString().trim();
      if (id == null || id <= 0 || name == null || name.isEmpty) return;
      groups.add({'id': id, 'name': name});
    }

    if (rawGroups is Map) {
      for (final entry in rawGroups.entries) {
        final value = entry.value;
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);
          addGroup(entry.key, map['name'] ?? map['completename']);
        } else {
          addGroup(entry.key, value);
        }
      }
    } else if (rawGroups is List) {
      for (final value in rawGroups) {
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);
          addGroup(map['id'], map['name'] ?? map['completename']);
        } else {
          addGroup(value, 'Grupo $value');
        }
      }
    }

    return {
      'profile': profileName,
      'profileId': profileId,
      'userId': int.tryParse('${userIdRaw ?? ''}'),
      'username': username,
      'activeEntityId': int.tryParse('${activeEntityIdRaw ?? ''}'),
      'activeEntityName': activeEntityName,
      'defaultEntityId': int.tryParse('${defaultEntityIdRaw ?? ''}'),
      'availableEntities': availableEntities,
      'groups': groups,
    };
  }

  // ====================================================================
  // MÉTODOS QUE O APP PRECISA (categorias/tickets/status)
  // ====================================================================

  Future<List<dynamic>> getItilCategories() async {
    final url = Uri.parse('${GlpiConfig.baseUrl}/ITILCategory');

    final response = await http
        .get(url, headers: _headers)
        .timeout(GlpiConfig.requestTimeout);
    _logResponse('ITILCategory', response);

    if (response.statusCode != 200) {
      if (_isAuthError(response.statusCode)) throw _authException(response);
      throw Exception(
        'Erro ao buscar categorias: ${response.statusCode} - ${response.body}',
      );
    }

    return jsonDecode(response.body);
  }

  /// Busca tickets do usuario (online).
  /// Prioriza filtro server-side por requerente para evitar mistura de dados
  /// quando o perfil logado tem visibilidade ampla (ex.: Super-Admin).
  Future<List<Map<String, dynamic>>> getTickets(
    String sessionToken, {
    String? requesterUsername,
    int? requesterUserId,
    List<int> actorFieldIds = const [],
  }) async {
    _debugLog('Buscando tickets...');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final normalizedRequester = requesterUsername?.trim();
      if ((requesterUserId != null && requesterUserId > 0) ||
          (normalizedRequester != null && normalizedRequester.isNotEmpty)) {
        final searchUri = GlpiClientSupport.buildRequesterTicketSearchUri(
          GlpiConfig.baseUrl,
          requesterUserId: requesterUserId,
          requesterUsername: normalizedRequester,
          actorFieldIds: actorFieldIds,
        );
        _debugLog('GET: $searchUri');

        final searchResponse = await http
            .get(searchUri, headers: headers)
            .timeout(
              GlpiConfig.requestTimeout,
              onTimeout: () =>
                  throw Exception('Timeout ao buscar tickets do requerente'),
            );

        _logResponse('SEARCH_TICKETS_REQUESTER', searchResponse);

        if (searchResponse.statusCode == 200 ||
            searchResponse.statusCode == 206) {
          final payload = (jsonDecode(searchResponse.body) as Map)
              .cast<String, dynamic>();
          final rows = payload['data'] as List<dynamic>? ?? const [];
          final mapped = rows
              .whereType<Map>()
              .map((row) => _mapSearchTicketRow(row.cast<String, dynamic>()))
              .toList();
          _debugLog(
            '${mapped.length} tickets encontrados para o requerente $normalizedRequester.',
          );
          return mapped;
        }

        if (_isAuthError(searchResponse.statusCode)) {
          throw _authException(searchResponse);
        }

        _debugLog(
          'search/Ticket por requerente falhou '
          '[${searchResponse.statusCode}]. Aplicando fallback.',
        );
      }

      // Fallback: comportamento anterior usando /Ticket direto.
      final uri = Uri.parse(
        '${GlpiConfig.baseUrl}/Ticket?expand_dropdowns=true&range=0-100&sort=date_mod&order=DESC',
      );
      _debugLog('GET: $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            GlpiConfig.requestTimeout,
            onTimeout: () => throw Exception('Timeout ao buscar tickets'),
          );

      _logResponse('GET_TICKETS', response);

      if (response.statusCode == 200 || response.statusCode == 206) {
        final List<dynamic> tickets = jsonDecode(response.body);
        _debugLog('${tickets.length} tickets encontrados.');
        return tickets.map((t) => t as Map<String, dynamic>).toList();
      }

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      throw Exception(
        'Erro ao buscar tickets: [${response.statusCode}] - ${response.body}',
      );
    } catch (e) {
      _debugLog('Falha ao buscar tickets: $e');
      rethrow;
    }
  }

  /// Busca fila operacional por status, sem restringir por requerente.
  /// O escopo continua sendo a ACL real do GLPI para a sessão ativa.
  Future<List<Map<String, dynamic>>> getTicketsByStatus(
    String sessionToken, {
    required int status,
    int rangeEnd = 500,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
    };

    final searchUri = Uri.parse(
      '${GlpiConfig.baseUrl}/search/Ticket'
      '?criteria[0][field]=12'
      '&criteria[0][searchtype]=equals'
      '&criteria[0][value]=$status'
      '&forcedisplay[0]=2'
      '&forcedisplay[1]=1'
      '&forcedisplay[2]=12'
      '&forcedisplay[3]=15'
      '&forcedisplay[4]=4'
      '&forcedisplay[5]=7'
      '&forcedisplay[6]=5'
      '&forcedisplay[7]=8'
      '&forcedisplay[8]=65'
      '&sort=15'
      '&order=DESC'
      '&range=0-$rangeEnd',
    );

    final response = await http
        .get(searchUri, headers: headers)
        .timeout(GlpiConfig.requestTimeout);

    _logResponse('SEARCH_TICKETS_STATUS_$status', response);

    if (response.statusCode == 200 || response.statusCode == 206) {
      final payload = (jsonDecode(response.body) as Map)
          .cast<String, dynamic>();
      final rows = payload['data'] as List<dynamic>? ?? const [];
      return rows
          .whereType<Map>()
          .map((row) => _mapSearchTicketRow(row.cast<String, dynamic>()))
          .toList();
    }

    if (_isAuthError(response.statusCode)) {
      throw _authException(response);
    }

    throw Exception(
      'Erro ao buscar tickets por status $status: [${response.statusCode}] - ${response.body}',
    );
  }

  /// Busca chamados para o campo glpiselect "Checklist Programada".
  /// Query vazia retorna os mais recentes (sem filtro de titulo).
  /// Retorna lista de {id: int, name: String} ordenada por data DESC.
  Future<List<Map<String, dynamic>>> searchTicketsForGlpiSelect(
    String sessionToken, {
    String query = '',
    int maxResults = 20,
  }) async {
    final text = query.trim();
    final String criteria = text.isEmpty
        ? ''
        : '&criteria[0][field]=1'
              '&criteria[0][searchtype]=contains'
              '&criteria[0][value]=${Uri.encodeQueryComponent(text)}';

    final uri = Uri.parse(
      '${GlpiConfig.baseUrl}/search/Ticket'
      '?forcedisplay[0]=2'
      '&forcedisplay[1]=1'
      '&sort=15'
      '&order=DESC'
      '&range=0-${maxResults - 1}'
      '$criteria',
    );

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
    };

    final response = await http
        .get(uri, headers: headers)
        .timeout(GlpiConfig.requestTimeout);
    _logResponse('SEARCH_TICKETS_GLPISELECT', response);

    if (response.statusCode == 200 || response.statusCode == 206) {
      final payload = (jsonDecode(response.body) as Map)
          .cast<String, dynamic>();
      final rows = payload['data'] as List<dynamic>? ?? const [];
      return rows
          .whereType<Map>()
          .map((row) {
            final r = row.cast<String, dynamic>();
            final id = int.tryParse('${r['2'] ?? ''}') ?? 0;
            final name = r['1']?.toString() ?? '';
            return {'id': id, 'name': name};
          })
          .where(
            (t) => (t['id'] as int) > 0 && (t['name'] as String).isNotEmpty,
          )
          .toList();
    }

    if (_isAuthError(response.statusCode)) throw _authException(response);
    return const [];
  }

  Future<Map<String, dynamic>> getTicketById(
    String ticketId,
    String sessionToken,
  ) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
    };

    final uri = Uri.parse(
      '${GlpiConfig.baseUrl}/Ticket/$ticketId?expand_dropdowns=true&with_documents=true',
    );
    final response = await http
        .get(uri, headers: headers)
        .timeout(
          GlpiConfig.requestTimeout,
          onTimeout: () =>
              throw Exception('Timeout ao buscar detalhe do ticket'),
        );

    _logResponse('GET_TICKET_DETAIL', response);

    if (_isAuthError(response.statusCode)) {
      throw _authException(response);
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar ticket $ticketId: ${response.statusCode} - ${response.body}',
      );
    }

    final ticket = (jsonDecode(response.body) as Map).cast<String, dynamic>();
    await _hydrateTicketUsers(ticketId, headers, ticket);
    return ticket;
  }

  Future<void> _hydrateTicketUsers(
    String ticketId,
    Map<String, String> headers,
    Map<String, dynamic> ticket,
  ) async {
    try {
      final relationUri = Uri.parse(
        '${GlpiConfig.baseUrl}/Ticket/$ticketId/Ticket_User?range=0-200',
      );
      final relationResp = await http
          .get(relationUri, headers: headers)
          .timeout(GlpiConfig.requestTimeout);

      if (_isAuthError(relationResp.statusCode)) {
        throw _authException(relationResp);
      }

      if (relationResp.statusCode != 200 && relationResp.statusCode != 206) {
        return;
      }

      final relations = jsonDecode(relationResp.body);
      if (relations is! List) return;

      dynamic requesterRelation;
      dynamic assigneeRelation;
      for (final relation in relations) {
        if (relation is! Map) continue;
        final type = relation['type']?.toString();
        if (type == '1' && requesterRelation == null) {
          requesterRelation = relation;
        } else if (type == '2' && assigneeRelation == null) {
          assigneeRelation = relation;
        }
        if (requesterRelation != null && assigneeRelation != null) break;
      }

      if (requesterRelation != null) {
        final requesterId = requesterRelation['users_id']?.toString();
        if (requesterId != null && requesterId.isNotEmpty) {
          final requesterName =
              await _resolveUserDisplayName(requesterId, headers) ??
              GlpiNameFormatter.fallbackUserLabel(requesterId);
          ticket['requester_user_id'] = requesterId;
          ticket['users_id_recipient_id'] = requesterId;
          ticket['Users_id_recipient_id'] = requesterId;
          ticket['users_id_recipient'] = requesterName;
          ticket['Users_id_recipient'] = requesterName;
        }
      }

      if (assigneeRelation != null) {
        final assigneeId = assigneeRelation['users_id']?.toString();
        if (assigneeId != null && assigneeId.isNotEmpty) {
          final assigneeName =
              await _resolveUserDisplayName(assigneeId, headers) ??
              GlpiNameFormatter.fallbackUserLabel(
                assigneeId,
                prefix: 'Tecnico',
              );
          ticket['assignee_user_id'] = assigneeId;
          ticket['users_id_assign'] = assigneeName;
          ticket['Users_id_assign'] = assigneeName;
        }
      }

      await _hydrateTicketGroups(ticketId, headers, ticket);
    } catch (e) {
      if (_isSessionInvalidException(e)) rethrow;
      _debugLog('Falha ao hidratar solicitante/tecnico responsavel: $e');
    }
  }

  Future<void> _hydrateTicketGroups(
    String ticketId,
    Map<String, String> headers,
    Map<String, dynamic> ticket,
  ) async {
    try {
      final relationUri = Uri.parse(
        '${GlpiConfig.baseUrl}/Ticket/$ticketId/Group_Ticket?range=0-200',
      );
      final relationResp = await http
          .get(relationUri, headers: headers)
          .timeout(GlpiConfig.requestTimeout);

      if (_isAuthError(relationResp.statusCode)) {
        throw _authException(relationResp);
      }

      if (relationResp.statusCode != 200 && relationResp.statusCode != 206) {
        return;
      }

      final relations = jsonDecode(relationResp.body);
      if (relations is! List) return;

      dynamic assignedGroupRelation;
      for (final relation in relations) {
        if (relation is! Map) continue;
        final type = relation['type']?.toString();
        if ((type == '2' || type == null) && assignedGroupRelation == null) {
          assignedGroupRelation = relation;
          break;
        }
      }

      if (assignedGroupRelation == null) return;

      final groupId = assignedGroupRelation['groups_id']?.toString();
      if (groupId == null || groupId.isEmpty) return;

      final groupName = await _resolveGroupDisplayName(groupId, headers);
      ticket['assigned_group_id'] = groupId;
      if (groupName != null && groupName.trim().isNotEmpty) {
        ticket['assigned_group_name'] = groupName.trim();
      }
    } catch (e) {
      if (_isSessionInvalidException(e)) rethrow;
      _debugLog('Falha ao hidratar fila/grupo responsavel do ticket: $e');
    }
  }

  Future<String?> _resolveGroupDisplayName(
    String groupId,
    Map<String, String> headers,
  ) async {
    try {
      final groupUri = Uri.parse(
        '${GlpiConfig.baseUrl}/Group/$groupId?expand_dropdowns=true',
      );
      final groupResp = await http
          .get(groupUri, headers: headers)
          .timeout(GlpiConfig.requestTimeout);

      if (_isAuthError(groupResp.statusCode)) {
        throw _authException(groupResp);
      }

      if (groupResp.statusCode != 200) return null;

      final groupMap = (jsonDecode(groupResp.body) as Map)
          .cast<String, dynamic>();
      final name = groupMap['completename'] ?? groupMap['name'];
      final text = name?.toString().trim();
      if (text == null || text.isEmpty || text == groupId) return null;
      return text;
    } catch (e) {
      if (_isSessionInvalidException(e)) rethrow;
      return null;
    }
  }

  Future<String?> _resolveUserDisplayName(
    String userId,
    Map<String, String> headers,
  ) async {
    final cached = _userDisplayNameCache[userId];
    if (cached != null && cached.trim().isNotEmpty) return cached;

    try {
      final userUri = Uri.parse(
        '${GlpiConfig.baseUrl}/User/$userId?expand_dropdowns=true',
      );
      final userResp = await http
          .get(userUri, headers: headers)
          .timeout(GlpiConfig.requestTimeout);

      if (_isAuthError(userResp.statusCode)) {
        throw _authException(userResp);
      }

      if (userResp.statusCode != 200) return null;

      final userMap = (jsonDecode(userResp.body) as Map)
          .cast<String, dynamic>();
      final displayName = GlpiNameFormatter.formatNameFromMap(userMap).trim();
      if (displayName.isEmpty ||
          GlpiNameFormatter.extractNumericId(displayName) != null) {
        return null;
      }
      _userDisplayNameCache[userId] = displayName;
      return displayName;
    } catch (e) {
      if (_isSessionInvalidException(e)) rethrow;
      return null;
    }
  }

  Future<List<GlpiUserRef>> searchUsers(
    String query,
    String sessionToken,
  ) async {
    final text = query.trim();
    if (text.length < 3) return const [];

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
    };
    // O Worker SIS só repassa caminhos do allowlist; `search/User` NÃO está
    // permitido (apenas `search/Ticket`). `GET /User?searchText[...]` passa
    // pelo allowlist (`User` + query) e filtra "contém" no GLPI. O perfil
    // helpdesk (Solicitante) não tem direito REST de ler User, então o Worker
    // eleva esses GETs com uma sessão de serviço (ver workers-vpc/src/index.js,
    // DIRECTORY_READ_PATTERN). Buscamos por login e nome real em paralelo.
    Future<List<dynamic>> fetchBy(String field) async {
      final uri = Uri.parse(
        '${GlpiConfig.baseUrl}/User',
      ).replace(queryParameters: {'searchText[$field]': text, 'range': '0-15'});
      final response = await http
          .get(uri, headers: headers)
          .timeout(GlpiConfig.requestTimeout);
      _logResponse('SEARCH_USER[$field]', response);
      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }
      // 404 do GLPI em getItems vazio é tratado como "sem resultados".
      if (response.statusCode == 404) return const [];
      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception(
          'Erro ao buscar usuários: ${response.statusCode} - ${response.body}',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) {
        return decoded['data'] as List;
      }
      return const [];
    }

    final results = await Future.wait([
      fetchBy('name'),
      fetchBy('realname'),
      fetchBy('firstname'),
    ], eagerError: false);

    final users = <GlpiUserRef>[];
    final seen = <int>{};
    for (final rows in results) {
      for (final row in rows) {
        if (row is! Map) continue;
        final user = GlpiUserRef.fromSearchRow(Map<String, dynamic>.from(row));
        if (user == null || !seen.add(user.id)) continue;
        users.add(user);
      }
    }
    return users;
  }

  Future<GlpiUserRef?> getUserById(int userId, String sessionToken) async {
    if (userId <= 0) return null;

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
    };
    final uri = Uri.parse('${GlpiConfig.baseUrl}/User/$userId');

    final response = await http
        .get(uri, headers: headers)
        .timeout(GlpiConfig.requestTimeout);
    _logResponse('GET_USER', response);

    if (_isAuthError(response.statusCode)) {
      throw _authException(response);
    }
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar usuário $userId: ${response.statusCode} - ${response.body}',
      );
    }

    final userMap = (jsonDecode(response.body) as Map).cast<String, dynamic>();
    final displayName = GlpiNameFormatter.formatNameFromMap(userMap).trim();
    final firstName = _fieldText(userMap['firstname'] ?? userMap['first_name']);
    final login = _fieldText(userMap['name'] ?? userMap['login']);
    final realName = _fieldText(userMap['realname'] ?? userMap['real_name']);
    return GlpiUserRef(
      id: userId,
      displayName: displayName.isEmpty
          ? 'Usuário não identificado'
          : displayName,
      login: login,
      firstName: firstName,
      realName: realName,
      defaultEntityId: _parseGlpiId(userMap['entities_id']),
    );
  }

  int? _parseGlpiId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Map) return _parseGlpiId(value['id'] ?? value['value']);
    return int.tryParse(value.toString().trim());
  }

  String? _fieldText(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return _fieldText(
        value['name'] ?? value['label'] ?? value['completename'] ?? value['id'],
      );
    }
    final text = value.toString().trim();
    return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
  }

  /// Atualiza status do ticket
  Future<Map<String, dynamic>> updateTicketStatus(
    String ticketId,
    String newStatus,
    String sessionToken,
  ) async {
    _debugLog('Atualizando status do ticket $ticketId para $newStatus...');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final statusId = GlpiStatusMapper.code(newStatus);
      if (statusId == null) {
        _debugLog(
          'Status invalido para atualizacao do ticket $ticketId: "$newStatus".',
        );
        return {
          'success': false,
          'error_message':
              'Status invalido: "$newStatus". Operacao cancelada para evitar '
              'rebaixar o chamado indevidamente.',
        };
      }
      final payload = {
        'input': {'id': ticketId, 'status': statusId},
      };

      final uri = Uri.parse('${GlpiConfig.baseUrl}/Ticket/$ticketId');

      _debugLog('PUT: $uri');
      _debugLog('Payload: ${jsonEncode(payload)}');

      final response = await http
          .put(uri, headers: headers, body: jsonEncode(payload))
          .timeout(
            GlpiConfig.requestTimeout,
            onTimeout: () => throw Exception('Timeout ao atualizar ticket'),
          );

      _logResponse('UPDATE_STATUS', response);

      if (response.statusCode == 200) {
        _debugLog('Status do ticket atualizado com sucesso.');
        return {'success': true, 'message': 'Status atualizado com sucesso.'};
      }

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      throw Exception(
        'Erro ao atualizar ticket: [${response.statusCode}] - ${response.body}',
      );
    } catch (e) {
      _debugLog('Falha ao atualizar ticket: $e');
      return {
        'success': false,
        'message': 'Falha ao atualizar status.',
        'error_message': e.toString(),
      };
    }
  }

  /// Valida (aprova/recusa) a última solução do ticket pelo fluxo do REQUERENTE.
  ///
  /// O requerente aprova/recusa a solução do próprio chamado via followup com
  /// `add_close`/`add_reopen` — mecanismo nativo do GLPI que usa o direito de
  /// followup (que o perfil Solicitante TEM), e não o `UPDATE` de ticket:
  /// - aprovação: `POST /TicketFollowup` com `add_close=1` (fecha o chamado);
  /// - recusa: `POST /TicketFollowup` com `add_reopen=1` (reabre o chamado).
  ///
  /// NÃO usar `PUT /Ticket {status}`: exige `UPDATE` em ticket, direito que o
  /// Solicitante não tem -> `ERROR_GLPI_UPDATE`. `PUT /ITILSolution` exige
  /// `maySolve` (solução técnica) -> `ERROR_RIGHT_MISSING`. Ambos os caminhos
  /// antigos falhavam para o Solicitante; o de followup foi validado E2E
  /// (2026-06-20) retornando 201 sem conceder permissão extra ao perfil.
  /// Aprova (`add_close`) ou recusa (`add_reopen`) a solução via TicketFollowup —
  /// caminho nativo do requerente (Solicitante tem direito de followup, mas NÃO
  /// de UPDATE em Ticket, logo não pode setar status diretamente).
  ///
  /// A1 (auditoria 2026-06-25, confirmado E2E + config GLPI): na RECUSA, o GLPI
  /// reabre o chamado para **Novo (1)**. Isto é POR DESIGN — não é defeito:
  ///  - o GLPI 10.0.2 reabre para Novo nativamente no `add_reopen`;
  ///  - a instância tem a RuleTicket #178 "Chamados recusados voltam para novos"
  ///    (critério status==2 → ação status=1), confirmando a intenção de negócio.
  /// Logo, recusado → Novo é o comportamento esperado e o app está alinhado.
  /// Nenhuma regra (ativa ou inativa) manda o reopen para "Em Atendimento".
  Future<Map<String, dynamic>> updateTicketSolutionDecision({
    required String ticketId,
    required bool approve,
    required String sessionToken,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final payload = {
        'input': {
          'tickets_id': ticketId,
          'content': approve
              ? 'Solução aprovada pelo solicitante.'
              : 'Solução recusada pelo solicitante.',
          if (approve) 'add_close': 1 else 'add_reopen': 1,
        },
      };

      final uri = Uri.parse('${GlpiConfig.baseUrl}/TicketFollowup');
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(GlpiConfig.requestTimeout);

      _logResponse(approve ? 'APPROVE_SOLUTION' : 'REJECT_SOLUTION', response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': approve
              ? 'Solução aprovada com sucesso.'
              : 'Solução recusada com sucesso.',
        };
      }

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      return {
        'success': false,
        'message': approve
            ? 'Falha ao aprovar solução.'
            : 'Falha ao recusar solução.',
        'error_message': '[${response.statusCode}] ${response.body}',
      };
    } catch (e) {
      _debugLog('Falha ao validar solução via followup: $e');
      return {
        'success': false,
        'message': approve
            ? 'Falha ao aprovar solução.'
            : 'Falha ao recusar solução.',
        'error_message': e.toString(),
      };
    }
  }

  // ====================================================================
  // AJUSTE PRINCIPAL: FORMULÁRIO COMPLETO NO CONTENT + CONTACT
  // ====================================================================

  // ====================================================================
  // ANEXOS (UPLOAD + VINCULAR AO TICKET)
  // ====================================================================

  MediaType? _parseMimeType(String? mime) {
    return GlpiTicketSupport.parseMimeType(mime);
  }

  String? _guessMimeFromFilename(String filename) {
    return GlpiTicketSupport.guessMimeFromFilename(filename);
  }

  void _logMultipartBasics(String label, http.MultipartRequest req) {
    GlpiTicketSupport.logMultipartBasics(label, req, _debugLog);
  }

  Future<void> uploadAndAttachToTicket({
    required String sessionToken,
    required String ticketId,
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) async {
    await uploadAndAttachToItem(
      sessionToken: sessionToken,
      itemType: 'Ticket',
      itemId: ticketId,
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
  }

  Future<void> uploadAndAttachToItem({
    required String sessionToken,
    required String itemType,
    required String itemId,
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) async {
    final resolvedMime = (mimeType != null && mimeType.trim().isNotEmpty)
        ? mimeType.trim()
        : _guessMimeFromFilename(filename);

    final contentType = _parseMimeType(resolvedMime);

    final uriDirect = Uri.parse(
      '${GlpiConfig.baseUrl}/$itemType/$itemId/Document',
    );
    _debugLog(
      '[UPLOAD] Tentando anexo direto em $itemType/$itemId -> $uriDirect',
    );
    _debugLog('[UPLOAD] Arquivo: $filename (${bytes.length} bytes)');

    final linkedDocumentIdsBefore = await _getLinkedDocumentIdsForItem(
      sessionToken: sessionToken,
      itemType: itemType,
      itemId: itemId,
    );

    final request = http.MultipartRequest('POST', uriDirect);
    request.headers.addAll({
      'Accept': 'application/json',
      if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
    });

    request.files.add(
      http.MultipartFile.fromString(
        'uploadManifest',
        jsonEncode({
          'input': {
            'name': filename,
            '_filename': [filename],
            'items_id': itemId,
            'itemtype': itemType,
          },
        }),
        contentType: MediaType('application', 'json'),
      ),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'filename[0]',
        bytes,
        filename: filename,
        contentType: contentType,
      ),
    );

    _logMultipartBasics('UPLOAD_ITEM_DOCUMENT_REQ', request);

    final streamed = await request.send().timeout(
      GlpiConfig.requestTimeout,
      onTimeout: () => throw Exception('Timeout no upload do anexo'),
    );

    final response = await http.Response.fromStream(streamed);
    _logResponse('UPLOAD_ITEM_DOCUMENT', response);

    if (_isAuthError(response.statusCode)) {
      throw _authException(response);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final returnedDocumentId = GlpiClientSupport.extractDocumentIdFromBody(
        response.body,
      );
      for (var attempt = 0; attempt < 3; attempt++) {
        final linkedDocumentIdsAfter = await _getLinkedDocumentIdsForItem(
          sessionToken: sessionToken,
          itemType: itemType,
          itemId: itemId,
        );
        if (GlpiClientSupport.verifiesDocumentUploadLink(
          before: linkedDocumentIdsBefore,
          after: linkedDocumentIdsAfter,
          documentId: returnedDocumentId,
        )) {
          _debugLog(
            'Anexo direto confirmado por novo vinculo Document_Item em $itemType/$itemId.',
          );
          return;
        }
        if (attempt < 2) {
          await Future<void>.delayed(
            Duration(milliseconds: 350 * (attempt + 1)),
          );
        }
      }
    }

    throw Exception(
      'Upload de anexo não retornou ID verificável nem novo vínculo '
      'Document_Item em $itemType/$itemId. Operação abortada para evitar '
      'criação de Document sem vínculo no GLPI SIS.',
    );
  }

  Future<Set<String>> _getLinkedDocumentIdsForItem({
    required String sessionToken,
    required String itemType,
    required String itemId,
  }) async {
    final embeddedIds = await _getEmbeddedDocumentIdsForItem(
      sessionToken: sessionToken,
      itemType: itemType,
      itemId: itemId,
    );
    if (embeddedIds != null) return embeddedIds;

    final uri = Uri.parse(
      '${GlpiConfig.baseUrl}/$itemType/$itemId/Document_Item',
    );
    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
          },
        )
        .timeout(GlpiConfig.requestTimeout);

    if (_isAuthError(response.statusCode)) throw _authException(response);
    if (response.statusCode != 200 && response.statusCode != 206) {
      _debugLog(
        'Falha ao consultar Document_Item de $itemType/$itemId para verificacao de upload: [${response.statusCode}] ${response.body}',
      );
      return <String>{};
    }

    return GlpiClientSupport.extractDocumentIdsFromDocumentItemBody(
      response.body,
    );
  }

  Future<void> linkDocumentToItem({
    required String sessionToken,
    required String itemId,
    required String documentId,
    required String itemType,
  }) async {
    final uri = Uri.parse('${GlpiConfig.baseUrl}/Document_Item');

    _debugLog(
      'Vinculando Document $documentId ao item $itemType/$itemId -> $uri',
    );

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
    };

    final payload = {
      'input': {
        'documents_id': int.tryParse(documentId) ?? documentId,
        'items_id': int.tryParse(itemId) ?? itemId,
        'itemtype': itemType,
      },
    };

    _debugLog('Payload Link: ${jsonEncode(payload)}');

    final response = await http
        .post(uri, headers: headers, body: jsonEncode(payload))
        .timeout(GlpiConfig.requestTimeout);

    _logResponse('LINK_DOCUMENT', response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _debugLog('Anexo vinculado ao ticket com sucesso.');
      return;
    }

    if (_isAuthError(response.statusCode)) {
      throw _authException(response);
    }

    throw Exception(
      'Falha ao vincular anexo: [${response.statusCode}] ${response.body}',
    );
  }

  // ====================================================================
  // CRIAR TICKET (TENTA ENVIAR ANEXO SE EXISTIR)
  // ====================================================================

  Future<Map<String, dynamic>> createTicket(
    Map<String, dynamic> formData,
    String sessionToken,
  ) async {
    _debugLog('Criando novo ticket...');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final payload = GlpiTicketSupport.buildCreateTicketPayload(formData);

      final uri = Uri.parse('${GlpiConfig.baseUrl}/Ticket');

      _debugLog('POST: $uri');
      _debugLog('Payload Ticket: ${jsonEncode(payload)}');

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(
            GlpiConfig.requestTimeout,
            onTimeout: () => throw Exception('Timeout ao criar ticket'),
          );

      _logResponse('CREATE_TICKET', response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        String? ticketId;

        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          ticketId = data['id']?.toString();
          _debugLog('Ticket criado com ID: $ticketId');
        } else {
          _debugLog('Ticket criado com sucesso (resposta vazia)');
          ticketId = null;
        }

        final attachments = await GlpiTicketSupport.normalizeAttachments(
          formData,
          debugLog: _debugLog,
        );

        if (ticketId != null && attachments.isNotEmpty) {
          int ok = 0;
          int fail = 0;
          final List<String> errors = [];

          for (int i = 0; i < attachments.length; i++) {
            final attachment = attachments[i];

            try {
              _debugLog(
                'Anexo ${i + 1}/${attachments.length} detectado. Iniciando upload/vinculo...',
              );
              await uploadAndAttachToTicket(
                sessionToken: sessionToken,
                ticketId: ticketId,
                bytes: attachment.bytes,
                filename: attachment.filename,
                mimeType: attachment.mimeType,
              );
              ok++;
            } catch (e) {
              fail++;
              errors.add('${attachment.filename}: $e');
              _debugLog('Falha ao anexar "${attachment.filename}": $e');
            }
          }

          if (fail > 0) {
            return {
              'success': true,
              'ticket_id': ticketId,
              'attachment_warning':
                  'Ticket criado, mas $fail/${attachments.length} anexos falharam: ${errors.join(' | ')}',
            };
          }

          _debugLog(
            'Upload de anexos concluido: $ok/${attachments.length} com sucesso.',
          );
        } else if (ticketId == null) {
          _debugLog(
            'Ticket criado sem ticketId no response; nao foi possivel anexar agora.',
          );
        } else {
          _debugLog('Sem anexos para enviar.');
        }

        final result = <String, dynamic>{
          'success': true,
          'ticket_id': ticketId ?? 'SYNC',
        };

        final governedExpectation = formData['governedReadbackExpectation'];
        if (ticketId != null &&
            governedExpectation is GovernedReadbackExpectation) {
          final readback = await validateGovernedTicketReadback(
            ticketId: ticketId,
            sessionToken: sessionToken,
            expectation: governedExpectation,
            requireAttachmentProof: attachments.isNotEmpty,
          );
          result.addAll(readback);
          final failures = readback['governed_readback_failures'];
          if (readback['governed_readback_ok'] != true && failures is List) {
            result['governed_readback_warning'] = failures.join(' | ');
          }
        }

        return result;
      }

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      throw Exception(
        'Erro ao criar ticket: [${response.statusCode}] - ${response.body}',
      );
    } catch (e) {
      _debugLog('Falha ao criar ticket: $e');
      return {
        'success': false,
        'error_message': GlpiClientSupport.cleanErrorMessage(e),
      };
    }
  }

  // ====================================================================
  // MAPEAMENTOS
  // ====================================================================

  // ====================================================================
  // MENSAGENS / FOLLOWUPS
  // ====================================================================

  Future<List<Map<String, dynamic>>> getTicketMessages(
    String ticketId,
    String sessionToken,
  ) async {
    _debugLog('Buscando mensagens do ticket $ticketId...');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final uri = Uri.parse(
        '${GlpiConfig.baseUrl}/Ticket/$ticketId/TicketFollowup?expand_dropdowns=true&range=0-200&sort=date_creation&order=DESC',
      );
      _debugLog('GET: $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            GlpiConfig.requestTimeout,
            onTimeout: () => throw Exception('Timeout ao buscar mensagens'),
          );

      _logResponse('GET_FOLLOWUPS', response);

      if (response.statusCode == 200 || response.statusCode == 206) {
        final List<dynamic> messages = jsonDecode(response.body);
        _debugLog('${messages.length} mensagens encontradas.');
        return messages.map((m) => m as Map<String, dynamic>).toList();
      }

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      _debugLog('Erro ao buscar mensagens: [${response.statusCode}]');
      return [];
    } catch (e) {
      _debugLog('Falha ao buscar mensagens: $e');
      if (_isSessionInvalidException(e)) rethrow;
      return [];
    }
  }

  Future<Map<String, dynamic>> addTicketMessage(
    String ticketId,
    String message,
    String sessionToken,
  ) async {
    _debugLog('Adicionando mensagem ao ticket $ticketId...');

    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final payload = {
        'input': {'tickets_id': ticketId, 'content': message, 'is_private': 0},
      };

      final uri = Uri.parse('${GlpiConfig.baseUrl}/TicketFollowup');
      _debugLog('POST: $uri');
      _debugLog('Payload followup: ${jsonEncode(payload)}');

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(
            GlpiConfig.requestTimeout,
            onTimeout: () => throw Exception('Timeout ao adicionar mensagem'),
          );

      _logResponse('ADD_FOLLOWUP', response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final followupId = _extractEntityIdFromBody(response.body);
        _debugLog('Mensagem adicionada com sucesso (followupId=$followupId)');
        return {
          'success': true,
          'message': 'Resposta enviada com sucesso',
          'entity_id': followupId,
        };
      }

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      _debugLog('Erro ao adicionar mensagem: [${response.statusCode}]');
      return {
        'success': false,
        'error':
            _extractApiErrorMessage(response.body) ??
            'Falha ao enviar resposta.',
      };
    } catch (e) {
      _debugLog('Falha ao adicionar mensagem: $e');
      if (_isSessionInvalidException(e)) rethrow;
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Envia uma SOLUÇÃO formal para o chamado.
  Future<Map<String, dynamic>> addTicketSolution(
    String ticketId,
    String message,
    String sessionToken,
  ) async {
    _debugLog('Adicionando SOLUÇÃO ao ticket $ticketId...');

    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final payload = {
        'input': {
          'itemtype': 'Ticket',
          'items_id': ticketId,
          'content': message,
          'status': 2,
        },
      };

      final uri = Uri.parse('${GlpiConfig.baseUrl}/ITILSolution');
      _debugLog('POST: $uri');
      _debugLog('Payload Solution: ${jsonEncode(payload)}');

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(
            GlpiConfig.requestTimeout,
            onTimeout: () => throw Exception('Timeout ao enviar solução'),
          );

      _logResponse('ADD_SOLUTION', response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final solutionId = _extractEntityIdFromBody(response.body);
        _debugLog('Solução adicionada com sucesso (solutionId=$solutionId)');
        return {
          'success': true,
          'message': 'Solução enviada com sucesso',
          'entity_id': solutionId,
        };
      }

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      return {
        'success': false,
        'error':
            _extractApiErrorMessage(response.body) ??
            'Falha ao enviar solução.',
      };
    } catch (e) {
      _debugLog('Falha ao adicionar solução: $e');
      if (_isSessionInvalidException(e)) rethrow;
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> validateGovernedTicketReadback({
    required String ticketId,
    required String sessionToken,
    required GovernedReadbackExpectation expectation,
    bool requireAttachmentProof = true,
  }) async {
    try {
      final ticket = await getTicketById(ticketId, sessionToken);
      final taskLabels = await getTicketTaskLabels(ticketId, sessionToken);
      final documentIds = await getTicketDocumentIds(ticketId, sessionToken);
      final result = expectation.validate(
        ticket: ticket,
        taskLabels: taskLabels,
        documentIds: documentIds,
        requireAttachmentProof: requireAttachmentProof,
      );

      return {
        'governed_readback_ok': result.ok,
        'governed_readback_failures': result.failures,
        'governed_readback_ticket': ticket,
        'governed_readback_task_labels': taskLabels,
        'governed_readback_document_ids': documentIds.toList(growable: false),
      };
    } catch (e) {
      if (_isSessionInvalidException(e)) rethrow;
      return {
        'governed_readback_ok': false,
        'governed_readback_failures': ['Read-back governado não executado: $e'],
      };
    }
  }

  Future<List<String>> getTicketTaskLabels(
    String ticketId,
    String sessionToken,
  ) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
    };
    final uri = Uri.parse(
      '${GlpiConfig.baseUrl}/Ticket/$ticketId/TicketTask?expand_dropdowns=true&range=0-200&sort=id&order=ASC',
    );
    final response = await http
        .get(uri, headers: headers)
        .timeout(GlpiConfig.requestTimeout);

    if (_isAuthError(response.statusCode)) throw _authException(response);
    if (response.statusCode != 200 && response.statusCode != 206) {
      _debugLog(
        'Falha ao buscar tarefas do ticket $ticketId para read-back: [${response.statusCode}] ${response.body}',
      );
      return const <String>[];
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) return const <String>[];
    return decoded
        .whereType<Map>()
        .map((task) {
          final label =
              task['tasktemplates_id'] ??
              task['name'] ??
              task['content'] ??
              task['id'];
          return label?.toString().trim() ?? '';
        })
        .where((label) => label.isNotEmpty)
        .toList(growable: false);
  }

  Future<Set<String>> getTicketDocumentIds(
    String ticketId,
    String sessionToken,
  ) async {
    final embeddedIds = await _getEmbeddedDocumentIdsForItem(
      sessionToken: sessionToken,
      itemType: 'Ticket',
      itemId: ticketId,
    );
    if (embeddedIds != null) return embeddedIds;

    return _getLinkedDocumentIdsForItem(
      sessionToken: sessionToken,
      itemType: 'Ticket',
      itemId: ticketId,
    );
  }

  /// Busca documentos vinculados ao Ticket
  Future<List<Map<String, dynamic>>> getTicketDocuments(
    String ticketId,
    String sessionToken,
  ) async {
    _debugLog('Buscando documentos principais do ticket $ticketId...');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final embeddedDocs = await _getEmbeddedDocumentsForTicket(
        ticketId,
        sessionToken,
      );
      if (embeddedDocs != null) return embeddedDocs;

      final docIds = await _getLinkedDocumentIdsForItem(
        sessionToken: sessionToken,
        itemType: 'Ticket',
        itemId: ticketId,
      );
      if (docIds.isEmpty) return [];

      return await _fetchDocumentDetails(docIds.toList(), ticketId, headers);
    } catch (e) {
      _debugLog('Erro ao buscar documentos do ticket: $e');
      if (_isSessionInvalidException(e)) rethrow;
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> _getEmbeddedDocumentsForTicket(
    String ticketId,
    String sessionToken,
  ) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
    };

    final uri = Uri.parse(
      '${GlpiConfig.baseUrl}/Ticket/$ticketId?expand_dropdowns=true&with_documents=true',
    );
    final response = await http
        .get(uri, headers: headers)
        .timeout(GlpiConfig.requestTimeout);

    if (_isAuthError(response.statusCode)) throw _authException(response);
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return null;

    final documents = decoded['_documents'];
    if (documents is! List) return null;

    return _normalizeEmbeddedDocuments(documents, ticketId);
  }

  List<Map<String, dynamic>> _normalizeEmbeddedDocuments(
    List<dynamic> documents,
    String contextId,
  ) {
    return documents
        .whereType<Map>()
        .map((raw) => raw.cast<String, dynamic>())
        .map((docData) {
          final id = docData['id']?.toString().trim() ?? '';
          if (id.isEmpty) return null;
          final filename =
              docData['filename']?.toString().trim().isNotEmpty == true
              ? docData['filename'].toString().trim()
              : docData['name']?.toString().trim().isNotEmpty == true
              ? docData['name'].toString().trim()
              : 'Anexo-$id';

          return {
            'id': id,
            'items_id': contextId,
            'name': filename,
            'date_creation': docData['date_creation'],
            'users_id': docData['users_id'],
            'uploader_id': docData['users_id'],
            'mime': docData['mime'],
            'download_url': '${GlpiConfig.baseUrl}/Document/$id?alt=media',
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  Future<Set<String>?> _getEmbeddedDocumentIdsForItem({
    required String sessionToken,
    required String itemType,
    required String itemId,
  }) async {
    if (itemType != 'Ticket') return null;

    final embeddedDocs = await _getEmbeddedDocumentsForTicket(
      itemId,
      sessionToken,
    );
    if (embeddedDocs == null) return null;

    return embeddedDocs
        .map((doc) => doc['id']?.toString().trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  // ---------------------------------------------------------------------
  // BUSCA ANEXOS DAS RESPOSTAS (TÉCNICOS)
  // ---------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getFollowupDocuments(
    List<String> followupIds,
    String sessionToken,
  ) async {
    _debugLog(
      'Buscando documentos de ${followupIds.length} respostas (followups)...',
    );

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      List<Map<String, dynamic>> allFollowupDocs = [];

      final List<Future<void>> tasks = followupIds.map((fId) async {
        try {
          final uri = Uri.parse(
            '${GlpiConfig.baseUrl}/ITILFollowup/$fId/Document_Item',
          );
          final resp = await http.get(uri, headers: headers);

          if (_isAuthError(resp.statusCode)) {
            throw _authException(resp);
          }

          if (resp.statusCode == 200 || resp.statusCode == 206) {
            final List<dynamic> links = jsonDecode(resp.body);
            final docIds = links.map((l) => l['documents_id']).toSet().toList();

            if (docIds.isNotEmpty) {
              final docs = await _fetchDocumentDetails(docIds, fId, headers);
              allFollowupDocs.addAll(docs);
            }
          }
        } catch (e) {
          if (_isSessionInvalidException(e)) rethrow;
          _debugLog('Erro doc followup $fId: $e');
        }
      }).toList();

      await Future.wait(tasks);
      return allFollowupDocs;
    } catch (e) {
      _debugLog('Erro geral ao buscar documentos de followups: $e');
      if (_isSessionInvalidException(e)) rethrow;
      return [];
    }
  }

  // ---------------------------------------------------------------------
  // MÉTODO AUXILIAR PARA EVITAR CÓDIGO REPETIDO
  // ---------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> _fetchDocumentDetails(
    List<dynamic> docIds,
    String contextId,
    Map<String, String> headers,
  ) async {
    final List<Future<Map<String, dynamic>?>> tasks = docIds.map((id) async {
      try {
        final uriDoc = Uri.parse('${GlpiConfig.baseUrl}/Document/$id');
        final responseDoc = await http.get(uriDoc, headers: headers);

        if (_isAuthError(responseDoc.statusCode)) {
          throw _authException(responseDoc);
        }

        if (responseDoc.statusCode == 200) {
          final docData = jsonDecode(responseDoc.body);
          final uploaderId = docData['users_id']?.toString();
          final uploaderName =
              uploaderId != null && uploaderId.trim().isNotEmpty
              ? await _resolveUserDisplayName(uploaderId, headers)
              : null;
          return {
            'id': id,
            'items_id': contextId,
            'name': docData['filename'] ?? docData['name'] ?? 'Anexo-$id',
            'date_creation': docData['date_creation'],
            'users_id': docData['users_id'],
            'uploader_id': docData['users_id'],
            if (uploaderName != null && uploaderName.trim().isNotEmpty)
              'uploader_name': uploaderName,
            'mime': docData['mime'],
            'download_url': '${GlpiConfig.baseUrl}/Document/$id?alt=media',
          };
        }
      } catch (e) {
        if (_isSessionInvalidException(e)) rethrow;
        _debugLog('Erro detalhes doc $id: $e');
      }
      return null;
    }).toList();

    final results = await Future.wait(tasks);
    return results.whereType<Map<String, dynamic>>().toList();
  }

  // ---------------------------------------------------------------------
  // BUSCA ANEXOS DAS SOLUÇÕES
  // ---------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getSolutionDocuments(
    List<String> solutionIds,
    String sessionToken,
  ) async {
    _debugLog('Buscando documentos de ${solutionIds.length} soluções...');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      List<Map<String, dynamic>> allSolutionDocs = [];

      final List<Future<void>> tasks = solutionIds.map((sId) async {
        try {
          final uri = Uri.parse(
            '${GlpiConfig.baseUrl}/ITILSolution/$sId/Document_Item',
          );
          final resp = await http.get(uri, headers: headers);

          if (_isAuthError(resp.statusCode)) {
            throw _authException(resp);
          }

          if (resp.statusCode == 200 || resp.statusCode == 206) {
            final List<dynamic> links = jsonDecode(resp.body);
            final docIds = links.map((l) => l['documents_id']).toSet().toList();

            if (docIds.isNotEmpty) {
              final docs = await _fetchDocumentDetails(docIds, sId, headers);
              allSolutionDocs.addAll(docs);
            }
          }
        } catch (e) {
          if (_isSessionInvalidException(e)) rethrow;
          _debugLog('Erro doc solution $sId: $e');
        }
      }).toList();

      await Future.wait(tasks);
      return allSolutionDocs;
    } catch (e) {
      _debugLog('Erro geral ao buscar documentos de soluções: $e');
      if (_isSessionInvalidException(e)) rethrow;
      return [];
    }
  }

  // ====================================================================
  // ATRIBUIÇÃO DE TÉCNICO
  // ====================================================================

  /// Busca o ID numérico interno do usuário logado na sessão atual
  Future<int?> getMyUserId(String sessionToken) async {
    try {
      final context = await getSessionContext(sessionToken);
      final id = context['userId'] as int?;
      if (id != null) {
        _debugLog('ID do usuário logado: $id');
      }
      return id;
    } catch (e) {
      _debugLog('Erro ao buscar ID do usuário na sessão: $e');
      if (_isSessionInvalidException(e)) rethrow;
    }
    return null;
  }

  /// Busca o nome do perfil ativo
  Future<String?> getActiveProfile(String sessionToken) async {
    try {
      final context = await getSessionContext(sessionToken);
      final profileName = context['profile']?.toString();
      if (profileName != null && profileName.trim().isNotEmpty) {
        _debugLog('Perfil ativo detectado: $profileName');
        return profileName;
      }
    } catch (e) {
      _debugLog('Erro ao buscar perfil na sessão: $e');
      if (_isSessionInvalidException(e)) rethrow;
    }
    return null;
  }

  /// Vincula um usuário ao chamado como Técnico (type = 2)
  Future<bool> assignTicketToMe(
    String ticketId,
    int userId,
    String sessionToken,
  ) async {
    _debugLog('Atribuindo ticket $ticketId ao usuário $userId...');
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final uri = Uri.parse('${GlpiConfig.baseUrl}/Ticket_User');
      final payload = {
        'input': {
          'tickets_id': ticketId,
          'users_id': userId,
          'type': 2,
          'use_notification': 1,
        },
      };

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(payload))
          .timeout(GlpiConfig.requestTimeout);

      _logResponse('ASSIGN_TICKET', response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _debugLog('Técnico atribuído com sucesso.');
        return true;
      }

      if (response.statusCode == 400 &&
          response.body.contains('Item already exists')) {
        _debugLog('O técnico já estava atribuído a este chamado. (Ignorando)');
        return true;
      }

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      return false;
    } catch (e) {
      _debugLog('Erro ao atribuir chamado: $e');
      if (_isSessionInvalidException(e)) rethrow;
      return false;
    }
  }

  /// Método Auxiliar para baixar imagem autenticada (História 6)
  Future<Uint8List?> downloadSecureImage(
    String url,
    String sessionToken,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Session-Token': sessionToken},
      );
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }
      return null;
    } catch (e) {
      if (_isSessionInvalidException(e)) rethrow;
      return null;
    }
  }

  /// Busca as soluções (ITILSolution) registradas neste ticket
  Future<List<Map<String, dynamic>>> getTicketSolutions(
    String ticketId,
    String sessionToken,
  ) async {
    _debugLog('Buscando soluções do ticket $ticketId...');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final uri = Uri.parse(
        '${GlpiConfig.baseUrl}/Ticket/$ticketId/ITILSolution?expand_dropdowns=true&sort=date_creation&order=DESC',
      );
      _debugLog('GET: $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(GlpiConfig.requestTimeout);

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      if (response.statusCode == 200 || response.statusCode == 206) {
        final List<dynamic> solutions = jsonDecode(response.body);
        _debugLog('${solutions.length} soluções encontradas.');
        return solutions.map((s) => s as Map<String, dynamic>).toList();
      }

      _debugLog(
        'Nenhuma solução encontrada ou erro na API. Status: [${response.statusCode}] ${response.body}',
      );
      return [];
    } catch (e) {
      _debugLog('Erro ao buscar soluções: $e');
      if (_isSessionInvalidException(e)) rethrow;
      return [];
    }
  }

  /// Altera o status da solução
  Future<bool> updateSolutionStatus({
    required String solutionId,
    required int newStatus,
    required String sessionToken,
  }) async {
    _debugLog('Atualizando status da solução $solutionId para $newStatus...');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      };

      final payload = {
        'input': {'id': solutionId, 'status': newStatus},
      };

      final uri = Uri.parse('${GlpiConfig.baseUrl}/ITILSolution/$solutionId');

      final response = await http
          .put(uri, headers: headers, body: jsonEncode(payload))
          .timeout(GlpiConfig.requestTimeout);

      _logResponse('UPDATE_SOLUTION', response);

      if (response.statusCode == 200) {
        _debugLog('Status da solução atualizado com sucesso!');
        return true;
      }

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      return false;
    } catch (e) {
      _debugLog('Falha ao atualizar solução: $e');
      if (_isSessionInvalidException(e)) rethrow;
      return false;
    }
  }

  /// Submissao FormCreator de checklist. Bloqueada por padrao: so executa quando
  /// `SIS_ENABLE_CHECKLISTS_SUBMISSION=true` no app E o Worker SIS permite a rota
  /// (`ALLOW_FORMCREATOR_SUBMISSION=true`), em ambiente autorizado. Anexos ficam
  /// bloqueados ate o contrato de arquivo ser validado em sandbox.
  ///
  /// O app NAO envia App-Token: o Worker SIS injeta o segredo upstream.
  Future<Map<String, dynamic>> submitFormCreatorAnswer({
    required SisChecklistPreparedSubmission submission,
    required String sessionToken,
  }) async {
    if (!GlpiConfig.sisChecklistSubmissionEnabled) {
      return {
        'success': false,
        'blocked': true,
        'message': 'Submissao de checklist desabilitada no app.',
      };
    }
    if (sessionToken.isEmpty) {
      return {
        'success': false,
        'blocked': true,
        'message': 'Sessao GLPI ausente para submissao de checklist.',
      };
    }
    if (submission.hasAttachments) {
      return {
        'success': false,
        'blocked': true,
        'message':
            'Submissao com anexos de checklist exige validacao sandbox antes de habilitar.',
      };
    }

    try {
      final uri = Uri.parse(
        '${GlpiConfig.baseUrl}/PluginFormcreatorFormAnswer',
      );
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Session-Token': sessionToken,
            },
            body: jsonEncode({'input': submission.toFormCreatorInput()}),
          )
          .timeout(GlpiConfig.requestTimeout);

      _logResponse('FORMCREATOR_SUBMIT', response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data;
        if (response.body.isNotEmpty) {
          data = jsonDecode(response.body);
        }
        final ticketId = (data is Map ? data['id'] : null)?.toString();
        return {'success': true, 'ticket_id': ticketId, 'raw': data};
      }

      if (_isAuthError(response.statusCode)) {
        throw _authException(response);
      }

      return {
        'success': false,
        'message': 'GLPI respondeu HTTP ${response.statusCode}',
        'status_code': response.statusCode,
        'body': response.body,
      };
    } catch (e) {
      if (_isSessionInvalidException(e)) rethrow;
      return {'success': false, 'message': 'Falha ao submeter checklist: $e'};
    }
  }

  /// Submissao de checklist via `POST /Ticket`. Usado quando FormCreator REST nao
  /// esta disponivel nesta versao do GLPI. O ticket recebe as respostas visiveis
  /// formatadas em HTML no campo `content`, com a categoria e entidade derivadas
  /// do target escolhido pelo operador — o que garante disparo correto das
  /// RuleTickets de atribuicao de grupo (CC-MANUTENCAO).
  Future<Map<String, dynamic>> submitChecklistAsTicket({
    required SisChecklistPreparedSubmission submission,
    required String sessionToken,
    required SisChecklistCatalog catalog,
    String? formName,
    String? targetName,
  }) async {
    if (!GlpiConfig.sisChecklistSubmissionEnabled) {
      return {
        'success': false,
        'blocked': true,
        'message': 'Submissao de checklist desabilitada no app.',
      };
    }
    if (sessionToken.isEmpty) {
      return {
        'success': false,
        'blocked': true,
        'message': 'Sessao GLPI ausente para submissao de checklist.',
      };
    }

    try {
      final uri = Uri.parse('${GlpiConfig.baseUrl}/Ticket');
      final ticketInput = submission.toTicketInput(
        catalog: catalog,
        formName: formName,
        targetName: targetName,
      );
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Session-Token': sessionToken,
            },
            body: jsonEncode({'input': ticketInput}),
          )
          .timeout(GlpiConfig.requestTimeout);

      _logResponse('CHECKLIST_TICKET_SUBMIT', response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data;
        if (response.body.isNotEmpty) data = jsonDecode(response.body);
        final ticketId = (data is Map ? data['id'] : null)?.toString();
        return {'success': true, 'ticket_id': ticketId, 'raw': data};
      }

      if (_isAuthError(response.statusCode)) throw _authException(response);

      return {
        'success': false,
        'message': 'GLPI respondeu HTTP ${response.statusCode}',
        'status_code': response.statusCode,
        'body': response.body,
      };
    } catch (e) {
      if (_isSessionInvalidException(e)) rethrow;
      return {
        'success': false,
        'message': 'Erro ao criar ticket de checklist: $e',
      };
    }
  }
}
