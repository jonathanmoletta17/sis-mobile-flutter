import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sis_mobile_flutter/models/operational_role.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';

import 'fixtures/sis_instance_groups.dart';

void main() {
  test(
    'technical/admin session includes operational New queue beyond requester tickets',
    () async {
      SharedPreferences.setMockInitialValues({
        'sessionToken': 'test-session',
        'loggedUsername': 'jonathan-moletta',
        'activeProfile': 'Super-Admin',
      });

      final api = _OperationalQueueGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final tickets = await appState.fetchTickets();

      expect(api.requesterUsername, 'jonathan-moletta');
      expect(api.requesterUserId, 2039);
      expect(api.statusQueries, unorderedEquals([1, 2, 3, 4, 5]));
      expect(
        tickets.map((ticket) => ticket['id'].toString()),
        contains('9276'),
      );
    },
  );

  test(
    'operational tickets are tagged with _source:operational and personal tickets are preserved',
    () async {
      SharedPreferences.setMockInitialValues({
        'sessionToken': 'test-session',
        'loggedUsername': 'jonathan-moletta',
        'activeProfile': 'Super-Admin',
      });

      final api = _OperationalQueueGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final tickets = await appState.fetchTickets();

      // Ticket pessoal (id 9245) não deve ter _source=operational
      final personalTicket = tickets.firstWhere(
        (t) => t['id'].toString() == '9245',
      );
      expect(personalTicket['_source'], isNot('operational'));

      // Ticket da fila operacional (id 9276) deve ter _source=operational
      final operationalTicket = tickets.firstWhere(
        (t) => t['id'].toString() == '9276',
      );
      expect(operationalTicket['_source'], equals('operational'));
    },
  );

  test(
    'requester-only session does not request broad operational New queue',
    () async {
      SharedPreferences.setMockInitialValues({
        'sessionToken': 'test-session',
        'loggedUsername': 'gabriel-conceicao',
        'activeProfile': 'Solicitante',
      });

      final api = _OperationalQueueGlpiClient(profile: 'Solicitante');
      final appState = AppState(api);
      await pumpEventQueue();

      await appState.fetchTickets();

      expect(api.statusQueries, isEmpty);
    },
  );

  test(
    'requester session hydrates numeric GLPI user id before filtering personal tickets',
    () async {
      SharedPreferences.setMockInitialValues({
        'sessionToken': 'test-session',
        'loggedUsername': 'teste',
        'activeProfile': 'Solicitante',
      });

      final api = _RequesterWithoutSessionIdGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final tickets = await appState.fetchTickets();

      expect(api.getMyUserIdCalls, 1);
      expect(api.requesterUsername, 'teste');
      expect(api.requesterUserId, 2373);
      expect(
        tickets.map((ticket) => ticket['id'].toString()),
        containsAll(['9597', '9598']),
      );
    },
  );

  test(
    'resolvedOperationalRole returns maintenanceTechnician for tecnico with maintenance group',
    () async {
      SharedPreferences.setMockInitialValues({
        'sessionToken': 'test-session',
        'loggedUsername': 'jonathan-moletta',
        'activeProfile': 'Super-Admin',
      });

      final api = _OperationalQueueGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();
      await appState.fetchTickets();

      expect(appState.resolvedOperationalRole, OperationalRole.admin);
    },
  );

  test(
    'resolvedOperationalRole returns standardRequester for solicitante without groups',
    () async {
      SharedPreferences.setMockInitialValues({
        'sessionToken': 'test-session',
        'loggedUsername': 'gabriel-conceicao',
        'activeProfile': 'Solicitante',
      });

      final api = _OperationalQueueGlpiClient(profile: 'Solicitante');
      final appState = AppState(api);
      await pumpEventQueue();
      await appState.fetchTickets();

      expect(
        appState.resolvedOperationalRole,
        OperationalRole.standardRequester,
      );
    },
  );

  test(
    'lab preview session resets operational profile and group context',
    () async {
      SharedPreferences.setMockInitialValues({
        'sessionToken': 'test-session',
        'loggedUsername': 'jonathan-moletta',
        'activeProfile': 'Super-Admin',
      });

      final api = _OperationalQueueGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      await appState.fetchTickets();
      expect(api.statusQueries, unorderedEquals([1, 2, 3, 4, 5]));
      expect(appState.activeProfileId, 11);
      expect(appState.groups, isNotEmpty);

      api.statusQueries.clear();
      appState.activateLabPreviewSession(
        username: 'lab-solicitante',
        profile: 'Solicitante',
        activeEntityId: 28,
        activeEntityName: 'Casa Civil',
      );

      expect(appState.activeProfileId, isNull);
      expect(appState.groups, isEmpty);

      await appState.fetchTickets();
      expect(api.statusQueries, isEmpty);
    },
  );
}

class _OperationalQueueGlpiClient extends GlpiClient {
  _OperationalQueueGlpiClient({this.profile = 'Super-Admin'});

  final String profile;
  String? requesterUsername;
  int? requesterUserId;
  final List<int> statusQueries = [];

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {
      'userId': profile == 'Solicitante' ? 2214 : 2039,
      'username': profile == 'Solicitante'
          ? 'gabriel-conceicao'
          : 'jonathan-moletta',
      'profile': profile,
      'profileId': profile == 'Solicitante' ? 12 : 11,
      'groups': profile == 'Solicitante'
          ? const []
          : [
              {'id': sisMaintenanceGroupId, 'name': 'CC-MANUTENCAO'},
            ],
      'activeEntityId': 1,
      'activeEntityName': 'Origem > PIRATINI',
      'defaultEntityId': 1,
      'availableEntities': const [],
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getTickets(
    String sessionToken, {
    String? requesterUsername,
    int? requesterUserId,
  }) async {
    this.requesterUsername = requesterUsername;
    this.requesterUserId = requesterUserId;
    return [
      {
        'id': 9245,
        'name': 'Meu chamado planejado',
        'status': 3,
        'itilcategories_id': 'Conservação > Carregadores',
        'users_id_recipient': profile == 'Solicitante' ? 2214 : 2039,
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTicketsByStatus(
    String sessionToken, {
    required int status,
    int rangeEnd = 500,
  }) async {
    statusQueries.add(status);
    return [
      {
        'id': 9276,
        'name': 'Teste',
        'status': status,
        'itilcategories_id': 'Conservação > Carregadores',
        'users_id_recipient': 2214,
        'entities_id':
            'Origem > PIRATINI > CASA CIVIL > Secretaria-Executiva > Subchefia Administrativa > Departamento de Tecnologia e Informação',
      },
    ];
  }
}

class _RequesterWithoutSessionIdGlpiClient extends GlpiClient {
  String? requesterUsername;
  int? requesterUserId;
  int getMyUserIdCalls = 0;

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {
      'userId': null,
      'username': 'teste',
      'profile': 'Solicitante',
      'profileId': 12,
      'groups': const [],
      'activeEntityId': 1,
      'activeEntityName': 'Origem > PIRATINI',
      'defaultEntityId': 1,
      'availableEntities': const [],
    };
  }

  @override
  Future<int?> getMyUserId(String sessionToken) async {
    getMyUserIdCalls += 1;
    return 2373;
  }

  @override
  Future<List<Map<String, dynamic>>> getTickets(
    String sessionToken, {
    String? requesterUsername,
    int? requesterUserId,
  }) async {
    this.requesterUsername = requesterUsername;
    this.requesterUserId = requesterUserId;
    return [
      {
        'id': 9598,
        'name': '[HERMES-E2E-NAO-APAGAR] HERMES_TEST_002',
        'status': 2,
        'itilcategories_id': 'Conservação > Limpeza',
        'users_id_recipient': '2373',
      },
      {
        'id': 9597,
        'name': '[HERMES-E2E-NAO-APAGAR] HERMES_TEST_001',
        'status': 2,
        'itilcategories_id': 'Manutenção > Ar Condicionado > Conserto',
        'users_id_recipient': '2373',
      },
    ];
  }
}
