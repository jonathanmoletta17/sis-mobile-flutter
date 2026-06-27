import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/checklists/checklist_catalog.dart';

// CHARACTERIZATION TEST (Onda 0 — rede de segurança da fase corretiva).
//
// Captura o comportamento ATUAL do operador de condição FormCreator ANTES da
// Onda 1.2 (implementar os 9 operadores de show_condition). NÃO valida o
// comportamento desejado — documenta o que existe hoje, para que a mudança na
// Onda 1 fique VISÍVEL e intencional (e nenhuma regressão passe silenciosa).
//
// Comportamento atual (lib/checklists/checklist_catalog.dart::_matchValue):
//   show_condition 1 => igualdade ; 2 => diferença ; 3..9 => SEMPRE false (não implementados).
// Evidência da API real (docs/discovery/glpi-live, MAPA_FONTE_DA_VERDADE): show_condition
// tem 9 operadores (1=igual,2=diferente,3=menor,4=maior,5=<=,6=>=,7=visível,8=invisível,9=regex).
//
// Quando a Onda 1.2 implementar os operadores, os expects de op 3..9 DEVEM mudar —
// essa mudança é o sinal de que a correção entrou.

SisChecklistCondition _cond({required int showCondition, required String showValue}) =>
    SisChecklistCondition(
      id: 1,
      itemType: SisChecklistCondition.questionItemType,
      itemId: 10,
      sourceQuestionId: 5,
      showCondition: showCondition,
      showValue: showValue,
      showLogic: 1,
      order: 0,
    );

void main() {
  group('CHARACTERIZATION: operadores show_condition (estado atual pré-Onda-1.2)', () {
    test('op 1 (igual): casa quando idênticos', () {
      expect(_cond(showCondition: 1, showValue: 'sim').matches('sim'), isTrue);
      expect(_cond(showCondition: 1, showValue: 'sim').matches('nao'), isFalse);
    });

    test('op 2 (diferente): casa quando divergem', () {
      expect(_cond(showCondition: 2, showValue: 'sim').matches('nao'), isTrue);
      expect(_cond(showCondition: 2, showValue: 'sim').matches('sim'), isFalse);
    });

    // DÍVIDA TÉCNICA: operadores 3..9 ainda NÃO implementados → hoje retornam
    // SEMPRE false, mesmo quando a semântica do GLPI casaria. A Onda 1.2 corrige.
    for (final op in [3, 4, 5, 6, 7, 8, 9]) {
      test('op $op (não implementado): SEMPRE false hoje', () {
        // ex.: '5' > '3' casaria no operador "maior" (4); hoje é false.
        expect(_cond(showCondition: op, showValue: '3').matches('5'), isFalse);
        expect(_cond(showCondition: op, showValue: '3').matches('3'), isFalse);
      });
    }

    test('resposta múltipla (Iterable) casa se qualquer valor casar — op 1', () {
      expect(_cond(showCondition: 1, showValue: 'b').matches(['a', 'b', 'c']), isTrue);
      expect(_cond(showCondition: 1, showValue: 'z').matches(['a', 'b', 'c']), isFalse);
    });

    test('resposta vazia nunca casa', () {
      expect(_cond(showCondition: 1, showValue: 'x').matches(''), isFalse);
      expect(_cond(showCondition: 1, showValue: 'x').matches(null), isFalse);
    });
  });
}
