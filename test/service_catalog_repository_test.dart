import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/catalog/service_catalog_repository.dart';
import 'package:sis_mobile_flutter/data/service_data.dart';

void main() {
  const runtimeCatalogJson = '''
{
  "consumer": "sis-mobile-flutter",
  "instance": "sis",
  "snapshot_hash": "runtime-hash",
  "etag": "runtime-etag",
  "services": [
    {
      "service_id": "carregadores",
      "label": "Carregadores",
      "category_id": 55,
      "category_label": "Conservação > Carregadores",
      "expected_assignment_group_id": 21,
      "expected_assignment_group_label": "CC-CONSERVACÃO",
      "risk": "medium",
      "sync_mode": "runtime_preferred_static_fallback",
      "ui_schema_source": "formcreator_runtime_metadata",
      "canonical_form_status": "ambiguous",
      "ui_schema": {
        "location_question": {
          "options": [
            {"id": 7001, "label": "CAFF"},
            {"id": 7002, "label": "Casa Civil 1005 > 1° Andar"}
          ]
        },
        "type_question": {
          "options": [
            {"id": 5501, "label": "Movimentação de Insumos"},
            {"id": 5502, "label": "Recolhimento"}
          ]
        }
      },
      "location_ids_currently_sent": [36]
    }
  ]
}
''';

  test('static repository keeps current SIS bootstrap catalog available', () {
    final repository = ServiceCatalogRepository.staticBootstrap();

    expect(repository.source, ServiceCatalogSource.staticBootstrap);
    expect(repository.services, hasLength(serviceCategories.length));
    expect(repository.findByName('Carregadores')?.categoryId, 55);
    expect(repository.tryResolveCategoryId('Vidracaria'), 94);
  });

  test(
    'runtime catalog can override static bootstrap by category contract',
    () {
      final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
        runtimeCatalogJson,
        staticFallback: serviceCategories,
      );

      expect(repository.source, ServiceCatalogSource.runtimeCatalog);
      expect(repository.snapshotHash, 'runtime-hash');
      expect(repository.etag, 'runtime-etag');
      expect(repository.services, hasLength(1));
      final service = repository.findByName('Carregadores');
      expect(service?.categoryId, 55);
      expect(service?.domainLabel, 'Conservação');
      expect(service?.assignmentGroupLabel, 'CC-CONSERVACÃO');
      expect(service?.locations, ['CAFF', 'Casa Civil 1005 > 1° Andar']);
      expect(service?.locationOptions.map((option) => option.id), [7001, 7002]);
      expect(service?.locationOptions.first.label, 'CAFF');
      expect(service?.locationOptions.first.fullLabel, 'CAFF');
      expect(service?.typeOptions, ['Movimentação de Insumos', 'Recolhimento']);
      expect(service?.uiSchemaSource, 'formcreator_runtime_metadata');
      expect(service?.runtimeFormStatus, 'ambiguous');
      expect(repository.tryResolveCategoryId('Conservação > Carregadores'), 55);
    },
  );

  test(
    'runtime catalog preserves location IDs and never emits Root labels',
    () {
      final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
        runtimeCatalogJson,
        staticFallback: serviceCategories,
      );

      final service = repository.findByName('Carregadores')!;

      expect(service.locationOptions, hasLength(2));
      expect(service.locationOptions.first.id, 7001);
      expect(service.locationOptions.first.label, 'CAFF');
      expect(service.locations.any((label) => label.contains('Root')), isFalse);
    },
  );

  test(
    'governed v2 records populate renderable services and keep contract records',
    () {
      const governedRuntimeCatalogJson = '''
{
  "schema_version": "2.0-readonly-draft",
  "consumer_id": "sis-mobile-flutter",
  "instance": "sis",
  "source_snapshot": {"sha256": "snapshot-v2"},
  "records": [
    {
      "catalog_record_id": "sis:carregadores:form-2:target-3",
      "service_id": "carregadores",
      "service_label": "Carregadores",
      "profile_visibility": [{"id": 9, "name": "Solicitante"}],
      "form": {"id": 2, "name": "Carregadores"},
      "targetticket": {
        "id": 3,
        "name": "Carregadores",
        "audience": "para_mim",
        "destination_entity": {"code": 2, "mode": "requester_context_para_mim"},
        "category_rule": 3,
        "category_question_id": 7,
        "location_rule": 3,
        "location_question_id": 8,
        "type_rule": 1,
        "urgency_rule": 3
      },
      "questions": {
        "category": {
          "id": 7,
          "required": true,
          "root_id": 55,
          "options_sample": [
            {"id": 5501, "label": "Transporte", "full_label": "Conservação > Carregadores > Transporte"}
          ]
        },
        "location": {
          "id": 8,
          "required": true,
          "root_id": 70,
          "raw_values": {"show_tree_root": "70", "selectable_tree_root": "0"},
          "options_sample": [
            {"id": 70, "label": "Locais", "full_label": "Locais"},
            {"id": 282, "label": "P01S08", "full_label": "Locais > Casa Civil 1005 > 1° Andar > P01S08"},
            {"id": 283, "label": "P01S08-A", "full_label": "Locais > Casa Civil 1005 > 1° Andar > P01S08 > P01S08-A"}
          ]
        }
      },
      "expected_result": {
        "domain": "Conservação",
        "assignment_group": {"id": 21, "label": "CC-CONSERVACAO"},
        "base_task_templates": [{"id": 1, "label": "SERVIÇO REALIZADO"}],
        "attachment_policy": {"create_route": "POST /Ticket/{ticket_id}/Document"},
        "readback_contract": ["GET Ticket"]
      }
    }
  ]
}
''';

      final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
        governedRuntimeCatalogJson,
        staticFallback: serviceCategories,
      );

      expect(repository.source, ServiceCatalogSource.runtimeCatalog);
      expect(repository.snapshotHash, 'snapshot-v2');
      expect(repository.governedCatalog?.records, hasLength(1));
      final service = repository.findByName('Carregadores')!;
      expect(service.uiSchemaSource, 'governed_v2_records');
      expect(service.governedRecords, hasLength(1));
      expect(service.typeOptions, ['Transporte']);
      expect(service.locationOptions.map((option) => option.id), [282, 283]);
      expect(service.displayLocations, [
        'Casa Civil 1005 > 1° Andar > P01S08',
        'Casa Civil 1005 > 1° Andar > P01S08 > P01S08-A',
      ]);
      expect(service.locationOptions.first.label, 'P01S08');
      expect(
        service.locationOptions.first.fullLabel,
        'Locais > Casa Civil 1005 > 1° Andar > P01S08',
      );
      expect(service.assignmentGroupLabel, 'CC-CONSERVACAO');
    },
  );

  test('invalid runtime catalog falls back to static bootstrap explicitly', () {
    final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
      '{not-json',
      staticFallback: serviceCategories,
    );

    expect(
      repository.source,
      ServiceCatalogSource.staticFallbackAfterRuntimeError,
    );
    expect(repository.lastError, isNotNull);
    expect(repository.findByName('Projeto')?.categoryId, 144);
  });

  test('unknown category does not silently fallback to Ar-Condicionado', () {
    final repository = ServiceCatalogRepository.staticBootstrap();

    expect(repository.tryResolveCategoryId('Categoria que nao existe'), isNull);
    expect(
      () => repository.resolveCategoryId('Categoria que nao existe'),
      throwsA(isA<UnknownServiceCategoryException>()),
    );
  });

  test(
    'profile projection renders GG aggregate forms instead of static individual cards',
    () {
      const governedRuntimeCatalogJson = '''
{
  "schema_version": "2.0-readonly-draft",
  "consumer_id": "sis-mobile-flutter",
  "instance": "sis",
  "source_snapshot": {"sha256": "snapshot-gg"},
  "records": [
    {
      "catalog_record_id": "sis:ar-condicionado:form-1:target-1",
      "service_id": "ar-condicionado",
      "service_label": "Ar-Condicionado",
      "profile_visibility": [{"id": 9, "name": "Solicitante"}],
      "form": {"id": 1, "name": "Ar-Condicionado"},
      "targetticket": {
        "id": 1,
        "name": "Chamado",
        "audience": "para_mim",
        "destination_entity": {"code": 2, "mode": "requester_context_para_mim"},
        "category_rule": 3,
        "location_rule": 3
      },
      "questions": {},
      "expected_result": {"domain": "Manutenção", "readback_contract": []}
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-202",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [{"id": 12, "name": "Solicitante-GG-Conservação"}],
      "form": {"id": 39, "name": "MANUTENÇÃO"},
      "targetticket": {
        "id": 202,
        "name": "Ar Condicionado",
        "audience": "para_mim",
        "destination_entity": {"code": 7, "mode": "maintenance_context_para_mim"},
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 639,
        "location_rule": 3,
        "location_question_id": 635
      },
      "questions": {
        "category": {
          "id": 639,
          "required": true,
          "root_id": 1,
          "options_sample": [
            {"id": 1, "label": "Ar Condicionado", "full_label": "Manutenção > Ar Condicionado"},
            {"id": 4, "label": "Instalação", "full_label": "Manutenção > Ar Condicionado > Instalação"}
          ]
        }
      },
      "expected_result": {"domain": "Manutenção", "readback_contract": []}
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-208",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [{"id": 12, "name": "Solicitante-GG-Conservação"}],
      "form": {"id": 39, "name": "MANUTENÇÃO"},
      "targetticket": {
        "id": 208,
        "name": "Pintura",
        "audience": "para_mim",
        "destination_entity": {"code": 7, "mode": "maintenance_context_para_mim"},
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 663,
        "location_rule": 3,
        "location_question_id": 635
      },
      "questions": {
        "category": {
          "id": 663,
          "required": true,
          "root_id": 85,
          "options_sample": [
            {"id": 85, "label": "Pintura", "full_label": "Manutenção > Pintura"},
            {"id": 86, "label": "Retoque", "full_label": "Manutenção > Pintura > Retoque"}
          ]
        }
      },
      "expected_result": {"domain": "Manutenção", "readback_contract": []}
    },
    {
      "catalog_record_id": "sis:conservacao:form-38:target-200",
      "service_id": "conservacao",
      "service_label": "CONSERVAÇÃO",
      "profile_visibility": [{"id": 12, "name": "Solicitante-GG-Conservação"}],
      "form": {"id": 38, "name": "CONSERVAÇÃO"},
      "targetticket": {
        "id": 200,
        "name": "Limpeza",
        "audience": "para_mim",
        "destination_entity": {"code": 7, "mode": "maintenance_context_para_mim"},
        "destination_entity_value": 58,
        "category_rule": 3,
        "location_rule": 3
      },
      "questions": {},
      "expected_result": {"domain": "Conservação", "readback_contract": []}
    }
  ]
}
''';

      final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
        governedRuntimeCatalogJson,
        staticFallback: serviceCategories,
      );

      final gg = repository.servicesForProfile('Solicitante-GG-Conservação');
      expect(
        gg.map((service) => service.name),
        containsAll(['CONSERVAÇÃO', 'MANUTENÇÃO']),
      );
      expect(
        gg.map((service) => service.name),
        isNot(contains('Ar-Condicionado')),
      );

      final manutencao = gg.singleWhere(
        (service) => service.name == 'MANUTENÇÃO',
      );
      expect(manutencao.governedRecords, hasLength(2));
      expect(
        manutencao.typeOptions,
        containsAll(['Ar Condicionado', 'Instalação', 'Pintura', 'Retoque']),
      );

      final solicitante = repository.servicesForProfile('Solicitante');
      expect(
        solicitante.map((service) => service.name),
        contains('Ar-Condicionado'),
      );
      expect(
        solicitante.map((service) => service.name),
        isNot(contains('MANUTENÇÃO')),
      );
    },
  );

  test(
    'governed category dropdown uses clean labels and only disambiguates collisions with full label',
    () {
      const governedRuntimeCatalogJson = '''
{
  "schema_version": "2.0-readonly-draft",
  "consumer_id": "sis-mobile-flutter",
  "instance": "sis",
  "records": [
    {
      "catalog_record_id": "sis:ar-condicionado:form-1:target-1",
      "service_id": "ar-condicionado",
      "service_label": "Ar-Condicionado",
      "profile_visibility": [{"id": 9, "name": "Solicitante"}],
      "form": {"id": 1, "name": "Ar-Condicionado"},
      "targetticket": {
        "id": 1,
        "name": "Chamado",
        "audience": "para_mim",
        "destination_entity": {"code": 2, "mode": "requester_context_para_mim"},
        "category_rule": 3,
        "location_rule": 3
      },
      "questions": {},
      "expected_result": {"readback_contract": []}
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-202",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [{"id": 12, "name": "Solicitante-GG-Conservação"}],
      "form": {"id": 39, "name": "MANUTENÇÃO"},
      "targetticket": {
        "id": 202,
        "name": "Ar Condicionado",
        "audience": "para_mim",
        "destination_entity": {"code": 7, "mode": "maintenance_context_para_mim"},
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 639,
        "location_rule": 3,
        "location_question_id": 635
      },
      "questions": {
        "category": {
          "id": 639,
          "required": true,
          "root_id": 1,
          "options_sample": [
            {"id": 4, "label": "Instalação", "full_label": "Manutenção > Ar Condicionado > Instalação"},
            {"id": 86, "label": "Retoque", "full_label": "Manutenção > Pintura > Retoque"}
          ]
        }
      },
      "expected_result": {"domain": "Manutenção", "readback_contract": []}
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-208",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [{"id": 12, "name": "Solicitante-GG-Conservação"}],
      "form": {"id": 39, "name": "MANUTENÇÃO"},
      "targetticket": {
        "id": 208,
        "name": "Pintura",
        "audience": "para_mim",
        "destination_entity": {"code": 7, "mode": "maintenance_context_para_mim"},
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 663,
        "location_rule": 3,
        "location_question_id": 635
      },
      "questions": {
        "category": {
          "id": 663,
          "required": true,
          "root_id": 85,
          "options_sample": [
            {"id": 401, "full_label": "Manutenção > Pintura > Retoque"},
            {"id": 402, "label": "Instalação", "full_label": "Manutenção > Pintura > Instalação"}
          ]
        }
      },
      "expected_result": {"domain": "Manutenção", "readback_contract": []}
    }
  ]
}
''';

      final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
        governedRuntimeCatalogJson,
        staticFallback: serviceCategories,
      );

      final service = repository
          .servicesForProfile('Solicitante-GG-Conservação')
          .singleWhere(
            (service) => service.governedRecords.any(
              (record) => record.serviceLabel == 'MANUTENÇÃO',
            ),
          );

      expect(service.typeOptions, contains('Retoque'));
      expect(
        service.typeOptions,
        contains('Manutenção > Pintura > Instalação'),
        reason: 'labels iguais precisam de fullLabel para desambiguação',
      );
      expect(
        service.typeOptions,
        isNot(contains('Manutenção > Ar Condicionado > Retoque')),
        reason: 'sem colisão, o dropdown não deve repetir o caminho completo',
      );
    },
  );

  test(
    'profile projection hides checklist-only services and keeps mixed generic records',
    () {
      const governedRuntimeCatalogJson = '''
{
  "schema_version": "2.0-readonly-draft",
  "consumer_id": "sis-mobile-flutter",
  "instance": "sis",
  "source_snapshot": {"sha256": "snapshot-checklists"},
  "records": [
    {
      "catalog_record_id": "sis:checklist-hidraulico:form-50:target-341",
      "service_id": "checklist-hidraulico",
      "service_label": "CHECKLIST HIDRÁULICO",
      "requires_specialized_flow": true,
      "profile_visibility": [{"id": 4, "name": "Super-Admin"}],
      "form": {"id": 50, "name": "CHECKLIST HIDRÁULICO"},
      "targetticket": {
        "id": 341,
        "name": "HIDRÁULICO ALA RESIDÊNCIAL",
        "audience": "para_mim",
        "destination_entity": {"code": 7, "mode": "maintenance_context_para_mim"},
        "destination_entity_value": 58
      },
      "questions": {},
      "expected_result": {"domain": "Manutenção", "readback_contract": []}
    },
    {
      "catalog_record_id": "sis:projeto:form-36:target-246",
      "service_id": "projeto",
      "service_label": "Projeto",
      "requires_specialized_flow": false,
      "profile_visibility": [{"id": 4, "name": "Super-Admin"}],
      "form": {"id": 36, "name": "Projeto"},
      "targetticket": {
        "id": 246,
        "name": "Chamado",
        "audience": "para_mim",
        "destination_entity": {"code": 7, "mode": "maintenance_context_para_mim"},
        "destination_entity_value": 58
      },
      "questions": {},
      "expected_result": {"domain": "Manutenção", "readback_contract": []}
    },
    {
      "catalog_record_id": "sis:projeto:form-99:target-999",
      "service_id": "projeto",
      "service_label": "Projeto",
      "requires_specialized_flow": true,
      "profile_visibility": [{"id": 4, "name": "Super-Admin"}],
      "form": {"id": 99, "name": "CHECKLIST PROJETO"},
      "targetticket": {
        "id": 999,
        "name": "Checklist",
        "audience": "para_mim",
        "destination_entity": {"code": 7, "mode": "maintenance_context_para_mim"},
        "destination_entity_value": 58
      },
      "questions": {},
      "expected_result": {"domain": "Manutenção", "readback_contract": []}
    }
  ]
}
''';

      final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
        governedRuntimeCatalogJson,
        staticFallback: serviceCategories,
      );

      final superAdmin = repository.servicesForProfile('Super-Admin');
      final names = superAdmin.map((service) => service.name).toList();
      expect(names, contains('Projeto'));
      expect(names, isNot(contains('CHECKLIST HIDRÁULICO')));

      final projeto = superAdmin.singleWhere(
        (service) => service.name == 'Projeto',
      );
      expect(projeto.governedRecords, hasLength(1));
      expect(projeto.governedRecords.single.catalogRecordId, contains('246'));
      expect(projeto.governedRecords.single.requiresSpecializedFlow, isFalse);
    },
  );
}
