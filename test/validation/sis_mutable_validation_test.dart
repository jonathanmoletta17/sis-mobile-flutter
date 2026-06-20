@Tags(['mutable-validation'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
      // Sem .env: cai para Platform.environment; pode ainda ser skip.
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
        await http.get(
          Uri.parse('$base/killSession'),
          headers: headers(token),
        );
      }
    },
  );

  test(
    'mutavel direto (APPLY): perfil-alvo cria ticket, valida grupo via '
    'read-back e fecha',
    () async {
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
        final userId = rawUserId is int
            ? rawUserId
            : int.tryParse('$rawUserId');
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
    },
  );

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
      final token = (jsonDecode(init.body) as Map)['session_token'] as String;

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
        print('ACAO followup -> ${fup.statusCode}'
            '${fup.statusCode >= 400 ? ' ${fup.body}' : ''}');

        // 2) Mudanca de status via PUT /Ticket (proxy de aprovar/recusar solucao).
        final put = await http.put(
          Uri.parse('$base/Ticket/$ticketId'),
          headers: headers(token),
          body: jsonEncode({
            'input': {'id': ticketId, 'status': 2},
          }),
        );
        // ignore: avoid_print
        print('ACAO put_status -> ${put.statusCode}'
            '${put.statusCode >= 400 ? ' ${put.body}' : ''}');
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
          'assunto': '$ticketMarker ciclo ${DateTime.now().microsecondsSinceEpoch}',
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
        print('APROVAR_SOLUCAO ticket=$tA solucao_post=$solA '
            'put_aprovar=${approve.statusCode}'
            '${approve.statusCode >= 400 ? ' ${approve.body}' : ''}');

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
        print('RECUSAR_SOLUCAO ticket=$tB solucao_post=$solB '
            'put_recusar=${reject.statusCode}'
            '${reject.statusCode >= 400 ? ' ${reject.body}' : ''}');

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
        print('ANEXAR ticket=$tC -> ${attachResp.statusCode}'
            '${attachResp.statusCode >= 400 ? ' ${attachResp.body}' : ''}');
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
        final userId =
            session['glpiID'] is int
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
}
