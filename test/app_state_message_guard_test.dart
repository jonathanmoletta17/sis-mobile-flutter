import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';

void main() {
  group('AppState.sendTicketMessageWithAttachments', () {
    test(
      'aborts before adding message when fresh ticket status is closed',
      () async {
        SharedPreferences.setMockInitialValues({});
        final api = _ClosedTicketGlpiClient();
        final appState = AppState(api);
        await pumpEventQueue();

        final authenticated = await appState.authenticate('tecnico', 'senha');
        expect(authenticated, isTrue);

        await appState.sendTicketMessageWithAttachments(
          ticketId: '8595',
          messageContent: 'Teste de mensagem',
        );

        expect(api.addTicketMessageCalls, 0);
        expect(api.getTicketByIdCalls, 1);
      },
    );

    test(
      'does not report attachment-only interaction as success when all uploads fail',
      () async {
        SharedPreferences.setMockInitialValues({});
        final tempDir = await Directory.systemTemp.createTemp(
          'sis-mobile-attachment-guard-',
        );
        final file = File('${tempDir.path}/evidencia.txt');
        await file.writeAsString('conteudo de teste');

        try {
          final api = _AttachmentUploadFailGlpiClient();
          final appState = AppState(api);
          await pumpEventQueue();

          final authenticated = await appState.authenticate('tecnico', 'senha');
          expect(authenticated, isTrue);

          final result = await appState.sendTicketMessageWithAttachments(
            ticketId: '8595',
            messageContent: '',
            filePaths: [file.path],
          );

          expect(result['success'], isFalse);
          expect(result['attachmentsSuccess'], 0);
          expect(result['attachmentsFail'], 1);
          expect(api.addTicketMessageCalls, 0);
          expect(api.uploadToItemCalls, 0);
          expect(api.uploadToTicketCalls, 1);
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );
  });
}

class _ClosedTicketGlpiClient extends GlpiClient {
  int getTicketByIdCalls = 0;
  int addTicketMessageCalls = 0;

  @override
  Future<String?> authenticate(String username, String password) async {
    return 'fake-session-token';
  }

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {'userId': 2039, 'username': 'tecnico', 'profile': 'Tecnico'};
  }

  @override
  Future<Map<String, dynamic>> getTicketById(
    String ticketId,
    String sessionToken,
  ) async {
    getTicketByIdCalls += 1;
    return {'id': ticketId, 'status': GlpiStatus.fechado.code};
  }

  @override
  Future<Map<String, dynamic>> addTicketMessage(
    String ticketId,
    String message,
    String sessionToken,
  ) async {
    addTicketMessageCalls += 1;
    return {'success': true, 'entity_id': '456'};
  }
}

class _AttachmentUploadFailGlpiClient extends GlpiClient {
  int addTicketMessageCalls = 0;
  int uploadToItemCalls = 0;
  int uploadToTicketCalls = 0;

  @override
  Future<String?> authenticate(String username, String password) async {
    return 'fake-session-token';
  }

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {'userId': 2039, 'username': 'tecnico', 'profile': 'Tecnico'};
  }

  @override
  Future<Map<String, dynamic>> getTicketById(
    String ticketId,
    String sessionToken,
  ) async {
    return {'id': ticketId, 'status': GlpiStatus.emAtendimento.code};
  }

  @override
  Future<Map<String, dynamic>> addTicketMessage(
    String ticketId,
    String message,
    String sessionToken,
  ) async {
    addTicketMessageCalls += 1;
    return {'success': true, 'entity_id': '456'};
  }

  @override
  Future<void> uploadAndAttachToItem({
    required String sessionToken,
    required String itemType,
    required String itemId,
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) async {
    uploadToItemCalls += 1;
    throw Exception('falha no upload do item');
  }

  @override
  Future<void> uploadAndAttachToTicket({
    required String sessionToken,
    required String ticketId,
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) async {
    uploadToTicketCalls += 1;
    throw Exception('falha no upload do ticket');
  }
}
