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

    // Cenários "Múltiplas Demandas": categoria genérica + domínio resolvido pelo
    // nome do grupo (field 8 da busca retorna completename, sem ID numérico).
    group('resolucao de dominio por nome de grupo (busca sem ID)', () {
      test('Multiplas Demandas + CC-MANUTENCAO -> fila manutencao', () {
        final queue = TicketQueueClassifier.primaryQueueForTicket(
          {
            'id': 9300,
            '_source': 'operational',
            'status': 1,
            'itilcategories_id': 'Múltiplas Demandas',
            // Sem assigned_group_id — apenas o nome vindo do field 8 da busca
            'assigned_group_name': 'CC-MANUTENÇÃO',
            'users_id_recipient': 2214,
          },
          role: OperationalRole.maintenanceTechnician,
          loggedUserId: 2039,
        );

        expect(queue, TicketQueueType.maintenanceQueue);
      });

      test('Multiplas Demandas + CC-CONSERVACAO -> fila conservacao', () {
        final queue = TicketQueueClassifier.primaryQueueForTicket(
          {
            'id': 9301,
            '_source': 'operational',
            'status': 1,
            'itilcategories_id': 'Múltiplas Demandas',
            'assigned_group_name': 'CC-CONSERVAÇÃO',
            'users_id_recipient': 2214,
          },
          role: OperationalRole.conservationTechnician,
          loggedUserId: 2039,
        );

        expect(queue, TicketQueueType.conservationQueue);
      });

      test('Multiplas Demandas + completename hierarquico -> manutencao', () {
        // GLPI pode retornar o completename com hierarquia: "SIS > CC-MANUTENÇÃO"
        final queue = TicketQueueClassifier.primaryQueueForTicket(
          {
            'id': 9302,
            '_source': 'operational',
            'status': 2,
            'itilcategories_id': 'Múltiplas Demandas',
            'assigned_group_name': 'SIS > CC-MANUTENÇÃO',
            'users_id_recipient': 2214,
          },
          role: OperationalRole.hybrid,
          loggedUserId: 2039,
        );

        expect(queue, TicketQueueType.maintenanceQueue);
      });

      test('sem grupo e categoria generica -> nao classifica (operational)', () {
        // Ticket sem grupo atribuído e sem categoria específica
        // deve retornar null (cai no bucket "Fila Operacional" / aguardando triagem)
        final queue = TicketQueueClassifier.primaryQueueForTicket(
          {
            'id': 9303,
            '_source': 'operational',
            'status': 1,
            'itilcategories_id': 'Múltiplas Demandas',
            'users_id_recipient': 2214,
          },
          role: OperationalRole.hybrid,
          loggedUserId: 2039,
        );

        expect(queue, isNull);
      });

      test('GG-CONSERVACAO no grupo observador por nome -> fila gg compartilhada', () {
        final queue = TicketQueueClassifier.primaryQueueForTicket(
          {
            'id': 9304,
            '_source': 'operational',
            'status': 1,
            'itilcategories_id': 'Múltiplas Demandas',
            // Sem observer_group_id — apenas o nome vindo do field 65
            'observer_group_name': 'GG-CONSERVAÇÃO',
            'users_id_recipient': 2214,
          },
          role: OperationalRole.ggConservationRequester,
          loggedUserId: 2214,
          sessionGroups: const [GlpiGroupRef(id: 49, name: 'GG-CONSERVAÇÃO')],
        );

        expect(queue, TicketQueueType.ggConservationShared);
      });
    });
  });
}
