import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_identity.dart';
import 'package:sis_mobile_flutter/models/operational_role.dart';
import 'package:sis_mobile_flutter/models/ticket_domain.dart';
import 'package:sis_mobile_flutter/models/ticket_queue_type.dart';
import 'package:sis_mobile_flutter/policy/ticket_queue_filter.dart';

void main() {
  group('TicketQueueFilter', () {
    test('standard requester only receives requested-by-me queue', () {
      final queues = TicketQueueFilter.resolveQueues(
        role: OperationalRole.standardRequester,
        ticketDomain: TicketDomain.maintenance,
        loggedUserId: 10,
        requesterUserId: 10,
        status: 2,
      );

      expect(queues, [TicketQueueType.requestedByMe]);
    });

    test(
      'GG conservation requester receives shared GG queue without technical queue',
      () {
        final queues = TicketQueueFilter.resolveQueues(
          role: OperationalRole.ggConservationRequester,
          ticketDomain: TicketDomain.ggConservationObserver,
          loggedUserId: 20,
          requesterUserId: 99,
          observerGroups: const [GlpiGroupRef(id: 49, name: 'GG-CONSERVACAO')],
          status: 2,
        );

        expect(queues, contains(TicketQueueType.ggConservationShared));
        expect(queues, isNot(contains(TicketQueueType.conservationQueue)));
        expect(queues, isNot(contains(TicketQueueType.maintenanceQueue)));
      },
    );

    test('technical users receive queues by ticket domain', () {
      expect(
        TicketQueueFilter.resolveQueues(
          role: OperationalRole.conservationTechnician,
          ticketDomain: TicketDomain.conservation,
          loggedUserId: 30,
          requesterUserId: 99,
          status: 2,
        ),
        contains(TicketQueueType.conservationQueue),
      );
      expect(
        TicketQueueFilter.resolveQueues(
          role: OperationalRole.maintenanceTechnician,
          ticketDomain: TicketDomain.maintenance,
          loggedUserId: 31,
          requesterUserId: 99,
          status: 2,
        ),
        contains(TicketQueueType.maintenanceQueue),
      );
    });

    test(
      'hybrid user keeps maintenance and conservation queues separated by domain',
      () {
        final maintenance = TicketQueueFilter.resolveQueues(
          role: OperationalRole.hybrid,
          ticketDomain: TicketDomain.maintenance,
          loggedUserId: 40,
          requesterUserId: 99,
          status: 2,
        );
        final conservation = TicketQueueFilter.resolveQueues(
          role: OperationalRole.hybrid,
          ticketDomain: TicketDomain.conservation,
          loggedUserId: 40,
          requesterUserId: 99,
          status: 2,
        );

        expect(maintenance, contains(TicketQueueType.maintenanceQueue));
        expect(maintenance, isNot(contains(TicketQueueType.conservationQueue)));
        expect(conservation, contains(TicketQueueType.conservationQueue));
        expect(conservation, isNot(contains(TicketQueueType.maintenanceQueue)));
      },
    );
  });
}
