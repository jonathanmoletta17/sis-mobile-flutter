import 'glpi_identity.dart';
import 'glpi_group_semantics.dart';

enum TicketDomain {
  maintenance,
  conservation,
  ggConservationObserver,
  dtic,
  // Ticket atribuído a ambas as equipes técnicas (CC-MANUTENCAO + CC-CONSERVACÃO)
  // simultaneamente — formulário "Múltiplas Demandas". Cada técnico vê na sua fila.
  multiDomain,
  unknown,
}

extension TicketDomainSemantics on TicketDomain {
  String get label => switch (this) {
    TicketDomain.maintenance => 'Manutenção',
    TicketDomain.conservation => 'Conservação',
    TicketDomain.ggConservationObserver => 'GG Conservação',
    TicketDomain.dtic => 'DTIC',
    TicketDomain.multiDomain => 'Múltiplas equipes',
    TicketDomain.unknown => 'Domínio desconhecido',
  };

  bool get isTechnicalExecution => switch (this) {
    TicketDomain.maintenance ||
    TicketDomain.conservation ||
    TicketDomain.multiDomain => true,
    _ => false,
  };
}

class TicketDomainResolver {
  static TicketDomain resolve({
    String? categoryCompletename,
    List<GlpiGroupRef> assignedGroups = const [],
    List<GlpiGroupRef> observerGroups = const [],
  }) {
    final category = normalizeGlpiText(categoryCompletename);

    final categoryCandidates = <TicketDomain>{};
    if (category.startsWith('manutencao') ||
        category.contains('> manutencao')) {
      categoryCandidates.add(TicketDomain.maintenance);
    }
    if (category.startsWith('conservacao') ||
        category.contains('> conservacao')) {
      categoryCandidates.add(TicketDomain.conservation);
    }

    final groupCandidates = <TicketDomain>{};

    // Classificação por nome de grupo vindo do GLPI. IDs variam por instância e
    // não são regra de domínio.
    for (final group in assignedGroups) {
      switch (GlpiGroupSemantics.classify(group)) {
        case GlpiGroupSemantic.maintenance:
          groupCandidates.add(TicketDomain.maintenance);
          break;
        case GlpiGroupSemantic.conservation:
          groupCandidates.add(TicketDomain.conservation);
          break;
        case GlpiGroupSemantic.ggConservation:
        case GlpiGroupSemantic.unknown:
          break;
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
    if (technicalCandidates.length > 1) {
      // Distingue dois casos diferentes de ambiguidade:
      // • multiDomain: AMBOS os grupos técnicos (CC-MANUTENCAO + CC-CONSERVACÃO)
      //   estão atribuídos simultaneamente, sem categoria que disambigue. É o padrão
      //   do formulário "Múltiplas Demandas" — fluxo validado nos históricos.
      // • unknown: categoria aponta para um domínio, grupo aponta para outro. É
      //   inconsistência de dados no GLPI; fica em Fila Operacional para triagem.
      final groupsAmbiguous = technicalGroupCandidates.length > 1;
      final noDisambiguatingCategory = technicalCategoryCandidates.isEmpty;
      if (groupsAmbiguous && noDisambiguatingCategory) {
        return TicketDomain.multiDomain;
      }
      return TicketDomain.unknown;
    }
    if (technicalCandidates.length == 1) return technicalCandidates.single;

    for (final group in observerGroups) {
      if (GlpiGroupSemantics.isGgConservation(group)) {
        return TicketDomain.ggConservationObserver;
      }
    }

    if (category.startsWith('dtic') || category.contains('informatica')) {
      return TicketDomain.dtic;
    }

    return TicketDomain.unknown;
  }
}
