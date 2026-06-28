import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_identity.dart';
import 'package:sis_mobile_flutter/models/ticket_domain.dart';

import 'fixtures/sis_instance_groups.dart';

void main() {
  group('TicketDomainResolver', () {
    test(
      'infers maintenance and conservation from root category or assignment groups',
      () {
        expect(
          TicketDomainResolver.resolve(
            categoryCompletename: 'Manutenção > Elétrica',
          ),
          TicketDomain.maintenance,
        );
        expect(
          TicketDomainResolver.resolve(
            categoryCompletename: 'Conservação > Limpeza',
          ),
          TicketDomain.conservation,
        );
        expect(
          TicketDomainResolver.resolve(
            assignedGroups: [
              GlpiGroupRef(id: sisMaintenanceGroupId, name: 'CC-MANUTENCAO', isAssign: true),
            ],
          ),
          TicketDomain.maintenance,
        );
        expect(
          TicketDomainResolver.resolve(
            assignedGroups: [
              GlpiGroupRef(id: sisConservationGroupId, name: 'CC-CONSERVACÃO', isAssign: true),
            ],
          ),
          TicketDomain.conservation,
        );
      },
    );

    test(
      'treats GG-CONSERVACAO as observer domain, not technical execution',
      () {
        final domain = TicketDomainResolver.resolve(
          observerGroups: [
            GlpiGroupRef(id: sisGgConservationGroupId, name: 'GG-CONSERVACAO', isAssign: false),
          ],
        );

        expect(domain, TicketDomain.ggConservationObserver);
        expect(domain.isTechnicalExecution, isFalse);
      },
    );

    test('returns unknown when category and assignment group conflict', () {
      final domain = TicketDomainResolver.resolve(
        categoryCompletename: 'Manutenção > Elétrica',
        assignedGroups: [
          GlpiGroupRef(id: sisConservationGroupId, name: 'CC-CONSERVACÃO', isAssign: true),
        ],
      );

      expect(domain, TicketDomain.unknown);
    });
  });
}
