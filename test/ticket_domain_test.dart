import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_identity.dart';
import 'package:sis_mobile_flutter/models/ticket_domain.dart';

void main() {
  group('TicketDomainResolver', () {
    test('infers maintenance and conservation from root category or assignment groups', () {
      expect(
        TicketDomainResolver.resolve(categoryCompletename: 'Manutenção > Elétrica'),
        TicketDomain.maintenance,
      );
      expect(
        TicketDomainResolver.resolve(categoryCompletename: 'Conservação > Limpeza'),
        TicketDomain.conservation,
      );
      expect(
        TicketDomainResolver.resolve(
          assignedGroups: const [GlpiGroupRef(id: 22, name: 'CC-MANUTENCAO', isAssign: true)],
        ),
        TicketDomain.maintenance,
      );
      expect(
        TicketDomainResolver.resolve(
          assignedGroups: const [GlpiGroupRef(id: 21, name: 'CC-CONSERVACÃO', isAssign: true)],
        ),
        TicketDomain.conservation,
      );
    });

    test('treats GG-CONSERVACAO as observer domain, not technical execution', () {
      final domain = TicketDomainResolver.resolve(
        observerGroups: const [GlpiGroupRef(id: 49, name: 'GG-CONSERVACAO', isAssign: false)],
      );

      expect(domain, TicketDomain.ggConservationObserver);
      expect(domain.isTechnicalExecution, isFalse);
    });

    test('returns unknown when category and assignment group conflict', () {
      final domain = TicketDomainResolver.resolve(
        categoryCompletename: 'Manutenção > Elétrica',
        assignedGroups: const [GlpiGroupRef(id: 21, name: 'CC-CONSERVACÃO', isAssign: true)],
      );

      expect(domain, TicketDomain.unknown);
    });
  });
}
