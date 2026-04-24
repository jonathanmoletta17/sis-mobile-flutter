import 'package:flutter_test/flutter_test.dart';
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

  test('ticket offline preserva contexto de entidade', () {
    final ticket = GlpiTicket(
      serviceName: 'Carregadores',
      atendimentoPara: 'Para mim',
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
  });
}
