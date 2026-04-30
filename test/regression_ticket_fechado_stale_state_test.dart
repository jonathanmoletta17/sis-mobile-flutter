import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';
import 'package:sis_mobile_flutter/state/app_state_attachment_support.dart';

void main() {
  group('regression ticket fechado stale state', () {
    test('updateTicketStatus aborts before updating ticket status', () async {
      SharedPreferences.setMockInitialValues({});
      final api = _ClosedTicketGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final authenticated = await appState.authenticate('tecnico', 'senha');
      expect(authenticated, isTrue);

      final result = await appState.updateTicketStatus(
        '8595',
        GlpiStatus.solucionado.label,
      );

      expect(result['success'], isFalse);
      expect(api.getTicketByIdCalls, 1);
      expect(api.updateTicketStatusCalls, 0);
    });

    test('approveSolution aborts before updating solution status', () async {
      SharedPreferences.setMockInitialValues({});
      final api = _ClosedTicketGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final authenticated = await appState.authenticate('tecnico', 'senha');
      expect(authenticated, isTrue);

      final result = await appState.approveSolution('8595', '123');

      expect(result['success'], isFalse);
      expect(api.getTicketByIdCalls, 1);
      expect(api.updateSolutionStatusCalls, 0);
    });

    test('rejectSolution aborts before updating solution status', () async {
      SharedPreferences.setMockInitialValues({});
      final api = _ClosedTicketGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final authenticated = await appState.authenticate('tecnico', 'senha');
      expect(authenticated, isTrue);

      final result = await appState.rejectSolution(
        '8595',
        '123',
        'Nao procede',
      );

      expect(result['success'], isFalse);
      expect(api.getTicketByIdCalls, 1);
      expect(api.updateSolutionStatusCalls, 0);
    });

    test('sendTicketMessageWithAttachments aborts before adding message',
        () async {
      SharedPreferences.setMockInitialValues({});
      final api = _ClosedTicketGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final authenticated = await appState.authenticate('tecnico', 'senha');
      expect(authenticated, isTrue);

      final result = await appState.sendTicketMessageWithAttachments(
        ticketId: '8595',
        messageContent: 'Teste de mensagem',
      );

      expect(result['success'], isFalse);
      expect(api.getTicketByIdCalls, 1);
      expect(api.addTicketMessageCalls, 0);
    });

    test('uploadAndLinkImage aborts before uploading attachment', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'sis-mobile-closed-ticket-test-',
      );
      final image = File('${tempDir.path}/evidencia.txt');
      await image.writeAsString('fake attachment');
      final api = _ClosedTicketGlpiClient();

      try {
        final result = await AppStateAttachmentSupport.uploadAndLinkImage(
          apiService: api,
          isAuthenticated: true,
          sessionToken: 'fake-session-token',
          ticketId: '8595',
          imagePath: image.path,
          isSessionInvalidError: (_) => false,
          handleSessionInvalid: (_) async {},
        );

        expect(result['success'], isFalse);
        expect(api.getTicketByIdCalls, 1);
        expect(api.uploadAndAttachToTicketCalls, 0);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });
}

class _ClosedTicketGlpiClient extends GlpiClient {
  int getTicketByIdCalls = 0;
  int updateTicketStatusCalls = 0;
  int updateSolutionStatusCalls = 0;
  int addTicketMessageCalls = 0;
  int uploadAndAttachToTicketCalls = 0;

  @override
  Future<String?> authenticate(String username, String password) async {
    return 'fake-session-token';
  }

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {
      'userId': 2039,
      'username': 'tecnico',
      'profile': 'Tecnico',
    };
  }

  @override
  Future<Map<String, dynamic>> getTicketById(
    String ticketId,
    String sessionToken,
  ) async {
    getTicketByIdCalls += 1;
    return {
      'id': ticketId,
      'status': GlpiStatus.fechado.code,
    };
  }

  @override
  Future<Map<String, dynamic>> updateTicketStatus(
    String ticketId,
    String newStatus,
    String sessionToken,
  ) async {
    updateTicketStatusCalls += 1;
    return {'success': true};
  }

  @override
  Future<bool> updateSolutionStatus({
    required String solutionId,
    required int newStatus,
    required String sessionToken,
  }) async {
    updateSolutionStatusCalls += 1;
    return true;
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
  Future<void> uploadAndAttachToTicket({
    required String sessionToken,
    required String ticketId,
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) async {
    uploadAndAttachToTicketCalls += 1;
  }
}
