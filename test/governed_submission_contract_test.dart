import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/catalog/governed_entity_resolver.dart';
import 'package:sis_mobile_flutter/catalog/governed_service_catalog.dart';
import 'package:sis_mobile_flutter/catalog/governed_submission_contract.dart';

void main() {
  GovernedServiceRecord record({
    required String id,
    required String profile,
    required String audience,
    required String mode,
    int formId = 1,
    int targetTicketId = 1,
    int? destinationValue,
    bool requiresSpecializedFlow = false,
    List<GovernedActor> actors = const [],
    List<GovernedOption> categoryOptions = const [],
    List<GovernedOption> locationOptions = const [],
  }) {
    return GovernedServiceRecord(
      catalogRecordId: id,
      serviceId: 'ar-condicionado',
      serviceLabel: 'Ar-Condicionado',
      profileVisibility: [GovernedProfile(name: profile)],
      formId: formId,
      targetTicketId: targetTicketId,
      requiresSpecializedFlow: requiresSpecializedFlow,
      actors: actors,
      audience: audience,
      destinationEntityMode: mode,
      destinationEntityValue: destinationValue,
      categoryQuestion: categoryOptions.isEmpty
          ? null
          : GovernedQuestion(id: 10, required: true, options: categoryOptions),
      locationQuestion: locationOptions.isEmpty
          ? null
          : GovernedQuestion(id: 20, required: true, options: locationOptions),
      expectedBaseTaskTemplates: const [],
      readbackContract: const [],
    );
  }

  group('GovernedSubmissionResolver', () {
    test('consolida Solicitante para_mim com entidade do requester', () {
      final resolved = GovernedSubmissionResolver.resolve(
        GovernedSubmissionInput(
          records: [
            record(
              id: 'solicitante:para-mim',
              profile: 'Solicitante',
              audience: 'para_mim',
              mode: 'requester_context_para_mim',
            ),
          ],
          profileName: 'Solicitante',
          audience: GovernedTicketAudience.paraMim,
          entityContext: const GovernedEntityContext(
            selectedTicketEntityId: 24,
            activeEntityId: 58,
          ),
        ),
      );

      expect(resolved.ok, isTrue);
      expect(resolved.contract?.record.catalogRecordId, 'solicitante:para-mim');
      expect(resolved.contract?.entityId, 24);
      expect(resolved.contract?.readbackExpectation.expectedEntityId, 24);
    });

    test('bloqueia para_terceiro sem entidade do beneficiario', () {
      final resolved = GovernedSubmissionResolver.resolve(
        GovernedSubmissionInput(
          records: [
            record(
              id: 'solicitante:terceiro',
              profile: 'Solicitante',
              audience: 'para_terceiro',
              mode: 'third_party_question',
              destinationValue: 371,
            ),
          ],
          profileName: 'Solicitante',
          audience: GovernedTicketAudience.paraTerceiro,
          entityContext: const GovernedEntityContext(
            selectedTicketEntityId: 24,
            activeEntityId: 58,
          ),
        ),
      );

      expect(resolved.ok, isFalse);
      expect(resolved.blocker, contains('third_party_question'));
    });

    test(
      'bloqueia para_terceiro quando perfil nao tem contrato para outra pessoa',
      () {
        final resolved = GovernedSubmissionResolver.resolve(
          GovernedSubmissionInput(
            records: [
              record(
                id: 'solicitante:terceiro',
                profile: 'Solicitante',
                audience: 'para_terceiro',
                mode: 'third_party_question',
                destinationValue: 371,
              ),
              record(
                id: 'gg:para-mim-question-person',
                profile: 'Solicitante-GG-Conservação',
                audience: 'para_mim',
                mode: 'maintenance_context_para_mim',
                destinationValue: 58,
                actors: const [
                  GovernedActor(
                    role: 'observer',
                    type: 'question_person',
                    value: 371,
                  ),
                ],
              ),
            ],
            profileName: 'Solicitante-GG-Conservação',
            audience: GovernedTicketAudience.paraTerceiro,
            entityContext: const GovernedEntityContext(
              selectedTicketEntityId: 24,
              activeEntityId: 58,
              beneficiaryEntityId: 50,
            ),
          ),
        );

        expect(resolved.ok, isFalse);
        expect(resolved.blocker, contains('não permite atendimento'));
        expect(resolved.blocker, contains('para_terceiro'));
      },
    );

    test(
      'consolida para_terceiro quando beneficiaryEntityId foi preenchido',
      () {
        final resolved = GovernedSubmissionResolver.resolve(
          GovernedSubmissionInput(
            records: [
              record(
                id: 'solicitante:terceiro',
                profile: 'Solicitante',
                audience: 'para_terceiro',
                mode: 'third_party_question',
                destinationValue: 371,
              ),
            ],
            profileName: 'Solicitante',
            audience: GovernedTicketAudience.paraTerceiro,
            entityContext: const GovernedEntityContext(
              selectedTicketEntityId: 24,
              activeEntityId: 58,
              beneficiaryEntityId: 50,
            ),
          ),
        );

        expect(resolved.ok, isTrue, reason: resolved.blocker);
        expect(resolved.contract?.entityId, 50);
        expect(
          resolved.contract?.record.destinationEntityMode,
          'third_party_question',
        );
      },
    );

    test(
      'consolida Solicitante-GG-Conservacao como requester GG, nao tecnico',
      () {
        final resolved = GovernedSubmissionResolver.resolve(
          GovernedSubmissionInput(
            records: [
              record(
                id: 'gg:conservacao',
                profile: 'Solicitante-GG-Conservação',
                audience: 'para_mim',
                mode: 'maintenance_context_para_mim',
                destinationValue: 58,
              ),
            ],
            profileName: 'Solicitante-GG-Conservação',
            audience: GovernedTicketAudience.paraMim,
            entityContext: const GovernedEntityContext(
              selectedTicketEntityId: 24,
              activeEntityId: 99,
            ),
          ),
        );

        expect(resolved.ok, isTrue);
        expect(resolved.contract?.entityId, 58);
        expect(
          resolved.contract?.record.destinationEntityMode,
          'maintenance_context_para_mim',
        );
      },
    );

    test(
      'usa categoria para desambiguar targetticket em vez de menor id silencioso',
      () {
        final records = [
          record(
            id: 'target-eletrica',
            profile: 'Manutenção e Conservação',
            audience: 'para_mim',
            mode: 'maintenance_context_para_mim',
            formId: 30,
            targetTicketId: 100,
            destinationValue: 58,
            categoryOptions: const [GovernedOption(id: 501, label: 'Elétrica')],
          ),
          record(
            id: 'target-hidraulica',
            profile: 'Manutenção e Conservação',
            audience: 'para_mim',
            mode: 'maintenance_context_para_mim',
            formId: 30,
            targetTicketId: 101,
            destinationValue: 59,
            categoryOptions: const [
              GovernedOption(id: 502, label: 'Hidráulica'),
            ],
          ),
        ];

        final ambiguous = GovernedSubmissionResolver.resolve(
          GovernedSubmissionInput(
            records: records,
            profileName: 'Manutenção e Conservação',
            audience: GovernedTicketAudience.paraMim,
            entityContext: const GovernedEntityContext(activeEntityId: 58),
          ),
        );
        final selected = GovernedSubmissionResolver.resolve(
          GovernedSubmissionInput(
            records: records,
            profileName: 'Manutenção e Conservação',
            audience: GovernedTicketAudience.paraMim,
            selectedCategoryId: 502,
            entityContext: const GovernedEntityContext(activeEntityId: 58),
          ),
        );

        expect(ambiguous.ok, isFalse);
        expect(ambiguous.blocker, contains('ambíguo'));
        expect(selected.ok, isTrue);
        expect(selected.contract?.record.catalogRecordId, 'target-hidraulica');
        expect(selected.contract?.entityId, 59);
        expect(selected.contract?.categoryId, 502);
      },
    );

    test(
      'bloqueia selecao de categoria que nao corresponde a nenhuma opcao '
      '(fail-closed, nao mais fail-open)',
      () {
        final resolved = GovernedSubmissionResolver.resolve(
          GovernedSubmissionInput(
            records: [
              record(
                id: 'target-eletrica',
                profile: 'Manutenção e Conservação',
                audience: 'para_mim',
                mode: 'maintenance_context_para_mim',
                destinationValue: 58,
                categoryOptions: const [
                  GovernedOption(id: 501, label: 'Elétrica'),
                ],
              ),
            ],
            profileName: 'Manutenção e Conservação',
            audience: GovernedTicketAudience.paraMim,
            selectedCategoryId: 999,
            entityContext: const GovernedEntityContext(activeEntityId: 58),
          ),
        );

        expect(resolved.ok, isFalse);
        expect(
          resolved.blocker,
          contains('nenhum contrato governado compatível'),
        );
      },
    );

    test(
      'bloqueia formulário de checklist sem resolver como formulário comum',
      () {
        final resolved = GovernedSubmissionResolver.resolve(
          GovernedSubmissionInput(
            records: [
              record(
                id: 'checklist:hidraulico',
                profile: 'Super-Admin',
                audience: 'para_mim',
                mode: 'maintenance_context_para_mim',
                destinationValue: 58,
                requiresSpecializedFlow: true,
              ),
            ],
            profileName: 'Super-Admin',
            audience: GovernedTicketAudience.paraMim,
            entityContext: const GovernedEntityContext(activeEntityId: 58),
          ),
        );

        expect(resolved.ok, isFalse);
        expect(
          resolved.blocker,
          'formulário de checklist requer fluxo especializado; indisponível no app',
        );
      },
    );
  });
}
