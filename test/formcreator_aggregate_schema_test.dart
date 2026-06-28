import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/formcreator/formcreator_aggregate_schema.dart';

void main() {
  test('detects multiselect controller and maps conditional sections', () {
    final sections = [
      const FormCreatorSection(
        id: 165,
        name: 'Dados Gerais',
        formId: 40,
        order: 1,
        showRule: 1,
      ),
      const FormCreatorSection(
        id: 166,
        name: 'Ar-Condicionado',
        formId: 40,
        order: 2,
        showRule: 2,
      ),
      const FormCreatorSection(
        id: 175,
        name: 'Carregadores',
        formId: 40,
        order: 11,
        showRule: 2,
      ),
    ];

    final questionsBySection = {
      165: [
        FormCreatorQuestion.fromMap({
          'id': 700,
          'name': 'Serviços',
          'plugin_formcreator_sections_id': 165,
          'fieldtype': 'multiselect',
          'required': 1,
          'values': '["Ar-Condicionado","Carregadores"]',
        }),
      ],
      166: [
        FormCreatorQuestion.fromMap({
          'id': 701,
          'name': 'Tipo',
          'plugin_formcreator_sections_id': 166,
          'fieldtype': 'dropdown',
          'required': 1,
        }),
        FormCreatorQuestion.fromMap({
          'id': 704,
          'name': 'Assunto',
          'plugin_formcreator_sections_id': 166,
          'fieldtype': 'text',
          'required': 1,
        }),
      ],
      175: [
        FormCreatorQuestion.fromMap({
          'id': 737,
          'name': 'Tipo',
          'plugin_formcreator_sections_id': 175,
          'fieldtype': 'dropdown',
          'required': 1,
        }),
      ],
    };

    final conditionsBySection = {
      166: [
        FormCreatorCondition.fromMap({
          'id': 771,
          'itemtype': 'PluginFormcreatorSection',
          'items_id': 166,
          'plugin_formcreator_questions_id': 700,
          'show_condition': 1,
          'show_value': 'Ar-Condicionado',
          'show_logic': 1,
        }),
      ],
      175: [
        FormCreatorCondition.fromMap({
          'id': 782,
          'itemtype': 'PluginFormcreatorSection',
          'items_id': 175,
          'plugin_formcreator_questions_id': 700,
          'show_condition': 1,
          'show_value': 'Carregadores',
          'show_logic': 1,
        }),
      ],
    };

    final schema = FormCreatorAggregateSchema.fromRaw(
      formId: 40,
      sections: sections,
      questionsBySection: questionsBySection,
      conditionsBySection: conditionsBySection,
    );

    expect(schema, isNotNull);
    expect(schema!.isMultiService, isTrue);
    expect(schema.controlQuestion.id, 700);
    expect(schema.serviceLabels, ['Ar-Condicionado', 'Carregadores']);
    expect(schema.sectionForLabel('Carregadores')?.section.id, 175);
  });

  test(
    'falls back to section names when conditions endpoint is unavailable',
    () {
      final schema = FormCreatorAggregateSchema.fromRaw(
        formId: 40,
        sections: const [
          FormCreatorSection(
            id: 165,
            name: 'Dados Gerais',
            formId: 40,
            order: 1,
            showRule: 1,
          ),
          FormCreatorSection(
            id: 166,
            name: 'Ar-Condicionado',
            formId: 40,
            order: 2,
            showRule: 2,
          ),
          FormCreatorSection(
            id: 175,
            name: 'Carregadores',
            formId: 40,
            order: 11,
            showRule: 2,
          ),
        ],
        questionsBySection: {
          165: [
            FormCreatorQuestion.fromMap({
              'id': 700,
              'name': 'Serviços',
              'plugin_formcreator_sections_id': 165,
              'fieldtype': 'multiselect',
              'required': 1,
              'values': '["Ar-Condicionado","Carregadores"]',
            }),
          ],
          166: [
            FormCreatorQuestion.fromMap({
              'id': 701,
              'name': 'Tipo',
              'plugin_formcreator_sections_id': 166,
              'fieldtype': 'dropdown',
            }),
          ],
          175: [
            FormCreatorQuestion.fromMap({
              'id': 737,
              'name': 'Tipo',
              'plugin_formcreator_sections_id': 175,
              'fieldtype': 'dropdown',
            }),
          ],
        },
        conditionsBySection: const {},
      );

      expect(schema, isNotNull);
      expect(schema!.serviceLabels, ['Ar-Condicionado', 'Carregadores']);
    },
  );
}
