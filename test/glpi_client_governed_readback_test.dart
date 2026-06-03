import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/catalog/governed_service_catalog.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';

void main() {
  const expectation = GovernedReadbackExpectation(
    expectedGroupLabel: 'CC-MANUTENCAO',
    expectedDomain: 'Manutenção',
    expectedTaskTemplateLabels: ['EQUIPE EXECUTORA', 'MATERIAIS UTILIZADOS'],
    attachmentProofRoute: 'POST /Ticket/{ticket_id}/Document',
    readbackContract: [
      'GET/SEARCH Ticket',
      'GET TicketTask',
      'GET Document_Item',
    ],
  );

  test(
    'client validates governed read-back after ticket creation evidence',
    () async {
      final client = _ReadbackGlpiClient(
        ticket: {
          'id': '9157',
          'assigned_group_name': 'CC-MANUTENCAO',
          'itilcategories_id': 'Manutenção > Pintura > Outros',
        },
        tasks: const ['EQUIPE EXECUTORA', 'MATERIAIS UTILIZADOS'],
        documents: const {'222'},
      );

      final result = await client.validateGovernedTicketReadback(
        ticketId: '9157',
        sessionToken: 'fake-session-token',
        expectation: expectation,
      );

      expect(result['governed_readback_ok'], isTrue);
      expect(result['governed_readback_failures'], isEmpty);
      expect(client.getTicketByIdCalls, 1);
      expect(client.getTicketTaskLabelsCalls, 1);
      expect(client.getTicketDocumentIdsCalls, 1);
    },
  );

  test('client returns explicit governed read-back drift', () async {
    final client = _ReadbackGlpiClient(
      ticket: {
        'id': '9158',
        'assigned_group_name': 'CC-CONSERVACAO',
        'itilcategories_id': 'Conservação > Pintura',
      },
      tasks: const ['EQUIPE EXECUTORA'],
      documents: const {},
    );

    final result = await client.validateGovernedTicketReadback(
      ticketId: '9158',
      sessionToken: 'fake-session-token',
      expectation: expectation,
    );

    expect(result['governed_readback_ok'], isFalse);
    expect(
      result['governed_readback_failures'],
      contains('Grupo esperado não confirmado no read-back: CC-MANUTENCAO'),
    );
    expect(
      result['governed_readback_failures'],
      contains('Domínio esperado não confirmado no read-back: Manutenção'),
    );
    expect(
      result['governed_readback_failures'],
      contains(
        'Tarefa esperada não confirmada no read-back: MATERIAIS UTILIZADOS',
      ),
    );
    expect(
      result['governed_readback_failures'],
      contains('Anexo não confirmado por Document_Item no read-back'),
    );
  });

  test(
    'client does not require Document_Item when the created ticket had no attachment',
    () async {
      final client = _ReadbackGlpiClient(
        ticket: {
          'id': '9159',
          'assigned_group_name': 'CC-MANUTENCAO',
          'itilcategories_id': 'Manutenção > Pintura > Outros',
        },
        tasks: const ['EQUIPE EXECUTORA', 'MATERIAIS UTILIZADOS'],
        documents: const {},
      );

      final result = await client.validateGovernedTicketReadback(
        ticketId: '9159',
        sessionToken: 'fake-session-token',
        expectation: expectation,
        requireAttachmentProof: false,
      );

      expect(result['governed_readback_ok'], isTrue);
      expect(result['governed_readback_failures'], isEmpty);
    },
  );

  test(
    'client reports partial read-back failure instead of hiding it',
    () async {
      final client = _ReadbackGlpiClient(
        ticket: {
          'id': '9160',
          'assigned_group_name': 'CC-MANUTENCAO',
          'itilcategories_id': 'Manutenção > Pintura > Outros',
        },
        tasks: const ['EQUIPE EXECUTORA', 'MATERIAIS UTILIZADOS'],
        documents: const {'333'},
        failTasks: true,
      );

      final result = await client.validateGovernedTicketReadback(
        ticketId: '9160',
        sessionToken: 'fake-session-token',
        expectation: expectation,
      );

      expect(result['governed_readback_ok'], isFalse);
      expect(
        result['governed_readback_failures'].single,
        contains('Read-back governado não executado'),
      );
      expect(
        result['governed_readback_failures'].single,
        contains('ERROR_RIGHT_MISSING'),
      );
    },
  );
}

class _ReadbackGlpiClient extends GlpiClient {
  _ReadbackGlpiClient({
    required this.ticket,
    required this.tasks,
    required this.documents,
    this.failTasks = false,
  });

  final Map<String, dynamic> ticket;
  final List<String> tasks;
  final Set<String> documents;
  final bool failTasks;
  int getTicketByIdCalls = 0;
  int getTicketTaskLabelsCalls = 0;
  int getTicketDocumentIdsCalls = 0;

  @override
  Future<Map<String, dynamic>> getTicketById(
    String ticketId,
    String sessionToken,
  ) async {
    getTicketByIdCalls += 1;
    return Map<String, dynamic>.from(ticket);
  }

  @override
  Future<List<String>> getTicketTaskLabels(
    String ticketId,
    String sessionToken,
  ) async {
    getTicketTaskLabelsCalls += 1;
    if (failTasks) {
      throw Exception('ERROR_RIGHT_MISSING ao listar TicketTask');
    }
    return List<String>.from(tasks);
  }

  @override
  Future<Set<String>> getTicketDocumentIds(
    String ticketId,
    String sessionToken,
  ) async {
    getTicketDocumentIdsCalls += 1;
    return Set<String>.from(documents);
  }
}
