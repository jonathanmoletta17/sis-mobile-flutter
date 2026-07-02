import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../data/service_data.dart';
import '../widgets/custom_dropdown_field.dart';
import 'form_template.dart';

class GenericFormScreen extends StatelessWidget {
  final ServiceCategory service;

  const GenericFormScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return FormTemplate(
      serviceName: service.name,
      localizacaoOptions: service.displayLocations,
      locationOptions: service.effectiveLocationOptions,
      tipoServicoOptions: service.typeOptions,
      urgenciaOptions: service.urgencyOptions,
      includeNomePessoa: service.includeNomePessoa,
      includeUrgencia: service.includeUrgencia,
      includeLocalizacao: service.includeLocalizacao,
      includeAnexo: service.includeAnexo,
      domainLabel: service.domainLabel,
      assignmentGroupLabel: service.assignmentGroupLabel,
      uiSchemaSource: service.uiSchemaSource,
      runtimeFormStatus: service.runtimeFormStatus,
      governedRecords: service.governedRecords,
      extraFieldBlocked: service.extraFieldPendingDynamicSource,
      extraFieldsBuilder: service.hasExtraField
          ? (BuildContext _, Function(String?) onChanged) {
              return CustomDropdownField(
                label: service.extraFieldLabel!,
                items: service.extraFieldOptions,
                isRequired: true,
                onChanged: onChanged,
              );
            }
          : service.extraFieldPendingDynamicSource
          ? (BuildContext _, Function(String?) __) =>
                _ExtraFieldUnavailable(label: service.extraFieldLabel!)
          : null,
    );
  }
}

/// Mostrado no lugar do campo extra quando o GLPI real exige uma pergunta
/// (ex.: escolher a entidade/divisão) que este app ainda não resolve
/// dinamicamente. Bloqueia o envio em vez de oferecer opções inventadas.
class _ExtraFieldUnavailable extends StatelessWidget {
  final String label;

  const _ExtraFieldUnavailable({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.danger),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          color: AppColors.danger.withValues(alpha: 0.06),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label é obrigatório neste tipo de solicitação, mas o app '
                'ainda não tem como buscar essa lista do GLPI dinamicamente. '
                'Abra este chamado pelo GLPI web até isso ser resolvido.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
