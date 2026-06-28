import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_identity.dart';
import 'package:sis_mobile_flutter/models/session_context.dart';

void main() {
  group('SessionContext', () {
    test(
      'parses GLPI full session and keeps active entity separate from ticket creation entity',
      () {
        final context = SessionContext.fromGlpiSession(
          {
            'glpiID': '77',
            'glpiname': 'jose.silva',
            'glpiactive_entity': '2',
            'glpiactive_entity_name': 'PIRATINI',
            'glpidefault_entity': '8',
            'glpiactiveprofile': {
              'id': '12',
              'name': 'Solicitante-GG-Conservação',
              'entities': {
                '2': {'id': 2, 'name': 'PIRATINI'},
                '8': {'id': '8', 'name': 'GG Conservação'},
              },
            },
          },
          ticketCreationEntity: const GlpiEntityRef(
            id: 8,
            name: 'GG Conservação',
          ),
        );

        expect(context.userId, 77);
        expect(context.username, 'jose.silva');
        expect(context.activeProfile, isNotNull);
        expect(context.activeProfile!.id, 12);
        expect(context.activeProfile!.name, 'Solicitante-GG-Conservação');
        expect(context.activeEntity?.id, 2);
        expect(context.defaultEntityId, 8);
        expect(context.ticketCreationEntity?.id, 8);
        expect(
          context.activeEntity?.id,
          isNot(context.ticketCreationEntity?.id),
        );
        expect(
          context.availableEntities.map((e) => e.name),
          contains('GG Conservação'),
        );
        expect(context.isValid, isTrue);
      },
    );

    test('parses active profile id and groups from GLPI session payload', () {
      final context = SessionContext.fromGlpiSession({
        'glpiID': 2039,
        'glpiname': 'tecnico.sis',
        'glpiactive_entity': 24,
        'glpiactive_entity_name': 'Manutenção',
        'glpiactiveprofile': {'id': '11', 'name': 'Manutenção e Conservação'},
        'glpigroups': {
          '101': {'id': '101', 'name': 'CC-CONSERVACAO'},
          '102': 'CC-MANUTENCAO',
          '149': {'name': 'GG-CONSERVACAO'},
        },
      });

      expect(context.activeProfile?.id, 11);
      expect(
        context.groups.map((group) => group.id),
        containsAll([101, 102, 149]),
      );
      expect(
        context.groups.map((group) => group.name),
        containsAll(['CC-CONSERVACAO', 'CC-MANUTENCAO', 'GG-CONSERVACAO']),
      );
    });

    test('is invalid without user or profile', () {
      final context = SessionContext.fromGlpiSession({
        'glpiactive_entity': '2',
        'glpiactive_entity_name': 'PIRATINI',
      });

      expect(context.isValid, isFalse);
      expect(
        context.warnings,
        contains('Sessão sem usuário GLPI identificado'),
      );
      expect(
        context.warnings,
        contains('Sessão sem perfil ativo GLPI identificado'),
      );
    });
  });
}
