import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/checklists/checklist_catalog.dart';

// CHARACTERIZATION TEST (Onda 0 — rede de segurança da fase corretiva).
//
// Captura o estado ATUAL do parsing de uma questão de Localização (dropdown do
// itemtype Location) ANTES da Onda 1.1 (ler show_tree_depth e podar a árvore).
//
// Fato provado ao vivo (docs/discovery/glpi-live, MAPA_FONTE_DA_VERDADE): a questão
// "Localização" (id=3) chega da API com:
//   values = {"show_tree_depth":"2","show_tree_root":"70",
//             "selectable_tree_root":"0","entity_restrict":"2"}
// e o valor de show_tree_depth VARIA por formulário (id=3 → 2, id=20 → 0, id=29 → -3).
//
// Estado atual: o JSON cru CHEGA ao app (rawValues), mas a semântica de poda da
// árvore (show_tree_depth / show_tree_root) NÃO é extraída nem aplicada — ou seja,
// o problema é de CONSUMO, não de disponibilidade do dado. A Onda 1.1 adicionará o
// parsing tipado e este teste mudará intencionalmente.

void main() {
  group('CHARACTERIZATION: questão Localização / show_tree_depth (pré-Onda-1.1)', () {
    final q = SisChecklistQuestion.fromMap({
      'id': 3,
      'name': 'Localização',
      'fieldtype': 'dropdown',
      'itemtype': 'Location',
      'values':
          '{"show_tree_depth":"2","show_tree_root":"70","selectable_tree_root":"0","entity_restrict":"2"}',
    });

    test('o dado JÁ chega ao app: rawValues preserva o JSON com show_tree_depth', () {
      expect(q.rawValues, contains('show_tree_depth'));
      expect(q.rawValues, contains('show_tree_root'));
    });

    test('mas a semântica de poda NÃO é consumida hoje (options vazio p/ dropdown Location)', () {
      // Para fieldtype dropdown/glpiselect o app não monta opções nem profundidade —
      // o show_tree_depth é simplesmente ignorado. A Onda 1.1 corrige isto.
      expect(q.fieldType, 'dropdown');
      expect(q.options, isEmpty);
    });
  });
}
