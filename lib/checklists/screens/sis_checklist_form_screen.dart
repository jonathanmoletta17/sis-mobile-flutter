import 'package:flutter/material.dart';

import '../checklist_catalog.dart';
import '../checklist_condition_engine.dart';
import '../checklist_submission.dart';
import '../widgets/checklist_question_field.dart';
import '../widgets/checklist_review_panel.dart';

/// Renderiza e valida um target de checklist em modo read-only por padrao.
///
/// A submissao FormCreator e Phase 7: so aparece quando [submissionEnabled] e
/// [onSubmit] estao presentes (ou seja, ambas as flags ligadas e ambiente
/// autorizado). Sem isso, a tela opera como preview/revisao.
class SisChecklistFormScreen extends StatefulWidget {
  const SisChecklistFormScreen({
    super.key,
    required this.catalog,
    required this.formId,
    required this.targetId,
    this.submissionEnabled = false,
    this.onSubmit,
  });

  final SisChecklistCatalog catalog;
  final int formId;
  final int targetId;
  final bool submissionEnabled;

  /// Callback de submissao real (Phase 7). Recebe a submissao preparada e
  /// devolve um mapa de resultado da mutacao.
  final Future<Map<String, dynamic>> Function(SisChecklistPreparedSubmission)? onSubmit;

  @override
  State<SisChecklistFormScreen> createState() => _SisChecklistFormScreenState();
}

class _SisChecklistFormScreenState extends State<SisChecklistFormScreen> {
  final Map<int, dynamic> _answers = {};
  late final SisChecklistConditionEngine _engine;
  late final SisChecklistSubmissionPreparer _preparer;
  bool _submitting = false;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _engine = SisChecklistConditionEngine(widget.catalog);
    _preparer = SisChecklistSubmissionPreparer(
      catalog: widget.catalog,
      conditionEngine: _engine,
    );
    _prefillFromTargetConditions();
  }

  // Pre-preenche as perguntas de "Local" (e similares) com base nas condicoes
  // que disparam este target especifico. Cada condicao igual (showCondition=1)
  // sobre o target define qual resposta faz aquele target ser alcancado — é
  // exatamente o valor que o usuario selecionaria para esse target aparecer.
  //
  // Multiselect recebe List<String> (necessario para o widget de checkbox
  // marcar visualmente); select e radios recebem String diretamente.
  void _prefillFromTargetConditions() {
    final conditions = widget.catalog.conditionsFor(
        SisChecklistCondition.targetTicketItemType, widget.targetId);
    if (conditions.isEmpty) return;

    final questionsById = {
      for (final q in widget.catalog.questionsForForm(widget.formId)) q.id: q,
    };

    for (final condition in conditions) {
      if (condition.showCondition == 1 && condition.sourceQuestionId > 0) {
        final q = questionsById[condition.sourceQuestionId];
        final value = (q?.isMultiselect == true)
            ? <String>[condition.showValue]
            : condition.showValue;
        _answers.putIfAbsent(condition.sourceQuestionId, () => value);
      }
    }
  }

  SisChecklistForm get _form => widget.catalog.formById(widget.formId)!;
  SisChecklistTarget get _target => widget.catalog.targetById(widget.targetId)!;

  void _setAnswer(int questionId, dynamic value) {
    setState(() => _answers[questionId] = value);
  }

  bool get _canSubmit =>
      widget.submissionEnabled && widget.onSubmit != null;

  @override
  Widget build(BuildContext context) {
    final submission = _preparer.prepare(
      formId: widget.formId,
      targetId: widget.targetId,
      answers: _answers,
    );
    final category = widget.catalog.categoryById(_target.categoryId);

    final ChecklistSubmissionState state;
    if (!submission.canReview) {
      state = ChecklistSubmissionState.blocked;
    } else if (_canSubmit) {
      state = ChecklistSubmissionState.readyToSubmit;
    } else {
      state = ChecklistSubmissionState.previewOnly;
    }

    return Scaffold(
      appBar: AppBar(title: Text(_target.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._buildSections(),
          const SizedBox(height: 16),
          ChecklistReviewPanel(
            form: _form,
            target: _target,
            category: category,
            submission: submission,
            state: state,
          ),
          if (_resultMessage != null) ...[
            const SizedBox(height: 12),
            Text(_resultMessage!, key: const Key('checklist_result_message')),
          ],
          const SizedBox(height: 16),
          _buildAction(submission, state),
        ],
      ),
    );
  }

  List<Widget> _buildSections() {
    final widgets = <Widget>[];
    final sections = widget.catalog.sectionsForForm(widget.formId);
    for (final section in sections) {
      if (!_engine.isSectionVisible(section, _answers)) continue;
      final questions = widget.catalog
          .questionsForSection(section.id)
          .where((question) => _engine.isQuestionVisible(question, _answers))
          .toList();
      if (questions.isEmpty) continue;
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(section.name, style: Theme.of(context).textTheme.titleMedium),
      ));
      for (final question in questions) {
        widgets.add(ChecklistQuestionField(
          question: question,
          value: _answers[question.id],
          onChanged: (value) => _setAnswer(question.id, value),
        ));
      }
    }
    return widgets;
  }

  Widget _buildAction(
    SisChecklistPreparedSubmission submission,
    ChecklistSubmissionState state,
  ) {
    if (!_canSubmit) {
      return FilledButton.tonalIcon(
        key: const Key('checklist_review_button'),
        onPressed: submission.canReview ? () {} : null,
        icon: const Icon(Icons.fact_check_outlined),
        label: const Text('Revisar dados'),
      );
    }

    return FilledButton.icon(
      key: const Key('checklist_submit_button'),
      onPressed: (submission.canReview && !_submitting)
          ? () => _submit(submission)
          : null,
      icon: _submitting
          ? const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.send_outlined),
      label: const Text('Enviar'),
    );
  }

  Future<void> _submit(SisChecklistPreparedSubmission submission) async {
    final onSubmit = widget.onSubmit;
    if (onSubmit == null) return;
    setState(() {
      _submitting = true;
      _resultMessage = null;
    });
    try {
      final result = await onSubmit(submission);
      if (!mounted) return;
      final success = result['success'] == true;
      setState(() {
        _resultMessage = success
            ? 'Checklist enviado. Ticket: ${result['ticket_id'] ?? '—'}'
            : 'Falha: ${result['message'] ?? 'erro desconhecido'}';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
