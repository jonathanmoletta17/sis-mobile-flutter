import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'checklist_catalog.dart';

/// Carrega o catalogo read-only de checklists do Worker SIS, com cache em
/// `SharedPreferences` e fallback seguro. Espelha o padrao de
/// `GlpiMetadataClient`: usa `If-None-Match`, timeout curto e nunca lanca para a
/// UI em caso de erro de rede/parsing.
class SisChecklistMetadataClient {
  static const String cacheKeyCatalogJson = 'sis_mobile_checklist_catalog_json';
  static const String cacheKeyCatalogEtag = 'sis_mobile_checklist_catalog_etag';
  static const String cacheKeyCatalogFetchedAt =
      'sis_mobile_checklist_catalog_fetched_at';

  final http.Client _httpClient;
  final Future<SharedPreferences> Function() _prefsFactory;
  final Duration timeout;

  SisChecklistMetadataClient({
    http.Client? httpClient,
    Future<SharedPreferences> Function()? prefsFactory,
    this.timeout = const Duration(seconds: 8),
  }) : _httpClient = httpClient ?? http.Client(),
       _prefsFactory = prefsFactory ?? SharedPreferences.getInstance;

  Future<SisChecklistCatalog?> loadChecklistCatalog({
    required String? catalogUrl,
  }) async {
    final normalizedUrl = catalogUrl?.trim() ?? '';
    if (normalizedUrl.isEmpty) {
      return _loadCachedCatalog();
    }

    try {
      final response = await _httpClient
          .get(Uri.parse(normalizedUrl), headers: await _requestHeaders())
          .timeout(timeout);

      if (response.statusCode == 304) {
        final cached = await _loadCachedCatalog();
        if (cached != null) return cached;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final catalog = _tryParse(response.body);
        if (catalog != null) {
          await _saveCatalog(response.body, response.headers['etag']);
          return catalog;
        }
      }

      return _loadCachedCatalog();
    } catch (_) {
      return _loadCachedCatalog();
    }
  }

  Future<Map<String, String>> _requestHeaders() async {
    final prefs = await _prefsFactory();
    final etag = prefs.getString(cacheKeyCatalogEtag)?.trim();
    return {
      'Accept': 'application/json',
      if (etag != null && etag.isNotEmpty) 'If-None-Match': etag,
    };
  }

  Future<SisChecklistCatalog?> _loadCachedCatalog() async {
    final prefs = await _prefsFactory();
    final raw = prefs.getString(cacheKeyCatalogJson);
    if (raw == null || raw.trim().isEmpty) return null;
    return _tryParse(raw);
  }

  SisChecklistCatalog? _tryParse(String rawJson) {
    try {
      return SisChecklistCatalog.fromJson(rawJson);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCatalog(String rawJson, String? etag) async {
    final prefs = await _prefsFactory();
    await prefs.setString(cacheKeyCatalogJson, rawJson);
    await prefs.setString(
      cacheKeyCatalogFetchedAt,
      DateTime.now().toUtc().toIso8601String(),
    );
    if (etag != null && etag.trim().isNotEmpty) {
      await prefs.setString(cacheKeyCatalogEtag, etag.trim());
    }
  }
}
