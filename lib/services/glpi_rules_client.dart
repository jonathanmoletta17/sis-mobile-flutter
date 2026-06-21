/// Cliente para consumir `assets/glpi_rules_sis.json` (contrato v2).
///
/// O contrato é gerado read-only dos dumps da API GLPI (caminho enxuto), em
/// `glpi-arch-investigation/bin/build_app_contract.py`. Expõe, por perfil:
/// rótulos/terminalidade de status, transições permitidas, escopo de
/// visibilidade, os SearchOptions de "meus chamados" e o catálogo FormCreator.
///
/// Uso:
/// ```dart
/// final rules = GlpiRulesClient();
/// await rules.load();
/// final next = rules.allowedStatusTransitions(profileId: 6, current: 1);
/// final scope = rules.visibilityScope(profileId: 6); // ALL_IN_ENTITY
/// ```
library;

import 'dart:convert';
import 'package:flutter/services.dart';

/// Escopo de visibilidade de tickets derivado dos bits de leitura do perfil.
enum VisibilityScope { allInEntity, groupOrAssigned, ownOnly, none }

VisibilityScope _scopeFromString(String? s) {
  switch (s) {
    case 'ALL_IN_ENTITY':
      return VisibilityScope.allInEntity;
    case 'GROUP_OR_ASSIGNED':
      return VisibilityScope.groupOrAssigned;
    case 'OWN_ONLY':
      return VisibilityScope.ownOnly;
    default:
      return VisibilityScope.none;
  }
}

class GlpiRulesClient {
  static const _assetPath = 'assets/glpi_rules_sis.json';

  Map<String, dynamic> _data = const {};
  Map<String, dynamic> _statusLabels = const {};
  Map<String, dynamic> _transitionsByProfile = const {};
  Map<String, dynamic> _visibility = const {};
  Map<String, dynamic> _searchOptions = const {};
  Map<String, dynamic> _formCatalog = const {};

  bool get isLoaded => _data.isNotEmpty;

  Future<void> load() async {
    final jsonStr = await rootBundle.loadString(_assetPath);
    _data = (jsonDecode(jsonStr) as Map).cast<String, dynamic>();
    final status = (_data['status'] as Map?)?.cast<String, dynamic>() ?? const {};
    _statusLabels = (status['labels'] as Map?)?.cast<String, dynamic>() ?? const {};
    _transitionsByProfile =
        (status['transitions_by_profile'] as Map?)?.cast<String, dynamic>() ?? const {};
    _visibility = (_data['visibility'] as Map?)?.cast<String, dynamic>() ?? const {};
    _searchOptions = (_data['search_options'] as Map?)?.cast<String, dynamic>() ?? const {};
    _formCatalog = (_data['form_catalog'] as Map?)?.cast<String, dynamic>() ?? const {};
  }

  // ---- Status (L3) ----
  String statusLabel(int statusId) {
    final entry = _statusLabels['$statusId'];
    if (entry is Map && entry['label'] is String) return entry['label'] as String;
    return 'Status $statusId';
  }

  bool isStatusTerminal(int statusId) {
    final entry = _statusLabels['$statusId'];
    return entry is Map && entry['is_terminal'] == true;
  }

  /// Próximos status permitidos para o perfil a partir do status atual.
  /// Combina a denylist do perfil (L2) com o ciclo de vida (L3).
  List<int> allowedStatusTransitions({required int profileId, required int current}) {
    final prof = _transitionsByProfile['$profileId'];
    if (prof is! Map) return const [];
    final trans = prof['transitions'];
    if (trans is! Map) return const [];
    final dests = trans['$current'];
    if (dests is! List) return const [];
    return dests.map((e) => (e as num).toInt()).toList();
  }

  // ---- Visibilidade (L2) ----
  VisibilityScope visibilityScope({required int profileId}) {
    final v = _visibility['$profileId'];
    return _scopeFromString(v is Map ? v['scope'] as String? : null);
  }

  List<String> visibilityReadBits({required int profileId}) {
    final v = _visibility['$profileId'];
    if (v is Map && v['read_bits'] is List) {
      return List<String>.from(v['read_bits'] as List);
    }
    return const [];
  }

  // ---- SearchOptions: "meus chamados" ----
  /// Campos de ator (OR) para a busca de "meus chamados". Default seguro [4,22,66]
  /// caso o contrato não traga (requerente, autor/recipient, observador).
  List<int> get myTicketsActorFields {
    final crit = _searchOptions['my_tickets_criteria'];
    if (crit is Map && crit['fields_or'] is List) {
      return (crit['fields_or'] as List).map((e) => (e as num).toInt()).toList();
    }
    return const [4, 22, 66];
  }

  // ---- FormCreator ----
  Map<String, dynamic>? form(String formId) =>
      (_formCatalog[formId] as Map?)?.cast<String, dynamic>();

  Map<String, dynamic> get formCatalog => _formCatalog;

  // ---- Meta ----
  Map<String, dynamic> get meta =>
      (_data['_meta'] as Map?)?.cast<String, dynamic>() ?? const {};
}
