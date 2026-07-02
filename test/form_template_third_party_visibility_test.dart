import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/services/glpi_client_support.dart';

// Historico deste arquivo: originalmente testava
// GovernedSubmissionResolver.hasThirdPartyOption (targetticket.audience),
// que codificava um bug como comportamento esperado — "GG desabilita Para
// outra Pessoa quando nao ha para_terceiro" partia da premissa errada de
// que a visibilidade da opcao vem do roteamento do alvo. Achado ao vivo
// 2026-07-02 (GLPI real, formularios 38/39/40/36): existe uma pergunta
// FormCreator real "Este atendimento e para quem?" (fieldtype select,
// valores "Para mim"/"Para outra Pessoa"), independente de
// targetticket.audience, que e a fonte da verdade correta — inclusive para
// o perfil GG, que tem essa pergunta em todos os formularios que enxerga.
// A funcao antiga foi removida (nao tinha mais uso em lib/); este arquivo
// agora testa GlpiClientSupport.isThirdPartyAudienceQuestion, que e o
// reconhecedor real usado por form_template.dart via
// AppState.hasThirdPartyAudienceQuestion.
void main() {
  group('isThirdPartyAudienceQuestion (reconhece a pergunta real do GLPI)', () {
    test('reconhece o padrao exato observado ao vivo nos forms 38/39/40/36', () {
      expect(
        GlpiClientSupport.isThirdPartyAudienceQuestion({
          'fieldtype': 'select',
          'values': '["Para mim","Para outra Pessoa"]',
        }),
        isTrue,
      );
    });

    test('e insensivel a maiusculas/minusculas e espacos', () {
      expect(
        GlpiClientSupport.isThirdPartyAudienceQuestion({
          'fieldtype': 'select',
          'values': '[" para mim ", "PARA OUTRA PESSOA"]',
        }),
        isTrue,
      );
    });

    test('aceita variante "para terceiro" no lugar de "para outra pessoa"', () {
      expect(
        GlpiClientSupport.isThirdPartyAudienceQuestion({
          'fieldtype': 'select',
          'values': '["Para mim","Para um terceiro"]',
        }),
        isTrue,
      );
    });

    test('rejeita fieldtype diferente de select (ex.: glpiselect do beneficiario)', () {
      expect(
        GlpiClientSupport.isThirdPartyAudienceQuestion({
          'fieldtype': 'glpiselect',
          'itemtype': 'User',
          'values': '',
        }),
        isFalse,
      );
    });

    test('rejeita select com valores que nao formam o par mim/terceiro', () {
      expect(
        GlpiClientSupport.isThirdPartyAudienceQuestion({
          'fieldtype': 'select',
          'values': '["Iluminação","Parado","Ventilação"]',
        }),
        isFalse,
      );
    });

    test('rejeita values malformado sem lancar excecao', () {
      expect(
        GlpiClientSupport.isThirdPartyAudienceQuestion({
          'fieldtype': 'select',
          'values': 'nao e json valido',
        }),
        isFalse,
      );
    });

    test('rejeita values ausente', () {
      expect(
        GlpiClientSupport.isThirdPartyAudienceQuestion({'fieldtype': 'select'}),
        isFalse,
      );
    });
  });
}
