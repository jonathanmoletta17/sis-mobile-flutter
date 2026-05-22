import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/ticket_message.dart';

void main() {
  group('TicketMessage identity', () {
    test('keeps solution author user id for approval policy', () {
      final message = TicketMessage.fromSolutionMap({
        'id': 51,
        'items_id': 8595,
        'content': 'Executado ajuste.',
        'users_id': {
          'id': 2039,
          'name': 'jonathan-moletta',
          'firstname': 'Jonathan',
          'realname': 'Moletta',
        },
        'status': 2,
        'date_creation': '2026-04-28 10:30:00',
      });

      expect(message.senderUserId, '2039');
      expect(message.sender, 'Jonathan Moletta');
    });

    test(
      'uses non-identifying fallback when followup author is a numeric id',
      () {
        final message = TicketMessage.fromMap({
          'id': 52,
          'tickets_id': 8595,
          'content': 'Acompanhamento registrado.',
          'users_id': '2039',
          'date_creation': '2026-04-28 10:31:00',
        });

        expect(message.senderUserId, '2039');
        expect(message.sender, 'Usuário não identificado');
      },
    );

    test(
      'uses non-identifying fallback when document uploader is a numeric id',
      () {
        final message = TicketMessage.fromDocumentMap({
          'id': 88,
          'items_id': 8595,
          'name': 'foto.jpg',
          'users_id': '2039',
          'date_creation': '2026-04-28 10:32:00',
        });

        expect(message.sender, 'Usuário não identificado');
      },
    );

    test('uses hydrated document uploader name and preserves user id', () {
      final message = TicketMessage.fromDocumentMap({
        'id': 89,
        'items_id': 8595,
        'name': 'foto.jpg',
        'users_id': '2039',
        'uploader_id': '2039',
        'uploader_name': 'Jonathan Nascimento Moletta',
        'date_creation': '2026-04-28 10:32:00',
      });

      expect(message.senderUserId, '2039');
      expect(message.sender, 'Jonathan Nascimento Moletta');
    });

    test('uses technician fallback when solution author is numeric', () {
      final message = TicketMessage.fromSolutionMap({
        'id': 53,
        'items_id': 8595,
        'content': 'Solução registrada.',
        'users_id': 2039,
        'status': 2,
        'date_creation': '2026-04-28 10:33:00',
      });

      expect(message.senderUserId, '2039');
      expect(message.sender, 'Técnico não identificado');
    });

    test('uses technician fallback when solution author map lacks names', () {
      final message = TicketMessage.fromSolutionMap({
        'id': 54,
        'items_id': 8595,
        'content': 'Solução sem nome expandido.',
        'users_id': {'id': 2039},
        'status': 2,
        'date_creation': '2026-04-28 10:34:00',
      });

      expect(message.senderUserId, '2039');
      expect(message.sender, 'Técnico não identificado');
    });
  });
}
