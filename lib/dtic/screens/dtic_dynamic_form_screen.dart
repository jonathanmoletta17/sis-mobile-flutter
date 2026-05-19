import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/ui/sis_empty_state.dart';
import '../../widgets/ui/sis_page_scaffold.dart';
import '../config/dtic_config.dart';
import '../models/dtic_formcreator_models.dart';
import '../state/dtic_app_state.dart';
import '../widgets/dtic_searchable_select_field.dart';

class DticDynamicFormScreen extends StatefulWidget {
  const DticDynamicFormScreen({super.key, required this.form});

  final DticForm form;

  @override
  State<DticDynamicFormScreen> createState() => _DticDynamicFormScreenState();
}

class _DticDynamicFormScreenState extends State<DticDynamicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, dynamic> _answers = {};

  void _setAnswer(int questionId, dynamic value) {
    setState(() => _answers[questionId] = value);
  }

  Future<void> _pickFiles(DticFormQuestion question) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    final names = result.files
        .map((file) => file.name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    _setAnswer(question.id, names);
  }

  Future<void> _pickDate(DticFormQuestion question) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (selected == null) return;
    _setAnswer(question.id, selected.toIso8601String().split('T').first);
  }

  void _validateOnly(List<DticFormQuestion> questions) {
    if (!_formKey.currentState!.validate()) return;
    final prepared = context.read<DticAppState>().validateFormAnswers(
      widget.form,
      questions,
      _answers,
    );
    final canValidate = prepared.canSubmitDryRun;
    final hasUnsupported = prepared.hasUnsupportedQuestions;

    final title = canValidate
        ? 'Dados prontos para envio'
        : hasUnsupported
        ? 'Atendimento parcialmente indisponivel'
        : 'Revise os campos obrigatorios';
    final message = canValidate
        ? 'Nenhum chamado foi criado. O envio pelo aplicativo segue bloqueado ate autorizacao explicita.'
        : hasUnsupported
        ? 'Este atendimento tem campo ainda indisponivel no app. Use o GLPI web para concluir esta solicitacao.'
        : 'Preencha os campos obrigatorios exibidos na tela ou abra este atendimento pelo GLPI web quando houver campo ainda indisponivel no app.';

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<DticAppState>().catalog;
    if (catalog == null) {
      return SisPageScaffold(
        title: widget.form.name,
        body: const SisEmptyState(
          icon: Icons.dynamic_form_outlined,
          title: 'Catalogo indisponivel',
          message: 'Recarregue o catalogo DTIC antes de abrir o formulario.',
        ),
      );
    }

    final sections = catalog.sectionsForForm(widget.form.id);
    final visibleSections = sections
        .where((section) => catalog.isSectionVisible(section, _answers))
        .toList();
    final visibleQuestions = visibleSections
        .expand(
          (section) => catalog
              .questionsForSection(section.id)
              .where((question) => question.formId == widget.form.id)
              .where(
                (question) => catalog.isQuestionVisible(question, _answers),
              ),
        )
        .toList();
    final allQuestions = sections
        .expand(
          (section) => catalog
              .questionsForSection(section.id)
              .where((question) => question.formId == widget.form.id),
        )
        .toList();
    final unsupportedCount = visibleQuestions
        .where((question) => !question.isSupported)
        .length;
    final hasVisibleFields = visibleQuestions.isNotEmpty;
    final hasConfiguredFields = allQuestions.isNotEmpty;

    final sectionQuestions = {
      for (final section in visibleSections)
        section.id: catalog
            .questionsForSection(section.id)
            .where((question) => question.formId == widget.form.id)
            .where((question) => catalog.isQuestionVisible(question, _answers))
            .toList(),
    };

    sectionQuestions.removeWhere((_, questions) => questions.isEmpty);

    final renderableQuestions = visibleQuestions
        .where((question) => question.isRenderable)
        .toList();
    final reviewQuestions = visibleQuestions;

    final buttonEnabled =
        hasVisibleFields && !context.watch<DticAppState>().isBusy;

    return SisPageScaffold(
      title: widget.form.name,
      subtitle: 'Nova solicitacao',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _GuardBanner(
              submissionEnabled: DticConfig.formSubmissionEnabled,
              unsupportedCount: unsupportedCount,
            ),
            const SizedBox(height: AppSpacing.md),
            if (sections.isEmpty || !hasConfiguredFields)
              const SisEmptyState(
                icon: Icons.view_list_outlined,
                title: 'Atendimento sem campos',
                message:
                    'O GLPI DTIC nao retornou campos para este atendimento.',
              )
            else if (sectionQuestions.isEmpty)
              const SisEmptyState(
                icon: Icons.rule_outlined,
                title: 'Escolha as opcoes iniciais',
                message:
                    'Alguns campos aparecem conforme as respostas informadas.',
              )
            else
              for (final section in visibleSections)
                _SectionCard(
                  section: section,
                  questions: sectionQuestions[section.id] ?? const [],
                  answers: _answers,
                  onChanged: _setAnswer,
                  onPickDate: _pickDate,
                  onPickFiles: _pickFiles,
                ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: buttonEnabled
                  ? () => _validateOnly(reviewQuestions)
                  : null,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Revisar dados'),
            ),
            if (renderableQuestions.length != visibleQuestions.length) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Este atendimento tem campo ainda indisponivel no app.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuardBanner extends StatelessWidget {
  const _GuardBanner({
    required this.submissionEnabled,
    required this.unsupportedCount,
  });

  final bool submissionEnabled;
  final int unsupportedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: submissionEnabled || unsupportedCount > 0
            ? AppColors.warningSoft
            : AppColors.infoSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            submissionEnabled || unsupportedCount > 0
                ? Icons.warning_amber_outlined
                : Icons.lock_outline,
            color: submissionEnabled || unsupportedCount > 0
                ? AppColors.warning
                : AppColors.info,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              unsupportedCount > 0
                  ? 'Este atendimento tem campo ainda indisponivel no app. Nenhum chamado sera criado nesta etapa.'
                  : 'Modo seguro: revise os dados no app. O envio ainda nao cria chamado sem autorizacao explicita.',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.questions,
    required this.answers,
    required this.onChanged,
    required this.onPickDate,
    required this.onPickFiles,
  });

  final DticFormSection section;
  final List<DticFormQuestion> questions;
  final Map<int, dynamic> answers;
  final void Function(int questionId, dynamic value) onChanged;
  final Future<void> Function(DticFormQuestion question) onPickDate;
  final Future<void> Function(DticFormQuestion question) onPickFiles;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(section.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            for (final question in questions) ...[
              if (!question.isRenderable)
                _BlockedQuestionField(
                  question: question,
                  reason: question.blockReason,
                )
              else
                _QuestionField(
                  question: question,
                  value: answers[question.id],
                  onChanged: (value) => onChanged(question.id, value),
                  onPickDate: () => onPickDate(question),
                  onPickFiles: () => onPickFiles(question),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuestionField extends StatelessWidget {
  const _QuestionField({
    required this.question,
    required this.value,
    required this.onChanged,
    required this.onPickDate,
    required this.onPickFiles,
  });

  final DticFormQuestion question;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final VoidCallback onPickDate;
  final VoidCallback onPickFiles;

  @override
  Widget build(BuildContext context) {
    final label = question.required ? '${question.name} *' : question.name;
    final helper = question.description;
    final initialText = value?.toString() ?? question.defaultValue;

    switch (question.fieldType) {
      case 'textarea':
        return TextFormField(
          initialValue: initialText,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(labelText: label, helperText: helper),
          onChanged: onChanged,
          validator: _requiredValidator,
        );
      case 'integer':
        return TextFormField(
          initialValue: initialText,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label, helperText: helper),
          onChanged: onChanged,
          validator: _requiredValidator,
        );
      case 'hostname':
      case 'text':
        return TextFormField(
          initialValue: initialText,
          decoration: InputDecoration(labelText: label, helperText: helper),
          onChanged: onChanged,
          validator: _requiredValidator,
        );
      case 'select':
        return DticSearchableSelectField(
          label: question.name,
          value: value?.toString(),
          required: question.required,
          options: question.options,
          onChanged: onChanged,
        );
      case 'date':
        return _ButtonFormField(
          label: label,
          value: value,
          required: question.required,
          helper: helper,
          icon: Icons.event_outlined,
          onPressed: onPickDate,
        );
      case 'file':
        return _ButtonFormField(
          label: label,
          value: value is List ? (value as List).join(', ') : '',
          required: question.required,
          helper: helper,
          icon: Icons.attach_file,
          onPressed: onPickFiles,
        );
      default:
        return _BlockedQuestionField(
          question: question,
          reason: question.blockReason,
        );
    }
  }

  String? _requiredValidator(String? input) {
    if (!question.required) return null;
    if (input == null || input.trim().isEmpty) return 'Campo obrigatorio.';
    return null;
  }
}

class _ButtonFormField extends StatelessWidget {
  const _ButtonFormField({
    required this.label,
    required this.value,
    required this.required,
    required this.helper,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final dynamic value;
  final bool required;
  final String helper;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final text = value?.toString().trim() ?? '';

    return FormField<void>(
      validator: (_) {
        if (!required) return null;
        if (text.isEmpty) return 'Campo obrigatorio.';
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(text.isNotEmpty ? text : label),
              ),
            ),
            if (helper.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                helper,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
            if (field.errorText != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                field.errorText!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BlockedQuestionField extends StatelessWidget {
  const _BlockedQuestionField({required this.question, required this.reason});

  final DticFormQuestion question;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final label = question.required ? '${question.name} *' : question.name;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.block_outlined, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  reason.isEmpty
                      ? 'Este campo ainda nao esta disponivel no aplicativo.'
                      : reason,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
