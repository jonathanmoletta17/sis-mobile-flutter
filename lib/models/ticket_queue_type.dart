enum TicketQueueType {
  requestedByMe,
  assignedToMe,
  maintenanceQueue,
  conservationQueue,
  ggConservationShared,
  pendingValidation,
  supervision,
  allAdmin,
}

extension TicketQueueTypeLabel on TicketQueueType {
  String get label => switch (this) {
        TicketQueueType.requestedByMe => 'Meus solicitados',
        TicketQueueType.assignedToMe => 'Atribuídos a mim',
        TicketQueueType.maintenanceQueue => 'Fila Manutenção',
        TicketQueueType.conservationQueue => 'Fila Conservação',
        TicketQueueType.ggConservationShared => 'Demandas GG Conservação',
        TicketQueueType.pendingValidation => 'Pendentes de validação',
        TicketQueueType.supervision => 'Supervisão',
        TicketQueueType.allAdmin => 'Administração',
      };
}
