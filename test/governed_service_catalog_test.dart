import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/catalog/governed_service_catalog.dart';

void main() {
  const catalogJson = '''
{
  "schema_version": "2.0-readonly-draft",
  "consumer_id": "sis-mobile-flutter",
  "instance": "sis",
  "records": [
    {
      "catalog_record_id": "sis:pintura:form-12:target-11",
      "service_id": "pintura",
      "service_label": "Pintura",
      "profile_visibility": [{"id": 1, "name": "Solicitante"}],
      "form": {"id": 12, "name": "Pintura"},
      "targetticket": {
        "id": 11,
        "name": "Pintura",
        "audience": "para_mim",
        "destination_entity": {"code": 2, "mode": "requester_context_para_mim"},
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 102,
        "location_rule": 3,
        "location_question_id": 98,
        "type_rule": 1,
        "urgency_rule": 3
      },
      "questions": {
        "category": {
          "id": 102,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "root_id": 85,
          "option_source": "categories",
          "options_sample": [{"id": 87, "label": "Outros", "full_label": "Manutenção > Pintura > Outros"}]
        },
        "location": {
          "id": 98,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "root_id": 70,
          "option_source": "locations",
          "options_sample": [{"id": 79, "label": "Casa Civil 1005 > 1° Andar", "full_label": "Locais > Casa Civil 1005 > 1° Andar"}]
        }
      },
      "expected_result": {
        "domain": "Manutenção",
        "assignment_group": {"id": 22, "label": "CC-MANUTENCAO", "source_rule_id": 156},
        "base_task_templates": [{"id": 1, "label": "EQUIPE EXECUTORA"}, {"id": 3, "label": "MATERIAIS UTILIZADOS"}, {"id": 2, "label": "SERVIÇO REALIZADO"}],
        "attachment_policy": {"create_route": "POST /Ticket/{ticket_id}/Document"},
        "readback_contract": ["GET/SEARCH Ticket"]
      }
    },
    {
      "catalog_record_id": "sis:pintura:form-32:target-151",
      "service_id": "pintura",
      "service_label": "Pintura",
      "profile_visibility": [{"id": 12, "name": "Manutenção e Conservação"}],
      "form": {"id": 32, "name": "Pintura"},
      "targetticket": {
        "id": 151,
        "name": "Pintura",
        "audience": "para_mim",
        "destination_entity": {"code": 7, "mode": "maintenance_context_para_mim"},
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 470,
        "location_rule": 3,
        "location_question_id": 467,
        "type_rule": 1,
        "urgency_rule": 3
      },
      "questions": {
        "category": {"id": 470, "name": "Tipo", "fieldtype": "dropdown", "required": true, "root_id": 85, "option_source": "categories", "options_sample": []},
        "location": {"id": 467, "name": "Localização", "fieldtype": "dropdown", "required": true, "root_id": 70, "option_source": "locations", "options_sample": []}
      },
      "expected_result": {
        "domain": "Manutenção",
        "assignment_group": {"id": 22, "label": "CC-MANUTENCAO", "source_rule_id": 156},
        "base_task_templates": [],
        "attachment_policy": {"create_route": "POST /Ticket/{ticket_id}/Document"},
        "readback_contract": []
      }
    }
  ]
}
''';

  test('parses governed catalog v2 records without losing FormCreator ids', () {
    final catalog = GovernedServiceCatalog.fromJson(catalogJson);

    expect(catalog.records, hasLength(2));
    expect(catalog.schemaVersion, '2.0-readonly-draft');
    expect(catalog.records.first.formId, 12);
    expect(catalog.records.first.targetTicketId, 11);
    expect(catalog.records.first.categoryQuestion?.id, 102);
    expect(catalog.records.first.locationQuestion?.id, 98);
    expect(
      catalog.records.first.expectedAssignmentGroup?.label,
      'CC-MANUTENCAO',
    );
  });

  test(
    'selects service by active profile and audience, not by service label only',
    () {
      final catalog = GovernedServiceCatalog.fromJson(catalogJson);

      final solicitante = catalog.select(
        profileName: 'Solicitante',
        serviceLabel: 'Pintura',
        audience: GovernedTicketAudience.paraMim,
      );
      final manutencao = catalog.select(
        profileName: 'Manutenção e Conservação',
        serviceLabel: 'Pintura',
        audience: GovernedTicketAudience.paraMim,
      );

      expect(solicitante?.formId, 12);
      expect(solicitante?.destinationEntityMode, 'requester_context_para_mim');
      expect(manutencao?.formId, 32);
      expect(manutencao?.destinationEntityMode, 'maintenance_context_para_mim');
    },
  );

  test('builds a read-back expectation for ticket validation', () {
    final catalog = GovernedServiceCatalog.fromJson(catalogJson);
    final record = catalog.select(
      profileName: 'Solicitante',
      serviceLabel: 'Pintura',
      audience: GovernedTicketAudience.paraMim,
    )!;

    final expected = record.toReadbackExpectation();

    expect(expected.expectedGroupLabel, 'CC-MANUTENCAO');
    expect(expected.expectedDomain, 'Manutenção');
    expect(expected.expectedTaskTemplateLabels, contains('EQUIPE EXECUTORA'));
    expect(expected.attachmentProofRoute, 'POST /Ticket/{ticket_id}/Document');
  });

  test(
    'validates ticket read-back against group, domain, tasks and documents',
    () {
      final catalog = GovernedServiceCatalog.fromJson(catalogJson);
      final record = catalog.select(
        profileName: 'Solicitante',
        serviceLabel: 'Pintura',
        audience: GovernedTicketAudience.paraMim,
      )!;

      final result = record.toReadbackExpectation().validate(
        ticket: {
          'id': 9157,
          'groups': [
            {'name': 'CC-MANUTENCAO'},
          ],
          'domain': 'Manutenção',
        },
        taskLabels: [
          'EQUIPE EXECUTORA',
          'MATERIAIS UTILIZADOS',
          'SERVIÇO REALIZADO',
        ],
        documentIds: ['222'],
      );

      expect(result.ok, isTrue);
      expect(result.failures, isEmpty);
    },
  );

  test(
    'reports exact read-back drift instead of treating created ticket as success',
    () {
      final catalog = GovernedServiceCatalog.fromJson(catalogJson);
      final record = catalog.select(
        profileName: 'Solicitante',
        serviceLabel: 'Pintura',
        audience: GovernedTicketAudience.paraMim,
      )!;

      final result = record.toReadbackExpectation().validate(
        ticket: {
          'id': 9158,
          'groups': [
            {'name': 'CC-CONSERVACAO'},
          ],
          'domain': 'Conservação',
        },
        taskLabels: ['EQUIPE EXECUTORA'],
        documentIds: const [],
      );

      expect(result.ok, isFalse);
      expect(
        result.failures,
        contains('Grupo esperado não confirmado no read-back: CC-MANUTENCAO'),
      );
      expect(
        result.failures,
        contains('Domínio esperado não confirmado no read-back: Manutenção'),
      );
      expect(
        result.failures,
        contains(
          'Tarefa esperada não confirmada no read-back: MATERIAIS UTILIZADOS',
        ),
      );
      expect(
        result.failures,
        contains('Anexo não confirmado por Document_Item no read-back'),
      );
    },
  );
}
