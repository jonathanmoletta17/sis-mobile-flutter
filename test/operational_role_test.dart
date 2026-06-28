import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_identity.dart';
import 'package:sis_mobile_flutter/models/operational_role.dart';

void main() {
  group('OperationalRoleResolver', () {
    const nonSisConservationGroupId = 10021;
    const nonSisMaintenanceGroupId = 10022;
    const nonSisGgConservationGroupId = 10049;

    test('classifies standard requester without technical groups', () {
      final role = OperationalRoleResolver.resolve(
        activeProfile: const GlpiProfileRef(id: 9, name: 'Solicitante'),
        groups: const [],
      );

      expect(role, OperationalRole.standardRequester);
      expect(role.isRequesterCapable, isTrue);
      expect(role.isTechnicianCapable, isFalse);
    });

    test(
      'classifies GG conservation requester as collaborative visibility, not execution',
      () {
        final role = OperationalRoleResolver.resolve(
          activeProfile: const GlpiProfileRef(
            id: 12,
            name: 'Solicitante-GG-Conservação',
          ),
          groups: const [
            GlpiGroupRef(
              id: nonSisGgConservationGroupId,
              name: 'GG-CONSERVACAO',
              isAssign: false,
            ),
          ],
        );

        expect(role, OperationalRole.ggConservationRequester);
        expect(role.isRequesterCapable, isTrue);
        expect(role.isTechnicianCapable, isFalse);
        expect(role.canUseTechnicalQueues, isFalse);
      },
    );

    test(
      'classifies technical domains by assignment groups, not profile substring alone',
      () {
        final profile = const GlpiProfileRef(
          id: 11,
          name: 'Manutenção e Conservação',
        );

        expect(
          OperationalRoleResolver.resolve(
            activeProfile: profile,
            groups: const [
              GlpiGroupRef(
                id: nonSisConservationGroupId,
                name: 'CC-CONSERVACÃO',
                isAssign: true,
              ),
            ],
          ),
          OperationalRole.conservationTechnician,
        );
        expect(
          OperationalRoleResolver.resolve(
            activeProfile: profile,
            groups: const [
              GlpiGroupRef(
                id: nonSisMaintenanceGroupId,
                name: 'CC-MANUTENCAO',
                isAssign: true,
              ),
            ],
          ),
          OperationalRole.maintenanceTechnician,
        );
        expect(
          OperationalRoleResolver.resolve(
            activeProfile: profile,
            groups: const [],
          ),
          OperationalRole.ineligible,
        );
      },
    );

    test('classifies admin and hybrid users explicitly', () {
      expect(
        OperationalRoleResolver.resolve(
          activeProfile: const GlpiProfileRef(id: 4, name: 'Super-Admin'),
          groups: const [],
        ),
        OperationalRole.admin,
      );
      expect(
        OperationalRoleResolver.resolve(
          activeProfile: const GlpiProfileRef(
            id: 11,
            name: 'Manutenção e Conservação',
          ),
          groups: const [
            GlpiGroupRef(
              id: nonSisConservationGroupId,
              name: 'CC-CONSERVACÃO',
              isAssign: true,
            ),
            GlpiGroupRef(
              id: nonSisMaintenanceGroupId,
              name: 'CC-MANUTENCAO',
              isAssign: true,
            ),
          ],
        ),
        OperationalRole.hybrid,
      );
    });

    test('does not classify technical role from numeric group id alone', () {
      final role = OperationalRoleResolver.resolve(
        activeProfile: const GlpiProfileRef(
          id: 11,
          name: 'Manutenção e Conservação',
        ),
        groups: const [GlpiGroupRef(id: 22, name: '', isAssign: true)],
      );

      expect(role, OperationalRole.ineligible);
    });
  });
}
