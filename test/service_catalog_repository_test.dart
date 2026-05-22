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
}
