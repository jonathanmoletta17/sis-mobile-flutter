import 'package:flutter/material.dart';

import '../checklist_catalog.dart';
import '../checklist_submission.dart';

/// Estado da submissao para a UI de revisao.
enum ChecklistSubmissionState {
  /// Faltam campos obrigatorios visiveis.
  blocked,

  /// Pronto para revisar, mas a submissao do app esta desligada (preview).
  previewOnly,

  /// Pronto para submeter (somente quando ambas as flags estao ligadas).
  readyToSubmit,
}

/// Mostra as derivacoes do checklist (categoria/entidade/target), contagem de
/// campos visiveis/obrigatorios faltantes e o estado de submissao.
class ChecklistReviewPanel extends StatelessWidget {
  const ChecklistReviewPanel({
    super.key,
    required this.form,
    required this.target,
    required this.category,
    required this.submission,
    required this.state,
  });

  final SisChecklistForm form;
  final SisChecklistTarget target;
  final SisChecklistCategory? category;
  final SisChecklistPreparedSubmission submission;
  final ChecklistSubmissionState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revisão', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _row(context, 'Formulário', form.name),
            _row(context, 'Destino', target.name),
            _row(
              context,
              'Categoria',
              category != null
                  ? '${category!.completeName} (#${category!.id})'
                  : '#${submission.categoryId}',
            ),
            _row(context, 'Entidade', '#${submission.entityId}'),
            _row(
              context,
              'Campos visíveis',
              '${submission.visibleQuestionIds.length}',
            ),
            _row(
              context,
              'Obrigatórios faltando',
              '${submission.missingRequiredQuestionIds.length}',
            ),
            const SizedBox(height: 12),
            _statusBanner(context),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color, message) = switch (state) {
      ChecklistSubmissionState.blocked => (
        Icons.error_outline,
        theme.colorScheme.error,
        'Preencha os campos obrigatórios visíveis para revisar.',
      ),
      ChecklistSubmissionState.previewOnly => (
        Icons.visibility_outlined,
        theme.colorScheme.primary,
        'Modo somente leitura: submissão de checklist desabilitada no app.',
      ),
      ChecklistSubmissionState.readyToSubmit => (
        Icons.check_circle_outline,
        Colors.green,
        'Pronto para enviar em ambiente autorizado.',
      ),
    };

    return Container(
      key: const Key('checklist_status_banner'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
