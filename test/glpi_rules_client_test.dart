import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/services/glpi_rules_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlpiRulesClient (contrato v2, asset real)', () {
    late GlpiRulesClient rules;

    setUpAll(() async {
      rules = GlpiRulesClient();
      await rules.load();
    });

    test('carrega o asset', () {
      expect(rules.isLoaded, isTrue);
      expect(rules.meta['glpi_instance'], 'sis');
    });

    test('status: rótulos e terminalidade', () {
      expect(rules.statusLabel(6), isNotEmpty);
      expect(rules.isStatusTerminal(6), isTrue); // Fechado
      expect(rules.isStatusTerminal(1), isFalse); // Novo
    });

    test('Tecnico (6) pode todas as transições; Solicitante (9) é restrito', () {
      final tecFromNew = rules.allowedStatusTransitions(profileId: 6, current: 1);
      expect(tecFromNew, containsAll(<int>[2, 5, 6]));

      final solFromNew = rules.allowedStatusTransitions(profileId: 9, current: 1);
      expect(solFromNew, isEmpty); // solicitante não move de Novo
    });

    test('visibilidade: Tecnico vê todos; Solicitante só os próprios', () {
      expect(rules.visibilityScope(profileId: 6), VisibilityScope.allInEntity);
      expect(rules.visibilityScope(profileId: 9), VisibilityScope.ownOnly);
    });

    test('meus chamados usa OR de atores [4,22,66]', () {
      expect(rules.myTicketsActorFields, <int>[4, 22, 66]);
    });

    test('catálogo de formulários não vazio', () {
      expect(rules.formCatalog, isNotEmpty);
    });
  });
}
