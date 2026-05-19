import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_mobile_flutter/dtic/models/dtic_formcreator_models.dart';
import 'package:sis_mobile_flutter/dtic/models/dtic_ticket_models.dart';
import 'package:sis_mobile_flutter/dtic/services/dtic_glpi_client.dart';
import 'package:sis_mobile_flutter/dtic/state/dtic_app_state.dart';
import 'package:sis_mobile_flutter/dtic/utils/dtic_text.dart';

void main() {
  group('DticFormCreator models', () {
    test('parses active forms and select options from JSON arrays', () {
      final form = DticForm.fromJson({
        'id': '12',
        'name': 'INCIDENTE',
        'is_active': '1',
        'plugin_formcreator_categories_id': '3',
      });
      final question = DticFormQuestion.fromJson({
        'id': '44',
        'plugin_formcreator_forms_id': '12',
        'plugin_formcreator_sections_id': '9',
        'name': 'Tipo de servico',
        'fieldtype': 'select',
        'required': '1',
        'values': '["Rede","Email"]',
      });

      expect(form.id, 12);
      expect(form.isActive, isTrue);
      expect(question.required, isTrue);
      expect(question.options.map((option) => option.label), ['Rede', 'Email']);
    });

    test('strips encoded html from FormCreator question descriptions', () {
      final question = DticFormQuestion.fromJson({
        'id': '45',
        'plugin_formcreator_forms_id': '12',
        'plugin_formcreator_sections_id': '9',
        'name': 'Arquivo',
        'fieldtype': 'file',
        'description':
            '&#60;p&#62;Anexe arquivos ou imagens pertinentes.&#60;/p&#62;',
      });

      expect(question.description, 'Anexe arquivos ou imagens pertinentes.');
    });

    test('resolves expanded dropdown ids from GLPI links', () {
      final form = DticForm.fromJson({
        'id': 1,
        'name': 'EMAIL E APLICATIVOS OFFICE 365',
        'plugin_formcreator_categories_id': 'SISTEMAS > OFFICE 365',
        'is_active': 1,
        'links': [
          {
            'rel': 'PluginFormcreatorCategory',
            'href':
                'http://cau.ppiratini.intra.rs.gov.br/glpi/apirest.php/PluginFormcreatorCategory/3',
          },
        ],
      });
      final section = DticFormSection.fromJson({
        'id': 1,
        'name': 'Dados Gerais',
        'plugin_formcreator_forms_id': 'EMAIL E APLICATIVOS OFFICE 365',
        'links': [
          {
            'rel': 'PluginFormcreatorForm',
            'href':
                'http://cau.ppiratini.intra.rs.gov.br/glpi/apirest.php/PluginFormcreatorForm/1',
          },
        ],
      });
      final question = DticFormQuestion.fromJson({
        'id': 1,
        'name': 'Este atendimento e para quem?',
        'plugin_formcreator_sections_id': 'Dados Gerais',
        'fieldtype': 'select',
        'values': '["Para mim","Para outra Pessoa"]',
        'links': [
          {
            'rel': 'PluginFormcreatorSection',
            'href':
                'http://cau.ppiratini.intra.rs.gov.br/glpi/apirest.php/PluginFormcreatorSection/1',
          },
        ],
      });

      expect(form.categoryId, 3);
      expect(section.formId, 1);
      expect(question.sectionId, 1);
    });

    test('builds FormCreator field names without writing remote data', () {
      final state = DticAppState(DticGlpiClient());
      const form = DticForm(
        id: 5,
        name: 'REQUISICAO',
        categoryId: null,
        isActive: true,
        description: '',
      );
      const questions = [
        DticFormQuestion(
          id: 10,
          formId: 5,
          sectionId: 1,
          name: 'Assunto',
          fieldType: 'text',
          required: true,
          description: '',
          row: 0,
          col: 0,
          width: 0,
          showRule: 1,
          options: [],
          defaultValue: '',
          rawValues: '',
        ),
      ];

      final prepared = state.validateFormAnswers(form, questions, {
        10: 'Teste',
      });

      expect(prepared.canSubmitDryRun, isTrue);
      expect(prepared.toFormCreatorInput(), {
        'plugin_formcreator_forms_id': 5,
        'add': '1',
        'formcreator_field_10': 'Teste',
      });
    });

    test('marks missing required questions before any remote submission', () {
      final state = DticAppState(DticGlpiClient());
      const form = DticForm(
        id: 1,
        name: 'EMAIL E APLICATIVOS OFFICE 365',
        categoryId: null,
        isActive: true,
        description: '',
      );
      const questions = [
        DticFormQuestion(
          id: 20,
          formId: 1,
          sectionId: 1,
          name: 'Descricao',
          fieldType: 'textarea',
          required: true,
          description: '',
          row: 0,
          col: 0,
          width: 0,
          showRule: 1,
          options: [],
          defaultValue: '',
          rawValues: '',
        ),
      ];

      final prepared = state.validateFormAnswers(form, questions, {});

      expect(prepared.canSubmitDryRun, isFalse);
      expect(prepared.missingRequiredQuestionIds, [20]);
      expect(prepared.toFormCreatorInput()['formcreator_field_20'], isNull);
    });

    test('parses conditions and controls question visibility from answers', () {
      final condition = DticFormCondition.fromJson({
        'id': '77',
        'itemtype': 'PluginFormcreatorQuestion',
        'show_condition': '1',
        'show_value': 'Para outra Pessoa',
        'show_logic': '1',
        'order': '0',
        'links': [
          {
            'rel': 'PluginFormcreatorQuestion',
            'href':
                'http://cau.ppiratini.intra.rs.gov.br/glpi/apirest.php/PluginFormcreatorQuestion/30',
          },
          {
            'rel': 'PluginFormcreatorQuestion',
            'href':
                'http://cau.ppiratini.intra.rs.gov.br/glpi/apirest.php/PluginFormcreatorQuestion/10',
          },
        ],
      });

      const sourceQuestion = DticFormQuestion(
        id: 10,
        formId: 2,
        sectionId: 1,
        name: 'Este atendimento e para quem?',
        fieldType: 'select',
        required: true,
        description: '',
        row: 0,
        col: 0,
        width: 0,
        showRule: 1,
        options: [],
        defaultValue: '',
        rawValues: '',
      );
      const conditionalQuestion = DticFormQuestion(
        id: 30,
        formId: 2,
        sectionId: 1,
        name: 'Nome do usuario',
        fieldType: 'text',
        required: true,
        description: '',
        row: 1,
        col: 0,
        width: 0,
        showRule: 2,
        options: [],
        defaultValue: '',
        rawValues: '',
      );
      final catalog = DticFormCatalog(
        forms: const [],
        categories: const [],
        sections: const [],
        questions: const [sourceQuestion, conditionalQuestion],
        conditions: [condition],
        targetTickets: const [],
      );

      expect(condition.itemId, 30);
      expect(condition.sourceQuestionId, 10);
      expect(catalog.isQuestionVisible(sourceQuestion, {}), isTrue);
      expect(catalog.isQuestionVisible(conditionalQuestion, {}), isFalse);
      expect(
        catalog.isQuestionVisible(conditionalQuestion, {
          10: 'Para outra Pessoa',
        }),
        isTrue,
      );
    });

    test('filters restricted forms by active GLPI profile', () {
      const openForm = DticForm(
        id: 1,
        name: 'Solicitacao aberta',
        categoryId: null,
        isActive: true,
        description: '',
      );
      const restrictedForm = DticForm(
        id: 2,
        name: 'NOMEIA / EXONERA',
        categoryId: null,
        isActive: true,
        description: '',
      );
      const catalog = DticFormCatalog(
        forms: [openForm, restrictedForm],
        categories: [],
        sections: [],
        questions: [],
        conditions: [],
        targetTickets: [],
        profiles: [
          DticProfile(id: 12, name: 'DRH'),
          DticProfile(id: 14, name: 'N3'),
          DticProfile(id: 9, name: 'Self-Service'),
        ],
        formProfiles: [
          DticFormProfile(id: 1, formId: 2, profileId: 12),
          DticFormProfile(id: 2, formId: 2, profileId: 14),
        ],
      );

      expect(
        catalog.forActiveProfile('Self-Service').forms.map((form) => form.name),
        ['Solicitacao aberta'],
      );
      expect(catalog.forActiveProfile('DRH').forms.map((form) => form.name), [
        'Solicitacao aberta',
        'NOMEIA / EXONERA',
      ]);
      expect(catalog.forActiveProfile(null).forms.map((form) => form.name), [
        'Solicitacao aberta',
      ]);
    });

    test(
      'uses explicit FormCreator default values for hostname dry-run only',
      () {
        final state = DticAppState(DticGlpiClient());
        const form = DticForm(
          id: 15,
          name: 'Problema de Rede',
          categoryId: null,
          isActive: true,
          description: '',
        );
        const hostname = DticFormQuestion(
          id: 10863,
          formId: 15,
          sectionId: 1,
          name: 'HOSTNAME:',
          fieldType: 'hostname',
          required: true,
          description: '',
          row: 0,
          col: 0,
          width: 0,
          showRule: 1,
          options: [],
          defaultValue: 'PC-GLPI-001',
          rawValues: '',
        );

        final prepared = state.validateFormAnswers(form, [hostname], {});

        expect(prepared.canSubmitDryRun, isTrue);
        expect(
          prepared.toFormCreatorInput()['formcreator_field_10863'],
          'PC-GLPI-001',
        );
      },
    );

    test('uses conditions for section visibility', () {
      const section = DticFormSection(
        id: 40,
        formId: 3,
        name: 'Dados da impressora',
        order: 1,
        showRule: 2,
      );
      const sourceQuestion = DticFormQuestion(
        id: 12,
        formId: 3,
        sectionId: 1,
        name: 'Tipo de atendimento',
        fieldType: 'select',
        required: true,
        description: '',
        row: 0,
        col: 0,
        width: 0,
        showRule: 1,
        options: [],
        defaultValue: '',
        rawValues: '',
      );
      final catalog = DticFormCatalog(
        forms: const [],
        categories: const [],
        sections: const [section],
        questions: const [sourceQuestion],
        conditions: const [
          DticFormCondition(
            id: 1,
            itemType: DticFormCondition.sectionItemType,
            itemId: 40,
            sourceQuestionId: 12,
            showCondition: 1,
            showValue: 'Impressora',
            showLogic: 1,
            order: 0,
          ),
        ],
        targetTickets: const [],
      );

      expect(catalog.isSectionVisible(section, {}), isFalse);
      expect(catalog.isSectionVisible(section, {12: 'Rede'}), isFalse);
      expect(catalog.isSectionVisible(section, {12: 'Impressora'}), isTrue);
    });

    test('keeps visible conditional questions eligible for dry-run review', () {
      final state = DticAppState(DticGlpiClient());
      const form = DticForm(
        id: 2,
        name: 'EMAIL E APLICATIVOS OFFICE 365',
        categoryId: null,
        isActive: true,
        description: '',
      );
      const conditionalQuestion = DticFormQuestion(
        id: 30,
        formId: 2,
        sectionId: 1,
        name: 'Caixa compartilhada',
        fieldType: 'text',
        required: true,
        description: '',
        row: 0,
        col: 0,
        width: 0,
        showRule: 2,
        options: [],
        defaultValue: '',
        rawValues: '',
      );

      final prepared = state.validateFormAnswers(
        form,
        [conditionalQuestion],
        {30: 'dtic@example.invalid'},
      );

      expect(conditionalQuestion.isConditional, isTrue);
      expect(conditionalQuestion.isRenderable, isTrue);
      expect(prepared.canSubmitDryRun, isTrue);
      expect(
        prepared.toFormCreatorInput()['formcreator_field_30'],
        'dtic@example.invalid',
      );
    });
  });

  group('Dtic ticket models', () {
    test('parses search summary update timestamp for unread checks', () {
      final summary = DticTicketSummary.fromSearchRow({
        'data': {
          '2': 13002,
          '1': '[TESTE E2E] Validação de Solução ITIL',
          '12': 5,
          '15': '2026-02-26 02:00:41',
          '19': '2026-02-26 02:46:55',
          '4': 'jonathan-moletta',
          '7': 'ACESSO A SISTEMAS',
        },
      });

      expect(summary.id, '13002');
      expect(summary.statusLabel, 'Solucionado');
      expect(summary.updatedAt, '2026-02-26 02:46:55');
    });

    test('tracks read state locally without writing GLPI data', () async {
      SharedPreferences.setMockInitialValues({});
      final state = DticAppState(DticGlpiClient());

      expect(state.hasUnreadContent('13002', '2026-02-26 02:00:41'), isTrue);

      await state.markTicketAsRead('13002');

      expect(state.hasUnreadContent('13002', '2026-02-26 02:00:41'), isFalse);
      expect(state.hasUnreadContent('13002', '2999-02-26 02:00:41'), isTrue);
    });

    test('decodes GLPI html entities and strips encoded html tags', () {
      final detail = DticTicketDetail.fromJson({
        'id': 7359,
        'name': 'RESET SENHA',
        'status': 5,
        'itilcategories_id': 'ACESSO A SISTEMAS &#62; REDE',
        'content':
            '&#60;p&#62;Sd. Caroline solicitou reset de senha&#60;/p&#62;',
      });

      expect(detail.statusLabel, 'Solucionado');
      expect(detail.category, 'ACESSO A SISTEMAS > REDE');
      expect(detail.content, 'Sd. Caroline solicitou reset de senha');
    });

    test('cleans entity names returned by expanded dropdowns', () {
      expect(
        DticText.cleanPlainText('Entidade raiz &#62; PIRATINI'),
        'Entidade raiz > PIRATINI',
      );
    });

    test('labels ticket, followup and solution document origins', () {
      final ticketDocument = DticTicketDocument.fromJson({
        'id': 10,
        'name': 'print.png',
        'mime': 'image/png',
        'download_path': '/Document/10?alt=media',
        'context_kind': 'ticket',
        'context_id': 7359,
      });
      final followupDocument = DticTicketDocument.fromJson({
        'id': 11,
        'name': 'retorno.pdf',
        'download_path': '/Document/11?alt=media',
        'context_kind': 'followup',
        'context_id': 20,
      });
      final solutionDocument = DticTicketDocument.fromJson({
        'id': 12,
        'name': 'solucao.txt',
        'download_path': '/Document/12?alt=media',
        'context_kind': 'solution',
        'context_id': 30,
      });

      expect(ticketDocument.contextLabel, 'Anexo do chamado');
      expect(followupDocument.contextLabel, 'Anexo de mensagem');
      expect(solutionDocument.contextLabel, 'Anexo de solucao');
    });
  });
}
