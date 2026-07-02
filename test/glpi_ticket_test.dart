import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_ticket.dart';
import 'package:sis_mobile_flutter/services/glpi_ticket_support.dart';

class _NaoSerializavel {
  const _NaoSerializavel();
}

void main() {
  group('GlpiTicket.fromMap/toMap round-trip (fix P1)', () {
    test(
      'preserva campos governed* sem representação explícita na classe',
      () {
        final original = {
          'serviceName': 'Hidráulico',
          'atendimentoPara': 'Para mim',
          'localizacao': 'Sala 1',
          'telefone': '',
          'tipo': 'Manutenção',
          'assunto': 'Vazamento',
          'descricao': 'Descricao',
          'entities_id': 58,
          'governedCategoryId': 151,
          'governedLocationId': 12,
          'governedFormId': 40,
          'governedTargetTicketId': 341,
          'governedCatalogRecordId': 9001,
          'governedAudience': 'para_mim',
          'governedEntityMode': 'fixed_or_direct',
          'governedEntityCode': 7,
          'governedEntityValue': 58,
        };

        final ticket = GlpiTicket.fromMap(original);
        final roundTripped = ticket.toMap();

        expect(roundTripped['governedCategoryId'], 151);
        expect(roundTripped['governedLocationId'], 12);
        expect(roundTripped['governedFormId'], 40);
        expect(roundTripped['governedTargetTicketId'], 341);
        expect(roundTripped['governedCatalogRecordId'], 9001);
        expect(roundTripped['governedAudience'], 'para_mim');
        expect(roundTripped['governedEntityMode'], 'fixed_or_direct');
      },
    );

    test(
      'resync (buildCreateTicketPayload) usa a categoria/localização governadas, '
      'não a busca legada por nome de serviço',
      () {
        final original = {
          'serviceName': 'Hidráulico',
          'atendimentoPara': 'Para mim',
          'localizacao': 'Sala 1',
          'telefone': '',
          'tipo': 'Manutenção',
          'assunto': 'Vazamento',
          'descricao': 'Descricao',
          'entities_id': 58,
          'governedCategoryId': 151,
          'governedLocationId': 12,
        };

        // Simula o ciclo completo: falha online -> GlpiTicket.fromMap salva
        // offline -> synchronizeTickets reconstroi via ticket.toMap().
        final ticket = GlpiTicket.fromMap(original);
        final resyncPayload = GlpiTicketSupport.buildCreateTicketPayload(
          ticket.toMap(),
        );

        expect(resyncPayload['input']['itilcategories_id'], 151);
        expect(resyncPayload['input']['locations_id'], isNotNull);
      },
    );

    test(
      'campos governed* ausentes no formData original não aparecem no toMap',
      () {
        final ticket = GlpiTicket.fromMap({
          'serviceName': 'Ar-Condicionado',
          'atendimentoPara': 'Para mim',
          'localizacao': 'Sala 2',
          'telefone': '',
          'tipo': 'Manutenção',
          'assunto': 'Não gela',
          'descricao': 'Descricao',
        });
        final map = ticket.toMap();
        expect(map.containsKey('governedCategoryId'), isFalse);
        expect(map.containsKey('governedLocationId'), isFalse);
      },
    );

    test(
      'valores não-JSON-safe (instância de classe) são descartados sem lançar, '
      'e o resultado de toMap continua serializável em JSON',
      () {
        final ticket = GlpiTicket.fromMap({
          'serviceName': 'Hidráulico',
          'atendimentoPara': 'Para mim',
          'localizacao': 'Sala 1',
          'telefone': '',
          'tipo': 'Manutenção',
          'assunto': 'Vazamento',
          'descricao': 'Descricao',
          'governedCategoryId': 151,
          'governedContract': const _NaoSerializavel(),
        });

        final map = ticket.toMap();
        expect(map.containsKey('governedContract'), isFalse);
        expect(map['governedCategoryId'], 151);
        expect(() => jsonEncode(map), returnsNormally);
      },
    );

    test('campos explícitos existentes continuam funcionando (sem regressão)', () {
      final ticket = GlpiTicket.fromMap({
        'serviceName': 'Elevador',
        'atendimentoPara': 'Para outra Pessoa',
        'nomePessoa': 'Fulano',
        'localizacao': 'Torre A',
        'telefone': '5100000000',
        'tipo': 'Manutenção',
        'assunto': 'Assunto',
        'descricao': 'Descricao',
        'entities_id': 28,
        'entityName': 'Entidade X',
      });
      final map = ticket.toMap();
      expect(map['serviceName'], 'Elevador');
      expect(map['nomePessoa'], 'Fulano');
      expect(map['entities_id'], 28);
      expect(map['entityName'], 'Entidade X');
      expect(() => jsonEncode(map), returnsNormally);
    });
  });
}
