import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sis_mobile_flutter/state/app_state.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';

void main() {
  group('AppState.switchActiveProfile', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'sessionToken': 'test-session',
        'loggedUsername': 'teste',
        'activeProfile': 'Solicitante',
      });
    });

    test('carrega perfis disponíveis e habilita troca quando há mais de um',
        () async {
      final api = _ProfileSwitchGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      expect(appState.availableProfiles.length, 3);
      expect(appState.canSwitchProfile, isTrue);
      expect(appState.activeProfileId, 9);
      expect(appState.activeProfile, 'Solicitante');
    });

    test('troca o perfil ativo e recarrega contexto (perfil + grupos)',
        () async {
      final api = _ProfileSwitchGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final ok = await appState.switchActiveProfile(11);

      expect(ok, isTrue);
      expect(api.changeProfileCalls, [11]);
      expect(appState.activeProfileId, 11);
      expect(appState.activeProfile, 'Manutenção e Conservação');
      // grupos técnicos chegam no novo contexto
      expect(appState.groups.map((g) => g.id), contains(22));
    });

    test('trocar para o perfil já ativo é no-op (retorna false)', () async {
      final api = _ProfileSwitchGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final ok = await appState.switchActiveProfile(9);

      expect(ok, isFalse);
      expect(api.changeProfileCalls, isEmpty);
      expect(appState.activeProfileId, 9);
    });
  });
}

class _ProfileSwitchGlpiClient extends GlpiClient {
  int _activeProfileId = 9;
  final List<int> changeProfileCalls = [];

  @override
  Future<List<Map<String, dynamic>>> getMyProfiles(String sessionToken) async {
    return [
      {'id': 11, 'name': 'Manutenção e Conservação'},
      {'id': 9, 'name': 'Solicitante'},
      {'id': 12, 'name': 'Solicitante-GG-Conservação'},
    ];
  }

  @override
  Future<void> changeActiveProfile(String sessionToken, int profilesId) async {
    changeProfileCalls.add(profilesId);
    _activeProfileId = profilesId;
  }

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    final isTechnical = _activeProfileId == 11;
    return {
      'userId': 2373,
      'username': 'teste',
      'profile': isTechnical ? 'Manutenção e Conservação' : 'Solicitante',
      'profileId': _activeProfileId,
      'groups': isTechnical
          ? [
              {'id': 22, 'name': 'CC-MANUTENCAO'},
            ]
          : const [],
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
    List<int> actorFieldIds = const [],
  }) async {
    return [];
  }
}
