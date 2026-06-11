import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/service_data.dart';
import 'service_catalog_repository.dart';

class GlpiMetadataClient {
  static const String cacheKeyCatalogJson = 'sis_mobile_runtime_catalog_json';
  static const String cacheKeyCatalogEtag = 'sis_mobile_runtime_catalog_etag';
  static const String cacheKeyCatalogSnapshotHash =
      'sis_mobile_runtime_catalog_snapshot_hash';
  static const String cacheKeyCatalogFetchedAt =
      'sis_mobile_runtime_catalog_fetched_at';

  final http.Client _httpClient;
  final Future<SharedPreferences> Function() _prefsFactory;
  final Duration timeout;

  GlpiMetadataClient({
    http.Client? httpClient,
    Future<SharedPreferences> Function()? prefsFactory,
    this.timeout = const Duration(seconds: 8),
  }) : _httpClient = httpClient ?? http.Client(),
       _prefsFactory = prefsFactory ?? SharedPreferences.getInstance;

  Future<ServiceCatalogRepository> loadServiceCatalog({
    required String? catalogUrl,
    List<ServiceCategory> staticFallback = serviceCategories,
  }) async {
    final normalizedUrl = catalogUrl?.trim() ?? '';
    if (normalizedUrl.isEmpty) {
      final cached = await _loadCachedCatalog(staticFallback: staticFallback);
      return cached ??
          ServiceCatalogRepository.staticBootstrap(
            staticServices: staticFallback,
          );
    }

    try {
      final headers = await _catalogRequestHeaders();
      final response = await _httpClient
          .get(Uri.parse(normalizedUrl), headers: headers)
          .timeout(timeout);

      if (response.statusCode == 304) {
        final cached = await _loadCachedCatalog(staticFallback: staticFallback);
        if (cached != null) return cached;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final fetchedAt = DateTime.now().toUtc();
        final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
          response.body,
          staticFallback: staticFallback,
          etagOverride: response.headers['etag'],
          fetchedAt: fetchedAt,
        );

        if (repository.source == ServiceCatalogSource.runtimeCatalog) {
          await _saveCatalog(response.body, repository, fetchedAt: fetchedAt);
          return repository;
        }
      }

      final cached = await _loadCachedCatalog(staticFallback: staticFallback);
      if (cached != null) return cached;

      return ServiceCatalogRepository.staticFallbackAfterRuntimeError(
        staticFallback: staticFallback,
        lastError:
            'metadata catalog HTTP ${response.statusCode}; cache unavailable',
      );
    } catch (error) {
      final cached = await _loadCachedCatalog(staticFallback: staticFallback);
      if (cached != null) return cached;

      return ServiceCatalogRepository.staticFallbackAfterRuntimeError(
        staticFallback: staticFallback,
        lastError: error.toString(),
      );
    }
  }

  Future<Map<String, String>> _catalogRequestHeaders() async {
    final prefs = await _prefsFactory();
    final etag = prefs.getString(cacheKeyCatalogEtag)?.trim();
    return {
      'Accept': 'application/json',
      if (etag != null && etag.isNotEmpty) 'If-None-Match': etag,
    };
  }

  Future<ServiceCatalogRepository?> _loadCachedCatalog({
    required List<ServiceCategory> staticFallback,
  }) async {
    final prefs = await _prefsFactory();
    final raw = prefs.getString(cacheKeyCatalogJson);
    if (raw == null || raw.trim().isEmpty) return null;
    final fetchedAt = DateTime.tryParse(
      prefs.getString(cacheKeyCatalogFetchedAt) ?? '',
    )?.toUtc();

    final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
      raw,
      staticFallback: staticFallback,
      sourceOverride: ServiceCatalogSource.cachedRuntimeCatalog,
      fetchedAt: fetchedAt,
    );

    if (repository.source == ServiceCatalogSource.cachedRuntimeCatalog) {
      return repository;
    }

    return null;
  }

  Future<void> _saveCatalog(
    String rawJson,
    ServiceCatalogRepository repository, {
    required DateTime fetchedAt,
  }) async {
    final prefs = await _prefsFactory();
    await prefs.setString(cacheKeyCatalogJson, rawJson);
    await prefs.setString(
      cacheKeyCatalogFetchedAt,
      fetchedAt.toIso8601String(),
    );
    if (repository.etag != null) {
      await prefs.setString(cacheKeyCatalogEtag, repository.etag!);
    }
    if (repository.snapshotHash != null) {
      await prefs.setString(
        cacheKeyCatalogSnapshotHash,
        repository.snapshotHash!,
      );
    }
  }
}
