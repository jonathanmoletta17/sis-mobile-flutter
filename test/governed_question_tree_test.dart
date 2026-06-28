import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/catalog/governed_service_catalog.dart';

/// Contrato de árvore ITILCategory (FormCreator "Tipo"):
/// só as FOLHAS selecionáveis devem ser oferecidas; o nó-pai não-selecionável
/// (raiz com selectable_tree_root="0") nunca aparece. Fonte: catálogo governado
/// (pré-resolvido), pois Solicitante/GG não leem /ITILCategory em runtime.
///
/// Dados reais do form 40 "Multiplas Demandas", target Ar-Condicionado
/// (root_id=1, selectable_tree_root="0"): 1 nó-pai + 6 folhas. As 6 folhas
/// batem com o GLPI ao vivo (Conserto, Desinstalação, Instalação, Remanejo,
/// Outras atividades, Higienização).
void main() {
  GovernedQuestion arCondicionadoTipo() => GovernedQuestion.fromMap({
        'id': 701,
        'name': 'Tipo',
        'fieldtype': 'dropdown',
        'root_id': 1,
        'raw_values': {
          'show_tree_root': '1',
          'selectable_tree_root': '0',
          'show_tree_depth': '0',
        },
        'options_sample': [
          {'id': 1, 'label': 'Ar Condicionado', 'full_label': 'Manutenção > Ar Condicionado'},
          {'id': 2, 'label': 'Conserto', 'full_label': 'Manutenção > Ar Condicionado > Conserto'},
          {'id': 3, 'label': 'Desinstalação', 'full_label': 'Manutenção > Ar Condicionado > Desinstalação'},
          {'id': 4, 'label': 'Instalação', 'full_label': 'Manutenção > Ar Condicionado > Instalação'},
          {'id': 6, 'label': 'Remanejo', 'full_label': 'Manutenção > Ar Condicionado > Remanejo'},
          {'id': 7, 'label': 'Outras atividades', 'full_label': 'Manutenção > Ar Condicionado > Outras atividades'},
          {'id': 100, 'label': 'Higienização', 'full_label': 'Manutenção > Ar Condicionado > Higienização'},
        ],
      });

  group('GovernedQuestion.selectableOptions', () {
    test('exclui o nó-pai não-selecionável e mantém só as 6 folhas', () {
      final q = arCondicionadoTipo();
      expect(q.rootId, 1);
      expect(q.selectableTreeRoot, isFalse);

      final labels = q.selectableOptions.map((o) => o.label).toList();
      expect(labels, [
        'Conserto',
        'Desinstalação',
        'Instalação',
        'Remanejo',
        'Outras atividades',
        'Higienização',
      ]);
      // O nó-pai "Ar Condicionado" (id=1) nunca aparece.
      expect(q.selectableOptions.any((o) => o.id == 1), isFalse);
    });

    test('exclui nó intermédio que é ancestral de outra folha (árvore profunda)', () {
      final q = GovernedQuestion.fromMap({
        'id': 1,
        'name': 'Tipo',
        'fieldtype': 'dropdown',
        'root_id': 10,
        'raw_values': {'selectable_tree_root': '0'},
        'options_sample': [
          {'id': 10, 'label': 'Raiz', 'full_label': 'A'},
          {'id': 11, 'label': 'Meio', 'full_label': 'A > B'},
          {'id': 12, 'label': 'Folha', 'full_label': 'A > B > C'},
        ],
      });
      // Raiz (id=10) e Meio (ancestral de C) saem; só a folha C fica.
      expect(q.selectableOptions.map((o) => o.label), ['Folha']);
    });

    test('lista plana sem hierarquia: todas as opções são folhas', () {
      final q = GovernedQuestion.fromMap({
        'id': 1,
        'name': 'Tipo',
        'fieldtype': 'select',
        'raw_values': {},
        'options_sample': [
          {'id': 1, 'label': 'Iluminação', 'full_label': 'Iluminação'},
          {'id': 2, 'label': 'Parado', 'full_label': 'Parado'},
        ],
      });
      expect(q.selectableOptions.map((o) => o.label), ['Iluminação', 'Parado']);
    });

    test('nó intermédio (com filhos) é sempre tratado como cabeçalho, não opção', () {
      // Comportamento fiel ao GLPI observado: "Manutenção"/"Ar Condicionado"
      // aparecem como cabeçalho não-clicável; só as folhas são selecionáveis.
      final q = GovernedQuestion.fromMap({
        'id': 1,
        'name': 'Tipo',
        'fieldtype': 'dropdown',
        'root_id': 5,
        'raw_values': {'selectable_tree_root': '1'},
        'options_sample': [
          {'id': 5, 'label': 'Raiz', 'full_label': 'R'},
          {'id': 6, 'label': 'Folha', 'full_label': 'R > F'},
        ],
      });
      // Mesmo com selectable_tree_root=1, um nó COM filhos é agrupador → só a
      // folha é oferecida. (Os dados reais do form 40 têm selectable_tree_root=0.)
      expect(q.selectableOptions.map((o) => o.label), ['Folha']);
    });

    test('root selecionável e sem filhos é mantido (lista de 1 nível)', () {
      final q = GovernedQuestion.fromMap({
        'id': 1,
        'name': 'Tipo',
        'fieldtype': 'dropdown',
        'root_id': 5,
        'raw_values': {'selectable_tree_root': '1'},
        'options_sample': [
          {'id': 5, 'label': 'Único', 'full_label': 'Único'},
        ],
      });
      expect(q.selectableOptions.map((o) => o.label), ['Único']);
    });
  });
}
