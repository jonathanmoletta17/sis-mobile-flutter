import 'package:flutter/material.dart';

import '../checklist_catalog.dart';
import '../checklist_submission.dart';
import 'sis_checklist_form_screen.dart';

/// Superficie de entrada dos checklists especializados. Lista os forms que o
/// GLPI atribui ao usuario via perfil OU grupo (OR semantico, espelhando
/// `access_rights=2` do FormCreator — `formcreator_forms_profiles` + `Form_Group`).
class SisChecklistCatalogScreen extends StatelessWidget {
  const SisChecklistCatalogScreen({
    super.key,
    required this.catalog,
    required this.activeProfileId,
    this.userGroupIds = const [],
    this.submissionEnabled = false,
    this.onSubmit,
    this.ticketSearcher,
  });

  final SisChecklistCatalog catalog;
  final int? activeProfileId;

  /// Grupos do usuario na sessao GLPI (`glpigroups` de `getFullSession`).
  /// Passado como complemento ao perfil para gate OR: acesso por perfil OU grupo.
  final List<int> userGroupIds;

  final bool submissionEnabled;
  final Future<Map<String, dynamic>> Function(SisChecklistPreparedSubmission)? onSubmit;

  /// Busca de chamados para o campo "Checklist Programada" (glpiselect/Ticket).
  /// Quando presente, o campo se torna interativo no form screen.
  final Future<List<Map<String, dynamic>>> Function(String query)? ticketSearcher;

  @override
  Widget build(BuildContext context) {
    final forms = catalog.formsVisibleToUser(activeProfileId, userGroupIds);
    return Scaffold(
      appBar: AppBar(title: const Text('Checklists')),
      body: forms.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final form in forms) _FormGroup(form: form, screen: this),
              ],
            ),
    );
  }
}

class _FormGroup extends StatefulWidget {
  const _FormGroup({required this.form, required this.screen});

  final SisChecklistForm form;
  final SisChecklistCatalogScreen screen;

  @override
  State<_FormGroup> createState() => _FormGroupState();
}

class _FormGroupState extends State<_FormGroup> {
  // Tipo selecionado pelo operador antes de abrir o form. Espelha a primeira
  // pergunta "Checklist" que aparece em todos os forms (default: PREVENTIVA).
  String _selectedType = 'PREVENTIVA';

  void _openTarget(BuildContext context, SisChecklistTarget target) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SisChecklistFormScreen(
          catalog: widget.screen.catalog,
          formId: widget.form.id,
          targetId: target.id,
          submissionEnabled: widget.screen.submissionEnabled,
          onSubmit: widget.screen.onSubmit,
          preselectedType: _selectedType,
          ticketSearcher: widget.screen.ticketSearcher,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targets = widget.screen.catalog.targetsForForm(widget.form.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              widget.form.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SegmentedButton<String>(
              key: Key('checklist_type_${widget.form.id}'),
              segments: const [
                ButtonSegment(
                  value: 'PREVENTIVA',
                  label: Text('Preventiva'),
                  icon: Icon(Icons.check_circle_outline, size: 16),
                ),
                ButtonSegment(
                  value: 'CORRETIVA',
                  label: Text('Corretiva'),
                  icon: Icon(Icons.build_outlined, size: 16),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (selection) =>
                  setState(() => _selectedType = selection.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          for (final target in targets)
            ListTile(
              key: Key('checklist_target_${target.id}'),
              title: Text(target.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openTarget(context, target),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('checklist_empty_state'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checklist_rtl, size: 48),
            const SizedBox(height: 12),
            Text(
              'Nenhum checklist disponível para o seu perfil.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
