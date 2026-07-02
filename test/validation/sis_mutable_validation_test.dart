@Tags(['mutable-validation'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sis_mobile_flutter/checklists/checklist_catalog.dart';
import 'package:sis_mobile_flutter/checklists/checklist_condition_engine.dart';
import 'package:sis_mobile_flutter/checklists/checklist_submission.dart';
import 'package:sis_mobile_flutter/models/glpi_ticket.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/services/glpi_ticket_support.dart';

/// Harness de validacao mutavel controlada contra o GLPI SIS real.
///
/// Governanca: ver `CLAUDE.md` > Regras locais. Opera SEMPRE como a conta de
/// teste dedicada (`SIS_TEST_USER`/`SIS_TEST_PASSWORD`), nunca como usuario real.
///
/// Modo direto (este harness): fala com o GLPI interno direto
/// (`SIS_TEST_BASE_URL`) usando `App-Token` (`GLPI_APP_TOKEN`). Isso permite
/// `changeActiveProfile` para simular papeis (Solicitante, Tecnico/Conservacao,
/// Tecnico/Manutencao) — algo que o Worker publico nao expoe. O payload de
/// criacao e montado pelo codigo real de producao
/// ([GlpiTicketSupport.buildCreateTicketPayload]).
///
/// Camadas de seguranca:
/// - `SIS_VALIDATION_ENABLE=true` -> condicao para QUALQUER acesso ao GLPI real.
/// - `GLPI_APP_TOKEN` + `SIS_TEST_BASE_URL` + credenciais -> necessarios.
/// - `SIS_VALIDATION_APPLY=true` -> habilita a criacao/fechamento do ticket.
/// - Todo ticket leva o prefixo `[TESTE-AUTOMATIZADO SIS]`, tem o ID registrado
///   no output e e fechado ao final (cleanup).
///
/// Execucao read-only (login + troca de perfil + contexto, sem mutar):
///   SIS_VALIDATION_ENABLE=true flutter test --tags mutable-validation
/// Execucao com mutacao real:
///   SIS_VALIDATION_ENABLE=true SIS_VALIDATION_APPLY=true \
///     flutter test --tags mutable-validation
///
/// IMPORTANTE para os testes 'P6 (APPLY)' e 'P1 (APPLY)' (validacao end-to-end
/// dos fixes de checklist/offline, criam via GlpiClient real): exporte as
/// variaveis do `.env` no shell primeiro (`set -a; source .env; set +a`) —
/// `dotenv.load()` sempre falha em `flutter test` porque `.env` nao e um
/// asset declarado no pubspec (nao pode ser, contem segredo), e o fallback
/// via `testLoad` so cobre o helper `envOf` deste arquivo, nao
/// `GlpiConfig`/`GlpiClient` (que so leem `dotenv.env`, sem fallback a
/// `Platform.environment`). Alem disso, o teste P6 (checklist) exige o
/// prefixo de marcacao via dart-define, pois `GlpiConfig.sisChecklistTicketNamePrefix`
/// nao tem fallback a `Platform.environment`:
///   SIS_VALIDATION_ENABLE=true SIS_VALIDATION_APPLY=true flutter test \
///     --tags mutable-validation --plain-name "(APPLY)" \
///     --dart-define="SIS_CHECKLIST_TICKET_NAME_PREFIX=[TESTE-AUTOMATIZADO SIS]" \
///     test/validation/sis_mutable_validation_test.dart
void main() {
  const ticketMarker = '[TESTE-AUTOMATIZADO SIS]';

  String envOf(String key) {
    final fromDotenv = dotenv.isInitialized ? (dotenv.maybeGet(key) ?? '') : '';
    final value = fromDotenv.isNotEmpty
        ? fromDotenv
        : (Platform.environment[key] ?? '');
    return value.trim();
  }

  late String base;
  late String appToken;
  late String testUser;
  late String testPassword;
  late bool ready;

  setUpAll(() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // dotenv.load() busca `.env` via asset bundle, mas `.env` nao e um
      // asset declarado no pubspec.yaml (nao pode ser: contem segredo, nunca
      // versionado) — em flutter test isso sempre lanca FileNotFoundError.
      // Fallback: le o arquivo direto do disco e usa testLoad (API oficial
      // do pacote para popular dotenv fora do asset bundle). Sem isso,
      // GlpiConfig/GlpiClient (que so leem via dotenv, sem fallback a
      // Platform.environment como o envOf() deste harness tem) nunca veem
      // as variaveis, mesmo com o .env exportado no shell.
      try {
        final envFile = File('.env');
        if (envFile.existsSync()) {
          dotenv.testLoad(fileInput: envFile.readAsStringSync());
        }
      } catch (_) {
        // Ainda assim sem .env: cai para Platform.environment; pode ser skip.
      }
    }
    final enabled = envOf('SIS_VALIDATION_ENABLE').toLowerCase() == 'true';
    base = envOf('SIS_TEST_BASE_URL');
    appToken = envOf('GLPI_APP_TOKEN');
    testUser = envOf('SIS_TEST_USER');
    testPassword = envOf('SIS_TEST_PASSWORD');
    // App-Token e opcional: alguns GLPI aceitam a API sem ele. Se o servidor
    // exigir, o initSession retorna erro claro e basta preencher GLPI_APP_TOKEN.
    ready =
        enabled &&
        base.isNotEmpty &&
        testUser.isNotEmpty &&
        testPassword.isNotEmpty;
  });

  Map<String, String> headers(String? sessionToken, {bool json = true}) => {
    if (json) 'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (appToken.isNotEmpty) 'App-Token': appToken,
    if (sessionToken != null) 'Session-Token': sessionToken,
  };

  Future<String> initSession() async {
    final resp = await http.get(
      Uri.parse('$base/initSession'),
      headers: {
        ...headers(null),
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$testUser:$testPassword'))}',
      },
    );
    expect(resp.statusCode, 200, reason: 'initSession falhou: ${resp.body}');
    return (jsonDecode(resp.body) as Map)['session_token'] as String;
  }

  // B2: extrai o session_token com seguranca. Quando o login falha (ex.: 401),
  // o corpo e um array de erro (`["ERROR_GLPI_LOGIN", ...]`) e o cast direto
  // `as Map` quebrava o teste com erro de tipo. Aqui lancamos mensagem clara.
  String tokenFromResponse(http.Response resp) {
    final decoded = jsonDecode(resp.body);
    if (decoded is Map && decoded['session_token'] != null) {
      return decoded['session_token'] as String;
    }
    throw StateError('initSession falhou (${resp.statusCode}): ${resp.body}');
  }

  String? jsonFieldValue(String body, String key) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded.containsKey(key)) {
        return decoded[key]?.toString();
      }
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map && item.containsKey(key)) {
            return item[key]?.toString();
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>> activateProfileAndContext(
    String token,
    int profileId,
  ) async {
    final cap = await http.post(
      Uri.parse('$base/changeActiveProfile'),
      headers: headers(token),
      body: jsonEncode({'profiles_id': profileId}),
    );
    // ignore: avoid_print
    print('changeActiveProfile($profileId) -> ${cap.statusCode}');
    expect(
      cap.statusCode,
      anyOf(200, 201),
      reason: 'changeActiveProfile falhou: ${cap.body}',
    );
    final full = await http.get(
      Uri.parse('$base/getFullSession'),
      headers: headers(token),
    );
    final session =
        ((jsonDecode(full.body) as Map)['session'] as Map?) ?? const {};
    return session.cast<String, dynamic>();
  }

  test(
    'certificacao F1/F2 (read-only): bitmask de direitos e ordenacao de '
    'visibilidade por perfil',
    () async {
      if (!ready) {
        markTestSkipped('SIS_VALIDATION_ENABLE!=true');
        return;
      }
      // F1: rights bitmask do ticket por perfil ativo (verdade Camada 1).
      // Estavel e identico ao contrato (re-certificado 2026-06-28).
      const expectedTicketRights = {9: 5, 11: 260102, 12: 145411};
      final token = await initSession();
      final counts = <int, int>{};
      for (final pid in const [9, 11, 12]) {
        final session = await activateProfileAndContext(token, pid);
        final active = (session['glpiactiveprofile'] as Map?) ?? const {};
        final rights = int.tryParse(active['ticket']?.toString() ?? '');
        expect(
          rights,
          expectedTicketRights[pid],
          reason: 'F1 perfil $pid: ticket rights esperado '
              '${expectedTicketRights[pid]}, veio $rights',
        );
        final r = await http.get(
          Uri.parse('$base/search/Ticket?is_deleted=0&range=0-0'),
          headers: headers(token, json: false),
        );
        counts[pid] =
            int.tryParse(jsonFieldValue(r.body, 'totalcount') ?? '') ?? 0;
        // ignore: avoid_print
        print('perfil $pid: rights=$rights totalcount=${counts[pid]}');
      }
      // F2: ordenacao semantica de scope 9 (OWN_ONLY) < 12 (GG) < 11 (tecnico).
      // Os counts driftam no tempo; certifica-se a ORDENACAO, nao o numero.
      expect(
        counts[9]! < counts[12]! && counts[12]! < counts[11]!,
        isTrue,
        reason: 'F2 ordenacao esperada 9<12<11; veio $counts',
      );
      // reverte ao perfil 9 (estado original da conta).
      await activateProfileAndContext(token, 9);
    },
  );

  test(
    'cleanup (APPLY): fecha tickets [TESTE-AUTOMATIZADO SIS] ainda abertos',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
        markTestSkipped('SIS_VALIDATION_APPLY!=true');
        return;
      }
      final adminUser = envOf('SIS_TEST_ADMIN_USER');
      final adminPassword = envOf('SIS_TEST_ADMIN_PASSWORD');
      if (adminUser.isEmpty || adminPassword.isEmpty) {
        markTestSkipped('sem credenciais admin de teste');
        return;
      }
      final init = await http.get(
        Uri.parse('$base/initSession'),
        headers: {
          ...headers(null),
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$adminUser:$adminPassword'))}',
        },
      );
      final token = tokenFromResponse(init);
      try {
        final uri = Uri.parse(
          '$base/search/Ticket'
          '?criteria[0][field]=1'
          '&criteria[0][searchtype]=contains'
          '&criteria[0][value]=TESTE-AUTOMATIZADO'
          '&forcedisplay[0]=2&forcedisplay[1]=12'
          '&range=0-300',
        );
        final r = await http.get(uri, headers: headers(token));
        final rows = ((jsonDecode(r.body) as Map)['data'] as List?) ?? const [];
        final fechados = <String>[];
        final falhou = <String>[];
        for (final row in rows) {
          if (row is! Map) continue;
          final id = '${row['2']}';
          if ('${row['12']}' == '6') continue;
          // Alguns tickets do probe foram criados sem categoria; o GLPI exige
          // categoria antes de solucionar/fechar. Atribui antes.
          await http.put(
            Uri.parse('$base/Ticket/$id'),
            headers: headers(token),
            body: jsonEncode({
              'input': {'id': id, 'itilcategories_id': 47},
            }),
          );
          // Ciclo de vida do GLPI: Novo nao vai direto a Fechado. Adiciona uma
          // solucao (-> Solucionado 5) e entao fecha (-> 6).
          final sol = await http.post(
            Uri.parse('$base/ITILSolution'),
            headers: headers(token),
            body: jsonEncode({
              'input': {
                'itemtype': 'Ticket',
                'items_id': id,
                'content': 'Encerramento de ticket de teste automatizado.',
              },
            }),
          );
          final put = await http.put(
            Uri.parse('$base/Ticket/$id'),
            headers: headers(token),
            body: jsonEncode({
              'input': {'id': id, 'status': 6},
            }),
          );
          // ignore: avoid_print
          print(
            '  $id sol=${sol.statusCode} put=${put.statusCode}'
            '${sol.statusCode >= 400 ? ' solbody=${sol.body}' : ''}',
          );
          final check = await http.get(
            Uri.parse('$base/Ticket/$id'),
            headers: headers(token),
          );
          final st = '${(jsonDecode(check.body) as Map)['status']}';
          if (st == '6') {
            fechados.add(id);
          } else {
            falhou.add('$id(st=$st)');
          }
        }
        // ignore: avoid_print
        print('CLEANUP_FINAL fechados=$fechados falhou=$falhou');
      } finally {
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  test(
    'auditoria read-only: lista tickets [TESTE-AUTOMATIZADO SIS] e seus status',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      final adminUser = envOf('SIS_TEST_ADMIN_USER');
      final adminPassword = envOf('SIS_TEST_ADMIN_PASSWORD');
      final hasAdmin = adminUser.isNotEmpty && adminPassword.isNotEmpty;
      // Usa admin (visao ampla) se houver; senao a propria conta de teste.
      final String token;
      if (hasAdmin) {
        final init = await http.get(
          Uri.parse('$base/initSession'),
          headers: {
            ...headers(null),
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$adminUser:$adminPassword'))}',
          },
        );
        token = tokenFromResponse(init);
      } else {
        token = await initSession();
      }
      try {
        final uri = Uri.parse(
          '$base/search/Ticket'
          '?criteria[0][field]=1'
          '&criteria[0][searchtype]=contains'
          '&criteria[0][value]=TESTE-AUTOMATIZADO'
          '&forcedisplay[0]=2&forcedisplay[1]=1&forcedisplay[2]=12'
          '&sort=2&order=ASC&range=0-300',
        );
        final r = await http.get(uri, headers: headers(token));
        final body = jsonDecode(r.body);
        final rows = (body is Map ? body['data'] : null) as List? ?? const [];
        const statusName = {
          '1': 'Novo',
          '2': 'Atendimento',
          '3': 'Atendimento(plan)',
          '4': 'Pendente',
          '5': 'Solucionado',
          '6': 'Fechado',
        };
        var abertos = 0;
        final lines = <String>[];
        for (final row in rows) {
          if (row is! Map) continue;
          final id = '${row['2']}';
          final st = '${row['12']}';
          if (st != '6') abertos++;
          lines.add('$id=${statusName[st] ?? st}');
        }
        // ignore: avoid_print
        print('AUDITORIA total=${rows.length} nao_fechados=$abertos');
        // ignore: avoid_print
        print('AUDITORIA tickets: ${lines.join(' | ')}');
      } finally {
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  test(
    'read-only direto: login + changeActiveProfile + contexto da conta de teste',
    () async {
      if (!ready) {
        markTestSkipped(
          'modo direto desabilitado (defina SIS_VALIDATION_ENABLE=true, '
          'SIS_TEST_BASE_URL, GLPI_APP_TOKEN e SIS_TEST_USER/SIS_TEST_PASSWORD).',
        );
        return;
      }
      final profileId = int.tryParse(envOf('SIS_TEST_PROFILE_ID')) ?? 9;
      final token = await initSession();
      try {
        final session = await activateProfileAndContext(token, profileId);
        // ignore: avoid_print
        print(
          'Contexto -> userId=${session['glpiID']} '
          'perfilAtivo=${session['glpiactiveprofile']?['name']} '
          'entidadeAtiva=${session['glpiactive_entity']}',
        );
        expect(session['glpiactiveprofile']?['name'], isNotNull);
      } finally {
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  test('mutavel direto (APPLY): perfil-alvo cria ticket, valida grupo via '
      'read-back e fecha', () async {
    if (!ready) {
      markTestSkipped('modo direto desabilitado');
      return;
    }
    if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
      markTestSkipped('SIS_VALIDATION_APPLY!=true: mutacao desabilitada');
      return;
    }
    final profileId = int.tryParse(envOf('SIS_TEST_PROFILE_ID')) ?? 9;
    final categoryId = int.tryParse(envOf('SIS_TEST_CATEGORY_ID'));
    final entityId = int.tryParse(envOf('SIS_TEST_ENTITY_ID'));
    expect(categoryId, isNotNull, reason: 'defina SIS_TEST_CATEGORY_ID');
    expect(entityId, isNotNull, reason: 'defina SIS_TEST_ENTITY_ID');

    final token = await initSession();
    String? ticketId;
    try {
      final session = await activateProfileAndContext(token, profileId);
      final rawUserId = session['glpiID'];
      final userId = rawUserId is int ? rawUserId : int.tryParse('$rawUserId');
      // ignore: avoid_print
      print(
        'Criando como perfil=${session['glpiactiveprofile']?['name']} '
        'userId=$userId entidade=$entityId categoria=$categoryId',
      );

      final stamp = DateTime.now().toIso8601String();
      final formData = <String, dynamic>{
        'assunto': '$ticketMarker validacao RuleTicket $stamp',
        'descricao':
            'Ticket de teste automatizado, descartavel. Valida atribuicao de '
            'grupo via RuleTicket (payload minimo). Pode ser fechado.',
        'serviceName': '',
        'governedCategoryId': categoryId,
        'entities_id': entityId,
        'loggedUserId': userId,
      };
      final payload = GlpiTicketSupport.buildCreateTicketPayload(formData);
      final input = payload['input'] as Map<String, dynamic>;
      // Prova local: o payload do app NAO contem campos de atribuicao.
      expect(input.containsKey('_groups_id_assign'), isFalse);
      expect(input.containsKey('_groups_id_requester'), isFalse);
      expect(input.containsKey('_users_id_assign'), isFalse);

      final create = await http.post(
        Uri.parse('$base/Ticket'),
        headers: headers(token),
        body: jsonEncode(payload),
      );
      // ignore: avoid_print
      print('POST /Ticket -> ${create.statusCode}: ${create.body}');
      expect(
        create.statusCode,
        anyOf(200, 201),
        reason: 'GLPI recusou a criacao (perfil $profileId): ${create.body}',
      );
      ticketId = (jsonDecode(create.body) as Map)['id'].toString();
      // ignore: avoid_print
      print('Ticket criado: ID=$ticketId (REGISTRAR p/ auditoria/limpeza)');

      // Read-back: prova de que a RuleTicket atribuiu um grupo, ja que o app
      // NAO envia mais _groups_id_assign.
      final gt = await http.get(
        Uri.parse('$base/Ticket/$ticketId/Group_Ticket?range=0-50'),
        headers: headers(token),
      );
      String? assignedGroupId;
      if (gt.statusCode == 200 || gt.statusCode == 206) {
        final rows = jsonDecode(gt.body);
        if (rows is List) {
          for (final r in rows) {
            if (r is Map && '${r['type']}' == '2') {
              assignedGroupId = '${r['groups_id']}';
              break;
            }
          }
        }
      }
      String? assignedGroupName;
      if (assignedGroupId != null) {
        final g = await http.get(
          Uri.parse('$base/Group/$assignedGroupId'),
          headers: headers(token),
        );
        if (g.statusCode == 200) {
          final gm = jsonDecode(g.body);
          if (gm is Map) {
            assignedGroupName = '${gm['completename'] ?? gm['name']}';
          }
        }
      }
      // ignore: avoid_print
      print(
        'Read-back -> grupo_atribuido_id=$assignedGroupId '
        'grupo_nome=$assignedGroupName',
      );
      expect(
        assignedGroupId,
        isNotNull,
        reason:
            'RuleTicket nao atribuiu grupo; revisar regra por categoria/entidade',
      );
    } finally {
      if (ticketId != null) {
        final close = await http.put(
          Uri.parse('$base/Ticket/$ticketId'),
          headers: headers(token),
          body: jsonEncode({
            'input': {'id': ticketId, 'status': 6},
          }),
        );
        // ignore: avoid_print
        print('Cleanup -> ticket $ticketId fechado: ${close.statusCode}');
      }
      await http.get(Uri.parse('$base/killSession'), headers: headers(token));
    }
  });

  test(
    'admin read-only: inspeciona ProfileRight ticket dos perfis 9 (Solicitante) '
    'e 11 (tecnico)',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      final adminUser = envOf('SIS_TEST_ADMIN_USER');
      final adminPassword = envOf('SIS_TEST_ADMIN_PASSWORD');
      if (adminUser.isEmpty || adminPassword.isEmpty) {
        markTestSkipped('sem SIS_TEST_ADMIN_USER/SIS_TEST_ADMIN_PASSWORD');
        return;
      }

      final auth =
          'Basic ${base64Encode(utf8.encode('$adminUser:$adminPassword'))}';
      final init = await http.get(
        Uri.parse('$base/initSession'),
        headers: {...headers(null), 'Authorization': auth},
      );
      expect(init.statusCode, 200, reason: 'admin initSession: ${init.body}');
      final token = tokenFromResponse(init);

      // Objetos exercidos pelas acoes mutaveis do app como Solicitante.
      const relevant = {
        'ticket',
        'followup',
        'task',
        'itilsolution',
        'ticketvalidation',
        'document',
        'ticketcost',
      };
      try {
        final resp = await http.get(
          Uri.parse('$base/Profile/9/ProfileRight?range=0-400'),
          headers: headers(token),
        );
        if (resp.statusCode == 200 || resp.statusCode == 206) {
          final rows = jsonDecode(resp.body);
          if (rows is List) {
            for (final r in rows) {
              if (r is Map && relevant.contains('${r['name']}')) {
                final v = int.tryParse('${r['rights']}') ?? 0;
                // ignore: avoid_print
                print(
                  'RIGHT9 name=${r['name']} rights=$v '
                  'READ=${v & 1 != 0} UPDATE=${v & 2 != 0} '
                  'CREATE=${v & 4 != 0} PURGE=${v & 16 != 0}',
                );
              }
            }
          }
        }
      } finally {
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  test(
    'acoes do Solicitante (APPLY): followup e mudanca de status num ticket proprio',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
        markTestSkipped('SIS_VALIDATION_APPLY!=true');
        return;
      }
      final categoryId = int.parse(envOf('SIS_TEST_CATEGORY_ID'));
      final entityId = int.parse(envOf('SIS_TEST_ENTITY_ID'));

      final token = await initSession();
      String? ticketId;
      try {
        await activateProfileAndContext(token, 9);
        // Cria o ticket de teste (ja sabemos que funciona com CREATE).
        final payload = GlpiTicketSupport.buildCreateTicketPayload({
          'assunto': '$ticketMarker acoes ${DateTime.now().toIso8601String()}',
          'descricao': 'Teste de acoes mutaveis do Solicitante. Descartavel.',
          'serviceName': '',
          'governedCategoryId': categoryId,
          'entities_id': entityId,
          'loggedUserId': 2373,
        });
        final create = await http.post(
          Uri.parse('$base/Ticket'),
          headers: headers(token),
          body: jsonEncode(payload),
        );
        if (create.statusCode != 200 && create.statusCode != 201) {
          // ignore: avoid_print
          print('ACOES: criacao falhou ${create.statusCode} ${create.body}');
          return;
        }
        ticketId = (jsonDecode(create.body) as Map)['id'].toString();

        // 1) Followup (enviar mensagem).
        final fup = await http.post(
          Uri.parse('$base/TicketFollowup'),
          headers: headers(token),
          body: jsonEncode({
            'input': {
              'tickets_id': ticketId,
              'content': 'mensagem de teste',
              'is_private': 0,
            },
          }),
        );
        // ignore: avoid_print
        print(
          'ACAO followup -> ${fup.statusCode}'
          '${fup.statusCode >= 400 ? ' ${fup.body}' : ''}',
        );

        // 2) Mudanca de status via PUT /Ticket (proxy de aprovar/recusar solucao).
        final put = await http.put(
          Uri.parse('$base/Ticket/$ticketId'),
          headers: headers(token),
          body: jsonEncode({
            'input': {'id': ticketId, 'status': 2},
          }),
        );
        // ignore: avoid_print
        print(
          'ACAO put_status -> ${put.statusCode}'
          '${put.statusCode >= 400 ? ' ${put.body}' : ''}',
        );
      } finally {
        if (ticketId != null) {
          await http.put(
            Uri.parse('$base/Ticket/$ticketId'),
            headers: headers(token),
            body: jsonEncode({
              'input': {'id': ticketId, 'status': 6},
            }),
          );
          // ignore: avoid_print
          print('ACOES cleanup ticket=$ticketId');
        }
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  test(
    'ciclo completo (APPLY): solucao (aprovar/recusar) e anexo como Solicitante',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
        markTestSkipped('SIS_VALIDATION_APPLY!=true');
        return;
      }
      final categoryId = int.parse(envOf('SIS_TEST_CATEGORY_ID'));
      final entityId = int.parse(envOf('SIS_TEST_ENTITY_ID'));
      final token = await initSession();

      Future<void> profile(int id) async {
        await http.post(
          Uri.parse('$base/changeActiveProfile'),
          headers: headers(token),
          body: jsonEncode({'profiles_id': id}),
        );
      }

      Future<String> createAsRequester() async {
        await profile(9);
        final payload = GlpiTicketSupport.buildCreateTicketPayload({
          'assunto':
              '$ticketMarker ciclo ${DateTime.now().microsecondsSinceEpoch}',
          'descricao': 'Teste de ciclo. Descartavel.',
          'serviceName': '',
          'governedCategoryId': categoryId,
          'entities_id': entityId,
          'loggedUserId': 2373,
        });
        final r = await http.post(
          Uri.parse('$base/Ticket'),
          headers: headers(token),
          body: jsonEncode(payload),
        );
        return (jsonDecode(r.body) as Map)['id'].toString();
      }

      Future<int> proposeSolutionAsTech(String id) async {
        await profile(11);
        final r = await http.post(
          Uri.parse('$base/ITILSolution'),
          headers: headers(token),
          body: jsonEncode({
            'input': {
              'itemtype': 'Ticket',
              'items_id': id,
              'content': 'solucao de teste',
            },
          }),
        );
        return r.statusCode;
      }

      final created = <String>[];
      try {
        // --- Cenario A: APROVAR solucao ---
        final tA = await createAsRequester();
        created.add(tA);
        final solA = await proposeSolutionAsTech(tA);
        await profile(9);
        final approve = await http.put(
          Uri.parse('$base/Ticket/$tA'),
          headers: headers(token),
          body: jsonEncode({
            'input': {'id': tA, 'status': 6, '_accepted': 1},
          }),
        );
        // ignore: avoid_print
        print(
          'APROVAR_SOLUCAO ticket=$tA solucao_post=$solA '
          'put_aprovar=${approve.statusCode}'
          '${approve.statusCode >= 400 ? ' ${approve.body}' : ''}',
        );

        // --- Cenario B: RECUSAR solucao ---
        final tB = await createAsRequester();
        created.add(tB);
        final solB = await proposeSolutionAsTech(tB);
        await profile(9);
        final reject = await http.put(
          Uri.parse('$base/Ticket/$tB'),
          headers: headers(token),
          body: jsonEncode({
            'input': {'id': tB, 'status': 2},
          }),
        );
        // ignore: avoid_print
        print(
          'RECUSAR_SOLUCAO ticket=$tB solucao_post=$solB '
          'put_recusar=${reject.statusCode}'
          '${reject.statusCode >= 400 ? ' ${reject.body}' : ''}',
        );

        // --- Cenario C: ANEXAR arquivo ---
        final tC = await createAsRequester();
        created.add(tC);
        final req = http.MultipartRequest(
          'POST',
          Uri.parse('$base/Ticket/$tC/Document'),
        );
        req.headers.addAll({
          'Accept': 'application/json',
          'App-Token': appToken,
          'Session-Token': token,
        });
        req.files.add(
          http.MultipartFile.fromString(
            'uploadManifest',
            jsonEncode({
              'input': {
                'name': 'anexo.txt',
                '_filename': ['anexo.txt'],
                'items_id': tC,
                'itemtype': 'Ticket',
              },
            }),
            contentType: MediaType('application', 'json'),
          ),
        );
        req.files.add(
          http.MultipartFile.fromBytes(
            'filename[0]',
            utf8.encode('conteudo de teste'),
            filename: 'anexo.txt',
            contentType: MediaType('text', 'plain'),
          ),
        );
        final attachResp = await http.Response.fromStream(await req.send());
        // ignore: avoid_print
        print(
          'ANEXAR ticket=$tC -> ${attachResp.statusCode}'
          '${attachResp.statusCode >= 400 ? ' ${attachResp.body}' : ''}',
        );
      } finally {
        // Cleanup com perfil tecnico (tem UPDATE) para garantir fechamento.
        await profile(11);
        for (final id in created) {
          await http.put(
            Uri.parse('$base/Ticket/$id'),
            headers: headers(token),
            body: jsonEncode({
              'input': {'id': id, 'status': 6},
            }),
          );
        }
        // ignore: avoid_print
        print('CICLO cleanup tickets=$created (fechados via perfil tecnico)');
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  test('investiga caminho correto de aprovacao de solucao (APPLY)', () async {
    if (!ready) {
      markTestSkipped('modo direto desabilitado');
      return;
    }
    if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
      markTestSkipped('SIS_VALIDATION_APPLY!=true');
      return;
    }
    final categoryId = int.parse(envOf('SIS_TEST_CATEGORY_ID'));
    final entityId = int.parse(envOf('SIS_TEST_ENTITY_ID'));
    final token = await initSession();

    Future<void> profile(int id) async {
      await http.post(
        Uri.parse('$base/changeActiveProfile'),
        headers: headers(token),
        body: jsonEncode({'profiles_id': id}),
      );
    }

    Future<String> createTicket() async {
      await profile(9);
      final payload = GlpiTicketSupport.buildCreateTicketPayload({
        'assunto':
            '$ticketMarker aprov ${DateTime.now().microsecondsSinceEpoch}',
        'descricao': 'Teste caminho aprovacao. Descartavel.',
        'serviceName': '',
        'governedCategoryId': categoryId,
        'entities_id': entityId,
        'loggedUserId': 2373,
      });
      final r = await http.post(
        Uri.parse('$base/Ticket'),
        headers: headers(token),
        body: jsonEncode(payload),
      );
      return (jsonDecode(r.body) as Map)['id'].toString();
    }

    Future<String?> proposeSolution(String id) async {
      await profile(11);
      final r = await http.post(
        Uri.parse('$base/ITILSolution'),
        headers: headers(token),
        body: jsonEncode({
          'input': {'itemtype': 'Ticket', 'items_id': id, 'content': 'sol'},
        }),
      );
      if (r.statusCode == 200 || r.statusCode == 201) {
        return (jsonDecode(r.body) as Map)['id'].toString();
      }
      return null;
    }

    // Status GLPI: 1=Novo, 2=Atendimento, 4=Pendente, 5=Solucionado, 6=Fechado.
    Future<String> ticketStatus(String id) async {
      final r = await http.get(
        Uri.parse('$base/Ticket/$id'),
        headers: headers(token),
      );
      return '${(jsonDecode(r.body) as Map)['status']}';
    }

    final created = <String>[];
    try {
      // RECUSAR: followup add_reopen deve REABRIR (5 -> 1/2).
      final tA = await createTicket();
      created.add(tA);
      await proposeSolution(tA);
      await profile(9);
      final beforeA = await ticketStatus(tA);
      final fa = await http.post(
        Uri.parse('$base/TicketFollowup'),
        headers: headers(token),
        body: jsonEncode({
          'input': {
            'tickets_id': tA,
            'content': 'nao resolvido',
            'add_reopen': 1,
          },
        }),
      );
      final afterA = await ticketStatus(tA);
      // ignore: avoid_print
      print(
        'RECUSAR http=${fa.statusCode} status_antes=$beforeA '
        'status_depois=$afterA EFEITO_OK=${beforeA == '5' && afterA != '5'}',
      );

      // APROVAR: followup add_close deve FECHAR (5 -> 6).
      final tB = await createTicket();
      created.add(tB);
      await proposeSolution(tB);
      await profile(9);
      final beforeB = await ticketStatus(tB);
      final pb = await http.post(
        Uri.parse('$base/TicketFollowup'),
        headers: headers(token),
        body: jsonEncode({
          'input': {
            'tickets_id': tB,
            'content': 'resolvido, obrigado',
            'add_close': 1,
          },
        }),
      );
      final afterB = await ticketStatus(tB);
      // ignore: avoid_print
      print(
        'APROVAR http=${pb.statusCode} status_antes=$beforeB '
        'status_depois=$afterB EFEITO_OK=${beforeB == '5' && afterB == '6'}',
      );
    } finally {
      await profile(11);
      for (final id in created) {
        await http.put(
          Uri.parse('$base/Ticket/$id'),
          headers: headers(token),
          body: jsonEncode({
            'input': {'id': id, 'status': 6},
          }),
        );
      }
      // ignore: avoid_print
      print('APROV cleanup tickets=$created');
      await http.get(Uri.parse('$base/killSession'), headers: headers(token));
    }
  });

  test(
    'validacao adicional (APPLY): anexo (efeito), read-back e para-terceiro',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
        markTestSkipped('SIS_VALIDATION_APPLY!=true');
        return;
      }
      final categoryId = int.parse(envOf('SIS_TEST_CATEGORY_ID'));
      final entityId = int.parse(envOf('SIS_TEST_ENTITY_ID'));

      // Beneficiario do "para-terceiro" = conta admin de teste (nao usuario real).
      int? thirdPartyId;
      final adminUser = envOf('SIS_TEST_ADMIN_USER');
      final adminPassword = envOf('SIS_TEST_ADMIN_PASSWORD');
      if (adminUser.isNotEmpty && adminPassword.isNotEmpty) {
        final ai = await http.get(
          Uri.parse('$base/initSession'),
          headers: {
            ...headers(null),
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$adminUser:$adminPassword'))}',
          },
        );
        final at = (jsonDecode(ai.body) as Map)['session_token'] as String;
        final fs = await http.get(
          Uri.parse('$base/getFullSession'),
          headers: headers(at),
        );
        final sess = (jsonDecode(fs.body) as Map)['session'] as Map;
        thirdPartyId = int.tryParse('${sess['glpiID']}');
        await http.get(Uri.parse('$base/killSession'), headers: headers(at));
      }

      final token = await initSession();
      Future<void> profile(int id) async {
        await http.post(
          Uri.parse('$base/changeActiveProfile'),
          headers: headers(token),
          body: jsonEncode({'profiles_id': id}),
        );
      }

      Future<String> createTicket(Map<String, dynamic> extra) async {
        await profile(9);
        final payload = GlpiTicketSupport.buildCreateTicketPayload({
          'assunto':
              '$ticketMarker extra ${DateTime.now().microsecondsSinceEpoch}',
          'descricao': 'Validacao adicional. Descartavel.',
          'serviceName': '',
          'governedCategoryId': categoryId,
          'entities_id': entityId,
          'loggedUserId': 2373,
          ...extra,
        });
        final r = await http.post(
          Uri.parse('$base/Ticket'),
          headers: headers(token),
          body: jsonEncode(payload),
        );
        expect(r.statusCode, anyOf(200, 201), reason: 'criacao: ${r.body}');
        return (jsonDecode(r.body) as Map)['id'].toString();
      }

      final created = <String>[];
      try {
        // 1) ANEXO — efeito real (documento vinculado ao ticket).
        final tA = await createTicket(const {});
        created.add(tA);
        final mp = http.MultipartRequest(
          'POST',
          Uri.parse('$base/Ticket/$tA/Document'),
        );
        mp.headers.addAll({
          'Accept': 'application/json',
          'App-Token': appToken,
          'Session-Token': token,
        });
        mp.files.add(
          http.MultipartFile.fromString(
            'uploadManifest',
            jsonEncode({
              'input': {
                'name': 'anexo.txt',
                '_filename': ['anexo.txt'],
                'items_id': tA,
                'itemtype': 'Ticket',
              },
            }),
            contentType: MediaType('application', 'json'),
          ),
        );
        mp.files.add(
          http.MultipartFile.fromBytes(
            'filename[0]',
            utf8.encode('conteudo de teste'),
            filename: 'anexo.txt',
            contentType: MediaType('text', 'plain'),
          ),
        );
        final up = await http.Response.fromStream(await mp.send());
        // Verificacao do vinculo com sessao ADMIN (direito de document garantido).
        var diStatus = -1;
        var docs = -1;
        if (adminUser.isNotEmpty && adminPassword.isNotEmpty) {
          final ai = await http.get(
            Uri.parse('$base/initSession'),
            headers: {
              ...headers(null),
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$adminUser:$adminPassword'))}',
            },
          );
          final at = (jsonDecode(ai.body) as Map)['session_token'] as String;
          final di = await http.get(
            Uri.parse('$base/Ticket/$tA/Document_Item'),
            headers: headers(at),
          );
          diStatus = di.statusCode;
          if (di.statusCode == 200 || di.statusCode == 206) {
            docs = (jsonDecode(di.body) as List).length;
          }
          await http.get(Uri.parse('$base/killSession'), headers: headers(at));
        }
        // ignore: avoid_print
        print(
          'ANEXO_EFEITO ticket=$tA upload=${up.statusCode} '
          'di_http=$diStatus docs_vinculados=$docs (le como admin)',
        );

        // 2) READ-BACK governado — grupo, categoria e task templates.
        final tB = await createTicket(const {});
        created.add(tB);
        final gt = await http.get(
          Uri.parse('$base/Ticket/$tB/Group_Ticket?range=0-50'),
          headers: headers(token),
        );
        String? grp;
        if (gt.statusCode == 200 || gt.statusCode == 206) {
          for (final r in (jsonDecode(gt.body) as List)) {
            if (r is Map && '${r['type']}' == '2') grp = '${r['groups_id']}';
          }
        }
        await profile(11); // tecnico le TicketTask
        final tk = await http.get(
          Uri.parse('$base/Ticket/$tB/TicketTask?range=0-50'),
          headers: headers(token),
        );
        final tasks = (tk.statusCode == 200 || tk.statusCode == 206)
            ? (jsonDecode(tk.body) as List).length
            : -1;
        final tBfull = await http.get(
          Uri.parse('$base/Ticket/$tB'),
          headers: headers(token),
        );
        final cat = '${(jsonDecode(tBfull.body) as Map)['itilcategories_id']}';
        // ignore: avoid_print
        print(
          'READBACK ticket=$tB grupo=$grp categoria=$cat '
          'task_templates=$tasks',
        );

        // 3) PARA-TERCEIRO — beneficiario=requester, autor logado=observer.
        if (thirdPartyId != null && thirdPartyId != 2373) {
          final tC = await createTicket({'beneficiaryUserId': thirdPartyId});
          created.add(tC);
          final tu = await http.get(
            Uri.parse('$base/Ticket/$tC/Ticket_User?range=0-50'),
            headers: headers(token),
          );
          String? requester;
          String? observer;
          if (tu.statusCode == 200 || tu.statusCode == 206) {
            for (final r in (jsonDecode(tu.body) as List)) {
              if (r is! Map) continue;
              if ('${r['type']}' == '1') requester = '${r['users_id']}';
              if ('${r['type']}' == '3') observer = '${r['users_id']}';
            }
          }
          // ignore: avoid_print
          print(
            'PARA_TERCEIRO ticket=$tC beneficiario=$thirdPartyId '
            'requester=$requester observer=$observer '
            'OK=${requester == '$thirdPartyId' && observer == '2373'}',
          );
        } else {
          // ignore: avoid_print
          print('PARA_TERCEIRO pulado (sem beneficiario de teste distinto)');
        }
      } finally {
        // Cleanup via tecnico (tem UPDATE): solucao + fechar. Categoria ja = 47.
        await profile(11);
        for (final id in created) {
          await http.post(
            Uri.parse('$base/ITILSolution'),
            headers: headers(token),
            body: jsonEncode({
              'input': {'itemtype': 'Ticket', 'items_id': id, 'content': 'fim'},
            }),
          );
          await http.put(
            Uri.parse('$base/Ticket/$id'),
            headers: headers(token),
            body: jsonEncode({
              'input': {'id': id, 'status': 6},
            }),
          );
        }
        // ignore: avoid_print
        print('EXTRA cleanup tickets=$created');
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  test(
    'valida caminho WORKER como Solicitante (APPLY): ajusta default, valida, reverte',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
        markTestSkipped('SIS_VALIDATION_APPLY!=true');
        return;
      }
      final adminUser = envOf('SIS_TEST_ADMIN_USER');
      final adminPassword = envOf('SIS_TEST_ADMIN_PASSWORD');
      final workerBase = envOf('GLPI_BASE_URL');
      if (adminUser.isEmpty || adminPassword.isEmpty || workerBase.isEmpty) {
        markTestSkipped('sem admin de teste ou GLPI_BASE_URL (Worker)');
        return;
      }
      const puId = 2714; // profile 9 (Solicitante) / entidade 28 (DTIC)
      final categoryId = int.parse(envOf('SIS_TEST_CATEGORY_ID'));

      // Sessao admin (GLPI direto) para ajustar/reverter o default.
      final ai = await http.get(
        Uri.parse('$base/initSession'),
        headers: {
          ...headers(null),
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$adminUser:$adminPassword'))}',
        },
      );
      final adminToken =
          (jsonDecode(ai.body) as Map)['session_token'] as String;

      // Headers para o Worker: o Worker injeta o proprio App-Token.
      Map<String, String> wHeaders(String? t) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (t != null) 'Session-Token': t,
      };

      var reverted = false;
      var defaultChanged = false;
      String? createdViaWorker;
      try {
        // 1) Marca Solicitante/DTIC como perfil padrao.
        final set = await http.put(
          Uri.parse('$base/Profile_User/$puId'),
          headers: headers(adminToken),
          body: jsonEncode({
            'input': {'id': puId, 'is_default': 1},
          }),
        );
        final afterSet = await http.get(
          Uri.parse('$base/Profile_User/$puId'),
          headers: headers(adminToken),
        );
        final persistedDefault = jsonFieldValue(afterSet.body, 'is_default');
        defaultChanged = set.statusCode == 200 && persistedDefault == '1';
        // ignore: avoid_print
        print(
          'SET_DEFAULT pu=$puId -> ${set.statusCode} '
          'is_default_persistiu=${persistedDefault ?? 'indisponivel'} '
          'alterou=$defaultChanged',
        );

        // 2) Login da conta de teste VIA WORKER e confere o perfil ativo.
        final wInit = await http.get(
          Uri.parse('$workerBase/initSession'),
          headers: {
            ...wHeaders(null),
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$testUser:$testPassword'))}',
          },
        );
        // ignore: avoid_print
        print('WORKER_INIT -> ${wInit.statusCode}');
        if (wInit.statusCode == 200) {
          final wToken =
              (jsonDecode(wInit.body) as Map)['session_token'] as String;
          final wFull = await http.get(
            Uri.parse('$workerBase/getFullSession'),
            headers: wHeaders(wToken),
          );
          final sess =
              ((jsonDecode(wFull.body) as Map)['session'] as Map?) ?? const {};
          final perfil = '${sess['glpiactiveprofile']?['name']}';
          final ent = '${sess['glpiactive_entity']}';
          // ignore: avoid_print
          print(
            'WORKER perfil_ativo=$perfil entidade=$ent userId=${sess['glpiID']}',
          );

          if (perfil.toLowerCase().contains('solicitante')) {
            // 3) Cria chamado COMO SOLICITANTE pelo Worker (caminho do APK).
            final payload = GlpiTicketSupport.buildCreateTicketPayload({
              'assunto':
                  '$ticketMarker WORKER ${DateTime.now().microsecondsSinceEpoch}',
              'descricao':
                  'Validacao via Worker (caminho do APK). Descartavel.',
              'serviceName': '',
              'governedCategoryId': categoryId,
              'entities_id': 28,
              'loggedUserId': 2373,
            });
            final wCreate = await http.post(
              Uri.parse('$workerBase/Ticket'),
              headers: wHeaders(wToken),
              body: jsonEncode(payload),
            );
            // ignore: avoid_print
            print('WORKER_CRIAR -> ${wCreate.statusCode}: ${wCreate.body}');
            if (wCreate.statusCode == 200 || wCreate.statusCode == 201) {
              createdViaWorker = (jsonDecode(wCreate.body) as Map)['id']
                  .toString();
            }
            await http.get(
              Uri.parse('$workerBase/killSession'),
              headers: wHeaders(wToken),
            );
          }
        }
      } finally {
        if (defaultChanged) {
          // 4) REVERTE o default ao estado original (is_default=0).
          final rev = await http.put(
            Uri.parse('$base/Profile_User/$puId'),
            headers: headers(adminToken),
            body: jsonEncode({
              'input': {'id': puId, 'is_default': 0},
            }),
          );
          final check = await http.get(
            Uri.parse('$base/Profile_User/$puId'),
            headers: headers(adminToken),
          );
          final nowDef = jsonFieldValue(check.body, 'is_default');
          reverted =
              rev.statusCode == 200 &&
              (nowDef == null || nowDef == '0' || nowDef == 'null');
          // ignore: avoid_print
          print(
            'REVERT_DEFAULT pu=$puId put=${rev.statusCode} '
            'is_default_agora=${nowDef ?? 'indisponivel'} revertido=$reverted',
          );
        } else {
          reverted = true;
          // ignore: avoid_print
          print('REVERT_DEFAULT pu=$puId ignorado: default nao foi alterado');
        }

        // Cleanup do ticket criado via Worker (via admin: categoria + solucao + fechar).
        if (createdViaWorker != null) {
          await http.post(
            Uri.parse('$base/ITILSolution'),
            headers: headers(adminToken),
            body: jsonEncode({
              'input': {
                'itemtype': 'Ticket',
                'items_id': createdViaWorker,
                'content': 'fim',
              },
            }),
          );
          await http.put(
            Uri.parse('$base/Ticket/$createdViaWorker'),
            headers: headers(adminToken),
            body: jsonEncode({
              'input': {'id': createdViaWorker, 'status': 6},
            }),
          );
          // ignore: avoid_print
          print('WORKER cleanup ticket=$createdViaWorker fechado');
        }
        await http.get(
          Uri.parse('$base/killSession'),
          headers: headers(adminToken),
        );
      }
      expect(
        reverted,
        isTrue,
        reason: 'ATENCAO: reverter is_default do Profile_User $puId para 0',
      );
    },
  );

  test(
    'valida WORKER E2E (APPLY): criar+grupo, mensagem, anexo, aprovar, recusar',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
        markTestSkipped('SIS_VALIDATION_APPLY!=true');
        return;
      }
      final adminUser = envOf('SIS_TEST_ADMIN_USER');
      final adminPassword = envOf('SIS_TEST_ADMIN_PASSWORD');
      final workerBase = envOf('GLPI_BASE_URL');
      if (adminUser.isEmpty || adminPassword.isEmpty || workerBase.isEmpty) {
        markTestSkipped('sem admin de teste ou GLPI_BASE_URL (Worker)');
        return;
      }
      final categoryId = int.parse(envOf('SIS_TEST_CATEGORY_ID'));

      // Worker injeta o App-Token; nao enviar aqui.
      Map<String, String> wH(String? t, {bool json = true}) => {
        if (json) 'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (t != null) 'Session-Token': t,
      };

      // Login da conta de teste VIA WORKER (perfil padrao = Solicitante).
      final wInit = await http.get(
        Uri.parse('$workerBase/initSession'),
        headers: {
          ...wH(null),
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$testUser:$testPassword'))}',
        },
      );
      expect(wInit.statusCode, 200, reason: 'worker init: ${wInit.body}');
      final wToken = (jsonDecode(wInit.body) as Map)['session_token'] as String;
      final wFull = await http.get(
        Uri.parse('$workerBase/getFullSession'),
        headers: wH(wToken),
      );
      final perfil =
          '${((jsonDecode(wFull.body) as Map)['session'] as Map)['glpiactiveprofile']?['name']}';
      // ignore: avoid_print
      print('WORKER_E2E perfil_ativo=$perfil');
      if (!perfil.toLowerCase().contains('solicitante')) {
        // ignore: avoid_print
        print('WORKER_E2E ABORTADO: padrao da conta nao e Solicitante');
        await http.get(
          Uri.parse('$workerBase/killSession'),
          headers: wH(wToken),
        );
        return;
      }

      // Sessao admin (GLPI direto) para propor solucao, read-back e cleanup.
      final ai = await http.get(
        Uri.parse('$base/initSession'),
        headers: {
          ...headers(null),
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$adminUser:$adminPassword'))}',
        },
      );
      final aToken = (jsonDecode(ai.body) as Map)['session_token'] as String;

      Future<String> criarViaWorker() async {
        final payload = GlpiTicketSupport.buildCreateTicketPayload({
          'assunto':
              '$ticketMarker WKE2E ${DateTime.now().microsecondsSinceEpoch}',
          'descricao':
              'Validacao E2E via Worker (caminho do APK). Descartavel.',
          'serviceName': '',
          'governedCategoryId': categoryId,
          'entities_id': 28,
          'loggedUserId': 2373,
        });
        final r = await http.post(
          Uri.parse('$workerBase/Ticket'),
          headers: wH(wToken),
          body: jsonEncode(payload),
        );
        expect(
          r.statusCode,
          anyOf(200, 201),
          reason: 'worker criar: ${r.body}',
        );
        return (jsonDecode(r.body) as Map)['id'].toString();
      }

      Future<String> statusOf(String id) async {
        final r = await http.get(
          Uri.parse('$base/Ticket/$id'),
          headers: headers(aToken),
        );
        return '${(jsonDecode(r.body) as Map)['status']}';
      }

      Future<void> proporSolucao(String id) async {
        await http.post(
          Uri.parse('$base/ITILSolution'),
          headers: headers(aToken),
          body: jsonEncode({
            'input': {'itemtype': 'Ticket', 'items_id': id, 'content': 'sol'},
          }),
        );
      }

      final created = <String>[];
      try {
        // CRIAR + grupo (read-back via admin).
        final id1 = await criarViaWorker();
        created.add(id1);
        final gt = await http.get(
          Uri.parse('$base/Ticket/$id1/Group_Ticket?range=0-50'),
          headers: headers(aToken),
        );
        String? grp;
        for (final r in (jsonDecode(gt.body) as List)) {
          if (r is Map && '${r['type']}' == '2') grp = '${r['groups_id']}';
        }
        // ignore: avoid_print
        print('WORKER_E2E_CRIAR id=$id1 grupo=$grp');

        // MENSAGEM via Worker.
        final msg = await http.post(
          Uri.parse('$workerBase/TicketFollowup'),
          headers: wH(wToken),
          body: jsonEncode({
            'input': {
              'tickets_id': id1,
              'content': 'msg teste',
              'is_private': 0,
            },
          }),
        );
        // ignore: avoid_print
        print('WORKER_E2E_MENSAGEM -> ${msg.statusCode}');

        // ANEXO via Worker (multipart) + verificacao via admin.
        final mp = http.MultipartRequest(
          'POST',
          Uri.parse('$workerBase/Ticket/$id1/Document'),
        );
        mp.headers.addAll({
          'Accept': 'application/json',
          'Session-Token': wToken,
        });
        mp.files.add(
          http.MultipartFile.fromString(
            'uploadManifest',
            jsonEncode({
              'input': {
                'name': 'a.txt',
                '_filename': ['a.txt'],
                'items_id': id1,
                'itemtype': 'Ticket',
              },
            }),
            contentType: MediaType('application', 'json'),
          ),
        );
        mp.files.add(
          http.MultipartFile.fromBytes(
            'filename[0]',
            utf8.encode('x'),
            filename: 'a.txt',
            contentType: MediaType('text', 'plain'),
          ),
        );
        final up = await http.Response.fromStream(await mp.send());
        final di = await http.get(
          Uri.parse('$base/Ticket/$id1/Document_Item'),
          headers: headers(aToken),
        );
        final docs = (di.statusCode == 200 || di.statusCode == 206)
            ? (jsonDecode(di.body) as List).length
            : -1;
        // ignore: avoid_print
        print('WORKER_E2E_ANEXO upload=${up.statusCode} docs=$docs');

        // APROVAR via Worker (followup add_close).
        final id2 = await criarViaWorker();
        created.add(id2);
        await proporSolucao(id2);
        final sb = await statusOf(id2);
        final ap = await http.post(
          Uri.parse('$workerBase/TicketFollowup'),
          headers: wH(wToken),
          body: jsonEncode({
            'input': {'tickets_id': id2, 'content': 'ok', 'add_close': 1},
          }),
        );
        final sa = await statusOf(id2);
        // ignore: avoid_print
        print(
          'WORKER_E2E_APROVAR http=${ap.statusCode} $sb->$sa '
          'OK=${sb == '5' && sa == '6'}',
        );

        // RECUSAR via Worker (followup add_reopen).
        final id3 = await criarViaWorker();
        created.add(id3);
        await proporSolucao(id3);
        final sb3 = await statusOf(id3);
        final rj = await http.post(
          Uri.parse('$workerBase/TicketFollowup'),
          headers: wH(wToken),
          body: jsonEncode({
            'input': {'tickets_id': id3, 'content': 'nao', 'add_reopen': 1},
          }),
        );
        final sa3 = await statusOf(id3);
        // ignore: avoid_print
        print(
          'WORKER_E2E_RECUSAR http=${rj.statusCode} $sb3->$sa3 '
          'OK=${sb3 == '5' && sa3 != '5'}',
        );
      } finally {
        // Cleanup via admin (categoria ja=47): solucao (tolerante) + fechar.
        for (final id in created) {
          await http.post(
            Uri.parse('$base/ITILSolution'),
            headers: headers(aToken),
            body: jsonEncode({
              'input': {'itemtype': 'Ticket', 'items_id': id, 'content': 'fim'},
            }),
          );
          await http.put(
            Uri.parse('$base/Ticket/$id'),
            headers: headers(aToken),
            body: jsonEncode({
              'input': {'id': id, 'status': 6},
            }),
          );
        }
        // ignore: avoid_print
        print('WORKER_E2E cleanup tickets=$created');
        await http.get(
          Uri.parse('$workerBase/killSession'),
          headers: wH(wToken),
        );
        await http.get(
          Uri.parse('$base/killSession'),
          headers: headers(aToken),
        );
      }
    },
  );

  test(
    'admin read-only: inspeciona Profile_User da conta de teste (2373)',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      final adminUser = envOf('SIS_TEST_ADMIN_USER');
      final adminPassword = envOf('SIS_TEST_ADMIN_PASSWORD');
      if (adminUser.isEmpty || adminPassword.isEmpty) {
        markTestSkipped('sem credenciais admin de teste');
        return;
      }
      final init = await http.get(
        Uri.parse('$base/initSession'),
        headers: {
          ...headers(null),
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$adminUser:$adminPassword'))}',
        },
      );
      final token = tokenFromResponse(init);
      try {
        final r = await http.get(
          Uri.parse('$base/User/2373/Profile_User?range=0-50'),
          headers: headers(token),
        );
        // ignore: avoid_print
        print('PROFILE_USER http=${r.statusCode}');
        if (r.statusCode == 200 || r.statusCode == 206) {
          for (final pu in (jsonDecode(r.body) as List)) {
            if (pu is! Map) continue;
            // ignore: avoid_print
            print(
              '  PU id=${pu['id']} profiles_id=${pu['profiles_id']} '
              'entities_id=${pu['entities_id']} '
              'is_default=${pu['is_default']} is_dynamic=${pu['is_dynamic']}',
            );
          }
        }
      } finally {
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  test(
    'valida fluxos TECNICOS (APPLY): criar, propor solucao, atualizar status, fila, mensagem',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
        markTestSkipped('SIS_VALIDATION_APPLY!=true');
        return;
      }
      final categoryId = int.parse(envOf('SIS_TEST_CATEGORY_ID'));
      final token = await initSession();

      Future<void> profile(int id) async {
        await http.post(
          Uri.parse('$base/changeActiveProfile'),
          headers: headers(token),
          body: jsonEncode({'profiles_id': id}),
        );
      }

      Future<String> statusOf(String id) async {
        final r = await http.get(
          Uri.parse('$base/Ticket/$id'),
          headers: headers(token),
        );
        return '${(jsonDecode(r.body) as Map)['status']}';
      }

      final created = <String>[];
      try {
        await profile(11); // Tecnico / Manutencao e Conservacao

        Future<String> criar() async {
          final payload = GlpiTicketSupport.buildCreateTicketPayload({
            'assunto':
                '$ticketMarker TEC ${DateTime.now().microsecondsSinceEpoch}',
            'descricao': 'Validacao fluxos tecnicos. Descartavel.',
            'serviceName': '',
            'governedCategoryId': categoryId,
            'entities_id': 28,
            'loggedUserId': 2373,
          });
          final c = await http.post(
            Uri.parse('$base/Ticket'),
            headers: headers(token),
            body: jsonEncode(payload),
          );
          return (jsonDecode(c.body) as Map)['id'].toString();
        }

        // Ticket A: criar + atualizar status (UPDATE) + mensagem.
        final tA = await criar();
        created.add(tA);
        final put = await http.put(
          Uri.parse('$base/Ticket/$tA'),
          headers: headers(token),
          body: jsonEncode({
            'input': {'id': tA, 'status': 2},
          }),
        );
        final st = await statusOf(tA);
        // ignore: avoid_print
        print(
          'TEC_CRIAR id=$tA | TEC_STATUS http=${put.statusCode} '
          'status=$st OK=${st == '2'}',
        );
        final msg = await http.post(
          Uri.parse('$base/TicketFollowup'),
          headers: headers(token),
          body: jsonEncode({
            'input': {
              'tickets_id': tA,
              'content': 'andamento',
              'is_private': 0,
            },
          }),
        );
        // ignore: avoid_print
        print('TEC_MENSAGEM -> ${msg.statusCode}');

        // NOTA: propor solucao pelo tecnico depende de `maySolve` (tecnico
        // atribuido ao grupo do chamado). Validado separadamente; aqui nao se
        // assegura para nao depender do estado de grupos/atribuicao da conta.

        // Ler fila operacional por status (search/Ticket).
        final fila = await http.get(
          Uri.parse(
            '$base/search/Ticket'
            '?criteria[0][field]=12&criteria[0][searchtype]=equals'
            '&criteria[0][value]=5&forcedisplay[0]=2&range=0-5',
          ),
          headers: headers(token),
        );
        // ignore: avoid_print
        print('TEC_FILA(status=5) http=${fila.statusCode}');
      } finally {
        for (final tid in created) {
          await http.put(
            Uri.parse('$base/Ticket/$tid'),
            headers: headers(token),
            body: jsonEncode({
              'input': {'id': tid, 'status': 6},
            }),
          );
        }
        // ignore: avoid_print
        print('TEC cleanup tickets=$created');
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  test(
    'diagnostico probe (APPLY+PROBE): isola o campo que dispara ERROR_GLPI_ADD',
    () async {
      if (!ready) {
        markTestSkipped('modo direto desabilitado');
        return;
      }
      if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true' ||
          envOf('SIS_VALIDATION_PROBE').toLowerCase() != 'true') {
        markTestSkipped('probe desabilitado (exige APPLY=true e PROBE=true)');
        return;
      }
      final profileId = int.tryParse(envOf('SIS_TEST_PROFILE_ID')) ?? 9;
      final categoryId = int.parse(envOf('SIS_TEST_CATEGORY_ID'));
      final entityId = int.parse(envOf('SIS_TEST_ENTITY_ID'));

      final token = await initSession();
      try {
        final session = await activateProfileAndContext(token, profileId);
        final userId = session['glpiID'] is int
            ? session['glpiID']
            : int.tryParse('${session['glpiID']}');
        const m = ticketMarker;

        // Cada variante adiciona um campo ao anterior. O primeiro que retorna
        // 400 ERROR_GLPI_ADD identifica o campo que o Solicitante nao pode setar.
        final variants = <String, Map<String, dynamic>>{
          'P1_name_content': {'name': '$m probe', 'content': 'probe'},
          'P2_entity': {
            'name': '$m probe',
            'content': 'probe',
            'entities_id': entityId,
          },
          'P3_category': {
            'name': '$m probe',
            'content': 'probe',
            'entities_id': entityId,
            'itilcategories_id': categoryId,
          },
          'P4_status': {
            'name': '$m probe',
            'content': 'probe',
            'entities_id': entityId,
            'itilcategories_id': categoryId,
            'status': 1,
          },
          'P5_requesttype': {
            'name': '$m probe',
            'content': 'probe',
            'entities_id': entityId,
            'itilcategories_id': categoryId,
            'status': 1,
            'requesttypes_id': 1,
          },
          'P6_requester': {
            'name': '$m probe',
            'content': 'probe',
            'entities_id': entityId,
            'itilcategories_id': categoryId,
            'status': 1,
            'requesttypes_id': 1,
            '_users_id_requester': [userId],
          },
        };

        for (final entry in variants.entries) {
          final resp = await http.post(
            Uri.parse('$base/Ticket'),
            headers: headers(token),
            body: jsonEncode({'input': entry.value}),
          );
          final ok = resp.statusCode == 200 || resp.statusCode == 201;
          // ignore: avoid_print
          print(
            'PROBE ${entry.key} -> ${resp.statusCode}'
            '${ok ? '' : ' ${resp.body}'}',
          );
          if (ok) {
            final id = (jsonDecode(resp.body) as Map)['id'].toString();
            await http.put(
              Uri.parse('$base/Ticket/$id'),
              headers: headers(token),
              body: jsonEncode({
                'input': {'id': id, 'status': 6},
              }),
            );
            // ignore: avoid_print
            print('   PROBE ${entry.key} criou ID=$id (fechado)');
          }
        }
      } finally {
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  // --- Validacao end-to-end dos fixes P1 (offline preserva IDs governados) e
  // P6 (upload de anexo em checklist), contra o GLPI real, usando as classes
  // de PRODUCAO (GlpiClient/GlpiTicket/checklist_submission), nao reimplementacao.

  // As duas validacoes abaixo criam SOMENTE como uma conta de teste dedicada
  // (SIS_TEST_CONSERVACAO_USER) — nunca como admin, conforme CLAUDE.md
  // ("Claude/agentes... criar tickets de teste... como a conta de teste";
  // admin fica restrito a ajuste de atribuicoes da propria conta de teste).
  // Usa o perfil 11 "Manutencao e Conservacao" (rights=260102: inclui CREATE
  // e UPDATE), com entidade PIRATINI recursiva — unico perfil desta conta com
  // alcance sobre a entidade 58 (todos os targets de checklist sao entidade
  // 58; perfil 9/Solicitante desta conta so alcanca a entidade 25 e devolve
  // ERROR_GLPI_ADD para entidade 58). Simulacao de papel via
  // changeActiveProfile, permitida pelo CLAUDE.md sobre a propria conta de
  // teste. UPDATE real permite fechar o ticket de verdade no cleanup, em vez
  // de so registrar para limpeza humana.
  Future<String> conservacaoTecnicoToken() async {
    final user = envOf('SIS_TEST_CONSERVACAO_USER');
    final password = envOf('SIS_TEST_CONSERVACAO_PASSWORD');
    final init = await http.get(
      Uri.parse('$base/initSession'),
      headers: {
        ...headers(null),
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$user:$password'))}',
      },
    );
    final token = tokenFromResponse(init);
    final cap = await http.post(
      Uri.parse('$base/changeActiveProfile'),
      headers: headers(token),
      body: jsonEncode({'profiles_id': 11}),
    );
    expect(
      cap.statusCode,
      anyOf(200, 201),
      reason: 'changeActiveProfile(11) falhou: ${cap.body}',
    );
    return token;
  }

  Future<void> closeAndReport(
    String label,
    String token,
    String ticketId,
  ) async {
    await http.post(
      Uri.parse('$base/ITILSolution'),
      headers: headers(token),
      body: jsonEncode({
        'input': {
          'itemtype': 'Ticket',
          'items_id': ticketId,
          'content': 'Encerramento de ticket de teste automatizado ($label).',
        },
      }),
    );
    final close = await http.put(
      Uri.parse('$base/Ticket/$ticketId'),
      headers: headers(token),
      body: jsonEncode({
        'input': {'id': ticketId, 'status': 6},
      }),
    );
    final after = await http.get(
      Uri.parse('$base/Ticket/$ticketId'),
      headers: headers(token),
    );
    // Defensivo: apos status=6 a visibilidade direta do proprio ticket pode
    // mudar de escopo para um perfil sem READALL (achado real, nao falha de
    // teste) — nesse caso o body vem como lista de erro, nao Map.
    final afterDecoded = jsonDecode(after.body);
    final statusAfter = afterDecoded is Map
        ? '${afterDecoded['status']}'
        : 'indisponivel(${after.statusCode}): $afterDecoded';
    // ignore: avoid_print
    print(
      '$label cleanup -> ticket $ticketId put_close=${close.statusCode} '
      'status_final=$statusAfter'
      '${statusAfter == '6' ? ' (FECHADO)' : ' (NAO CONFIRMADO FECHADO — REGISTRAR PARA LIMPEZA/AUDITORIA: ticket $ticketId)'}',
    );
  }

  test(
    'P6 (APPLY): checklist com anexo real via GlpiClient.submitChecklistAsTicket',
    () async {
      final conservacaoUser = envOf('SIS_TEST_CONSERVACAO_USER');
      final conservacaoPassword = envOf('SIS_TEST_CONSERVACAO_PASSWORD');
      if (conservacaoUser.isEmpty || conservacaoPassword.isEmpty) {
        markTestSkipped(
          'sem SIS_TEST_CONSERVACAO_USER/SIS_TEST_CONSERVACAO_PASSWORD',
        );
        return;
      }
      if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
        markTestSkipped('SIS_VALIDATION_APPLY!=true');
        return;
      }

      // Catalogo real embarcado; target 316 "REFRIGERACAO AR CENTRAL" (form 48,
      // categoria 152, entidade 58) tem uma pergunta `file` (11482) que so fica
      // visivel quando a sala 11480 e marcada como problema, nao OK.
      final catalogJson =
          jsonDecode(
                File('assets/sis_checklists_catalog.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final catalog = SisChecklistCatalog.fromMap(catalogJson);
      final preparer = SisChecklistSubmissionPreparer(
        catalog: catalog,
        conditionEngine: SisChecklistConditionEngine(catalog),
      );
      final submission = preparer.prepare(
        formId: 48,
        targetId: 316,
        answers: {
          10599: 'PREVENTIVA',
          10604: ['AR CENTRAL'],
          11480: '❌ Ação - Reparo / Reforma',
          11482: [
            GlpiTicketAttachment(
              bytes: utf8.encode(
                'evidencia de teste automatizado P6 $ticketMarker',
              ),
              filename: 'evidencia_p6.txt',
            ),
          ],
        },
      );
      expect(submission.canReview, isTrue);
      expect(submission.fileQuestionIds, contains(11482));
      expect(submission.attachedFileCount, 1);

      final token = await conservacaoTecnicoToken();
      String? ticketId;
      try {
        final result = await GlpiClient().submitChecklistAsTicket(
          submission: submission,
          sessionToken: token,
          catalog: catalog,
          formName: catalog.formById(48)?.name,
          targetName: catalog.targetById(316)?.name,
        );
        // ignore: avoid_print
        print('P6_SUBMIT -> $result');
        expect(result['success'], isTrue, reason: 'submissao falhou: $result');
        ticketId = result['ticket_id']?.toString();
        expect(ticketId, isNotNull);
        expect(
          result['attachments_success'],
          greaterThanOrEqualTo(1),
          reason: 'anexo nao foi enviado: $result',
        );
        expect(
          result.containsKey('attachment_warning'),
          isFalse,
          reason: 'upload de anexo reportou falha: $result',
        );

        // Read-back: confirma o Document_Item de fato vinculado (nao so o
        // upload retornar sucesso local). Achado real: perfil 11 (sem
        // READALL) recebe 403 em GET .../Document_Item sobre um ticket que
        // criou mas nao esta atribuido a si — direto E via Worker, mesmo
        // token. Ortogonal ao fix P6 (a propria uploadAndAttachToTicket ja
        // fez essa mesma checagem internamente, com sucesso, antes de
        // retornar attachments_success). Verificacao aqui usa leitura
        // READ-ONLY via admin (nao cria nem muta nada) — mesmo padrao ja
        // estabelecido nos testes ANEXO_EFEITO/READBACK deste arquivo.
        final adminUser = envOf('SIS_TEST_ADMIN_USER');
        final adminPassword = envOf('SIS_TEST_ADMIN_PASSWORD');
        if (adminUser.isNotEmpty && adminPassword.isNotEmpty) {
          final ai = await http.get(
            Uri.parse('$base/initSession'),
            headers: {
              ...headers(null),
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$adminUser:$adminPassword'))}',
            },
          );
          final at = tokenFromResponse(ai);
          final di = await http.get(
            Uri.parse('$base/Ticket/$ticketId/Document_Item'),
            headers: headers(at),
          );
          var linked = 0;
          if (di.statusCode == 200 || di.statusCode == 206) {
            linked = (jsonDecode(di.body) as List).length;
          }
          // ignore: avoid_print
          print(
            'P6_READBACK(admin, read-only) ticket=$ticketId '
            'document_item_http=${di.statusCode} vinculados=$linked',
          );
          expect(
            linked,
            greaterThanOrEqualTo(1),
            reason: 'Document_Item nao encontrado para o ticket $ticketId',
          );
          await http.get(Uri.parse('$base/killSession'), headers: headers(at));
        } else {
          // ignore: avoid_print
          print(
            'P6_READBACK pulado: sem admin para verificacao read-only '
            '(attachments_success ja confirmado pelo codigo real: $result)',
          );
        }

        // Confirma tambem que categoria/entidade do target continuam corretas
        // (o resto do fluxo de checklist nao regrediu).
        final full = await http.get(
          Uri.parse('$base/Ticket/$ticketId'),
          headers: headers(token),
        );
        final fullData = jsonDecode(full.body) as Map;
        // ignore: avoid_print
        print(
          'P6_TICKET categoria=${fullData['itilcategories_id']} '
          'entidade=${fullData['entities_id']}',
        );
        expect(fullData['itilcategories_id'], 152);
        expect(fullData['entities_id'], 58);
      } finally {
        if (ticketId != null) {
          await closeAndReport('P6', token, ticketId);
        }
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );

  test(
    'P1 (APPLY): resync offline via GlpiTicket round-trip preserva categoria governada',
    () async {
      final conservacaoUser = envOf('SIS_TEST_CONSERVACAO_USER');
      final conservacaoPassword = envOf('SIS_TEST_CONSERVACAO_PASSWORD');
      if (conservacaoUser.isEmpty || conservacaoPassword.isEmpty) {
        markTestSkipped(
          'sem SIS_TEST_CONSERVACAO_USER/SIS_TEST_CONSERVACAO_PASSWORD',
        );
        return;
      }
      if (envOf('SIS_VALIDATION_APPLY').toLowerCase() != 'true') {
        markTestSkipped('SIS_VALIDATION_APPLY!=true');
        return;
      }
      final categoryId = int.parse(envOf('SIS_TEST_CATEGORY_ID'));
      final entityId = int.parse(envOf('SIS_TEST_ENTITY_ID'));

      final token = await conservacaoTecnicoToken();
      final fullSession = await http.get(
        Uri.parse('$base/getFullSession'),
        headers: headers(token),
      );
      final loggedUserId =
          ((jsonDecode(fullSession.body) as Map)['session']
              as Map)['glpiID'];

      // Simula EXATAMENTE o momento em que o app salva offline apos falha de
      // rede: stampedFormData (com campos governed*) -> GlpiTicket.fromMap.
      final originalFormData = <String, dynamic>{
        'serviceName': '',
        'atendimentoPara': 'Para mim',
        'localizacao': '',
        'telefone': '',
        'tipo': '',
        'assunto':
            '$ticketMarker P1 resync ${DateTime.now().microsecondsSinceEpoch}',
        'descricao':
            'Valida que categoria governada sobrevive ao ciclo '
            'offline->resync. Descartavel.',
        'entities_id': entityId,
        'loggedUserId': loggedUserId,
        'governedCategoryId': categoryId,
      };
      final ticket = GlpiTicket.fromMap(originalFormData);
      // Simula synchronizeTickets(): reconstroi o payload via toMap().
      final resyncMap = ticket.toMap();
      expect(
        resyncMap['governedCategoryId'],
        categoryId,
        reason:
            'fix P1 quebrou: campo governado nao sobreviveu ao round-trip local',
      );

      String? ticketId;
      try {
        final result = await GlpiClient().createTicket(resyncMap, token);
        // ignore: avoid_print
        print('P1_RESYNC -> $result');
        expect(result['success'], isTrue, reason: 'resync falhou: $result');
        ticketId = result['ticket_id']?.toString();
        expect(ticketId, isNotNull);

        final full = await http.get(
          Uri.parse('$base/Ticket/$ticketId'),
          headers: headers(token),
        );
        final fullData = jsonDecode(full.body) as Map;
        // ignore: avoid_print
        print(
          'P1_TICKET categoria=${fullData['itilcategories_id']} '
          'esperado=$categoryId',
        );
        expect(
          fullData['itilcategories_id'],
          categoryId,
          reason:
              'GLPI recebeu categoria diferente da governada originalmente '
              '- fix P1 nao esta funcionando no caminho real',
        );
      } finally {
        if (ticketId != null) {
          await closeAndReport('P1', token, ticketId);
        }
        await http.get(Uri.parse('$base/killSession'), headers: headers(token));
      }
    },
  );
}
