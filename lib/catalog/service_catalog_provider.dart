import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'glpi_metadata_client.dart';
import 'service_catalog_repository.dart';

/// Current app-facing catalog boundary.
///
/// Starts with the static SIS bootstrap catalog, then can be upgraded at app
/// startup from the governed GLPI metadata catalog when SIS_METADATA_CATALOG_URL
/// or GLPI_METADATA_CATALOG_URL is configured.
ServiceCatalogRepository serviceCatalogRepository =
    ServiceCatalogRepository.staticBootstrap();

String? configuredSisMetadataCatalogUrl() {
  return dotenv.env['SIS_METADATA_CATALOG_URL'] ??
      dotenv.env['GLPI_METADATA_CATALOG_URL'];
}

Future<ServiceCatalogRepository> initializeServiceCatalogRepository({
  GlpiMetadataClient? metadataClient,
  String? catalogUrl,
}) async {
  final client = metadataClient ?? GlpiMetadataClient();
  serviceCatalogRepository = await client.loadServiceCatalog(
    catalogUrl: catalogUrl ?? configuredSisMetadataCatalogUrl(),
  );
  return serviceCatalogRepository;
}

/// Revalida o catálogo governado contra o endpoint configurado.
///
/// A tela de serviços chama isto ao abrir/retomar o app para que mudanças já
/// publicadas pelo GLPI Governance Runtime sejam refletidas sem exigir novo
/// build do aplicativo. Se o endpoint estiver fora, o client mantém cache ou
/// fallback explícito, nunca troca silenciosamente para regra inventada.
Future<ServiceCatalogRepository> refreshServiceCatalogRepository({
  GlpiMetadataClient? metadataClient,
  String? catalogUrl,
}) {
  return initializeServiceCatalogRepository(
    metadataClient: metadataClient,
    catalogUrl: catalogUrl,
  );
}
