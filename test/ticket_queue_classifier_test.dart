import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_identity.dart';
import 'package:sis_mobile_flutter/models/operational_role.dart';
import 'package:sis_mobile_flutter/models/ticket_queue_type.dart';
import 'package:sis_mobile_flutter/policy/ticket_queue_classifier.dart';

void main() {
  group('TicketQueueClassifier', () {
    test('classifica tickets operacionais por fila de dominio', () {
      final queue = TicketQueueClassifier.primaryQueueForTicket(
        {
          'id': 9276,
          '_source': 'operational',
          'status': 1,
          'itilcategories_id': 'Manutenção > Ar-Condicionado',
          'assigned_group_id': '22',
          'assigned_group_name': 'CC-MANUTENCAO',
          'users_id_recipient': 2214,
        },
        role: OperationalRole.hybrid,
        loggedUserId: 2039,
      );

      expect(queue, TicketQueueType.maintenanceQueue);
    });

    test('prioriza atribuidos a mim sobre fila ampla', () {
      final queue = TicketQueueClassifier.primaryQueueForTicket(
        {
          'id': 9278,
          '_source': 'operational',
          'status': 2,
          'itilcategories_id': 'Manutenção > Pintura',
          'assigned_group_id': '22',
          'assigned_group_name': 'CC-MANUTENCAO',
          'assignee_user_id': '2039',
          'users_id_recipient': 2214,
        },
        role: OperationalRole.hybrid,
        loggedUserId: 2039,
      );

      expect(queue, TicketQueueType.assignedToMe);
    });

    test('reconhece fila compartilhada GG por grupo observador', () {
      final queue = TicketQueueClassifier.primaryQueueForTicket(
        {
          'id': 9280,
          '_source': 'operational',
          'status': 2,
          'itilcategories_id': 'Projeto GG',
          'observer_group_id': '49',
          'observer_group_name': 'GG-CONSERVACAO',
          'users_id_recipient': 2214,
        },
        role: OperationalRole.ggConservationRequester,
        loggedUserId: 2039,
        sessionGroups: const [GlpiGroupRef(id: 49, name: 'GG-CONSERVACAO')],
      );

      expect(queue, TicketQueueType.ggConservationShared);
    });
  });
}
