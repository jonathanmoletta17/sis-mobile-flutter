import 'dart:convert';

import '../data/service_data.dart';

enum ServiceCatalogSource {
  staticBootstrap,
  runtimeCatalog,
  cachedRuntimeCatalog,
  staticFallbackAfterRuntimeError,
}

class UnknownServiceCategoryException implements Exception {
  final dynamic rawCategory;
  final String normalizedLabel;

  const UnknownServiceCategoryException(this.rawCategory, this.normalizedLabel);

  @override
  String toString() {
    return 'UnknownServiceCategoryException: categoria SIS nao encontrada no catalogo governado: "$normalizedLabel"';
  }
}

class ServiceCatalogRepository {
  final List<ServiceCategory> services;
  final ServiceCatalogSource source;
  final String? snapshotHash;
  final String? etag;
  final String? lastError;

  const ServiceCatalogRepository._({
    required this.services,
    required this.source,
    this.snapshotHash,
    this.etag,
    this.lastError,
  });

  factory ServiceCatalogRepository.staticBootstrap({
    List<ServiceCategory> staticServices = serviceCategories,
  }) {
    return ServiceCatalogRepository._(
      services: List<ServiceCategory>.unmodifiable(staticServices),
      source: ServiceCatalogSource.staticBootstrap,
    );
  }

  factory ServiceCatalogRepository.staticFallbackAfterRuntimeError({
    required List<ServiceCategory> staticFallback,
    required String lastError,
  }) {
    return ServiceCatalogRepository._(
      services: List<ServiceCategory>.unmodifiable(staticFallback),
      source: ServiceCatalogSource.staticFallbackAfterRuntimeError,
      lastError: lastError,
    );
  }

  factory ServiceCatalogRepository.fromRuntimeCatalogJson(
    String rawJson, {
    List<ServiceCategory> staticFallback = serviceCategories,
    ServiceCatalogSource sourceOverride = ServiceCatalogSource.runtimeCatalog,
    String? etagOverride,
  }) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('runtime catalog root must be an object');
      }

      final rawServices = decoded['services'];
      if (rawServices is! List || rawServices.isEmpty) {
        throw const FormatException(
          'runtime catalog services must be a non-empty array',
        );
      }

      final fallbackByCategoryId = {
        for (final service in staticFallback) service.categoryId: service,
      };
      final parsed = <ServiceCategory>[];
      for (final item in rawServices) {
        if (item is! Map<String, dynamic>) continue;
        final categoryId = _parseInt(item['category_id']);
        if (categoryId == null) continue;

        final fallback = fallbackByCategoryId[categoryId];
        if (fallback != null) {
          parsed.add(_mergeRuntimeService(fallback, item));
          continue;
        }

        // Runtime services sem equivalente estatico ainda nao sao renderizaveis
        // pela UI atual porque faltam icone/cor/campos. Mantemos o contrato
        // conservador ate o schema dinamico existir.
      }

      if (parsed.isEmpty) {
        throw const FormatException(
          'runtime catalog has no renderable SIS services',
        );
      }

      return ServiceCatalogRepository._(
        services: List<ServiceCategory>.unmodifiable(parsed),
        source: sourceOverride,
        snapshotHash:
            (decoded['snapshot_hash'] ?? decoded['source_snapshot_hash'])
                ?.toString(),
        etag: etagOverride ?? decoded['etag']?.toString(),
      );
    } catch (error) {
      return ServiceCatalogRepository._(
        services: List<ServiceCategory>.unmodifiable(staticFallback),
        source: ServiceCatalogSource.staticFallbackAfterRuntimeError,
        lastError: error.toString(),
      );
    }
  }

  ServiceCategory? findByName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final normalized = normalizeServiceLabel(name);

    for (final service in services) {
      if (normalizeServiceLabel(service.name) == normalized) {
        return service;
      }
      if (service.aliases.any(
        (alias) => normalizeServiceLabel(alias) == normalized,
      )) {
        return service;
      }
    }

    return null;
  }

  ServiceCategory? findById(int? categoryId) {
    if (categoryId == null) return null;
    for (final service in services) {
      if (service.categoryId == categoryId) return service;
    }
    return null;
  }

  int? tryResolveCategoryId(dynamic rawCategory) {
    if (rawCategory is int) return rawCategory;

    final numeric = int.tryParse(rawCategory?.toString() ?? '');
    if (numeric != null) return numeric;

    final service = findByName(extractServiceCategoryLabel(rawCategory));
    return service?.categoryId;
  }

  int resolveCategoryId(dynamic rawCategory) {
    final categoryId = tryResolveCategoryId(rawCategory);
    if (categoryId != null) return categoryId;

    final label = extractServiceCategoryLabel(rawCategory);
    throw UnknownServiceCategoryException(rawCategory, label);
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static ServiceCategory _mergeRuntimeService(
    ServiceCategory fallback,
    Map<String, dynamic> item,
  ) {
    final uiSchema = item['ui_schema'] is Map<String, dynamic>
        ? item['ui_schema'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final runtimeLocationOptions = _extractLocationOptions(
      uiSchema['location_question'],
    );
    final runtimeLocations = runtimeLocationOptions
        .map((option) => option.label)
        .toList(growable: false);
    final runtimeTypes = _extractOptionLabels(uiSchema['type_question']);

    final domainLabel =
        item['service_domain_label']?.toString() ??
        _domainFromCategoryLabel(item['category_label']);

    return fallback.copyWith(
      locations: runtimeLocations.isNotEmpty ? runtimeLocations : null,
      locationOptions: runtimeLocationOptions.isNotEmpty
          ? runtimeLocationOptions
          : null,
      typeOptions: runtimeTypes.isNotEmpty ? runtimeTypes : null,
      includeLocalizacao: runtimeLocations.isNotEmpty
          ? true
          : fallback.includeLocalizacao,
      domainLabel: domainLabel,
      assignmentGroupLabel: item['expected_assignment_group_label']?.toString(),
      runtimeFormStatus: item['canonical_form_status']?.toString(),
      uiSchemaSource: item['ui_schema_source']?.toString(),
    );
  }

  static String? _domainFromCategoryLabel(dynamic rawLabel) {
    final label = rawLabel?.toString().trim();
    if (label == null || label.isEmpty) return null;
    return label.split('>').first.trim();
  }

  static List<LocationOption> _extractLocationOptions(dynamic rawQuestion) {
    if (rawQuestion is! Map<String, dynamic>) return const [];
    final rawOptions = rawQuestion['options'];
    if (rawOptions is! List) return const [];

    final rootId = _parseInt(rawQuestion['root_id']);
    final sourceQuestionId = _parseInt(rawQuestion['id']);
    final options = <LocationOption>[];

    for (final option in rawOptions) {
      if (option is Map) {
        final id = _parseInt(option['id']);
        final label = option['label']?.toString().trim();
        if (id == null || label == null || label.isEmpty) continue;
        final fullLabel = option['full_label']?.toString().trim();
        options.add(
          LocationOption(
            id: id,
            label: label,
            fullLabel: fullLabel != null && fullLabel.isNotEmpty
                ? fullLabel
                : label,
            rootId: rootId,
            sourceQuestionId: sourceQuestionId,
          ),
        );
      }
    }

    return List<LocationOption>.unmodifiable(options);
  }

  static List<String> _extractOptionLabels(dynamic rawQuestion) {
    if (rawQuestion is! Map<String, dynamic>) return const [];
    final rawOptions = rawQuestion['options'];
    if (rawOptions is! List) return const [];
    final labels = <String>[];
    for (final option in rawOptions) {
      if (option is Map) {
        final label = option['label']?.toString().trim();
        if (label != null && label.isNotEmpty) labels.add(label);
      } else {
        final label = option?.toString().trim();
        if (label != null && label.isNotEmpty) labels.add(label);
      }
    }
    return List<String>.unmodifiable(labels);
  }
}
