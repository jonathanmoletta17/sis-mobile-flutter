import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';

void main() {
  group('AppState.approveSolution', () {
    test(
      'allows requester validation flow when fresh ticket status is solved',
      () async {
        SharedPreferences.setMockInitialValues({});
        final api = _SolvedTicketGlpiClient();
        final appState = AppState(api);
        await pumpEventQueue();

        final authenticated = await appState.authenticate('solicitante', 'senha');
        expect(authenticated, isTrue);

        final result = await appState.approveSolution('8595', '123');

        expect(result['success'], isTrue);
        expect(api.getTicketByIdCalls, 1);
        expect(api.updateSolutionStatusCalls, 1);
        expect(api.lastSolutionStatus, 3);
        expect(api.updateTicketStatusCalls, 1);
        expect(api.lastTicketStatus, GlpiStatus.fechado.label);
      },
    );

    test(
      'aborts before updating solution when fresh ticket status is closed',
      () async {
        SharedPreferences.setMockInitialValues({});
        final api = _ClosedTicketGlpiClient();
        final appState = AppState(api);
        await pumpEventQueue();

        final authenticated = await appState.authenticate('tecnico', 'senha');
        expect(authenticated, isTrue);

        await appState.approveSolution('8595', '123');

        expect(api.updateSolutionStatusCalls, 0);
        expect(api.getTicketByIdCalls, 1);
      },
    );

    test(
      'aborts before updating solution when fresh ticket status is open',
      () async {
        SharedPreferences.setMockInitialValues({});
        final api = _OpenTicketGlpiClient();
        final appState = AppState(api);
        await pumpEventQueue();

        final authenticated = await appState.authenticate('solicitante', 'senha');
        expect(authenticated, isTrue);

        final result = await appState.approveSolution('8595', '123');

        expect(result['success'], isFalse);
        expect(api.updateSolutionStatusCalls, 0);
        expect(api.getTicketByIdCalls, 1);
      },
    );

    test('reports failure when approved solution does not close ticket', () async {
      SharedPreferences.setMockInitialValues({});
      final api = _SolvedTicketGlpiClient(closeSucceeds: false);
      final appState = AppState(api);
      await pumpEventQueue();

      final authenticated = await appState.authenticate('solicitante', 'senha');
      expect(authenticated, isTrue);

      final result = await appState.approveSolution('8595', '123');

      expect(result['success'], isFalse);
      expect(result['error'], contains('Falha ao fechar'));
      expect(api.updateSolutionStatusCalls, 1);
      expect(api.updateTicketStatusCalls, 1);
    });
  });
}

class _OpenTicketGlpiClient extends GlpiClient {
  int getTicketByIdCalls = 0;
  int updateSolutionStatusCalls = 0;

  @override
  Future<String?> authenticate(String username, String password) async {
    return 'fake-session-token';
  }

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {
      'userId': 2039,
      'username': 'solicitante',
      'profile': 'Self-Service',
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
      'status': GlpiStatus.novo.code,
    };
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
}

class _SolvedTicketGlpiClient extends GlpiClient {
  _SolvedTicketGlpiClient({this.closeSucceeds = true});

  final bool closeSucceeds;
  int getTicketByIdCalls = 0;
  int updateSolutionStatusCalls = 0;
  int updateTicketStatusCalls = 0;
  int? lastSolutionStatus;
  String? lastTicketStatus;

  @override
  Future<String?> authenticate(String username, String password) async {
    return 'fake-session-token';
  }

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {
      'userId': 2039,
      'username': 'solicitante',
      'profile': 'Self-Service',
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
      'status': GlpiStatus.solucionado.code,
    };
  }

  @override
  Future<bool> updateSolutionStatus({
    required String solutionId,
    required int newStatus,
    required String sessionToken,
  }) async {
    updateSolutionStatusCalls += 1;
    lastSolutionStatus = newStatus;
    return true;
  }

  @override
  Future<Map<String, dynamic>> updateTicketStatus(
    String ticketId,
    String newStatus,
    String sessionToken,
  ) async {
    updateTicketStatusCalls += 1;
    lastTicketStatus = newStatus;
    return closeSucceeds
        ? {'success': true}
        : {'success': false, 'message': 'Falha ao fechar chamado'};
  }
}

class _ClosedTicketGlpiClient extends GlpiClient {
  int getTicketByIdCalls = 0;
  int updateSolutionStatusCalls = 0;

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
  Future<bool> updateSolutionStatus({
    required String solutionId,
    required int newStatus,
    required String sessionToken,
  }) async {
    updateSolutionStatusCalls += 1;
    return false;
  }
}
