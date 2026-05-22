import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_mobile_flutter/catalog/glpi_metadata_client.dart';
import 'package:sis_mobile_flutter/catalog/service_catalog_repository.dart';

void main() {
  test(
    'metadata client consumes a real local governance runtime endpoint',
    () async {
      const catalogUrl = String.fromEnvironment('SIS_METADATA_CATALOG_URL');
      if (catalogUrl.isEmpty) {
        markTestSkipped('SIS_METADATA_CATALOG_URL dart-define not provided.');
        return;
      }

      SharedPreferences.setMockInitialValues({});
      final client = GlpiMetadataClient(timeout: const Duration(seconds: 5));
      final repository = await client.loadServiceCatalog(
        catalogUrl: catalogUrl,
      );

      expect(repository.source, ServiceCatalogSource.runtimeCatalog);
      expect(repository.services, isNotEmpty);
      expect(repository.etag, isNotEmpty);
      expect(repository.snapshotHash, isNotEmpty);
      expect(repository.tryResolveCategoryId('Carregadores'), 55);
    },
  );
}
