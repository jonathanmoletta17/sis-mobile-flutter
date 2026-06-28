import 'dart:convert';

import '../data/service_data.dart';
import 'governed_service_catalog.dart';

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
  final DateTime? fetchedAt;
  final GovernedServiceCatalog? governedCatalog;

  const ServiceCatalogRepository._({
    required this.services,
    required this.source,
    this.snapshotHash,
    this.etag,
    this.lastError,
    this.fetchedAt,
    this.governedCatalog,
  });

  bool get isRuntimeBacked =>
      source == ServiceCatalogSource.runtimeCatalog ||
      source == ServiceCatalogSource.cachedRuntimeCatalog;

  bool get isLiveRuntime => source == ServiceCatalogSource.runtimeCatalog;

  String get sourceLabel {
    switch (source) {
      case ServiceCatalogSource.runtimeCatalog:
        return 'Runtime GLPI atualizado';
      case ServiceCatalogSource.cachedRuntimeCatalog:
        return 'Runtime GLPI em cache';
      case ServiceCatalogSource.staticFallbackAfterRuntimeError:
        return 'Fallback estático após erro';
      case ServiceCatalogSource.staticBootstrap:
        return 'Catálogo estático local';
    }
  }

  String get shortSnapshotHash {
    final value = snapshotHash?.trim() ?? '';
    if (value.isEmpty) return 'sem snapshot';
    return value.length <= 12 ? value : value.substring(0, 12);
  }

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
    DateTime? fetchedAt,
  }) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('runtime catalog root must be an object');
      }

      if (decoded['records'] is List) {
        return _fromGovernedV2Catalog(
          rawJson,
          decoded,
          staticFallback: staticFallback,
          sourceOverride: sourceOverride,
          etagOverride: etagOverride,
          fetchedAt: fetchedAt,
        );
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
        fetchedAt: fetchedAt,
      );
    } catch (error) {
      return ServiceCatalogRepository._(
        services: List<ServiceCategory>.unmodifiable(staticFallback),
        source: ServiceCatalogSource.staticFallbackAfterRuntimeError,
        lastError: error.toString(),
      );
    }
  }

  static ServiceCatalogRepository _fromGovernedV2Catalog(
    String rawJson,
    Map<String, dynamic> decoded, {
    required List<ServiceCategory> staticFallback,
    required ServiceCatalogSource sourceOverride,
    String? etagOverride,
    DateTime? fetchedAt,
  }) {
    final governedCatalog = GovernedServiceCatalog.fromJson(rawJson);
    final groupLabelIndex = _buildGroupLabelIndex(governedCatalog.records);
    final recordsByService = <String, List<GovernedServiceRecord>>{};
    for (final record in governedCatalog.records) {
      for (final key in [record.serviceLabel, record.serviceId]) {
        final normalized = normalizeServiceLabel(key);
        if (normalized.isEmpty) continue;
        recordsByService.putIfAbsent(normalized, () => []).add(record);
      }
    }

    final parsed = <ServiceCategory>[];
    for (final fallback in staticFallback) {
      final records = <GovernedServiceRecord>[];
      for (final key in [fallback.name, ...fallback.aliases]) {
        final matched = recordsByService[normalizeServiceLabel(key)];
        if (matched != null) records.addAll(matched);
      }
      final uniqueRecords = <String, GovernedServiceRecord>{
        for (final record in records) record.catalogRecordId: record,
      }.values.toList(growable: false);
      if (uniqueRecords.isEmpty) continue;
      parsed.add(_mergeGovernedService(fallback, uniqueRecords, groupLabelIndex));
    }

    if (parsed.isEmpty) {
      throw const FormatException(
        'governed runtime catalog has no renderable SIS services',
      );
    }

    final sourceSnapshot = decoded['source_snapshot'];
    return ServiceCatalogRepository._(
      services: List<ServiceCategory>.unmodifiable(parsed),
      source: sourceOverride,
      snapshotHash:
          (decoded['snapshot_hash'] ??
                  decoded['source_snapshot_hash'] ??
                  (sourceSnapshot is Map ? sourceSnapshot['sha256'] : null))
              ?.toString(),
      etag: etagOverride ?? decoded['etag']?.toString(),
      fetchedAt: fetchedAt,
      governedCatalog: governedCatalog,
    );
  }

  List<ServiceCategory> servicesForProfile(String? profileName) {
    final catalog = governedCatalog;
    final normalizedProfile = normalizeServiceLabel(profileName ?? '');
    // Sem catálogo governado (modo legado): mantém o catálogo estático.
    if (catalog == null) return services;
    // Catálogo governado v2 SEM perfil ativo ainda: NÃO expõe todos os serviços
    // (evita um perfil ver serviços de outro, ex.: GG vendo "Ar-Condicionado").
    if (normalizedProfile.isEmpty) return const [];

    final groupLabelIndex = _buildGroupLabelIndex(catalog.records);
    final recordsByService = <String, List<GovernedServiceRecord>>{};
    for (final record in catalog.records) {
      if (!_recordVisibleForProfile(record, normalizedProfile)) continue;
      final key = normalizeServiceLabel(
        record.serviceLabel.isNotEmpty ? record.serviceLabel : record.serviceId,
      );
      if (key.isEmpty) continue;
      recordsByService.putIfAbsent(key, () => []).add(record);
    }

    if (recordsByService.isEmpty) return const [];

    final projected = <ServiceCategory>[];
    for (final entry in recordsByService.entries) {
      final records = entry.value
          .where((record) => !record.requiresSpecializedFlow)
          .toList(growable: false);
      if (records.isEmpty) continue;
      records.sort(_compareGovernedRecordsStable);
      final representative = records.first;
      final fallback =
          _findStaticServiceByGovernedRecord(representative) ??
          governedServiceTemplate(
            representative.serviceLabel.isNotEmpty
                ? representative.serviceLabel
                : representative.serviceId,
            categoryId: representative.categoryQuestion?.rootId ?? 0,
            domainLabel: representative.expectedDomain,
          );
      projected.add(_mergeGovernedService(fallback, records, groupLabelIndex));
    }

    projected.sort(
      (a, b) => normalizeServiceLabel(
        a.name,
      ).compareTo(normalizeServiceLabel(b.name)),
    );
    return List<ServiceCategory>.unmodifiable(projected);
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

  /// Mapa id-de-grupo -> label, construído a partir de TODOS os registros que
  /// resolveram `expected_result.assignment_group` (id + label). Usado para
  /// derivar o label de registros cujo grupo ficou nulo no catálogo.
  static Map<int, String> _buildGroupLabelIndex(
    Iterable<GovernedServiceRecord> records,
  ) {
    final index = <int, String>{};
    for (final record in records) {
      final group = record.expectedAssignmentGroup;
      final id = group?.id;
      final label = group?.label?.trim();
      if (id != null && id > 0 && label != null && label.isNotEmpty) {
        index.putIfAbsent(id, () => label);
      }
    }
    return index;
  }

  /// Deriva o label do grupo de atribuição. Preferência: o label já resolvido
  /// no `expected_result`. Fallback: o grupo `assigned` listado nos `actors[]`
  /// do form, mapeado pelo índice id->label. Não inventa dado — usa o grupo que
  /// o próprio catálogo declara no form e um label já presente em outro registro.
  static String? _deriveAssignmentGroupLabel(
    GovernedServiceRecord representative,
    Map<int, String> groupLabelIndex,
  ) {
    final resolved = representative.expectedAssignmentGroup?.label?.trim();
    if (resolved != null && resolved.isNotEmpty) return resolved;

    for (final actor in representative.actors) {
      if (actor.role == 'assigned' &&
          actor.type == 'group' &&
          actor.value != null) {
        final label = groupLabelIndex[actor.value];
        if (label != null && label.isNotEmpty) return label;
      }
    }
    return null;
  }

  static ServiceCategory _mergeGovernedService(
    ServiceCategory fallback,
    List<GovernedServiceRecord> records,
    Map<int, String> groupLabelIndex,
  ) {
    final representative = _preferredGovernedRecord(records);
    final categoryOptions = _mergedOptions(
      records
          .map((record) => record.categoryQuestion)
          .whereType<GovernedQuestion>(),
    );
    final locationQuestions = records
        .map((record) => record.locationQuestion)
        .whereType<GovernedQuestion>()
        .toList(growable: false);
    final nonSelectableLocationRoots = locationQuestions
        .where((question) => !question.selectableTreeRoot)
        .map((question) => question.rootId)
        .whereType<int>()
        .toSet();
    final locationOptions = _mergedOptions(locationQuestions)
        .where(
          (option) =>
              option.id > 0 &&
              !nonSelectableLocationRoots.contains(option.id) &&
              (option.label ?? '').trim().isNotEmpty,
        )
        .map(
          (option) => LocationOption(
            id: option.id,
            label: option.label!.trim(),
            fullLabel: option.fullLabel,
            rootId: locationQuestions.isEmpty
                ? null
                : locationQuestions.first.rootId,
            sourceQuestionId: locationQuestions.isEmpty
                ? null
                : locationQuestions.first.id,
          ),
        )
        .toList(growable: false);

    final categoryFullLabelsByCleanLabel = <String, Set<String>>{};
    for (final option in categoryOptions) {
      final cleanLabel = _cleanCategoryOptionLabel(option);
      if (cleanLabel.isEmpty) continue;
      final normalizedCleanLabel = normalizeServiceLabel(cleanLabel);
      final fullLabel = (option.fullLabel?.trim().isNotEmpty ?? false)
          ? option.fullLabel!.trim()
          : cleanLabel;
      categoryFullLabelsByCleanLabel
          .putIfAbsent(normalizedCleanLabel, () => <String>{})
          .add(normalizeServiceLabel(fullLabel));
    }

    final categoryLabels = categoryOptions
        .map((option) {
          final cleanLabel = _cleanCategoryOptionLabel(option);
          if (cleanLabel.isEmpty) return '';
          final normalizedCleanLabel = normalizeServiceLabel(cleanLabel);
          final hasCollision =
              (categoryFullLabelsByCleanLabel[normalizedCleanLabel]?.length ??
                  0) >
              1;
          final fullLabel = option.fullLabel?.trim() ?? '';
          if (hasCollision && fullLabel.isNotEmpty) return fullLabel;
          return cleanLabel;
        })
        .where((label) => label.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return fallback.copyWith(
      locations: locationOptions.isNotEmpty
          ? locationOptions
                .map((option) => option.label)
                .toList(growable: false)
          : null,
      locationOptions: locationOptions.isNotEmpty ? locationOptions : null,
      typeOptions: categoryLabels.isNotEmpty ? categoryLabels : null,
      includeLocalizacao: representative.locationQuestion != null
          ? true
          : fallback.includeLocalizacao,
      domainLabel: representative.expectedDomain ?? fallback.domainLabel,
      assignmentGroupLabel:
          _deriveAssignmentGroupLabel(representative, groupLabelIndex) ??
          fallback.assignmentGroupLabel,
      runtimeFormStatus: representative.formName,
      uiSchemaSource: 'governed_v2_records',
      governedRecords: records,
    );
  }

  static String _cleanCategoryOptionLabel(GovernedOption option) {
    final label = option.label?.trim() ?? '';
    if (label.isNotEmpty) return label;
    final fullLabel = option.fullLabel?.trim() ?? '';
    if (fullLabel.isEmpty) return '';
    return fullLabel.split('>').last.trim();
  }

  static List<GovernedOption> _mergedOptions(
    Iterable<GovernedQuestion> questions,
  ) {
    final byId = <int, GovernedOption>{};
    for (final question in questions) {
      for (final option in question.options) {
        if (option.id <= 0) continue;
        byId.putIfAbsent(option.id, () => option);
      }
    }
    final options = byId.values.toList(growable: false)
      ..sort((a, b) {
        final fullA = a.fullLabel ?? a.label ?? '';
        final fullB = b.fullLabel ?? b.label ?? '';
        return normalizeServiceLabel(
          fullA,
        ).compareTo(normalizeServiceLabel(fullB));
      });
    return options;
  }

  static bool _recordVisibleForProfile(
    GovernedServiceRecord record,
    String normalizedProfile,
  ) {
    return record.profileVisibility.any(
      (profile) => normalizeServiceLabel(profile.name) == normalizedProfile,
    );
  }

  static ServiceCategory? _findStaticServiceByGovernedRecord(
    GovernedServiceRecord record,
  ) {
    final keys = {
      normalizeServiceLabel(record.serviceLabel),
      normalizeServiceLabel(record.serviceId),
    }..removeWhere((key) => key.isEmpty);
    for (final service in serviceCategories) {
      final serviceKeys = {
        normalizeServiceLabel(service.name),
        for (final alias in service.aliases) normalizeServiceLabel(alias),
      };
      if (serviceKeys.any(keys.contains)) return service;
    }
    return null;
  }

  static int _compareGovernedRecordsStable(
    GovernedServiceRecord a,
    GovernedServiceRecord b,
  ) {
    final formCompare = a.formId.compareTo(b.formId);
    if (formCompare != 0) return formCompare;
    return a.targetTicketId.compareTo(b.targetTicketId);
  }

  static GovernedServiceRecord _preferredGovernedRecord(
    List<GovernedServiceRecord> records,
  ) {
    final sorted = List<GovernedServiceRecord>.of(records)
      ..sort((a, b) {
        final aScore = _recordPreferenceScore(a);
        final bScore = _recordPreferenceScore(b);
        if (aScore != bScore) return aScore.compareTo(bScore);
        final formCompare = a.formId.compareTo(b.formId);
        if (formCompare != 0) return formCompare;
        return a.targetTicketId.compareTo(b.targetTicketId);
      });
    return sorted.first;
  }

  static int _recordPreferenceScore(GovernedServiceRecord record) {
    return record.audience == 'para_mim' ? 0 : 10;
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
