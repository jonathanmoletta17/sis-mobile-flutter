import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

const marker = '[TESTE-AUTOMATIZADO SIS]';
const controlledMarker = '$marker [E2E-CONTROLADO]';
const statePath = 'output/e2e/sis_controlled_state.json';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help')) {
    _usage();
    return;
  }

  final env = _loadEnv('.env');
  final client = _GlpiE2eClient(env);

  switch (args.first) {
    case 'audit':
      final result = await client.audit();
      _printJson(result);
      break;
    case 'setup':
      final result = await client.setup();
      _writeState(result);
      _printJson(result);
      break;
    case 'tech-main':
      final state = _readState();
      final result = await client.techMain(state);
      state['techMain'] = result;
      _writeState(state);
      _printJson(result);
      break;
    case 'cleanup':
      final state = File(statePath).existsSync() ? _readState() : null;
      final result = await client.cleanup(state);
      if (state != null) {
        state['cleanup'] = result;
        _writeState(state);
      }
      _printJson(result);
      break;
    default:
      stderr.writeln('Comando desconhecido: ${args.first}');
      _usage();
      exitCode = 64;
  }
}

void _usage() {
  stdout.writeln('''
Uso:
  dart run tool/validation/sis_controlled_e2e.dart audit
  dart run tool/validation/sis_controlled_e2e.dart setup
  dart run tool/validation/sis_controlled_e2e.dart tech-main
  dart run tool/validation/sis_controlled_e2e.dart cleanup

Garantias:
  - usa somente credenciais de teste/admin do .env;
  - nao imprime senhas, tokens nem App-Token;
  - setup cria no maximo 3 tickets sinteticos;
  - cleanup fecha os tickets registrados em $statePath.
''');
}

Map<String, String> _loadEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    throw StateError('Arquivo $path nao encontrado.');
  }

  final env = <String, String>{};
  for (final rawLine in file.readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final index = line.indexOf('=');
    if (index <= 0) continue;
    final key = line.substring(0, index).trim();
    var value = line.substring(index + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1);
    }
    env[key] = value;
  }
  return env;
}

Map<String, dynamic> _readState() {
  final file = File(statePath);
  if (!file.existsSync()) {
    throw StateError('Estado nao encontrado: $statePath');
  }
  return (jsonDecode(file.readAsStringSync()) as Map).cast<String, dynamic>();
}

void _writeState(Map<String, dynamic> state) {
  final file = File(statePath);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(state));
}

void _printJson(Object value) {
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(value));
}

String _required(Map<String, String> env, String key) {
  final value = env[key]?.trim() ?? '';
  if (value.isEmpty) throw StateError('$key ausente no .env');
  return value;
}

String _optional(Map<String, String> env, String key, String fallback) {
  final value = env[key]?.trim() ?? '';
  return value.isEmpty ? fallback : value;
}

String _normalizeBase(String url) =>
    url.trim().replaceFirst(RegExp(r'/+$'), '');

class _Session {
  const _Session({
    required this.token,
    required this.userId,
    required this.username,
    required this.profileName,
    required this.profileId,
    required this.entityId,
  });

  final String token;
  final int? userId;
  final String? username;
  final String? profileName;
  final int? profileId;
  final int? entityId;

  Map<String, dynamic> toEvidence() => {
    'userId': userId,
    'username': username,
    'profileName': profileName,
    'profileId': profileId,
    'entityId': entityId,
  };
}

class _GlpiE2eClient {
  _GlpiE2eClient(this.env)
    : originalBase = _normalizeBase(_required(env, 'SIS_TEST_BASE_URL')),
      workerBase = _normalizeBase(_required(env, 'GLPI_BASE_URL')),
      appToken = env['GLPI_APP_TOKEN']?.trim() ?? '',
      testUser = _required(env, 'SIS_TEST_USER'),
      testPassword = _required(env, 'SIS_TEST_PASSWORD'),
      adminUser = _required(env, 'SIS_TEST_ADMIN_USER'),
      adminPassword = _required(env, 'SIS_TEST_ADMIN_PASSWORD'),
      categoryId = int.parse(_required(env, 'SIS_TEST_CATEGORY_ID')),
      entityId = int.parse(_optional(env, 'SIS_TEST_ENTITY_ID', '28')),
      requesterProfileId = int.parse(
        _optional(env, 'SIS_TEST_PROFILE_ID', '9'),
      ),
      techProfileId = int.parse(
        _optional(env, 'SIS_TEST_TECH_PROFILE_ID', '11'),
      );

  final Map<String, String> env;
  final String originalBase;
  final String workerBase;
  final String appToken;
  final String testUser;
  final String testPassword;
  final String adminUser;
  final String adminPassword;
  final int categoryId;
  final int entityId;
  final int requesterProfileId;
  final int techProfileId;

  Map<String, String> _directHeaders(String? token, {bool json = true}) => {
    if (json) 'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (appToken.isNotEmpty) 'App-Token': appToken,
    if (token != null) 'Session-Token': token,
  };

  Map<String, String> _workerHeaders(String? token, {bool json = true}) => {
    if (json) 'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Session-Token': token,
  };

  Future<_Session> _initDirect(String user, String password) async {
    final token = await _initSession(
      originalBase,
      user,
      password,
      (token) => _directHeaders(token),
    );
    final session = await _sessionContext(
      originalBase,
      token,
      (token) => _directHeaders(token),
    );
    return _Session(
      token: token,
      userId: _intValue(session['glpiID']),
      username: session['glpiname']?.toString(),
      profileName: (session['glpiactiveprofile'] as Map?)?['name']?.toString(),
      profileId: _intValue((session['glpiactiveprofile'] as Map?)?['id']),
      entityId: _intValue(session['glpiactive_entity']),
    );
  }

  Future<_Session> _initWorker(String user, String password) async {
    final token = await _initSession(
      workerBase,
      user,
      password,
      (token) => _workerHeaders(token),
    );
    final session = await _sessionContext(
      workerBase,
      token,
      (token) => _workerHeaders(token),
    );
    return _Session(
      token: token,
      userId: _intValue(session['glpiID']),
      username: session['glpiname']?.toString(),
      profileName: (session['glpiactiveprofile'] as Map?)?['name']?.toString(),
      profileId: _intValue((session['glpiactiveprofile'] as Map?)?['id']),
      entityId: _intValue(session['glpiactive_entity']),
    );
  }

  Future<String> _initSession(
    String base,
    String user,
    String password,
    Map<String, String> Function(String? token) headers,
  ) async {
    final resp = await http.get(
      Uri.parse('$base/initSession'),
      headers: {
        ...headers(null),
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$user:$password'))}',
      },
    );
    final decoded = jsonDecode(resp.body);
    if (resp.statusCode == 200 && decoded is Map) {
      return decoded['session_token'] as String;
    }
    throw StateError('initSession falhou em $base: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> _sessionContext(
    String base,
    String token,
    Map<String, String> Function(String? token) headers,
  ) async {
    final resp = await http.get(
      Uri.parse('$base/getFullSession'),
      headers: headers(token),
    );
    if (resp.statusCode != 200) {
      throw StateError('getFullSession falhou em $base: ${resp.statusCode}');
    }
    final decoded = jsonDecode(resp.body) as Map;
    return ((decoded['session'] as Map?) ?? const {}).cast<String, dynamic>();
  }

  Future<_Session> _changeDirectProfile(_Session session, int profileId) async {
    final resp = await http.post(
      Uri.parse('$originalBase/changeActiveProfile'),
      headers: _directHeaders(session.token),
      body: jsonEncode({'profiles_id': profileId}),
    );
    if (resp.statusCode != 200) {
      throw StateError(
        'changeActiveProfile($profileId) falhou: ${resp.statusCode}',
      );
    }
    final data = await _sessionContext(
      originalBase,
      session.token,
      (token) => _directHeaders(token),
    );
    return _Session(
      token: session.token,
      userId: _intValue(data['glpiID']),
      username: data['glpiname']?.toString(),
      profileName: (data['glpiactiveprofile'] as Map?)?['name']?.toString(),
      profileId: _intValue((data['glpiactiveprofile'] as Map?)?['id']),
      entityId: _intValue(data['glpiactive_entity']),
    );
  }

  Future<Map<String, dynamic>> setup() async {
    final createdAt = DateTime.now().toIso8601String();
    final slug = DateTime.now().millisecondsSinceEpoch.toString();
    final evidenceFile = _writeEvidencePng(slug);

    final worker = await _initWorker(testUser, testPassword);
    final admin = await _initDirect(adminUser, adminPassword);

    try {
      final main = await _createViaWorker(
        worker,
        name: '$controlledMarker MAIN $slug',
        description:
            'Validacao controlada: criacao, mensagem, anexo e visualizacao. Descartavel.',
      );

      final followup = await _addWorkerFollowup(
        worker,
        main,
        'Mensagem de validacao controlada do app/Worker.',
      );

      final upload = await _uploadWorkerDocument(
        worker: worker,
        itemType: 'Ticket',
        itemId: main,
        file: evidenceFile,
      );

      final mainReadback = await _ticketReadback(admin, main);
      final mainDocsWorker = await _documentItems(
        base: workerBase,
        headers: _workerHeaders(worker.token),
        itemType: 'Ticket',
        itemId: main,
      );
      final mainDocsOriginal = await _documentItems(
        base: originalBase,
        headers: _directHeaders(admin.token),
        itemType: 'Ticket',
        itemId: main,
      );

      final approval = await _solutionCase(
        worker: worker,
        admin: admin,
        name: '$controlledMarker APROVAR $slug',
        close: true,
      );
      final rejection = await _solutionCase(
        worker: worker,
        admin: admin,
        name: '$controlledMarker RECUSAR $slug',
        close: false,
      );

      return {
        'createdAt': createdAt,
        'marker': controlledMarker,
        'ticketCount': 3,
        'statePath': statePath,
        'evidenceFile': evidenceFile.path,
        'originalWebUrl': _webUrlFromApi(originalBase),
        'appWorkerApiUrl': workerBase,
        'sessions': {
          'workerRequester': worker.toEvidence(),
          'originalAdmin': admin.toEvidence(),
        },
        'main': {
          'id': main,
          'name': '$controlledMarker MAIN $slug',
          'followupId': followup['id'],
          'messageStatus': followup['statusCode'],
          'attachment': upload,
          'readback': mainReadback,
          'documentItemsViaWorker': mainDocsWorker,
          'documentItemsViaOriginal': mainDocsOriginal,
        },
        'approval': approval,
        'rejection': rejection,
        'tickets': [main, approval['id'], rejection['id']],
      };
    } finally {
      await _kill(workerBase, worker.token, (token) => _workerHeaders(token));
      await _kill(originalBase, admin.token, (token) => _directHeaders(token));
    }
  }

  Future<Map<String, dynamic>> techMain(Map<String, dynamic> state) async {
    final main = '${(state['main'] as Map)['id']}';
    final session0 = await _initDirect(testUser, testPassword);
    final session = await _changeDirectProfile(session0, techProfileId);
    try {
      final put = await http.put(
        Uri.parse('$originalBase/Ticket/$main'),
        headers: _directHeaders(session.token),
        body: jsonEncode({
          'input': {'id': main, 'status': 2},
        }),
      );
      final assigned = await _assignTicketToUser(
        session,
        ticketId: main,
        userId: session.userId,
      );
      final readback = await _ticketReadback(session, main);
      final assignees = await _ticketUsers(session, main);

      return {
        'ticketId': main,
        'session': session.toEvidence(),
        'statusPut': put.statusCode,
        'assignedPost': assigned,
        'readback': readback,
        'ticketUsers': assignees,
        'statusConfirmed': '${readback['status']}' == '2',
        'assignmentConfirmed': assignees.any(
          (item) =>
              '${item['type']}' == '2' &&
              '${item['users_id']}' == '${session.userId}',
        ),
      };
    } finally {
      await _kill(
        originalBase,
        session.token,
        (token) => _directHeaders(token),
      );
    }
  }

  Future<Map<String, dynamic>> cleanup(Map<String, dynamic>? state) async {
    final admin = await _initDirect(adminUser, adminPassword);
    final ids = <String>{};
    if (state != null) {
      final tickets = state['tickets'];
      if (tickets is List) {
        ids.addAll(tickets.map((id) => '$id'));
      }
    }

    final auditBefore = await audit(existingAdmin: admin);
    for (final item in (auditBefore['openTickets'] as List)) {
      ids.add('${(item as Map)['id']}');
    }

    final closed = <Map<String, dynamic>>[];
    try {
      for (final id in ids) {
        await http.put(
          Uri.parse('$originalBase/Ticket/$id'),
          headers: _directHeaders(admin.token),
          body: jsonEncode({
            'input': {'id': id, 'itilcategories_id': categoryId},
          }),
        );
        final solution = await http.post(
          Uri.parse('$originalBase/ITILSolution'),
          headers: _directHeaders(admin.token),
          body: jsonEncode({
            'input': {
              'itemtype': 'Ticket',
              'items_id': id,
              'content': 'Encerramento de validacao controlada SIS Mobile.',
            },
          }),
        );
        final close = await http.put(
          Uri.parse('$originalBase/Ticket/$id'),
          headers: _directHeaders(admin.token),
          body: jsonEncode({
            'input': {'id': id, 'status': 6},
          }),
        );
        final readback = await _ticketReadback(admin, id);
        closed.add({
          'id': id,
          'solutionStatus': solution.statusCode,
          'closeStatus': close.statusCode,
          'finalStatus': readback['status'],
          'closed': '${readback['status']}' == '6',
        });
      }
      final auditAfter = await audit(existingAdmin: admin);
      return {
        'closed': closed,
        'auditBefore': auditBefore,
        'auditAfter': auditAfter,
      };
    } finally {
      await _kill(originalBase, admin.token, (token) => _directHeaders(token));
    }
  }

  Future<Map<String, dynamic>> audit({_Session? existingAdmin}) async {
    final admin = existingAdmin ?? await _initDirect(adminUser, adminPassword);
    try {
      final uri = Uri.parse(
        '$originalBase/search/Ticket'
        '?criteria[0][field]=1'
        '&criteria[0][searchtype]=contains'
        '&criteria[0][value]=TESTE-AUTOMATIZADO'
        '&forcedisplay[0]=2&forcedisplay[1]=1&forcedisplay[2]=12'
        '&sort=2&order=ASC&range=0-300',
      );
      final resp = await http.get(uri, headers: _directHeaders(admin.token));
      if (resp.statusCode != 200 && resp.statusCode != 206) {
        throw StateError('audit falhou: ${resp.statusCode}');
      }
      final decoded = jsonDecode(resp.body) as Map;
      final rows = (decoded['data'] as List?) ?? const [];
      final tickets = <Map<String, dynamic>>[];
      final open = <Map<String, dynamic>>[];
      for (final row in rows) {
        if (row is! Map) continue;
        final item = {
          'id': '${row['2']}',
          'name': '${row['1']}',
          'status': '${row['12']}',
          'statusLabel': _statusLabel('${row['12']}'),
        };
        tickets.add(item);
        if (item['status'] != '6') open.add(item);
      }
      return {
        'total': tickets.length,
        'openCount': open.length,
        'openTickets': open,
        'tickets': tickets,
      };
    } finally {
      if (existingAdmin == null) {
        await _kill(
          originalBase,
          admin.token,
          (token) => _directHeaders(token),
        );
      }
    }
  }

  Future<String> _createViaWorker(
    _Session worker, {
    required String name,
    required String description,
  }) async {
    final payload = _buildCreateTicketPayload(
      name: name,
      description: description,
      requesterUserId: worker.userId,
    );
    final resp = await http.post(
      Uri.parse('$workerBase/Ticket'),
      headers: _workerHeaders(worker.token),
      body: jsonEncode(payload),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw StateError('POST Worker /Ticket falhou: ${resp.statusCode}');
    }
    return '${(jsonDecode(resp.body) as Map)['id']}';
  }

  Map<String, dynamic> _buildCreateTicketPayload({
    required String name,
    required String description,
    required int? requesterUserId,
  }) {
    return {
      'input': {
        'name': name,
        'content':
            '''
$description

-- FORMULARIO DO APP
--------------------------------
Servico: Validacao controlada SIS Mobile
'''
                .trim(),
        'status': 1,
        'requesttypes_id': 1,
        'entities_id': entityId,
        'itilcategories_id': categoryId,
        if (requesterUserId != null) '_users_id_requester': [requesterUserId],
      },
    };
  }

  Future<Map<String, dynamic>> _addWorkerFollowup(
    _Session worker,
    String ticketId,
    String content,
  ) async {
    final resp = await http.post(
      Uri.parse('$workerBase/TicketFollowup'),
      headers: _workerHeaders(worker.token),
      body: jsonEncode({
        'input': {'tickets_id': ticketId, 'content': content, 'is_private': 0},
      }),
    );
    final decoded = _safeDecode(resp.body);
    return {
      'statusCode': resp.statusCode,
      'id': decoded is Map ? decoded['id'] ?? decoded['entity_id'] : null,
    };
  }

  Future<Map<String, dynamic>> _uploadWorkerDocument({
    required _Session worker,
    required String itemType,
    required String itemId,
    required File file,
  }) async {
    final filename = file.uri.pathSegments.last;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$workerBase/$itemType/$itemId/Document'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'Session-Token': worker.token,
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
        file.readAsBytesSync(),
        filename: filename,
        contentType: MediaType('image', 'png'),
      ),
    );
    final response = await http.Response.fromStream(await request.send());
    return {
      'statusCode': response.statusCode,
      'filename': filename,
      'documentId': _extractDocumentId(response.body),
    };
  }

  Future<Map<String, dynamic>> _solutionCase({
    required _Session worker,
    required _Session admin,
    required String name,
    required bool close,
  }) async {
    final id = await _createViaWorker(
      worker,
      name: name,
      description: close
          ? 'Validacao controlada: aprovar solucao.'
          : 'Validacao controlada: recusar solucao.',
    );
    final solution = await http.post(
      Uri.parse('$originalBase/ITILSolution'),
      headers: _directHeaders(admin.token),
      body: jsonEncode({
        'input': {
          'itemtype': 'Ticket',
          'items_id': id,
          'content': 'Solucao proposta para validacao controlada.',
        },
      }),
    );
    final before = await _ticketReadback(admin, id);
    final action = await http.post(
      Uri.parse('$workerBase/TicketFollowup'),
      headers: _workerHeaders(worker.token),
      body: jsonEncode({
        'input': {
          'tickets_id': id,
          'content': close
              ? 'Aprovacao controlada da solucao.'
              : 'Recusa controlada da solucao.',
          if (close) 'add_close': 1 else 'add_reopen': 1,
        },
      }),
    );
    final after = await _ticketReadback(admin, id);
    return {
      'id': id,
      'mode': close ? 'approve' : 'reject',
      'solutionPostStatus': solution.statusCode,
      'actionStatus': action.statusCode,
      'statusBefore': before['status'],
      'statusAfter': after['status'],
      'ok': close
          ? '${before['status']}' == '5' && '${after['status']}' == '6'
          : '${before['status']}' == '5' && '${after['status']}' != '5',
    };
  }

  Future<Map<String, dynamic>> _ticketReadback(
    _Session session,
    String ticketId,
  ) async {
    final resp = await http.get(
      Uri.parse('$originalBase/Ticket/$ticketId'),
      headers: _directHeaders(session.token),
    );
    if (resp.statusCode != 200) {
      return {'id': ticketId, 'httpStatus': resp.statusCode};
    }
    final data = (jsonDecode(resp.body) as Map).cast<String, dynamic>();
    final group = await _assignedGroup(session, ticketId);
    return {
      'id': ticketId,
      'httpStatus': resp.statusCode,
      'name': data['name'],
      'status': data['status'],
      'statusLabel': _statusLabel('${data['status']}'),
      'entities_id': data['entities_id'],
      'itilcategories_id': data['itilcategories_id'],
      'assignedGroupId': group,
    };
  }

  Future<String?> _assignedGroup(_Session session, String ticketId) async {
    final resp = await http.get(
      Uri.parse('$originalBase/Ticket/$ticketId/Group_Ticket?range=0-50'),
      headers: _directHeaders(session.token),
    );
    if (resp.statusCode != 200 && resp.statusCode != 206) return null;
    final decoded = jsonDecode(resp.body);
    if (decoded is! List) return null;
    for (final row in decoded) {
      if (row is Map && '${row['type']}' == '2') {
        return '${row['groups_id']}';
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _ticketUsers(
    _Session session,
    String ticketId,
  ) async {
    final resp = await http.get(
      Uri.parse('$originalBase/Ticket/$ticketId/Ticket_User?range=0-50'),
      headers: _directHeaders(session.token),
    );
    if (resp.statusCode != 200 && resp.statusCode != 206) return const [];
    final decoded = jsonDecode(resp.body);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }

  Future<Map<String, dynamic>> _assignTicketToUser(
    _Session session, {
    required String ticketId,
    required int? userId,
  }) async {
    if (userId == null) {
      return {'statusCode': null, 'ok': false, 'reason': 'sem userId'};
    }
    final resp = await http.post(
      Uri.parse('$originalBase/Ticket_User'),
      headers: _directHeaders(session.token),
      body: jsonEncode({
        'input': {
          'tickets_id': ticketId,
          'users_id': userId,
          'type': 2,
          'use_notification': 1,
        },
      }),
    );
    return {
      'statusCode': resp.statusCode,
      'ok':
          resp.statusCode == 200 ||
          resp.statusCode == 201 ||
          (resp.statusCode == 400 && resp.body.contains('Item already exists')),
    };
  }

  Future<Map<String, dynamic>> _documentItems({
    required String base,
    required Map<String, String> headers,
    required String itemType,
    required String itemId,
  }) async {
    final resp = await http.get(
      Uri.parse('$base/$itemType/$itemId/Document_Item?range=0-50'),
      headers: headers,
    );
    final ids = <String>[];
    if (resp.statusCode == 200 || resp.statusCode == 206) {
      final decoded = jsonDecode(resp.body);
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map && item['documents_id'] != null) {
            ids.add('${item['documents_id']}');
          }
        }
      }
    }
    return {
      'httpStatus': resp.statusCode,
      'documentIds': ids,
      'count': ids.length,
    };
  }

  Future<void> _kill(
    String base,
    String token,
    Map<String, String> Function(String? token) headers,
  ) async {
    try {
      await http.get(Uri.parse('$base/killSession'), headers: headers(token));
    } catch (_) {
      // Best effort.
    }
  }

  File _writeEvidencePng(String slug) {
    final dir = Directory('output/e2e');
    dir.createSync(recursive: true);
    final file = File('${dir.path}/sis-e2e-evidencia-$slug.png');
    // PNG 1x1 valido. O nome do arquivo carrega a identificacao da evidencia.
    file.writeAsBytesSync(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=',
      ),
    );
    return file;
  }
}

Object? _safeDecode(String body) {
  try {
    return jsonDecode(body);
  } catch (_) {
    return null;
  }
}

String? _extractDocumentId(String body) {
  final decoded = _safeDecode(body);
  if (decoded is Map) {
    for (final key in ['id', 'documents_id']) {
      if (decoded[key] != null) return '${decoded[key]}';
    }
    final input = decoded['input'];
    if (input is Map) {
      for (final key in ['id', 'documents_id']) {
        if (input[key] != null) return '${input[key]}';
      }
    }
  }
  if (decoded is List) {
    for (final item in decoded) {
      if (item is Map) {
        for (final key in ['id', 'documents_id']) {
          if (item[key] != null) return '${item[key]}';
        }
      }
    }
  }
  return null;
}

int? _intValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String _statusLabel(String status) {
  const labels = {
    '1': 'Novo',
    '2': 'Em Atendimento',
    '3': 'Em Atendimento Planejado',
    '4': 'Pendente',
    '5': 'Solucionado',
    '6': 'Fechado',
  };
  return labels[status] ?? status;
}

String _webUrlFromApi(String apiBase) {
  return apiBase.replaceFirst(RegExp(r'/apirest\.php/?$'), '/');
}
