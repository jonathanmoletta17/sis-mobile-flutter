import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';

void main() {
  test(
    'requester ticket creation uses GLPI default entity before active entity',
    () async {
      SharedPreferences.setMockInitialValues({});
      final api = _EntityResolutionGlpiClient(
        activeEntityId: 2,
        defaultEntityId: 8,
        availableEntities: const [
          {'id': 99, 'name': 'Entidade primeira da lista'},
          {'id': 8, 'name': 'Departamento do solicitante'},
          {'id': 2, 'name': 'Entidade ativa tecnica'},
        ],
      );
      final appState = AppState(api);
      await pumpEventQueue();

      expect(await appState.authenticate('solicitante', 'senha'), isTrue);
      await appState.submitTicket({
        'assunto': 'Teste entidade',
        'descricao': 'Descricao',
        'serviceName': 'Carregadores',
      });

      expect(api.lastCreatedFormData?['entities_id'], 8);
      expect(appState.selectedTicketEntityId, 8);
      expect(appState.selectedTicketEntityName, 'Departamento do solicitante');
    },
  );

  test(
    'requester ticket creation does not silently use first available entity',
    () async {
      SharedPreferences.setMockInitialValues({});
      final api = _EntityResolutionGlpiClient(
        activeEntityId: null,
        defaultEntityId: null,
        availableEntities: const [
          {'id': 99, 'name': 'Entidade primeira da lista'},
        ],
      );
      final appState = AppState(api);
      await pumpEventQueue();

      expect(await appState.authenticate('solicitante', 'senha'), isTrue);
      await appState.submitTicket({
        'assunto': 'Teste entidade ausente',
        'descricao': 'Descricao',
        'serviceName': 'Carregadores',
      });

      expect(api.lastCreatedFormData?.containsKey('entities_id'), isFalse);
      expect(appState.selectedTicketEntityId, isNull);
    },
  );

  test(
    'governed read-back drift is surfaced to the user after creation',
    () async {
      SharedPreferences.setMockInitialValues({});
      final api = _EntityResolutionGlpiClient(
        activeEntityId: 28,
        defaultEntityId: 28,
        availableEntities: const [
          {'id': 28, 'name': 'Departamento de Tecnologia e Informação'},
        ],
        createTicketResult: const {
          'success': true,
          'ticket_id': 12346,
          'governed_readback_warning':
              'Grupo esperado não confirmado no read-back: CC-MANUTENCAO',
        },
      );
      final appState = AppState(api);
      await pumpEventQueue();

      expect(await appState.authenticate('teste', 'senha'), isTrue);
      final message = await appState.submitTicket({
        'assunto': 'Teste read-back',
        'descricao': 'Descricao',
        'serviceName': 'Pintura',
      });

      expect(message, contains('read-back governado encontrou divergência'));
      expect(message, contains('CC-MANUTENCAO'));
    },
  );

  test('GLPI permission/add errors are not saved as offline tickets', () async {
    SharedPreferences.setMockInitialValues({});
    final api = _EntityResolutionGlpiClient(
      activeEntityId: 28,
      defaultEntityId: 28,
      availableEntities: const [
        {'id': 28, 'name': 'Departamento de Tecnologia e Informação'},
      ],
      createTicketError:
          'Exception: Erro ao criar ticket: [400] - ["ERROR_GLPI_ADD","Você não tem permissão para executar essa ação."]',
    );
    final appState = AppState(api);
    await pumpEventQueue();

    expect(await appState.authenticate('teste', 'senha'), isTrue);
    final message = await appState.submitTicket({
      'assunto': 'Teste bloqueio permissão',
      'descricao': 'Descricao',
      'serviceName': 'Ar-Condicionado',
    });

    expect(message, contains('GLPI recusou'));
    expect(appState.pendingTickets, isEmpty);
  });
}

class _EntityResolutionGlpiClient extends GlpiClient {
  _EntityResolutionGlpiClient({
    required this.activeEntityId,
    required this.defaultEntityId,
    required this.availableEntities,
    this.createTicketError,
    this.createTicketResult,
  });

  final int? activeEntityId;
  final int? defaultEntityId;
  final List<Map<String, dynamic>> availableEntities;
  final String? createTicketError;
  final Map<String, dynamic>? createTicketResult;
  Map<String, dynamic>? lastCreatedFormData;

  @override
  Future<String?> authenticate(String username, String password) async {
    return 'fake-session-token';
  }

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {
      'userId': 2214,
      'username': 'solicitante',
      'profile': 'Solicitante',
      'activeEntityId': activeEntityId,
      'activeEntityName': activeEntityId == null
          ? null
          : 'Entidade ativa tecnica',
      'defaultEntityId': defaultEntityId,
      'availableEntities': availableEntities,
    };
  }

  @override
  Future<Map<String, dynamic>> createTicket(
    Map<String, dynamic> formData,
    String sessionToken,
  ) async {
    lastCreatedFormData = Map<String, dynamic>.from(formData);
    final error = createTicketError;
    if (error != null) {
      throw Exception(error);
    }
    return createTicketResult ?? {'success': true, 'ticket_id': 12345};
  }
}
