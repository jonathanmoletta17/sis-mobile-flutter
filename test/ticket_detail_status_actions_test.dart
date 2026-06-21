import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sis_mobile_flutter/screens/ticket_detail_screen.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';

// Ticket de fixture: ID 9734 criado pelo Hermes para o user "teste" (ID 2373),
// entidade 28 (Departamento de Tecnologia e Informação). Status Em Atendimento
// para garantir que canSendCommonInteraction = true.
const _kFixtureTicket = {
  'id': '9734',
  'name': '[HERMES-E2E-NAO-APAGAR] SOLICITANTE_TESTE - validação ponta a ponta SIS Mobile',
  'status': 2, // Em Atendimento
  'date_mod': '2026-06-18 10:00:00',
  'itilcategories_id': 'Limpeza',
  'users_id_recipient': 'teste',
  'Users_id_recipient': 'teste',
  'entities_id': 28,
};

Widget _wrap(AppState appState, Map<String, dynamic> ticket) =>
    ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        home: TicketDetailScreen(ticket: ticket),
      ),
    );

// Monta a tela e aguarda _loadState() completar antes de aplicar o perfil de
// lab. Sem esse pump inicial, _loadState() sobrescreveria activateLabPreviewSession.
Future<AppState> _pumpWithProfile(
  WidgetTester tester,
  Map<String, dynamic> ticket, {
  required String profile,
  String username = 'teste',
  int entityId = 28,
}) async {
  final appState = AppState(GlpiClient());
  await tester.pumpWidget(_wrap(appState, ticket));
  // Deixa _loadState completar (SharedPreferences mock vazio → não autentica).
  await tester.pump();
  // Agora aplica o perfil de lab — _loadState já terminou, não vai sobrescrever.
  appState.activateLabPreviewSession(
    username: username,
    profile: profile,
    activeEntityId: entityId,
    activeEntityName: 'Departamento de TI',
  );
  // Rebuild com o estado correto.
  await tester.pump();
  return appState;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(mergeWith: const <String, String>{});
  });

  group('TicketDetailScreen — seção "Ações de Status"', () {
    testWidgets('Solicitante NÃO vê "Ações de Status" no chamado fixture', (
      tester,
    ) async {
      await _pumpWithProfile(
        tester,
        Map.from(_kFixtureTicket),
        profile: 'Solicitante',
        username: 'teste',
      );

      expect(
        find.text('Ações de Status'),
        findsNothing,
        reason:
            'Perfil Solicitante não deve expor a seção de transição de status técnica.',
      );
    });

    testWidgets(
      'Técnico VÊ "Ações de Status" quando não é requerente do chamado',
      (tester) async {
        // Técnico logado como 'tecnico_teste'; ticket pertence a 'teste' →
        // isLoggedUserRequester = false → canShowTechnicianActions = true.
        await _pumpWithProfile(
          tester,
          {
            ...Map.from(_kFixtureTicket),
            'users_id_recipient': 'teste',
            'Users_id_recipient': 'teste',
          },
          profile: 'Tecnico',
          username: 'tecnico_teste',
        );

        expect(
          find.text('Ações de Status'),
          findsOneWidget,
          reason:
              'Perfil Técnico deve expor a seção de transição de status para chamados de outros usuários.',
        );
      },
    );

    testWidgets(
      'Técnico NÃO vê "Ações de Status" quando é o próprio requerente',
      (tester) async {
        // Técnico logado como 'teste'; ticket pertence a 'teste' →
        // isLoggedUserRequester = true → canShowTechnicianActions = false.
        await _pumpWithProfile(
          tester,
          Map.from(_kFixtureTicket),
          profile: 'Tecnico',
          username: 'teste',
        );

        expect(
          find.text('Ações de Status'),
          findsNothing,
          reason:
              'Técnico requerente do próprio chamado não recebe ações técnicas.',
        );
      },
    );
  });
}
