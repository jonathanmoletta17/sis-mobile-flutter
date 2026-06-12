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
    final candidates = <TicketDomain>{};
    final category = normalizeGlpiText(categoryCompletename);

    if (category.startsWith('manutencao') ||
        category.contains('> manutencao')) {
      candidates.add(TicketDomain.maintenance);
    }
    if (category.startsWith('conservacao') ||
        category.contains('> conservacao')) {
      candidates.add(TicketDomain.conservation);
    }

    final assignedIds = assignedGroups.map((group) => group.id).toSet();
    if (assignedIds.contains(maintenanceGroupId)) {
      candidates.add(TicketDomain.maintenance);
    }
    if (assignedIds.contains(conservationGroupId)) {
      candidates.add(TicketDomain.conservation);
    }

    final technicalCandidates = candidates
        .where((candidate) => candidate.isTechnicalExecution)
        .toSet();
    if (technicalCandidates.length > 1) return TicketDomain.unknown;
    if (technicalCandidates.length == 1) return technicalCandidates.single;

    final observerIds = observerGroups.map((group) => group.id).toSet();
    if (observerIds.contains(ggConservationGroupId)) {
      return TicketDomain.ggConservationObserver;
    }

    if (category.startsWith('dtic') || category.contains('informatica')) {
      return TicketDomain.dtic;
    }

    return TicketDomain.unknown;
  }
}
