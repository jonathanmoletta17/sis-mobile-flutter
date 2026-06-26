import 'package:flutter/material.dart';

import '../checklist_catalog.dart';

/// Renderiza uma pergunta FormCreator de checklist conforme o `fieldtype`.
/// Tipos suportados: `select`, `radios`, `multiselect`, `textarea`/`text`,
/// `file` e `glpiselect`.
///
/// O valor e propagado via [onChanged]; a validacao de obrigatoriedade visivel
/// e feita fora (engine + preparer). Para `file` e `glpiselect` o widget mostra
/// estados informativos quando o provedor de lookup nao esta disponivel.
class ChecklistQuestionField extends StatelessWidget {
  const ChecklistQuestionField({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
    this.glpiSelectBuilder,
    this.fileBuilder,
  });

  final SisChecklistQuestion question;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  /// Construtor opcional para `glpiselect` (lookup read-only). Conectado na
  /// fase de lookups; ausente => estado informativo.
  final Widget Function(
    SisChecklistQuestion question,
    dynamic value,
    ValueChanged<dynamic> onChanged,
  )?
  glpiSelectBuilder;

  /// Construtor opcional para `file` (anexo). Ausente => estado informativo.
  final Widget Function(
    SisChecklistQuestion question,
    dynamic value,
    ValueChanged<dynamic> onChanged,
  )?
  fileBuilder;

  @override
  Widget build(BuildContext context) {
    final label = _label(context);
    final field = switch (question.fieldType) {
      'select' => _buildSelect(context),
      'radios' => _buildRadios(context),
      'multiselect' => _buildMultiselect(context),
      'textarea' || 'text' => _buildText(context),
      'glpiselect' => _buildGlpiSelect(context),
      'file' => _buildFile(context),
      _ => _buildUnsupported(context),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [label, const SizedBox(height: 4), field],
      ),
    );
  }

  Widget _label(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            question.name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        if (question.required)
          Text(
            '*',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }

  Widget _buildSelect(BuildContext context) {
    final current = value?.toString();
    return DropdownButtonFormField<String>(
      key: const Key('checklist_select'),
      initialValue: question.options.any((o) => o.value == current)
          ? current
          : null,
      isExpanded: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: question.options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option.value,
              child: Text(option.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildRadios(BuildContext context) {
    final current = value?.toString();
    return Column(
      children: question.options
          .map(
            (option) => RadioListTile<String>(
              key: Key('checklist_radio_${option.value}'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: option.value,
              // ignore: deprecated_member_use
              groupValue: current,
              title: Text(option.label),
              // ignore: deprecated_member_use
              onChanged: onChanged,
            ),
          )
          .toList(),
    );
  }

  Widget _buildMultiselect(BuildContext context) {
    final selected = <String>{
      if (value is Iterable)
        ...(value as Iterable).map((item) => item.toString()),
    };
    return Column(
      children: question.options
          .map(
            (option) => CheckboxListTile(
              key: Key('checklist_check_${option.value}'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: selected.contains(option.value),
              title: Text(option.label),
              onChanged: (checked) {
                final next = Set<String>.from(selected);
                if (checked == true) {
                  next.add(option.value);
                } else {
                  next.remove(option.value);
                }
                onChanged(next.toList());
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildText(BuildContext context) {
    return TextFormField(
      key: const Key('checklist_text'),
      initialValue: value?.toString() ?? '',
      maxLines: question.isTextArea ? 4 : 1,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      onChanged: onChanged,
    );
  }

  Widget _buildGlpiSelect(BuildContext context) {
    final builder = glpiSelectBuilder;
    if (builder != null) {
      return builder(question, value, onChanged);
    }
    return _infoBox(
      context,
      Icons.search_off,
      'Lookup (${question.itemType.isEmpty ? 'item' : question.itemType}) '
      'disponivel no fluxo de submissao.',
    );
  }

  Widget _buildFile(BuildContext context) {
    final builder = fileBuilder;
    if (builder != null) {
      return builder(question, value, onChanged);
    }
    return _infoBox(
      context,
      Icons.attach_file,
      'Anexo sera capturado no fluxo de submissao autorizado.',
    );
  }

  Widget _buildUnsupported(BuildContext context) {
    return _infoBox(
      context,
      Icons.help_outline,
      'Tipo de campo "${question.fieldType}" ainda nao suportado no app.',
    );
  }

  Widget _infoBox(BuildContext context, IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
