import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/catalog/governed_service_catalog.dart';
import 'package:sis_mobile_flutter/catalog/governed_submission_contract.dart';
import 'package:sis_mobile_flutter/models/glpi_ticket.dart';
import 'package:sis_mobile_flutter/services/glpi_ticket_support.dart';

void main() {
  GovernedSubmissionContract contractWithActors(List<GovernedActor> actors) {
    final record = GovernedServiceRecord(
      catalogRecordId: 'test:actors',
      serviceId: 'pintura',
      serviceLabel: 'Pintura',
      profileVisibility: const [GovernedProfile(name: 'Solicitante')],
      formId: 12,
      targetTicketId: 28,
      audience: 'para_terceiro',
      actors: actors,
      expectedBaseTaskTemplates: const [],
      readbackContract: const [],
    );
    return GovernedSubmissionContract(
      record: record,
      entityId: 50,
      readbackExpectation: record.toReadbackExpectation(expectedEntityId: 50),
    );
  }

  test('payload de criacao inclui entities_id quando presente', () {
    final payload = GlpiTicketSupport.buildCreateTicketPayload({
      'assunto': 'Teste',
      'descricao': 'Descricao',
      'serviceName': 'Carregadores',
      'localizacao': 'Local (Root 36): Armazem',
      'entities_id': 24,
    });

    final input = payload['input'] as Map<String, dynamic>;

    expect(input['entities_id'], 24);
    expect(input['itilcategories_id'], 55);
    expect(input['locations_id'], 36);
  });

  test(
    'payload aborta categoria desconhecida em vez de cair em Ar-Condicionado',
    () {
      expect(
        () => GlpiTicketSupport.buildCreateTicketPayload({
          'assunto': 'Teste',
          'descricao': 'Descricao',
          'serviceName': 'Categoria inexistente',
        }),
        throwsA(isA<ArgumentError>()),
      );
    },
  );

  test('payload uses governed location id from runtime option map', () {
    final payload = GlpiTicketSupport.buildCreateTicketPayload({
      'assunto': 'Teste',
      'descricao': 'Descricao',
      'serviceName': 'Carregadores',
      'localizacao': {'id': 7002, 'label': 'Casa Civil 1005 > 1° Andar'},
      'entities_id': 24,
    });

    final input = payload['input'] as Map<String, dynamic>;

    expect(input['locations_id'], 7002);
  });

  test('payload aborta localizacao desconhecida em vez de cair no root 1', () {
    expect(
      () => GlpiTicketSupport.buildCreateTicketPayload({
        'assunto': 'Teste',
        'descricao': 'Descricao',
        'serviceName': 'Carregadores',
        'localizacao': 'Almoxarifado sem id GLPI',
      }),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('payload usa entidade governada resolvida no pre-submit', () {
    final payload = GlpiTicketSupport.buildCreateTicketPayload({
      'assunto': 'Teste',
      'descricao': 'Descricao',
      'serviceName': 'Carregadores',
      'governedCategoryId': 7001,
      'governedLocationId': 7002,
      'governedEntityId': 58,
      'entities_id': 58,
    });

    final input = payload['input'] as Map<String, dynamic>;

    expect(input['entities_id'], 58);
    expect(input['itilcategories_id'], 7001);
    expect(input['locations_id'], 7002);
  });

  test('ticket offline preserva contexto de entidade', () {
    final ticket = GlpiTicket(
      serviceName: 'Carregadores',
      atendimentoPara: 'Para mim',
      beneficiaryUserId: 2373,
      beneficiaryUserName: 'Pessoa Teste',
      beneficiaryEntityId: 50,
      loggedUserId: 1548,
      governedActors: const [
        {'role': 'requester', 'type': 'question_person', 'value': 371},
      ],
      entitiesId: 24,
      entityName: 'Departamento de Manutencao',
      localizacao: 'Local (Root 36): Armazem',
      telefone: '51999999999',
      urgencia: 'Alta',
      tipo: 'Solicitacao',
      assunto: 'Teste offline',
      descricao: 'Descricao',
      anexoPath: 'C:/tmp/foto.jpg',
      anexoName: 'foto.jpg',
    );

    final restored = GlpiTicket.fromMap(ticket.toMap());

    expect(restored.entitiesId, 24);
    expect(restored.entityName, 'Departamento de Manutencao');
    expect(restored.localizacao, ticket.localizacao);
    expect(restored.beneficiaryUserId, 2373);
    expect(restored.beneficiaryEntityId, 50);
    expect(restored.loggedUserId, 1548);
    expect(restored.governedActors.single['type'], 'question_person');
  });

  test(
    'payload aplica atores Solicitante: terceiro requester e autor observer',
    () {
      final payload = GlpiTicketSupport.buildCreateTicketPayload({
        'assunto': 'Teste',
        'descricao': 'Descricao',
        'serviceName': 'Pintura',
        'beneficiaryUserId': 2373,
        'loggedUserId': 1548,
        'governedContract': contractWithActors(const [
          GovernedActor(role: 'requester', type: 'question_person', value: 371),
          GovernedActor(role: 'observer', type: 'author'),
        ]),
      });

      final input = payload['input'] as Map<String, dynamic>;

      expect(input['_users_id_requester'], [2373]);
      expect(input['_users_id_observer'], [1548]);
    },
  );

  test('payload aplica atores GG: terceiro observer e grupos do catalogo', () {
    final payload = GlpiTicketSupport.buildCreateTicketPayload({
      'assunto': 'Teste',
      'descricao': 'Descricao',
      'serviceName': 'Limpeza',
      'beneficiaryUserId': 2373,
      'loggedUserId': 1548,
      'governedContract': contractWithActors(const [
        GovernedActor(role: 'observer', type: 'question_person', value: 572),
        GovernedActor(role: 'requester', type: 'group', value: 49),
        GovernedActor(role: 'assigned', type: 'group', value: 21),
      ]),
    });

    final input = payload['input'] as Map<String, dynamic>;

    expect(input.containsKey('_users_id_requester'), isFalse);
    expect(input['_users_id_observer'], [2373]);
    expect(input['_groups_id_requester'], [49]);
    expect(input['_groups_id_assign'], [21]);
  });

  test(
    'payload Marcenaria/Pintura sem question_person nao promove terceiro a ator',
    () {
      final payload = GlpiTicketSupport.buildCreateTicketPayload({
        'assunto': 'Teste',
        'descricao': 'Descricao',
        'serviceName': 'Pintura',
        'beneficiaryUserId': 2373,
        'loggedUserId': 1548,
        'governedContract': contractWithActors(const [
          GovernedActor(role: 'requester', type: 'author'),
          GovernedActor(role: 'assigned', type: 'group', value: 22),
        ]),
      });

      final input = payload['input'] as Map<String, dynamic>;

      expect(input.containsKey('_users_id_requester'), isFalse);
      expect(input.containsKey('_users_id_observer'), isFalse);
      expect(input['_groups_id_assign'], [22]);
    },
  );
}
