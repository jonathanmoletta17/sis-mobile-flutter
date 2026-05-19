import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../models/glpi_status.dart';
import '../config/dtic_config.dart';
import '../models/dtic_formcreator_models.dart';
import '../models/dtic_ticket_models.dart';

class DticGlpiClient {
  String? _sessionToken;

  bool get isAuthenticated => _sessionToken != null;
  String? get sessionToken => _sessionToken;

  void hydrateSession(String token) {
    _sessionToken = token;
  }

  void clearSession() {
    _sessionToken = null;
  }

  Map<String, String> _headers({String? sessionToken}) {
    final token = sessionToken ?? _sessionToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Session-Token': token,
    };
  }

  Map<String, String> _multipartHeaders({String? sessionToken}) {
    final token = sessionToken ?? _sessionToken;
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Session-Token': token,
    };
  }

  Future<String> authenticate(String username, String password) async {
    final response = await http
        .post(
          _uri('/initSession'),
          headers: _headers(),
          body: jsonEncode({'login': username, 'password': password}),
        )
        .timeout(DticConfig.requestTimeout);

    if (response.statusCode != 200) {
      throw Exception(_apiError('Falha na autenticacao DTIC', response));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final token = decoded['session_token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('GLPI DTIC nao retornou session_token.');
    }
    _sessionToken = token;
    return token;
  }

  Future<void> killSession() async {
    final token = _sessionToken;
    if (token == null || token.isEmpty) return;

    try {
      await http
          .get(_uri('/killSession'), headers: _headers(sessionToken: token))
          .timeout(DticConfig.requestTimeout);
    } finally {
      _sessionToken = null;
    }
  }

  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    final response = await http
        .get(
          _uri('/getFullSession'),
          headers: _headers(sessionToken: sessionToken),
        )
        .timeout(DticConfig.requestTimeout);

    if (response.statusCode != 200) {
      throw Exception(_apiError('Falha ao validar sessao DTIC', response));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final session = decoded['session'] as Map<String, dynamic>? ?? {};
    final profile = session['glpiactiveprofile'];
    return {
      'username': session['glpiname']?.toString(),
      'userId': int.tryParse('${session['glpiID'] ?? ''}'),
      'profile': profile is Map ? profile['name']?.toString() : null,
      'activeEntityId': int.tryParse('${session['glpiactive_entity'] ?? ''}'),
      'activeEntityName': session['glpiactive_entity_name']?.toString(),
    };
  }

  Future<DticFormCatalog> fetchFormCatalog(String sessionToken) async {
    final results = await Future.wait([
      _getList(
        '/PluginFormcreatorForm?range=0-200&expand_dropdowns=true',
        sessionToken,
      ),
      _getList(
        '/PluginFormcreatorCategory?range=0-300&expand_dropdowns=true',
        sessionToken,
      ),
      _getList(
        '/PluginFormcreatorSection?range=0-600&expand_dropdowns=true',
        sessionToken,
      ),
      _getList(
        '/PluginFormcreatorQuestion?range=0-1200&expand_dropdowns=true',
        sessionToken,
      ),
      _getList(
        '/PluginFormcreatorTargetTicket?range=0-600&expand_dropdowns=true',
        sessionToken,
      ),
      _getList(
        '/PluginFormcreatorCondition?range=0-2000&expand_dropdowns=true',
        sessionToken,
      ),
      _getList('/Profile?range=0-300&expand_dropdowns=true', sessionToken),
      _getList(
        '/PluginFormcreatorForm_Profile?range=0-1000&expand_dropdowns=true',
        sessionToken,
      ),
    ]);

    final forms =
        results[0]
            .map((json) => DticForm.fromJson(json))
            .where((form) => form.isActive)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    final sections = results[2]
        .map((json) => DticFormSection.fromJson(json))
        .toList();
    final sectionToForm = <int, int>{};
    for (final section in sections) {
      if (section.formId != null) {
        sectionToForm[section.id] = section.formId!;
      }
    }

    final questions = results[3].map((json) {
      final question = DticFormQuestion.fromJson(json);
      final resolvedFormId =
          question.formId ?? sectionToForm[question.sectionId];
      if (resolvedFormId == question.formId) return question;
      return DticFormQuestion(
        id: question.id,
        formId: resolvedFormId,
        sectionId: question.sectionId,
        name: question.name,
        fieldType: question.fieldType,
        required: question.required,
        description: question.description,
        row: question.row,
        col: question.col,
        width: question.width,
        showRule: question.showRule,
        options: question.options,
        defaultValue: question.defaultValue,
        rawValues: question.rawValues,
      );
    }).toList();

    return DticFormCatalog(
      forms: forms,
      categories: results[1]
          .map((json) => DticFormCategory.fromJson(json))
          .toList(),
      sections: sections,
      questions: questions,
      conditions: results[5]
          .map((json) => DticFormCondition.fromJson(json))
          .where(
            (condition) =>
                condition.itemId > 0 && condition.sourceQuestionId > 0,
          )
          .toList(),
      targetTickets: results[4]
          .map((json) => DticTargetTicket.fromJson(json))
          .toList(),
      profiles: results[6]
          .map((json) => DticProfile.fromJson(json))
          .where((profile) => profile.id > 0)
          .toList(),
      formProfiles: results[7]
          .map((json) => DticFormProfile.fromJson(json))
          .where((link) => link.formId > 0 && link.profileId > 0)
          .toList(),
    );
  }

  Future<List<DticTicketSummary>> fetchMyTickets({
    required String sessionToken,
    required String requesterUsername,
  }) async {
    final normalizedRequester = requesterUsername.trim();
    if (normalizedRequester.isEmpty) return const [];

    final query = [
      'criteria[0][field]=4',
      'criteria[0][searchtype]=contains',
      'criteria[0][value]=${Uri.encodeQueryComponent(normalizedRequester)}',
      'forcedisplay[0]=2',
      'forcedisplay[1]=1',
      'forcedisplay[2]=12',
      'forcedisplay[3]=15',
      'forcedisplay[4]=4',
      'forcedisplay[5]=7',
      'forcedisplay[6]=19',
      'sort=15',
      'order=DESC',
      'range=0-200',
    ].join('&');

    final response = await http
        .get(
          _uri('/search/Ticket?$query'),
          headers: _headers(sessionToken: sessionToken),
        )
        .timeout(DticConfig.requestTimeout);

    if (!_isOk(response.statusCode)) {
      throw Exception(_apiError('Falha ao buscar chamados DTIC', response));
    }

    final decoded = jsonDecode(response.body);
    final rows = decoded is Map ? decoded['data'] : decoded;
    if (rows is! List) return const [];

    return rows
        .whereType<Map>()
        .map(
          (row) =>
              DticTicketSummary.fromSearchRow(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<DticTicketDetail> fetchTicketDetail({
    required String sessionToken,
    required String ticketId,
  }) async {
    final response = await http
        .get(
          _uri('/Ticket/$ticketId?expand_dropdowns=true'),
          headers: _headers(sessionToken: sessionToken),
        )
        .timeout(DticConfig.requestTimeout);

    if (!_isOk(response.statusCode)) {
      throw Exception(_apiError('Falha ao buscar detalhe DTIC', response));
    }

    return DticTicketDetail.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<DticTicketInteraction>> fetchTicketInteractions({
    required String sessionToken,
    required String ticketId,
  }) async {
    final responses = await Future.wait([
      _getList(
        '/Ticket/$ticketId/TicketFollowup?expand_dropdowns=true&range=0-200&sort=date_creation&order=DESC',
        sessionToken,
      ),
      _getList(
        '/Ticket/$ticketId/ITILSolution?expand_dropdowns=true&range=0-200&sort=date_creation&order=DESC',
        sessionToken,
      ),
    ]);

    final interactions = <DticTicketInteraction>[
      ...responses[0].map(DticTicketInteraction.followup),
      ...responses[1].map(DticTicketInteraction.solution),
    ];
    interactions.sort((a, b) => b.date.compareTo(a.date));
    return interactions;
  }

  Future<List<DticTicketDocument>> fetchTicketDocuments({
    required String sessionToken,
    required String ticketId,
    List<DticTicketInteraction> interactions = const [],
  }) async {
    final documentRefs = <_DticDocumentRef>[
      ...await _fetchDocumentRefsBySearch(
        sessionToken: sessionToken,
        itemType: 'Ticket',
        itemId: ticketId,
        contextKind: 'ticket',
      ),
    ];

    final followupIds = interactions
        .where((interaction) => interaction.kind == 'Mensagem')
        .map((interaction) => interaction.id)
        .where((id) => id.isNotEmpty)
        .toList();
    final solutionIds = interactions
        .where((interaction) => interaction.kind == 'Solucao')
        .map((interaction) => interaction.id)
        .where((id) => id.isNotEmpty)
        .toList();

    for (final followupId in followupIds) {
      documentRefs.addAll(
        await _fetchDocumentRefsFromEndpoint(
          sessionToken: sessionToken,
          path: '/ITILFollowup/$followupId/Document_Item',
          contextKind: 'followup',
          contextId: followupId,
          expectedItemType: 'ITILFollowup',
        ),
      );
    }

    for (final solutionId in solutionIds) {
      documentRefs.addAll(
        await _fetchDocumentRefsFromEndpoint(
          sessionToken: sessionToken,
          path: '/ITILSolution/$solutionId/Document_Item',
          contextKind: 'solution',
          contextId: solutionId,
          expectedItemType: 'ITILSolution',
        ),
      );
    }

    final uniqueRefs = <String, _DticDocumentRef>{};
    for (final ref in documentRefs) {
      uniqueRefs['${ref.contextKind}:${ref.contextId}:${ref.documentId}'] = ref;
    }

    final docs = await Future.wait(
      uniqueRefs.values.map((ref) => _fetchDocumentDetail(sessionToken, ref)),
    );

    return docs.whereType<DticTicketDocument>().toList()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  Future<List<_DticDocumentRef>> _fetchDocumentRefsBySearch({
    required String sessionToken,
    required String itemType,
    required String itemId,
    required String contextKind,
  }) async {
    final query = [
      'expand_dropdowns=false',
      'range=0-200',
      'order=DESC',
      'sort=id',
      'criteria[0][field]=items_id',
      'criteria[0][searchtype]=equals',
      'criteria[0][value]=$itemId',
      'criteria[1][link]=AND',
      'criteria[1][field]=itemtype',
      'criteria[1][searchtype]=equals',
      'criteria[1][value]=$itemType',
    ].join('&');

    final links = await _getList('/Document_Item?$query', sessionToken);
    return _documentRefsFromLinks(
      links,
      contextKind: contextKind,
      contextId: itemId,
      expectedItemType: itemType,
      expectedItemId: itemId,
    );
  }

  Future<List<_DticDocumentRef>> _fetchDocumentRefsFromEndpoint({
    required String sessionToken,
    required String path,
    required String contextKind,
    required String contextId,
    String? expectedItemType,
  }) async {
    final response = await http
        .get(_uri(path), headers: _headers(sessionToken: sessionToken))
        .timeout(DticConfig.requestTimeout);

    if (!_isOk(response.statusCode)) return const [];

    final decoded = jsonDecode(response.body);
    if (decoded is! List) return const [];
    final links = decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    return _documentRefsFromLinks(
      links,
      contextKind: contextKind,
      contextId: contextId,
      expectedItemType: expectedItemType,
      expectedItemId: contextId,
    );
  }

  List<_DticDocumentRef> _documentRefsFromLinks(
    List<Map<String, dynamic>> links, {
    required String contextKind,
    required String contextId,
    String? expectedItemType,
    String? expectedItemId,
  }) {
    return links
        .map((link) {
          final linkItemId = link['items_id']?.toString() ?? '';
          final linkItemType = link['itemtype']?.toString() ?? '';
          if (expectedItemId != null &&
              linkItemId.isNotEmpty &&
              linkItemId != expectedItemId) {
            return null;
          }
          if (expectedItemType != null &&
              linkItemType.isNotEmpty &&
              linkItemType != expectedItemType) {
            return null;
          }
          final documentId = link['documents_id']?.toString() ?? '';
          if (documentId.isEmpty) return null;
          return _DticDocumentRef(
            documentId: documentId,
            contextKind: contextKind,
            contextId: contextId,
          );
        })
        .whereType<_DticDocumentRef>()
        .toList();
  }

  Future<DticTicketDocument?> _fetchDocumentDetail(
    String sessionToken,
    _DticDocumentRef ref,
  ) async {
    final response = await http
        .get(
          _uri('/Document/${ref.documentId}'),
          headers: _headers(sessionToken: sessionToken),
        )
        .timeout(DticConfig.requestTimeout);
    if (!_isOk(response.statusCode)) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return DticTicketDocument.fromJson({
      ...json,
      'download_path': '/Document/${ref.documentId}?alt=media',
      'context_kind': ref.contextKind,
      'context_id': ref.contextId,
    });
  }

  Future<List<int>> downloadDocumentBytes({
    required String sessionToken,
    required DticTicketDocument document,
  }) async {
    if (document.downloadPath.isEmpty) {
      throw Exception('Documento DTIC sem caminho de download.');
    }

    final response = await http
        .get(
          _uri(document.downloadPath),
          headers: _headers(sessionToken: sessionToken),
        )
        .timeout(DticConfig.requestTimeout);

    if (!_isOk(response.statusCode)) {
      throw Exception(_apiError('Falha ao baixar anexo DTIC', response));
    }

    return response.bodyBytes;
  }

  Future<Map<String, dynamic>> addTicketMessage({
    required String sessionToken,
    required String ticketId,
    required String message,
  }) async {
    final response = await http
        .post(
          _uri('/TicketFollowup'),
          headers: _headers(sessionToken: sessionToken),
          body: jsonEncode({
            'input': {
              'tickets_id': ticketId,
              'content': message,
              'is_private': 0,
            },
          }),
        )
        .timeout(DticConfig.requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'entity_id': _extractEntityId(response.body)};
    }

    return {
      'success': false,
      'error': _apiError('Falha ao enviar mensagem DTIC', response),
    };
  }

  Future<Map<String, dynamic>> uploadAndAttachToTicket({
    required String sessionToken,
    required String ticketId,
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) {
    return uploadAndAttachToItem(
      sessionToken: sessionToken,
      itemType: 'Ticket',
      itemId: ticketId,
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
  }

  Future<Map<String, dynamic>> uploadAndAttachToItem({
    required String sessionToken,
    required String itemType,
    required String itemId,
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) async {
    final resolvedMime = _resolveMimeType(filename, mimeType);
    final directResult = await _uploadDirectToItem(
      sessionToken: sessionToken,
      itemType: itemType,
      itemId: itemId,
      bytes: bytes,
      filename: filename,
      mimeType: resolvedMime,
    );

    if (directResult['success'] == true) return directResult;

    final documentId = await _uploadDocument(
      sessionToken: sessionToken,
      bytes: bytes,
      filename: filename,
      mimeType: resolvedMime,
    );

    if (documentId == null || documentId.isEmpty) {
      return {
        'success': false,
        'error':
            directResult['error']?.toString() ??
            'Upload DTIC nao retornou documento.',
      };
    }

    return linkDocumentToItem(
      sessionToken: sessionToken,
      itemType: itemType,
      itemId: itemId,
      documentId: documentId,
    );
  }

  Future<Map<String, dynamic>> _uploadDirectToItem({
    required String sessionToken,
    required String itemType,
    required String itemId,
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/$itemType/$itemId/Document'),
    );
    request.headers.addAll(_multipartHeaders(sessionToken: sessionToken));
    request.fields['uploadManifest'] = jsonEncode({
      'input': {
        'name': filename,
        '_filename': [filename],
        'items_id': itemId,
        'itemtype': itemType,
      },
    });
    request.files.add(
      http.MultipartFile.fromBytes(
        'filename[0]',
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamed = await request.send().timeout(DticConfig.requestTimeout);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true};
    }

    return {
      'success': false,
      'error': _apiError('Falha no upload direto DTIC', response),
    };
  }

  Future<String?> _uploadDocument({
    required String sessionToken,
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/Document'));
    request.headers.addAll(_multipartHeaders(sessionToken: sessionToken));
    request.fields['uploadManifest'] = jsonEncode({
      'input': {'name': filename},
    });
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamed = await request.send().timeout(DticConfig.requestTimeout);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200 && response.statusCode != 201) {
      return null;
    }

    return _extractEntityId(response.body);
  }

  Future<Map<String, dynamic>> linkDocumentToItem({
    required String sessionToken,
    required String itemType,
    required String itemId,
    required String documentId,
  }) async {
    final response = await http
        .post(
          _uri('/Document_Item'),
          headers: _headers(sessionToken: sessionToken),
          body: jsonEncode({
            'input': {
              'documents_id': int.tryParse(documentId) ?? documentId,
              'items_id': int.tryParse(itemId) ?? itemId,
              'itemtype': itemType,
            },
          }),
        )
        .timeout(DticConfig.requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true};
    }

    return {
      'success': false,
      'error': _apiError('Falha ao vincular anexo DTIC', response),
    };
  }

  Future<Map<String, dynamic>> addTicketSolution({
    required String sessionToken,
    required String ticketId,
    required String message,
  }) async {
    final response = await http
        .post(
          _uri('/ITILSolution'),
          headers: _headers(sessionToken: sessionToken),
          body: jsonEncode({
            'input': {
              'itemtype': 'Ticket',
              'items_id': ticketId,
              'content': message,
              'status': 2,
            },
          }),
        )
        .timeout(DticConfig.requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'entity_id': _extractEntityId(response.body)};
    }

    return {
      'success': false,
      'error': _apiError('Falha ao enviar solucao DTIC', response),
    };
  }

  Future<Map<String, dynamic>> updateTicketStatus({
    required String sessionToken,
    required String ticketId,
    required String status,
  }) async {
    final statusId = GlpiStatusMapper.code(status) ?? int.tryParse(status);
    if (statusId == null) {
      return {'success': false, 'error': 'Status DTIC invalido.'};
    }

    final response = await http
        .put(
          _uri('/Ticket/$ticketId'),
          headers: _headers(sessionToken: sessionToken),
          body: jsonEncode({
            'input': {'id': ticketId, 'status': statusId},
          }),
        )
        .timeout(DticConfig.requestTimeout);

    if (response.statusCode == 200) return {'success': true};

    return {
      'success': false,
      'error': _apiError('Falha ao atualizar chamado DTIC', response),
    };
  }

  Future<Map<String, dynamic>> updateSolutionStatus({
    required String sessionToken,
    required String solutionId,
    required int status,
  }) async {
    final response = await http
        .put(
          _uri('/ITILSolution/$solutionId'),
          headers: _headers(sessionToken: sessionToken),
          body: jsonEncode({
            'input': {'id': solutionId, 'status': status},
          }),
        )
        .timeout(DticConfig.requestTimeout);

    if (response.statusCode == 200) return {'success': true};

    return {
      'success': false,
      'error': _apiError('Falha ao atualizar solucao DTIC', response),
    };
  }

  Future<List<Map<String, dynamic>>> _getList(
    String path,
    String sessionToken,
  ) async {
    final response = await http
        .get(_uri(path), headers: _headers(sessionToken: sessionToken))
        .timeout(DticConfig.requestTimeout);

    if (!_isOk(response.statusCode)) {
      throw Exception(_apiError('Falha na consulta DTIC', response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return const [];
  }

  Uri _uri(String path) {
    final base = DticConfig.baseUrl;
    if (base.isEmpty) {
      throw Exception('GLPI_BASE_URL nao configurada para DTIC.');
    }
    final normalizedBase = base.replaceAll(RegExp(r'/+$'), '');
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  bool _isOk(int statusCode) => statusCode == 200 || statusCode == 206;

  String _resolveMimeType(String filename, String? explicitMimeType) {
    final explicit = explicitMimeType?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final lower = filename.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.csv')) return 'text/csv';
    if (lower.endsWith('.doc')) return 'application/msword';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
    if (lower.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    return 'application/octet-stream';
  }

  String _apiError(String label, http.Response response) {
    return '$label (${response.statusCode}) - ${response.body}';
  }

  String? _extractEntityId(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final id = decoded['id'] ?? decoded['items_id'];
        return id?.toString();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

class _DticDocumentRef {
  const _DticDocumentRef({
    required this.documentId,
    required this.contextKind,
    required this.contextId,
  });

  final String documentId;
  final String contextKind;
  final String contextId;
}
