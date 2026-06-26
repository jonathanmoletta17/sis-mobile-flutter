import 'glpi_identity.dart';

enum TicketDomain {
  maintenance,
  conservation,
  ggConservationObserver,
  dtic,
  unknown,
}

extension TicketDomainSemantics on TicketDomain {
  String get label => switch (this) {
    TicketDomain.maintenance => 'Manutenção',
    TicketDomain.conservation => 'Conservação',
    TicketDomain.ggConservationObserver => 'GG Conservação',
    TicketDomain.dtic => 'DTIC',
    TicketDomain.unknown => 'Domínio desconhecido',
  };

  bool get isTechnicalExecution => switch (this) {
    TicketDomain.maintenance || TicketDomain.conservation => true,
    _ => false,
  };
}

class TicketDomainResolver {
  static const int conservationGroupId = 21;
  static const int maintenanceGroupId = 22;
  static const int ggConservationGroupId = 49;

  static TicketDomain resolve({
    String? categoryCompletename,
    List<GlpiGroupRef> assignedGroups = const [],
    List<GlpiGroupRef> observerGroups = const [],
  }) {
    final category = normalizeGlpiText(categoryCompletename);

    final categoryCandidates = <TicketDomain>{};
    if (category.startsWith('manutencao') || category.contains('> manutencao')) {
      categoryCandidates.add(TicketDomain.maintenance);
    }
    if (category.startsWith('conservacao') || category.contains('> conservacao')) {
      categoryCandidates.add(TicketDomain.conservation);
    }

    final groupCandidates = <TicketDomain>{};

    // Classificação por ID de grupo (precisa; vem do endpoint /Ticket/ID/Group_Ticket).
    final assignedIds = assignedGroups.map((group) => group.id).toSet();
    if (assignedIds.contains(maintenanceGroupId)) {
      groupCandidates.add(TicketDomain.maintenance);
    }
    if (assignedIds.contains(conservationGroupId)) {
      groupCandidates.add(TicketDomain.conservation);
    }

    // Classificação por nome de grupo (fallback; vem do field 8 da busca /search/Ticket
    // onde o GLPI devolve completename em vez de ID). id==0 é o sentinela nome-only.
    for (final group in assignedGroups) {
      if (group.id != 0) continue;
      final norm = normalizeGlpiText(group.name);
      if (norm.contains('manutencao')) groupCandidates.add(TicketDomain.maintenance);
      if (norm.contains('conservacao') && !norm.contains('gg')) {
        groupCandidates.add(TicketDomain.conservation);
      }
    }

    final technicalGroupCandidates = groupCandidates
        .where((c) => c.isTechnicalExecution)
        .toSet();
    final technicalCategoryCandidates = categoryCandidates
        .where((c) => c.isTechnicalExecution)
        .toSet();

    // Quando os grupos são ambíguos (2 domínios) e a categoria aponta para um
    // único domínio, a categoria desempata. Exemplo: ticket #8942 com categoria
    // "Manutenção > Pintura" e dois grupos (CC-MANUTENCAO + CC-CONSERVACÃO) →
    // deve ser Manutenção, não unknown.
    // Conflito real (categoria ≠ grupo único) permanece como unknown.
    if (technicalCategoryCandidates.length == 1 &&
        technicalGroupCandidates.length > 1) {
      return technicalCategoryCandidates.single;
    }

    final technicalCandidates = {
      ...technicalCategoryCandidates,
      ...technicalGroupCandidates,
    };
    if (technicalCandidates.length > 1) return TicketDomain.unknown;
    if (technicalCandidates.length == 1) return technicalCandidates.single;

    // Grupo observador por ID.
    final observerIds = observerGroups.map((group) => group.id).toSet();
    if (observerIds.contains(ggConservationGroupId)) {
      return TicketDomain.ggConservationObserver;
    }

    // Grupo observador por nome (fallback id==0).
    for (final group in observerGroups) {
      if (group.id != 0) continue;
      final norm = normalizeGlpiText(group.name);
      if (norm.contains('gg') && norm.contains('conservacao')) {
        return TicketDomain.ggConservationObserver;
      }
    }

    if (category.startsWith('dtic') || category.contains('informatica')) {
      return TicketDomain.dtic;
    }

    return TicketDomain.unknown;
  }
}
