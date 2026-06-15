import '../models/glpi_identity.dart';
import '../models/glpi_status.dart';
import '../models/operational_role.dart';
import '../models/ticket_domain.dart';
import 'ticket_permission_decision.dart';

class PermissionService {
  // NOTA (2026-06-14): Regras de permissão são institucionais e raramente mudam.
  // Se precisar alterar (ex: quem pode validar solução, quem pode mudar status),
  // edite as condições abaixo + execute `flutter test` + redistribua APK.
  // Decisão: MANTER HARDCODED (não implementar dinâmico) por pragmatismo/MVP.
  static const int ggConservationGroupId = 49;

  static TicketPermissionDecision evaluate({
    required OperationalRole role,
    required TicketDomain ticketDomain,
    required int? loggedUserId,
    required int? requesterUserId,
    required dynamic status,
    List<GlpiGroupRef> assignedGroups = const [],
    List<GlpiGroupRef> observerGroups = const [],
  }) {
    final reasons = <String>[];
    final warnings = <String>[];
    final isRequester =
        loggedUserId != null &&
        requesterUserId != null &&
        loggedUserId == requesterUserId;
    final isOpen = _isOpenForInteraction(status);
    final isClosed = _normalizeStatus(status) == 6;

    if (isRequester) reasons.add('Usuário é requerente do ticket');

    final isGgShared =
        role == OperationalRole.ggConservationRequester &&
        ticketDomain == TicketDomain.ggConservationObserver &&
        observerGroups.any((group) => group.id == ggConservationGroupId);
    if (isGgShared) reasons.add('Ticket compartilhado com GG-CONSERVACAO');

    final technicalDomainAllowed = _roleCoversDomain(role, ticketDomain);
    if (role.isTechnicianCapable &&
        !technicalDomainAllowed &&
        !role.isAdminCapable) {
      warnings.add('Papel técnico não cobre o domínio do ticket');
    }

    final canViewTechnicalQueue = role.isAdminCapable || technicalDomainAllowed;
    final canView =
        role.isAdminCapable ||
        isRequester ||
        isGgShared ||
        canViewTechnicalQueue;

    final requesterTechnicalBlocked = isRequester && role.isTechnicianCapable;
    if (requesterTechnicalBlocked) {
      warnings.add(
        'Requerente do ticket não recebe ações técnicas no próprio ticket',
      );
    }

    final canMutateCommon = canView && isOpen && !isClosed;
    final canUseTechnicalAction =
        canMutateCommon &&
        (role.isAdminCapable || technicalDomainAllowed) &&
        !requesterTechnicalBlocked;

    if (canView && reasons.isEmpty) {
      if (role.isAdminCapable) {
        reasons.add('Administrador com visibilidade ampla no mobile');
      } else if (technicalDomainAllowed) {
        reasons.add('Papel técnico cobre o domínio do ticket');
      }
    }

    return TicketPermissionDecision(
      canView: canView,
      canOpenConversation: canView,
      canSendFollowup: canMutateCommon,
      canAttachFile: canMutateCommon,
      canAssignToSelf: canUseTechnicalAction,
      canChangeStatus: canUseTechnicalAction,
      canProposeSolution: canUseTechnicalAction,
      canValidateSolution:
          isRequester && GlpiStatusMapper.canValidateSolution(status),
      canViewTechnicalQueue: canViewTechnicalQueue,
      canViewGgSharedQueue: isGgShared,
      reasons: reasons,
      warnings: warnings,
      riskLevel: warnings.isEmpty ? 'baixo' : 'médio',
    );
  }

  static bool _roleCoversDomain(OperationalRole role, TicketDomain domain) {
    return switch ((role, domain)) {
      (OperationalRole.maintenanceTechnician, TicketDomain.maintenance) => true,
      (OperationalRole.conservationTechnician, TicketDomain.conservation) =>
        true,
      (OperationalRole.hybrid, TicketDomain.maintenance) => true,
      (OperationalRole.hybrid, TicketDomain.conservation) => true,
      (OperationalRole.admin, _) => true,
      _ => false,
    };
  }

  static int? _normalizeStatus(dynamic status) {
    if (status == null) return null;
    if (status is int) return status;
    if (status is num) return status.toInt();
    final text = normalizeGlpiText(status.toString());
    final parsed = int.tryParse(text);
    if (parsed != null) return parsed;
    if (text.contains('novo')) return 1;
    if (text.contains('atendimento') || text.contains('atribuido')) return 2;
    if (text.contains('planejado')) return 3;
    if (text.contains('pendente')) return 4;
    if (text.contains('solucionado')) return 5;
    if (text.contains('fechado')) return 6;
    return null;
  }

  static bool _isOpenForInteraction(dynamic status) {
    final normalized = _normalizeStatus(status);
    return normalized == 1 ||
        normalized == 2 ||
        normalized == 3 ||
        normalized == 4;
  }
}
