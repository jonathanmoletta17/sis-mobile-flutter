import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/glpi_config.dart';

/// Opcao de lookup read-only para perguntas `glpiselect` de checklist.
class SisChecklistLookupOption {
  const SisChecklistLookupOption({required this.id, required this.label});
  final int id;
  final String label;
}

/// Provedor read-only de opcoes para `glpiselect`. Suporta apenas:
/// - `Ticket` (para "Checklist Programada");
/// - `PluginGenericobjectConservacao` (itens de conservacao).
///
/// Sempre GET; nunca lanca para a UI; itemtype desconhecido devolve lista vazia.
/// O Worker SIS so permite estes GETs em allowlist read-only.
class SisChecklistOptionClient {
  SisChecklistOptionClient({http.Client? httpClient, this.rangeEnd = 25})
      : _httpClient = httpClient ?? http.Client();

  static const Set<String> supportedItemTypes = {
    'Ticket',
    'PluginGenericobjectConservacao',
  };

  final http.Client _httpClient;
  final int rangeEnd;

  /// Resolve um item pelo ID exato. Usa o campo 2 (ID) da busca GLPI com
  /// searchtype=equals. Retorna null se não encontrado ou em caso de erro.
  Future<SisChecklistLookupOption?> lookupById({
    required String itemType,
    required int id,
    required String sessionToken,
  }) async {
    if (!supportedItemTypes.contains(itemType)) return null;

    final uri = Uri.parse(
      '${GlpiConfig.baseUrl}/search/$itemType'
      '?criteria[0][field]=2'
      '&criteria[0][searchtype]=equals'
      '&criteria[0][value]=$id'
      '&forcedisplay[0]=2'
      '&forcedisplay[1]=1'
      '&range=0-0',
    );

    try {
      final response = await _httpClient.get(uri, headers: {
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      }).timeout(GlpiConfig.requestTimeout);

      if (response.statusCode != 200 && response.statusCode != 206) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      final rows = decoded['data'];
      if (rows is! List || rows.isEmpty) return null;

      return _mapRow(rows.first as Map);
    } catch (_) {
      return null;
    }
  }

  Future<List<SisChecklistLookupOption>> search({
    required String itemType,
    required String query,
    required String sessionToken,
  }) async {
    if (!supportedItemTypes.contains(itemType)) {
      return const [];
    }

    final uri = Uri.parse(
      '${GlpiConfig.baseUrl}/search/$itemType'
      '?criteria[0][field]=1'
      '&criteria[0][searchtype]=contains'
      '&criteria[0][value]=${Uri.encodeQueryComponent(query)}'
      '&forcedisplay[0]=2'
      '&forcedisplay[1]=1'
      '&range=0-$rangeEnd',
    );

    try {
      final response = await _httpClient.get(uri, headers: {
        'Accept': 'application/json',
        if (sessionToken.isNotEmpty) 'Session-Token': sessionToken,
      }).timeout(GlpiConfig.requestTimeout);

      if (response.statusCode != 200 && response.statusCode != 206) {
        return const [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return const [];
      final rows = decoded['data'];
      if (rows is! List) return const [];

      return rows
          .whereType<Map>()
          .map(_mapRow)
          .where((option) => option != null)
          .cast<SisChecklistLookupOption>()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  SisChecklistLookupOption? _mapRow(Map row) {
    final id = _readInt(row['2'] ?? row['id']);
    if (id == null || id <= 0) return null;
    final label = _readText(row['1'] ?? row['name']) ?? '#$id';
    return SisChecklistLookupOption(id: id, label: label);
  }

  int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  String? _readText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
