import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_mobile_flutter/catalog/glpi_metadata_client.dart';
import 'package:sis_mobile_flutter/catalog/service_catalog_provider.dart';
import 'package:sis_mobile_flutter/catalog/service_catalog_repository.dart';

String runtimeCatalogJson({String snapshotHash = 'snapshot-1'}) {
  return jsonEncode({
    'schema_version': 'mobile.catalog.v1',
    'snapshot_hash': snapshotHash,
    'etag': 'etag-$snapshotHash',
    'services': [
      {'service_id': 'carregadores', 'category_id': 55},
      {'service_id': 'projeto', 'category_id': 144},
    ],
  });
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    serviceCatalogRepository = ServiceCatalogRepository.staticBootstrap();
  });

  test(
    'metadata client loads runtime catalog and saves cache metadata',
    () async {
      final client = GlpiMetadataClient(
        httpClient: MockClient((request) async {
          expect(request.headers['Accept'], 'application/json');
          return http.Response(runtimeCatalogJson(), 200);
        }),
      );

      final repository = await client.loadServiceCatalog(
        catalogUrl: 'https://metadata.example/mobile/sis/catalog',
      );

      expect(repository.source, ServiceCatalogSource.runtimeCatalog);
      expect(repository.snapshotHash, 'snapshot-1');
      expect(repository.etag, 'etag-snapshot-1');
      expect(repository.services.map((s) => s.categoryId), [55, 144]);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(GlpiMetadataClient.cacheKeyCatalogSnapshotHash),
        'snapshot-1',
      );
      expect(
        prefs.getString(GlpiMetadataClient.cacheKeyCatalogEtag),
        'etag-snapshot-1',
      );
      expect(
        prefs.getString(GlpiMetadataClient.cacheKeyCatalogJson),
        isNotEmpty,
      );
    },
  );

  test(
    'metadata client sends If-None-Match and uses cached catalog on 304',
    () async {
      SharedPreferences.setMockInitialValues({
        GlpiMetadataClient.cacheKeyCatalogJson: runtimeCatalogJson(
          snapshotHash: 'cached-snapshot',
        ),
        GlpiMetadataClient.cacheKeyCatalogEtag: 'etag-cached-snapshot',
      });

      Map<String, String>? seenHeaders;
      final client = GlpiMetadataClient(
        httpClient: MockClient((request) async {
          seenHeaders = Map<String, String>.from(request.headers);
          return http.Response('', 304);
        }),
      );

      final repository = await client.loadServiceCatalog(
        catalogUrl: 'https://metadata.example/mobile/sis/catalog',
      );

      expect(
        seenHeaders,
        containsPair('If-None-Match', 'etag-cached-snapshot'),
      );
      expect(repository.source, ServiceCatalogSource.cachedRuntimeCatalog);
      expect(repository.snapshotHash, 'cached-snapshot');
      expect(repository.services.map((s) => s.categoryId), [55, 144]);
    },
  );

  test(
    'metadata client falls back to cached runtime catalog when endpoint fails',
    () async {
      SharedPreferences.setMockInitialValues({
        GlpiMetadataClient.cacheKeyCatalogJson: runtimeCatalogJson(
          snapshotHash: 'cached-snapshot',
        ),
      });

      final client = GlpiMetadataClient(
        httpClient: MockClient((request) async => http.Response('nope', 503)),
      );

      final repository = await client.loadServiceCatalog(
        catalogUrl: 'https://metadata.example/mobile/sis/catalog',
      );

      expect(repository.source, ServiceCatalogSource.cachedRuntimeCatalog);
      expect(repository.snapshotHash, 'cached-snapshot');
      expect(repository.services.map((s) => s.categoryId), [55, 144]);
    },
  );

  test(
    'metadata client uses static bootstrap when no URL and no cache exist',
    () async {
      final client = GlpiMetadataClient(
        httpClient: MockClient(
          (request) async => http.Response('should-not-call', 500),
        ),
      );

      final repository = await client.loadServiceCatalog(catalogUrl: null);

      expect(repository.source, ServiceCatalogSource.staticBootstrap);
      expect(repository.services.length, 15);
    },
  );

  test(
    'metadata client makes runtime failure explicit when cache is unavailable',
    () async {
      final client = GlpiMetadataClient(
        httpClient: MockClient((request) async => http.Response('nope', 503)),
      );

      final repository = await client.loadServiceCatalog(
        catalogUrl: 'https://metadata.example/mobile/sis/catalog',
      );

      expect(
        repository.source,
        ServiceCatalogSource.staticFallbackAfterRuntimeError,
      );
      expect(repository.lastError, contains('HTTP 503'));
      expect(repository.services.length, 15);
    },
  );

  test(
    'provider can initialize global repository from governed metadata client',
    () async {
      final client = GlpiMetadataClient(
        httpClient: MockClient(
          (request) async => http.Response(runtimeCatalogJson(), 200),
        ),
      );

      final repository = await initializeServiceCatalogRepository(
        metadataClient: client,
        catalogUrl: 'https://metadata.example/mobile/sis/catalog',
      );

      expect(repository.source, ServiceCatalogSource.runtimeCatalog);
      expect(
        serviceCatalogRepository.source,
        ServiceCatalogSource.runtimeCatalog,
      );
      expect(serviceCatalogRepository.services.map((s) => s.categoryId), [
        55,
        144,
      ]);
    },
  );
}
