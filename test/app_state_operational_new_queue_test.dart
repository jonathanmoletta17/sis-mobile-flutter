import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sis_mobile_flutter/state/app_state.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';

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
      expect(api.statusQueries, [1]);
      expect(
        tickets.map((ticket) => ticket['id'].toString()),
        contains('9276'),
      );
      expect(
        tickets.firstWhere(
          (ticket) => ticket['id'].toString() == '9276',
        )['status'],
        1,
      );
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
      expect(api.statusQueries, [1]);
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
          : const [
              {'id': 22, 'name': 'CC-MANUTENCAO'},
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
