import 'package:flutter/material.dart';

import '../../config/glpi_config.dart';
import '../../state/app_state.dart';
import '../screens/sis_checklist_catalog_screen.dart';

/// Entrada para os checklists especializados na home de serviços.
///
/// So aparece quando: o preview carregou um catalogo (flag `*_PREVIEW=true`) E o
/// perfil ativo recebe ao menos um form pelo GLPI (`formcreator_forms_profiles`).
/// Caso contrario renderiza vazio — `Solicitante` e preview desligado nao veem.
class SisChecklistEntryCard extends StatelessWidget {
  const SisChecklistEntryCard({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final catalog = appState.checklistCatalog;
    if (catalog == null) return const SizedBox.shrink();

    final userGroupIds = appState.groups.map((g) => g.id).toList(growable: false);
    final forms = catalog.formsVisibleToUser(appState.activeProfileId, userGroupIds);
    if (forms.isEmpty) return const SizedBox.shrink();

    final targetCount =
        forms.fold<int>(0, (sum, form) => sum + catalog.targetsForForm(form.id).length);

    return Card(
      key: const Key('checklist_entry_card'),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.checklist_rtl),
        title: const Text('Checklists de manutenção'),
        subtitle: Text('${forms.length} formulário(s) · $targetCount item(ns)'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SisChecklistCatalogScreen(
              catalog: catalog,
              activeProfileId: appState.activeProfileId,
              userGroupIds: userGroupIds,
              submissionEnabled: GlpiConfig.sisChecklistSubmissionEnabled,
              onSubmit: appState.submitChecklist,
              ticketSearcher: appState.searchTicketsForChecklist,
            ),
          ),
        ),
      ),
    );
  }
}
