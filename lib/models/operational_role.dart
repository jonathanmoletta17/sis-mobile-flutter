import 'glpi_identity.dart';
import 'glpi_group_semantics.dart';

enum OperationalRole {
  standardRequester,
  ggConservationRequester,
  conservationTechnician,
  maintenanceTechnician,
  supervisor,
  admin,
  hybrid,
  ineligible,
  unknown,
}

extension OperationalRoleSemantics on OperationalRole {
  String get label => switch (this) {
    OperationalRole.standardRequester => 'Solicitante padrão',
    OperationalRole.ggConservationRequester => 'Solicitante GG Conservação',
    OperationalRole.conservationTechnician => 'Técnico de Conservação',
    OperationalRole.maintenanceTechnician => 'Técnico de Manutenção',
    OperationalRole.supervisor => 'Supervisor',
    OperationalRole.admin => 'Administrador',
    OperationalRole.hybrid => 'Usuário híbrido',
    OperationalRole.ineligible => 'Configuração operacional incompleta',
    OperationalRole.unknown => 'Papel desconhecido',
  };

  bool get isRequesterCapable => switch (this) {
    OperationalRole.standardRequester ||
    OperationalRole.ggConservationRequester ||
    OperationalRole.hybrid ||
    OperationalRole.admin => true,
    _ => false,
  };

  bool get isTechnicianCapable => switch (this) {
    OperationalRole.conservationTechnician ||
    OperationalRole.maintenanceTechnician ||
    OperationalRole.hybrid ||
    OperationalRole.admin => true,
    _ => false,
  };

  bool get isAdminCapable => this == OperationalRole.admin;

  bool get requiresDomain => switch (this) {
    OperationalRole.conservationTechnician ||
    OperationalRole.maintenanceTechnician ||
    OperationalRole.hybrid => true,
    _ => false,
  };

  bool get canUseTechnicalQueues => isTechnicianCapable;
}

class OperationalRoleResolver {
  static OperationalRole resolve({
    required GlpiProfileRef? activeProfile,
    required List<GlpiGroupRef> groups,
  }) {
    final profileName = normalizeGlpiText(activeProfile?.name);
    final hasConservation = groups.any(GlpiGroupSemantics.isConservation);
    final hasMaintenance = groups.any(GlpiGroupSemantics.isMaintenance);
    final hasGgConservation = groups.any(GlpiGroupSemantics.isGgConservation);

    if (profileName.isEmpty) return OperationalRole.unknown;

    if (profileName == 'admin' || profileName.contains('super-admin')) {
      return OperationalRole.admin;
    }

    if (profileName.contains('supervisor')) {
      return OperationalRole.supervisor;
    }

    final hasTechnicalProfile =
        profileName == 'tecnico' ||
        profileName.contains('manutencao e conservacao') ||
        profileName.contains('supervisor');

    if (hasTechnicalProfile) {
      if (hasConservation && hasMaintenance) return OperationalRole.hybrid;
      if (hasConservation) return OperationalRole.conservationTechnician;
      if (hasMaintenance) return OperationalRole.maintenanceTechnician;
      return OperationalRole.ineligible;
    }

    if (profileName.contains('solicitante-gg-conservacao') ||
        (profileName.contains('solicitante') && hasGgConservation)) {
      return OperationalRole.ggConservationRequester;
    }

    if (profileName.contains('solicitante') ||
        profileName.contains('self-service')) {
      return OperationalRole.standardRequester;
    }

    return OperationalRole.unknown;
  }
}
