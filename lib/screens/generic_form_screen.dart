import 'package:flutter/material.dart';

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
      extraFieldsBuilder: service.hasExtraField
          ? (BuildContext _, Function(String?) onChanged) {
              return CustomDropdownField(
                label: service.extraFieldLabel!,
                items: service.extraFieldOptions,
                isRequired: true,
                onChanged: onChanged,
              );
            }
          : null,
    );
  }
}
