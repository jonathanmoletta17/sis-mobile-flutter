import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';

void main() {
  test(
    'hasThirdPartyAudienceQuestion busca ao vivo uma vez e usa cache depois',
    () async {
      SharedPreferences.setMockInitialValues({});
      final api = _AudienceGlpiClient(resultForForm: {38: true, 39: false});
      final appState = AppState(api);
      await pumpEventQueue();
      expect(await appState.authenticate('gg', 'senha'), isTrue);

      expect(await appState.hasThirdPartyAudienceQuestion(38), isTrue);
      expect(await appState.hasThirdPartyAudienceQuestion(38), isTrue);
      expect(api.callCountByForm[38], 1); // segunda chamada veio do cache

      expect(await appState.hasThirdPartyAudienceQuestion(39), isFalse);
      expect(api.callCountByForm[39], 1);
    },
  );

  test('sem sessão autenticada, retorna false sem chamar a API', () async {
    SharedPreferences.setMockInitialValues({});
    final api = _AudienceGlpiClient(resultForForm: {38: true});
    final appState = AppState(api);
    await pumpEventQueue();

    expect(await appState.hasThirdPartyAudienceQuestion(38), isFalse);
    expect(api.callCountByForm.containsKey(38), isFalse);
  });

  test(
    'clearThirdPartyAudienceCache força nova busca ao vivo no próximo call '
    '(mesmo gatilho de refresh do catálogo governado ao voltar do background)',
    () async {
      SharedPreferences.setMockInitialValues({});
      final api = _AudienceGlpiClient(resultForForm: {38: true});
      final appState = AppState(api);
      await pumpEventQueue();
      expect(await appState.authenticate('gg', 'senha'), isTrue);

      expect(await appState.hasThirdPartyAudienceQuestion(38), isTrue);
      expect(api.callCountByForm[38], 1);

      // Sem limpar o cache, chamada repetida não bate na API de novo.
      await appState.hasThirdPartyAudienceQuestion(38);
      expect(api.callCountByForm[38], 1);

      appState.clearThirdPartyAudienceCache();
      await appState.hasThirdPartyAudienceQuestion(38);
      expect(api.callCountByForm[38], 2);
    },
  );
}

class _AudienceGlpiClient extends GlpiClient {
  _AudienceGlpiClient({required this.resultForForm});

  final Map<int, bool> resultForForm;
  final Map<int, int> callCountByForm = {};

  @override
  Future<String?> authenticate(String username, String password) async {
    return 'fake-session-token';
  }

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {
      'userId': 2402,
      'username': 'sis-teste-gg',
      'profile': 'Solicitante-GG-Conservação',
      'activeEntityId': 58,
      'activeEntityName': 'Departamento de Conservação',
      'defaultEntityId': 58,
      'availableEntities': const [
        {'id': 58, 'name': 'Departamento de Conservação'},
      ],
    };
  }

  @override
  Future<bool> formHasThirdPartyAudienceQuestion({
    required int formId,
    required String sessionToken,
  }) async {
    callCountByForm[formId] = (callCountByForm[formId] ?? 0) + 1;
    return resultForForm[formId] ?? false;
  }
}
