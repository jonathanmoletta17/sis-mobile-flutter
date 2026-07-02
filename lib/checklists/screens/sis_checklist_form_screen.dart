import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/glpi_ticket_support.dart';
import '../../widgets/anexar_arquivo_widget.dart';
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
    this.preselectedType,
    this.ticketSearcher,
    this.conservacaoSearcher,
    this.conservacaoResolver,
  });

  final SisChecklistCatalog catalog;
  final int formId;
  final int targetId;
  final bool submissionEnabled;

  /// Tipo de manutencao pre-selecionado na tela de catalogo ("PREVENTIVA" ou
  /// "CORRETIVA"). Quando presente, sobrepoe o defaultValue da pergunta
  /// "Checklist" do formulario. Permite que o usuario escolha o tipo antes de
  /// abrir o form, replicando o fluxo do helpdesk web do GLPI.
  final String? preselectedType;

  /// Busca de chamados para o campo "Checklist Programada" (glpiselect/Ticket).
  final Future<List<Map<String, dynamic>>> Function(String query)?
  ticketSearcher;

  /// Busca de itens de conservação física para campos glpiselect/PluginGenericobjectConservacao.
  final Future<List<Map<String, dynamic>>> Function(String query)?
  conservacaoSearcher;

  /// Resolve nome de item Conservacao por ID (para pré-popular default_values).
  final Future<String?> Function(int id)? conservacaoResolver;

  /// Callback de submissao real. Recebe a submissao preparada e devolve um
  /// mapa de resultado da mutacao.
  final Future<Map<String, dynamic>> Function(SisChecklistPreparedSubmission)?
  onSubmit;

  @override
  State<SisChecklistFormScreen> createState() => _SisChecklistFormScreenState();
}

class _SisChecklistFormScreenState extends State<SisChecklistFormScreen> {
  final Map<int, dynamic> _answers = {};
  late final SisChecklistConditionEngine _engine;
  late final SisChecklistSubmissionPreparer _preparer;
  bool _submitting = false;
  String? _resultMessage;
  // IDs de questões com resolução de default em andamento (evita duplicatas).
  final Set<int> _pendingResolutions = {};

  @override
  void initState() {
    super.initState();
    _engine = SisChecklistConditionEngine(widget.catalog);
    _preparer = SisChecklistSubmissionPreparer(
      catalog: widget.catalog,
      conditionEngine: _engine,
    );
    _prefillFromTargetConditions();
    _initDefaultValues();
    _resolveVisibleConservacaoDefaults();
  }

  // Inicializa respostas a partir dos valores padrao das perguntas. Executado
  // APOS _prefillFromTargetConditions para que condicoes de target tenham
  // prioridade (o guard containsKey abaixo pula questoes ja preenchidas).
  // A pergunta "Checklist" (PREVENTIVA/CORRETIVA) usa [preselectedType] se fornecido.
  // Campos glpiselect sao ignorados: seus default_values sao IDs numericos do GLPI
  // que nao podem ser exibidos sem resolucao de nome via API.
  void _initDefaultValues() {
    for (final question in widget.catalog.questionsForForm(widget.formId)) {
      if (_answers.containsKey(question.id)) continue;
      if (question.isGlpiSelect) continue;
      final isChecklistTypeField =
          question.name == 'Checklist' &&
          question.isSelect &&
          question.rawValues.contains('PREVENTIVA');
      final rawDefault = isChecklistTypeField && widget.preselectedType != null
          ? widget.preselectedType!
          : question.defaultValues;
      if (rawDefault.isEmpty) continue;
      if (question.isMultiselect) {
        final list = _parseMultiselectDefault(rawDefault);
        if (list.isEmpty) continue;
        _answers[question.id] = list;
      } else {
        _answers[question.id] = rawDefault;
      }
    }
  }

  // Parseia default_values de campo multiselect: tenta JSON array primeiro
  // (formato do GLPI: '["A","B"]' ou '[]'), com fallback para CSV.
  // Retorna lista vazia se rawDefault for um array JSON vazio.
  static List<String> _parseMultiselectDefault(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // Percorre as questões atualmente visíveis e dispara resolução assíncrona de
  // default_values para campos glpiselect/Conservacao ainda não preenchidos.
  // Chamado no initState e após cada mudança de resposta para cobrir campos que
  // se tornam visíveis condicionalmente (show_rule=2).
  void _resolveVisibleConservacaoDefaults() {
    final resolver = widget.conservacaoResolver;
    if (resolver == null) return;
    for (final section in widget.catalog.sectionsForForm(widget.formId)) {
      if (!_engine.isSectionVisible(section, _answers)) continue;
      for (final q in widget.catalog.questionsForSection(section.id)) {
        if (!_engine.isQuestionVisible(q, _answers)) continue;
        if (!q.isGlpiSelect) continue;
        if (q.itemType != 'PluginGenericobjectConservacao') continue;
        if (_answers.containsKey(q.id)) continue;
        if (_pendingResolutions.contains(q.id)) continue;
        final id = int.tryParse(q.defaultValues);
        if (id == null || id <= 0) continue;
        _resolveConservacaoDefault(resolver, q.id, id);
      }
    }
  }

  Future<void> _resolveConservacaoDefault(
    Future<String?> Function(int) resolver,
    int questionId,
    int itemId,
  ) async {
    _pendingResolutions.add(questionId);
    try {
      final name = await resolver(itemId);
      if (!mounted) return;
      // Só preenche se o usuário ainda não interagiu com o campo.
      if (name != null &&
          name.isNotEmpty &&
          !_answers.containsKey(questionId)) {
        setState(() => _answers[questionId] = name);
      }
    } finally {
      _pendingResolutions.remove(questionId);
    }
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
      SisChecklistCondition.targetTicketItemType,
      widget.targetId,
    );
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
    // Após cada mudança de resposta, campos condicionais podem ter ficado
    // visíveis — resolve defaults de Conservacao para os recém-visíveis.
    _resolveVisibleConservacaoDefaults();
  }

  bool get _canSubmit => widget.submissionEnabled && widget.onSubmit != null;

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
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            section.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
      for (final question in questions) {
        widgets.add(
          ChecklistQuestionField(
            question: question,
            value: _answers[question.id],
            onChanged: (value) => _setAnswer(question.id, value),
            glpiSelectBuilder: _glpiSelectBuilder,
            fileBuilder: _fileBuilder,
          ),
        );
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
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
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
      final attachmentWarning = result['attachment_warning']?.toString();
      setState(() {
        if (!success) {
          _resultMessage = 'Falha: ${result['message'] ?? 'erro desconhecido'}';
        } else if (attachmentWarning != null && attachmentWarning.isNotEmpty) {
          _resultMessage =
              '⚠️ Checklist enviado. Ticket: ${result['ticket_id'] ?? '—'}, '
              'mas houve falha em anexo. $attachmentWarning';
        } else {
          _resultMessage = 'Checklist enviado. Ticket: ${result['ticket_id'] ?? '—'}';
        }
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget Function(SisChecklistQuestion, dynamic, ValueChanged<dynamic>)
  get _glpiSelectBuilder {
    final ticketSearcher = widget.ticketSearcher;
    final conservacaoSearcher = widget.conservacaoSearcher;
    return (question, value, onChanged) {
      if (question.itemType == 'Ticket' && ticketSearcher != null) {
        return _GlpiItemSelectField(
          question: question,
          value: value,
          onChanged: onChanged,
          searcher: ticketSearcher,
          placeholder: 'Selecionar chamado...',
          widgetKey: const Key('checklist_glpiselect_field'),
        );
      }
      if (question.itemType == 'PluginGenericobjectConservacao' &&
          conservacaoSearcher != null) {
        return _GlpiItemSelectField(
          question: question,
          value: value,
          onChanged: onChanged,
          searcher: conservacaoSearcher,
          placeholder: 'Selecionar item de inventário...',
          widgetKey: Key('checklist_conservacao_${question.id}'),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
            prefixIcon: Icon(Icons.inventory_2_outlined),
          ),
          child: Text(
            'Item de inventário — seleção disponível no GLPI web.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    };
  }

  // Captura anexo(s) de uma pergunta `file` reaproveitando o mesmo picker do
  // fluxo normal de ticket. Key por question.id para o AnexarArquivoWidget
  // preservar a seleção do usuário através dos rebuilds de _setAnswer (que
  // acontecem a cada resposta de QUALQUER pergunta na tela, não só desta).
  Widget _fileBuilder(
    SisChecklistQuestion question,
    dynamic value,
    ValueChanged<dynamic> onChanged,
  ) {
    return AnexarArquivoWidget(
      key: Key('checklist_file_${question.id}'),
      onFilesSelected: (files) {
        onChanged(
          files
              .map(
                (file) => GlpiTicketAttachment(
                  bytes: file.bytes ?? const [],
                  filename: file.name,
                ),
              )
              // Backstop: AnexarArquivoWidget já rejeita/avisa arquivo com
              // bytes vazio antes de chamar onFilesSelected — este filtro só
              // protege contra o contrato do widget mudar sem este código
              // acompanhar.
              .where((attachment) => attachment.bytes.isNotEmpty)
              .toList(),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Widget generico de seleção de item glpiselect (Ticket, Conservacao, etc.)
// ---------------------------------------------------------------------------

class _GlpiItemSelectField extends StatelessWidget {
  const _GlpiItemSelectField({
    required this.question,
    required this.value,
    required this.onChanged,
    required this.searcher,
    required this.placeholder,
    required this.widgetKey,
  });

  final SisChecklistQuestion question;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final Future<List<Map<String, dynamic>>> Function(String) searcher;
  final String placeholder;
  final Key widgetKey;

  Future<void> _openSearch(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _ItemSearchSheet(searcher: searcher, placeholder: placeholder),
    );
    if (result != null) {
      onChanged(result['name']?.toString() ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value.toString().isNotEmpty;
    return InkWell(
      key: widgetKey,
      onTap: () => _openSearch(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        child: Text(
          hasValue ? value.toString() : placeholder,
          style: TextStyle(
            color: hasValue ? null : Theme.of(context).hintColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ItemSearchSheet extends StatefulWidget {
  const _ItemSearchSheet({required this.searcher, required this.placeholder});

  final Future<List<Map<String, dynamic>>> Function(String) searcher;
  final String placeholder;

  @override
  State<_ItemSearchSheet> createState() => _ItemSearchSheetState();
}

class _ItemSearchSheetState extends State<_ItemSearchSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await widget.searcher(query);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Falha ao buscar itens.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final sheetHeight = MediaQuery.of(context).size.height * 0.65;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: _onQueryChanged,
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : _results.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum item encontrado.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (ctx, i) {
                        final item = _results[i];
                        final id = item['id'];
                        final name = item['name']?.toString() ?? '';
                        return ListTile(
                          key: Key('item_result_$id'),
                          title: Text(name, overflow: TextOverflow.ellipsis),
                          subtitle: Text('#$id'),
                          onTap: () => Navigator.of(ctx).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
