import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';

void main() {
  group('AppState.updateTicketStatus', () {
    test('aborts before PUT when fresh ticket status is closed', () async {
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
      expect(
        result['message'],
        'Chamado já está solucionado ou fechado. Recarregue a tela.',
      );
      expect(api.getTicketByIdCalls, 1);
      expect(api.updateTicketStatusCalls, 0);
    });

    test(
      'treats failed auto-assignment after moving to in-progress as operational failure',
      () async {
        SharedPreferences.setMockInitialValues({});
        final api = _AssignFailsGlpiClient();
        final appState = AppState(api);
        await pumpEventQueue();

        final authenticated = await appState.authenticate('tecnico', 'senha');
        expect(authenticated, isTrue);

        final result = await appState.updateTicketStatus(
          '8595',
          GlpiStatus.emAtendimento.label,
        );

        expect(result['success'], isFalse);
        expect(result['statusUpdated'], isTrue);
        expect(result['assignmentFailed'], isTrue);
        expect(api.getTicketByIdCalls, 1);
        expect(api.updateTicketStatusCalls, 1);
        expect(api.assignTicketToMeCalls, 1);
      },
    );

    test(
      'confirms in-progress auto-assignment with fresh ticket read-back',
      () async {
        SharedPreferences.setMockInitialValues({});
        final api = _AssignSucceedsWithReadBackGlpiClient();
        final appState = AppState(api);
        await pumpEventQueue();

        final authenticated = await appState.authenticate('tecnico', 'senha');
        expect(authenticated, isTrue);

        final result = await appState.updateTicketStatus(
          '8595',
          GlpiStatus.emAtendimento.label,
        );

        expect(result['success'], isTrue);
        expect(result['statusUpdated'], isTrue);
        expect(result['assigned'], isTrue);
        expect(result['readBackConfirmed'], isTrue);
        expect(api.getTicketByIdCalls, 2);
        expect(api.updateTicketStatusCalls, 1);
        expect(api.assignTicketToMeCalls, 1);
      },
    );
  });
}

class _ClosedTicketGlpiClient extends GlpiClient {
  int getTicketByIdCalls = 0;
  int updateTicketStatusCalls = 0;

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
  Future<Map<String, dynamic>> updateTicketStatus(
    String ticketId,
    String newStatus,
    String sessionToken,
  ) async {
    updateTicketStatusCalls += 1;
    return {'success': true};
  }
}

class _AssignFailsGlpiClient extends GlpiClient {
  int getTicketByIdCalls = 0;
  int updateTicketStatusCalls = 0;
  int assignTicketToMeCalls = 0;

  @override
  Future<String?> authenticate(String username, String password) async {
    return 'fake-session-token';
  }

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {'userId': 2039, 'username': 'tecnico', 'profile': 'Tecnico'};
  }

  @override
  Future<int?> getMyUserId(String sessionToken) async {
    return 2039;
  }

  @override
  Future<Map<String, dynamic>> getTicketById(
    String ticketId,
    String sessionToken,
  ) async {
    getTicketByIdCalls += 1;
    return {'id': ticketId, 'status': GlpiStatus.novo.code};
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
  Future<bool> assignTicketToMe(
    String ticketId,
    int userId,
    String sessionToken,
  ) async {
    assignTicketToMeCalls += 1;
    return false;
  }
}

class _AssignSucceedsWithReadBackGlpiClient extends GlpiClient {
  int getTicketByIdCalls = 0;
  int updateTicketStatusCalls = 0;
  int assignTicketToMeCalls = 0;

  @override
  Future<String?> authenticate(String username, String password) async {
    return 'fake-session-token';
  }

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {'userId': 2039, 'username': 'tecnico', 'profile': 'Tecnico'};
  }

  @override
  Future<int?> getMyUserId(String sessionToken) async {
    return 2039;
  }

  @override
  Future<Map<String, dynamic>> getTicketById(
    String ticketId,
    String sessionToken,
  ) async {
    getTicketByIdCalls += 1;
    if (getTicketByIdCalls == 1) {
      return {'id': ticketId, 'status': GlpiStatus.novo.code};
    }
    return {
      'id': ticketId,
      'status': GlpiStatus.emAtendimento.code,
      'assignee_user_id': '2039',
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
  Future<bool> assignTicketToMe(
    String ticketId,
    int userId,
    String sessionToken,
  ) async {
    assignTicketToMeCalls += 1;
    return true;
  }
}
