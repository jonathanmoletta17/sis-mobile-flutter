import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sis_mobile_flutter/models/glpi_ticket.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';
import 'package:sis_mobile_flutter/state/app_state_storage.dart';

void main() {
  test(
    'synchronizeTickets sends stored offline attachment bytes without local path',
    () async {
      final pendingTicket = {
        'serviceName': 'Carregadores',
        'atendimentoPara': 'Para mim',
        'loggedUserId': 1548,
        'entities_id': 24,
        'entityName': 'Departamento de Manutencao',
        'localizacao': 'Local (Root 36): Armazem',
        'telefone': '51999999999',
        'urgencia': 'Alta',
        'tipo': 'Solicitacao',
        'assunto': 'Offline com anexo PWA',
        'descricao': 'Descricao offline',
        'anexoPath': '',
        'anexoName': 'evidencia.pdf',
        'attachmentBytesList': [
          [1, 2, 3, 4],
        ],
        'attachmentNameList': ['evidencia.pdf'],
        'attachmentMimeList': ['application/pdf'],
      };
      SharedPreferences.setMockInitialValues({
        'sessionToken': 'stored-session',
        'loggedUsername': 'teste',
        'pendingTickets': [jsonEncode(pendingTicket)],
      });
      final api = _OfflineSyncGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final synced = await appState.synchronizeTickets();

      expect(synced, 1);
      expect(appState.pendingTickets, isEmpty);
      expect(api.createTicketCalls, 1);
      expect(api.lastSessionToken, 'stored-session');
      expect(api.lastCreatedFormData?['attachmentBytesList'], [
        [1, 2, 3, 4],
      ]);
      expect(api.lastCreatedFormData?['attachmentNameList'], ['evidencia.pdf']);
    },
  );

  test(
    'synchronizeTickets preserves queue and skips API without session',
    () async {
      final pendingTicket = {
        'serviceName': 'Carregadores',
        'atendimentoPara': 'Para mim',
        'entities_id': 24,
        'localizacao': 'Local (Root 36): Armazem',
        'telefone': '51999999999',
        'urgencia': 'Alta',
        'tipo': 'Solicitacao',
        'assunto': 'Offline sem sessao',
        'descricao': 'Descricao offline',
      };
      SharedPreferences.setMockInitialValues({
        'pendingTickets': [jsonEncode(pendingTicket)],
      });
      final api = _OfflineSyncGlpiClient();
      final appState = AppState(api);
      await pumpEventQueue();

      final synced = await appState.synchronizeTickets();

      expect(synced, 0);
      expect(appState.pendingTickets, hasLength(1));
      expect(api.createTicketCalls, 0);
    },
  );

  test(
    'savePendingTickets strips bytes above maxOfflineAttachmentBytes limit',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Cria ticket com bytes acima do limite (10 MB + 1 byte)
      final largeBytes = List.filled(
        AppStateStorage.maxOfflineAttachmentBytes + 1,
        0,
      );
      final ticket = {
        'serviceName': 'Carregadores',
        'atendimentoPara': 'Para mim',
        'entities_id': 24,
        'localizacao': 'Local (Root 36): Armazem',
        'telefone': '51999999999',
        'urgencia': 'Alta',
        'tipo': 'Solicitacao',
        'assunto': 'Offline com anexo grande',
        'descricao': 'Descricao offline',
        'attachmentBytesList': [largeBytes],
        'attachmentNameList': ['video_grande.mp4'],
        'attachmentMimeList': ['video/mp4'],
        'attachmentPathsList': ['/storage/video_grande.mp4'],
      };

      // Salva diretamente via storage para testar o limite
      final glpiTicket = _makeGlpiTicket(ticket);
      await AppStateStorage.savePendingTickets([glpiTicket]);

      final stored = prefs.getStringList('pendingTickets') ?? [];
      expect(stored, hasLength(1));
      final decoded = jsonDecode(stored.first) as Map<String, dynamic>;

      // Bytes devem ter sido removidos; path e nome preservados
      final storedBytes = decoded['attachmentBytesList'] as List;
      expect(storedBytes, isEmpty);
      expect((decoded['attachmentNameList'] as List).first, 'video_grande.mp4');
    },
  );
}

GlpiTicket _makeGlpiTicket(Map<String, dynamic> map) => GlpiTicket.fromMap(map);

class _OfflineSyncGlpiClient extends GlpiClient {
  int createTicketCalls = 0;
  String? lastSessionToken;
  Map<String, dynamic>? lastCreatedFormData;

  @override
  Future<Map<String, dynamic>> getSessionContext(String sessionToken) async {
    return {
      'userId': 1548,
      'username': 'teste',
      'profile': 'Solicitante',
      'activeEntityId': 24,
      'activeEntityName': 'Departamento de Manutencao',
      'defaultEntityId': 24,
      'availableEntities': const [
        {'id': 24, 'name': 'Departamento de Manutencao'},
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> createTicket(
    Map<String, dynamic> formData,
    String sessionToken,
  ) async {
    createTicketCalls++;
    lastSessionToken = sessionToken;
    lastCreatedFormData = Map<String, dynamic>.from(formData);
    return {'success': true, 'ticket_id': 12345};
  }
}
