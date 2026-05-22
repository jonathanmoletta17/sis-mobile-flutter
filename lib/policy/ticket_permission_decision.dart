class TicketPermissionDecision {
  const TicketPermissionDecision({
    required this.canView,
    required this.canOpenConversation,
    required this.canSendFollowup,
    required this.canAttachFile,
    required this.canAssignToSelf,
    required this.canChangeStatus,
    required this.canProposeSolution,
    required this.canValidateSolution,
    required this.canViewTechnicalQueue,
    required this.canViewGgSharedQueue,
    this.reasons = const [],
    this.warnings = const [],
    this.riskLevel = 'baixo',
  });

  final bool canView;
  final bool canOpenConversation;
  final bool canSendFollowup;
  final bool canAttachFile;
  final bool canAssignToSelf;
  final bool canChangeStatus;
  final bool canProposeSolution;
  final bool canValidateSolution;
  final bool canViewTechnicalQueue;
  final bool canViewGgSharedQueue;
  final List<String> reasons;
  final List<String> warnings;
  final String riskLevel;
}
