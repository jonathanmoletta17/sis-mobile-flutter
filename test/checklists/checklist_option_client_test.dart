import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sis_mobile_flutter/checklists/checklist_option_client.dart';

void main() {
  setUp(() {
    dotenv.testLoad(
      mergeWith: const <String, String>{
        'SIS_GLPI_BASE_URL': 'https://worker.test/sis/apirest.php',
      },
    );
  });

  test('Ticket lookup uses /search/Ticket and parses rows', () async {
    Uri? requested;
    final client = SisChecklistOptionClient(
      httpClient: MockClient((request) async {
        requested = request.url;
        return http.Response(
          jsonEncode({
            'data': [
              {'2': 8595, '1': 'Checklist programada A'},
              {'2': '8596', '1': 'Checklist programada B'},
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final options = await client.search(
      itemType: 'Ticket',
      query: 'checklist',
      sessionToken: 'sess',
    );

    expect(requested!.path, contains('/search/Ticket'));
    expect(options.map((o) => o.id), [8595, 8596]);
    expect(options.first.label, 'Checklist programada A');
  });

  test(
    'PluginGenericobjectConservacao lookup uses its own search path',
    () async {
      Uri? requested;
      final client = SisChecklistOptionClient(
        httpClient: MockClient((request) async {
          requested = request.url;
          return http.Response(
            jsonEncode({'data': []}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      await client.search(
        itemType: 'PluginGenericobjectConservacao',
        query: 'bomba',
        sessionToken: 'sess',
      );

      expect(
        requested!.path,
        contains('/search/PluginGenericobjectConservacao'),
      );
    },
  );

  test('unknown itemtype returns empty list without HTTP', () async {
    var called = false;
    final client = SisChecklistOptionClient(
      httpClient: MockClient((_) async {
        called = true;
        return http.Response('[]', 200);
      }),
    );

    final options = await client.search(
      itemType: 'User',
      query: 'x',
      sessionToken: 'sess',
    );

    expect(options, isEmpty);
    expect(called, isFalse);
  });

  test('HTTP error returns empty list, not an exception', () async {
    final client = SisChecklistOptionClient(
      httpClient: MockClient((_) async => http.Response('boom', 500)),
    );

    final options = await client.search(
      itemType: 'Ticket',
      query: 'x',
      sessionToken: 'sess',
    );

    expect(options, isEmpty);
  });
}
