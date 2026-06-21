import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/data/service_data.dart';
import 'package:sis_mobile_flutter/models/glpi_ticket.dart';
import 'package:sis_mobile_flutter/services/glpi_ticket_support.dart';

void main() {
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

  test('payload "para mim": requerente = usuario logado, sem grupos/assign', () {
    final payload = GlpiTicketSupport.buildCreateTicketPayload({
      'assunto': 'Teste',
      'descricao': 'Descricao',
      'serviceName': 'Carregadores',
      'localizacao': 'Local (Root 36): Armazem',
      'entities_id': 24,
      'loggedUserId': 1548,
    });

    final input = payload['input'] as Map<String, dynamic>;

    expect(input['_users_id_requester'], [1548]);
    expect(input.containsKey('_users_id_observer'), isFalse);
    // Perfil Solicitante nao pode atribuir grupo/tecnico: nunca emitir.
    expect(input.containsKey('_groups_id_assign'), isFalse);
    expect(input.containsKey('_groups_id_requester'), isFalse);
    expect(input.containsKey('_groups_id_observer'), isFalse);
    expect(input.containsKey('_users_id_assign'), isFalse);
  });

  test(
    'payload "para outra pessoa": beneficiario requester, autor observer, sem grupos',
    () {
      final payload = GlpiTicketSupport.buildCreateTicketPayload({
        'assunto': 'Teste',
        'descricao': 'Descricao',
        'serviceName': 'Carregadores',
        'localizacao': 'Local (Root 36): Armazem',
        'entities_id': 24,
        'beneficiaryUserId': 2373,
        'loggedUserId': 1548,
      });

      final input = payload['input'] as Map<String, dynamic>;

      expect(input['_users_id_requester'], [2373]);
      expect(input['_users_id_observer'], [1548]);
      expect(input.containsKey('_groups_id_assign'), isFalse);
      expect(input.containsKey('_groups_id_requester'), isFalse);
      expect(input.containsKey('_groups_id_observer'), isFalse);
      expect(input.containsKey('_users_id_assign'), isFalse);
    },
  );

  test(
    'regressao Henrique: Solicitante "para mim" nao envia _groups_id_assign '
    '(causa do ERROR_GLPI_ADD) e mantem gatilhos da RuleTicket',
    () {
      for (final serviceName in const ['Limpeza', 'Jardinagem', 'Marcenaria']) {
        final payload = GlpiTicketSupport.buildCreateTicketPayload({
          'assunto': 'Limpar agua do chao',
          'descricao': 'Teste',
          'serviceName': serviceName,
          'governedCategoryId': 7001,
          'governedLocationId': 7002,
          'governedEntityId': 81,
          'entities_id': 81,
          'loggedUserId': 2363, // henrique-missio
        });

        final input = payload['input'] as Map<String, dynamic>;

        // Nenhum campo de atribuicao/grupo: o GLPI atribui via RuleTicket.
        expect(input.containsKey('_groups_id_assign'), isFalse);
        expect(input.containsKey('_groups_id_requester'), isFalse);
        expect(input.containsKey('_groups_id_observer'), isFalse);
        expect(input.containsKey('_users_id_assign'), isFalse);
        // Gatilhos da RuleTicket presentes (categoria + entidade).
        expect(input['entities_id'], 81);
        expect(input['itilcategories_id'], 7001);
        // Requerente = proprio usuario logado.
        expect(input['_users_id_requester'], [2363]);
      }
    },
  );

  test('default urgency labels are human-readable and hide GLPI ids', () {
    expect(serviceCategories.first.urgencyOptions, [
      'Média (padrão)',
      'Baixa',
      'Alta',
    ]);
  });

  test('mapUrgency keeps GLPI 2/3/4 contract and supports legacy labels', () {
    expect(GlpiTicketSupport.mapUrgency('Muito baixa'), 1);
    expect(GlpiTicketSupport.mapUrgency('Baixa'), 2);
    expect(GlpiTicketSupport.mapUrgency('Média (padrão)'), 3);
    expect(GlpiTicketSupport.mapUrgency('Alta'), 4);
    expect(GlpiTicketSupport.mapUrgency('Muito alta'), 5);
    expect(GlpiTicketSupport.mapUrgency('Urgente'), 5);

    expect(GlpiTicketSupport.mapUrgency('1 - Baixa'), 2);
    expect(GlpiTicketSupport.mapUrgency('3 - Média (Padrão)'), 3);
    expect(GlpiTicketSupport.mapUrgency('5 - Alta'), 4);
    expect(GlpiTicketSupport.mapUrgency(5), 5);
  });
}
