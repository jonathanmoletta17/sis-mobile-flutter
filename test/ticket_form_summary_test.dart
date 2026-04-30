import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/utils/ticket_form_summary.dart';

void main() {
  group('TicketFormSummary', () {
    test(
      'parses app payload into readable fields and hides machine markers',
      () {
        final summary = TicketFormSummary.parse('''
Ar condicionado nao liga na sala de reuniao.

-- FORMULARIO DO APP
--------------------------------
Servico: Ar-Condicionado
Atendimento para: Para mim
Telefone: 51999999999
Localizacao: PIRATINI > 2o Andar
Urgencia: 3
Tipo: Manutencao
Anexo: 6df4a4cc-768b-43de-95c6-6fe5f6f33a91.jpg
''');

        expect(
          summary.description,
          'Ar condicionado nao liga na sala de reuniao.',
        );
        expect(summary.fields.map((field) => field.label), [
          'Serviço',
          'Atendimento para',
          'Telefone',
          'Localização',
          'Urgência',
          'Tipo',
        ]);
        expect(
          summary.fields.firstWhere((field) => field.label == 'Urgência').value,
          'Media',
        );
        expect(summary.fields.any((field) => field.label == 'Anexo'), isFalse);
        expect(summary.asPlainText(), isNot(contains('FORMULARIO')));
        expect(summary.asPlainText(), isNot(contains('----')));
        expect(summary.asPlainText(), isNot(contains('6df4a4cc')));
      },
    );
  });
}
