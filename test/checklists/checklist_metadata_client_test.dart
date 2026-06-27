import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_mobile_flutter/checklists/checklist_metadata_client.dart';

String _fixtureJson() =>
    File('test/fixtures/sis_checklists_catalog.json').readAsStringSync();

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('empty URL returns null and does not throw', () async {
    final client = SisChecklistMetadataClient(
      httpClient: MockClient(
        (_) async => http.Response('should not be called', 500),
      ),
    );
    final catalog = await client.loadChecklistCatalog(catalogUrl: '');
    expect(catalog, isNull);
  });

  test('HTTP 200 parses catalog and caches it', () async {
    var calls = 0;
    final client = SisChecklistMetadataClient(
      httpClient: MockClient((request) async {
        calls += 1;
        expect(request.headers['Accept'], 'application/json');
        return http.Response(
          _fixtureJson(),
          200,
          headers: {
            'etag': '"abc"',
            'content-type': 'application/json; charset=utf-8',
          },
        );
      }),
    );

    final catalog = await client.loadChecklistCatalog(
      catalogUrl: 'https://worker.test/metadata/mobile/sis/checklists',
    );
    expect(catalog, isNotNull);
    expect(catalog!.forms, hasLength(5));
    expect(catalog.questions, hasLength(1271));
    expect(catalog.targets, hasLength(18));
    expect(calls, 1);

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(SisChecklistMetadataClient.cacheKeyCatalogEtag),
      '"abc"',
    );
    expect(
      prefs.getString(SisChecklistMetadataClient.cacheKeyCatalogJson),
      isNotNull,
    );
  });

  test('HTTP 304 falls back to cache and sends If-None-Match', () async {
    SharedPreferences.setMockInitialValues({
      SisChecklistMetadataClient.cacheKeyCatalogJson: _fixtureJson(),
      SisChecklistMetadataClient.cacheKeyCatalogEtag: '"cached"',
    });

    String? sentEtag;
    final client = SisChecklistMetadataClient(
      httpClient: MockClient((request) async {
        sentEtag = request.headers['If-None-Match'];
        return http.Response('', 304);
      }),
    );

    final catalog = await client.loadChecklistCatalog(
      catalogUrl: 'https://worker.test/metadata/mobile/sis/checklists',
    );
    expect(sentEtag, '"cached"');
    expect(catalog, isNotNull);
    expect(catalog!.forms, hasLength(5));
  });

  test('network error uses cache when available', () async {
    SharedPreferences.setMockInitialValues({
      SisChecklistMetadataClient.cacheKeyCatalogJson: _fixtureJson(),
    });
    final client = SisChecklistMetadataClient(
      httpClient: MockClient(
        (_) async => throw const SocketException('offline'),
      ),
    );
    final catalog = await client.loadChecklistCatalog(
      catalogUrl: 'https://worker.test/metadata/mobile/sis/checklists',
    );
    expect(catalog, isNotNull);
    expect(catalog!.forms, hasLength(5));
  });

  test('network error without cache returns null', () async {
    final client = SisChecklistMetadataClient(
      httpClient: MockClient(
        (_) async => throw const SocketException('offline'),
      ),
    );
    final catalog = await client.loadChecklistCatalog(
      catalogUrl: 'https://worker.test/metadata/mobile/sis/checklists',
    );
    expect(catalog, isNull);
  });

  test('invalid cache returns null', () async {
    SharedPreferences.setMockInitialValues({
      SisChecklistMetadataClient.cacheKeyCatalogJson: '{not json',
    });
    final client = SisChecklistMetadataClient(
      httpClient: MockClient((_) async => http.Response('boom', 500)),
    );
    final catalog = await client.loadChecklistCatalog(
      catalogUrl: 'https://worker.test/metadata/mobile/sis/checklists',
    );
    expect(catalog, isNull);
  });
}
