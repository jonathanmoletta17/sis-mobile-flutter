import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/checklists/checklist_catalog.dart';
import 'package:sis_mobile_flutter/checklists/screens/sis_checklist_catalog_screen.dart';
import 'package:sis_mobile_flutter/checklists/screens/sis_checklist_form_screen.dart';

/// Variantes do preview de checklist SIS (read-only).
enum SisChecklistSurfaceVariant {
  /// Entrada visivel para Super-Admin (profile 4).
  catalogSuperAdmin,

  /// Solicitante (profile 11) nao recebe os forms => estado vazio.
  catalogSolicitante,

  /// Formulario com campo obrigatorio visivel faltando (revisao bloqueada).
  formMissingRequired,
}

class SisChecklistSurfacePreview extends StatelessWidget {
  const SisChecklistSurfacePreview({
    super.key,
    this.variant = SisChecklistSurfaceVariant.catalogSuperAdmin,
  });

  final SisChecklistSurfaceVariant variant;

  @override
  Widget build(BuildContext context) {
    final catalog = _previewCatalog();
    return switch (variant) {
      // Super-Admin (profile 4) enxerga via profile_ids — sem necessidade de grupos.
      SisChecklistSurfaceVariant.catalogSuperAdmin =>
        SisChecklistCatalogScreen(
            catalog: catalog, activeProfileId: 4, userGroupIds: const []),
      // Perfil 11 sem grupo 22 => nenhum form disponivel (estado vazio).
      SisChecklistSurfaceVariant.catalogSolicitante =>
        SisChecklistCatalogScreen(
            catalog: catalog, activeProfileId: 11, userGroupIds: const []),
      SisChecklistSurfaceVariant.formMissingRequired =>
        SisChecklistFormScreen(catalog: catalog, formId: 50, targetId: 341),
    };
  }
}

SisChecklistCatalog _previewCatalog() {
  return SisChecklistCatalog.fromMap({
    'schema_version': 'preview',
    'source_snapshot_sha256': 'preview',
    'forms': [
      {'id': 50, 'name': 'CHECKLIST HIDRÁULICO', 'is_active': true, 'is_visible': true, 'helpdesk_home': true, 'profile_ids': [4], 'group_ids': [22]},
    ],
    'sections': [
      {'id': 500, 'form_id': 50, 'name': 'Dados Gerais', 'order': 1},
    ],
    'questions': [
      {'id': 0, 'form_id': 50, 'section_id': 500, 'name': 'Checklist', 'fieldtype': 'select', 'required': false, 'show_rule': 1, 'row': 0, 'col': 0, 'width': 4, 'values': '["CORRETIVA","PREVENTIVA"]', 'default_values': 'PREVENTIVA'},
      {'id': 1, 'form_id': 50, 'section_id': 500, 'name': 'Local', 'fieldtype': 'select', 'required': true, 'show_rule': 1, 'row': 1, 'col': 0, 'width': 4, 'values': '["ALA RESIDENCIAL","ALA GOVERNAMENTAL"]'},
      {'id': 4, 'form_id': 50, 'section_id': 500, 'name': 'Checklist Programada', 'fieldtype': 'glpiselect', 'itemtype': 'Ticket', 'required': false, 'show_rule': 1, 'row': 2, 'col': 0, 'width': 4, 'values': '{"entity_restrict":"2"}'},
      {'id': 2, 'form_id': 50, 'section_id': 500, 'name': 'Observações', 'fieldtype': 'textarea', 'required': false, 'show_rule': 1, 'row': 3, 'col': 0, 'width': 4},
    ],
    'conditions': const [],
    'targets': [
      {'id': 341, 'form_id': 50, 'name': 'HIDRÁULICO ALA RESIDENCIAL', 'destination_entity_value': 58, 'category_rule': 2, 'category_id': 151, 'location_rule': 2, 'urgency_rule': 1, 'type_rule': 1, 'show_rule': 2},
    ],
    'categories': [
      {'id': 151, 'name': 'Hidraulico', 'completename': 'Manutenção > Checklist > Hidráulico', 'parent_id': 147, 'level': 3},
    ],
  });
}
