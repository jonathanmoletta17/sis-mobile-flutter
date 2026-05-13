import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/dtic/models/dtic_formcreator_models.dart';
import 'package:sis_mobile_flutter/dtic/widgets/dtic_searchable_select_field.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_radius.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_page_scaffold.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_section_header.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_status_chip.dart';
import 'package:sis_mobile_flutter/theme/app_status.dart';

enum DticFormCreatorSurfaceVariant { simple, largeSelect, complexBlocked }

class DticFormCreatorSurfacePreview extends StatelessWidget {
  const DticFormCreatorSurfacePreview({
    super.key,
    this.variant = DticFormCreatorSurfaceVariant.simple,
  });

  final DticFormCreatorSurfaceVariant variant;

  @override
  Widget build(BuildContext context) {
    final data = _DticFormCreatorPreviewData.forVariant(variant);

    return SisPageScaffold(
      title: data.title,
      subtitle: data.subtitle,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _GuardBanner(data: data),
          const SizedBox(height: AppSpacing.md),
          SisSectionHeader(
            title: data.formName,
            subtitle: data.formMeta,
            trailing: SisStatusChip(
              label: data.statusLabel,
              tone: data.statusTone,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final section in data.sections) ...[
            _PreviewSection(section: section),
            const SizedBox(height: AppSpacing.md),
          ],
          _ValidationFooter(data: data),
        ],
      ),
    );
  }
}

class _GuardBanner extends StatelessWidget {
  const _GuardBanner({required this.data});

  final _DticFormCreatorPreviewData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: data.guardTone == AppStatusTone.warning
            ? AppColors.warningSoft
            : AppColors.infoSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.guardIcon, color: data.guardColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              data.guardText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.section});

  final _PreviewSectionData section;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(section.title, style: Theme.of(context).textTheme.titleMedium),
            if (section.subtitle.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                section.subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            for (final field in section.fields) ...[
              _PreviewField(field: field),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewField extends StatelessWidget {
  const _PreviewField({required this.field});

  final _PreviewFieldData field;

  @override
  Widget build(BuildContext context) {
    final label = field.required ? '${field.label} *' : field.label;

    switch (field.kind) {
      case _PreviewFieldKind.text:
        return TextField(
          controller: TextEditingController(text: field.value),
          decoration: InputDecoration(labelText: label),
        );
      case _PreviewFieldKind.textarea:
        return TextField(
          controller: TextEditingController(text: field.value),
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(labelText: label),
        );
      case _PreviewFieldKind.integer:
        return TextField(
          controller: TextEditingController(text: field.value),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
        );
      case _PreviewFieldKind.select:
        return DticSearchableSelectField(
          label: field.label,
          required: field.required,
          value: field.value.isEmpty ? null : field.value,
          options: field.options,
          onChanged: (_) {},
        );
      case _PreviewFieldKind.date:
        return OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.event_outlined),
          label: Align(
            alignment: Alignment.centerLeft,
            child: Text(field.value.isEmpty ? label : field.value),
          ),
        );
      case _PreviewFieldKind.file:
        return OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.attach_file),
          label: Align(
            alignment: Alignment.centerLeft,
            child: Text(field.value.isEmpty ? label : field.value),
          ),
        );
      case _PreviewFieldKind.unsupported:
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warningSoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.block_outlined, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '$label\n${field.unavailableMessage}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _ValidationFooter extends StatelessWidget {
  const _ValidationFooter({required this.data});

  final _DticFormCreatorPreviewData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.footerText.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(data.footerText),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Revisar dados'),
        ),
      ],
    );
  }
}

enum _PreviewFieldKind {
  text,
  textarea,
  integer,
  select,
  date,
  file,
  unsupported,
}

class _DticFormCreatorPreviewData {
  const _DticFormCreatorPreviewData({
    required this.title,
    required this.subtitle,
    required this.formName,
    required this.formMeta,
    required this.statusLabel,
    required this.statusTone,
    required this.guardTone,
    required this.guardIcon,
    required this.guardColor,
    required this.guardText,
    required this.footerText,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final String formName;
  final String formMeta;
  final String statusLabel;
  final AppStatusTone statusTone;
  final AppStatusTone guardTone;
  final IconData guardIcon;
  final Color guardColor;
  final String guardText;
  final String footerText;
  final List<_PreviewSectionData> sections;

  static _DticFormCreatorPreviewData forVariant(
    DticFormCreatorSurfaceVariant variant,
  ) {
    return switch (variant) {
      DticFormCreatorSurfaceVariant.simple => _simple,
      DticFormCreatorSurfaceVariant.largeSelect => _largeSelect,
      DticFormCreatorSurfaceVariant.complexBlocked => _complexBlocked,
    };
  }

  static final _simple = _DticFormCreatorPreviewData(
    title: 'DTIC Mobile',
    subtitle: 'Nova solicitacao',
    formName: 'INCIDENTE',
    formMeta: '5 campos | 3 obrigatorios | 1 anexo',
    statusLabel: 'Pronto',
    statusTone: AppStatusTone.success,
    guardTone: AppStatusTone.info,
    guardIcon: Icons.lock_outline,
    guardColor: AppColors.info,
    guardText: 'Modo seguro: revise os dados no app sem criar chamado.',
    footerText:
        'Envio pelo aplicativo permanece bloqueado ate autorizacao explicita.',
    sections: [
      _PreviewSectionData(
        title: 'Dados do incidente',
        subtitle: 'Campos principais para registrar o atendimento',
        fields: [
          _PreviewFieldData.text(
            label: 'Assunto',
            required: true,
            value: 'Falha ao acessar sistema interno',
          ),
          _PreviewFieldData.textarea(
            label: 'Descricao do incidente',
            required: true,
            value:
                'Sistema apresenta erro ao autenticar com usuario de rede desde o inicio do expediente.',
          ),
          _PreviewFieldData.select(
            label: 'Tipo de servico',
            required: true,
            value: 'Rede',
            options: const [
              DticFormOption(value: 'Rede', label: 'Rede'),
              DticFormOption(value: 'Email', label: 'Email'),
              DticFormOption(value: 'Estacao', label: 'Estacao'),
            ],
          ),
          _PreviewFieldData.file(
            label: 'Evidencia',
            required: false,
            value: 'erro-login.png',
          ),
        ],
      ),
    ],
  );

  static final _largeSelect = _DticFormCreatorPreviewData(
    title: 'DTIC Mobile',
    subtitle: 'Opcoes pesquisaveis',
    formName: 'SISTEMAS INTERNOS',
    formMeta: 'Lista grande | busca local | sem escrita',
    statusLabel: 'Medio',
    statusTone: AppStatusTone.info,
    guardTone: AppStatusTone.info,
    guardIcon: Icons.manage_search_outlined,
    guardColor: AppColors.info,
    guardText:
        'Listas grandes precisam manter toque, busca e leitura confortaveis.',
    footerText:
        'Criterio visual: selects extensos nao podem estourar largura nem esconder obrigatoriedade.',
    sections: [
      _PreviewSectionData(
        title: 'Sistema e usuario',
        subtitle: 'Campo de sistema com muitas opcoes',
        fields: [
          _PreviewFieldData.select(
            label: 'Sistema',
            required: true,
            value: 'proa',
            options: _largeSystemOptions,
          ),
          _PreviewFieldData.text(
            label: 'Usuario de rede',
            required: true,
            value: 'jonathan-moletta',
          ),
          _PreviewFieldData.integer(
            label: 'Ramal',
            required: false,
            value: '2234',
          ),
          _PreviewFieldData.date(
            label: 'Data desejada',
            required: false,
            value: '2026-05-05',
          ),
        ],
      ),
    ],
  );

  static final _complexBlocked = _DticFormCreatorPreviewData(
    title: 'DTIC Mobile',
    subtitle: 'Campos condicionais',
    formName: 'EMAIL E APLICATIVOS OFFICE 365',
    formMeta: '42 campos | 32 obrigatorios | anexos',
    statusLabel: 'Validar',
    statusTone: AppStatusTone.warning,
    guardTone: AppStatusTone.warning,
    guardIcon: Icons.warning_amber_outlined,
    guardColor: AppColors.warning,
    guardText:
        'Alguns campos aparecem apenas conforme as respostas informadas.',
    footerText:
        'Envio continua bloqueado ate a janela autorizada de validacao.',
    sections: [
      _PreviewSectionData(
        title: 'Licenca e conta',
        subtitle: 'Campos exibidos conforme as opcoes selecionadas',
        fields: [
          _PreviewFieldData.select(
            label: 'Este atendimento e para quem?',
            required: true,
            value: 'outra_pessoa',
            options: const [
              DticFormOption(value: 'mim', label: 'Para mim'),
              DticFormOption(value: 'outra_pessoa', label: 'Para outra pessoa'),
            ],
          ),
          _PreviewFieldData.text(
            label: 'Nome do usuario',
            required: true,
            value: 'Maria Silva',
          ),
          _PreviewFieldData.unsupported(
            label: 'Plano de licenca dinamico',
            required: true,
            unavailableMessage:
                'Abra este atendimento pelo GLPI web enquanto este campo nao esta disponivel no app.',
          ),
          _PreviewFieldData.unsupported(
            label: 'Caixa compartilhada',
            required: false,
            unavailableMessage:
                'Este campo sera exibido no app quando estiver mapeado para o atendimento selecionado.',
          ),
        ],
      ),
    ],
  );
}

class _PreviewSectionData {
  const _PreviewSectionData({
    required this.title,
    required this.subtitle,
    required this.fields,
  });

  final String title;
  final String subtitle;
  final List<_PreviewFieldData> fields;
}

class _PreviewFieldData {
  const _PreviewFieldData._({
    required this.kind,
    required this.label,
    required this.required,
    this.value = '',
    this.options = const [],
    this.unavailableMessage = '',
  });

  factory _PreviewFieldData.text({
    required String label,
    required bool required,
    String value = '',
  }) {
    return _PreviewFieldData._(
      kind: _PreviewFieldKind.text,
      label: label,
      required: required,
      value: value,
    );
  }

  factory _PreviewFieldData.textarea({
    required String label,
    required bool required,
    String value = '',
  }) {
    return _PreviewFieldData._(
      kind: _PreviewFieldKind.textarea,
      label: label,
      required: required,
      value: value,
    );
  }

  factory _PreviewFieldData.integer({
    required String label,
    required bool required,
    String value = '',
  }) {
    return _PreviewFieldData._(
      kind: _PreviewFieldKind.integer,
      label: label,
      required: required,
      value: value,
    );
  }

  factory _PreviewFieldData.select({
    required String label,
    required bool required,
    required List<DticFormOption> options,
    String value = '',
  }) {
    return _PreviewFieldData._(
      kind: _PreviewFieldKind.select,
      label: label,
      required: required,
      value: value,
      options: options,
    );
  }

  factory _PreviewFieldData.date({
    required String label,
    required bool required,
    String value = '',
  }) {
    return _PreviewFieldData._(
      kind: _PreviewFieldKind.date,
      label: label,
      required: required,
      value: value,
    );
  }

  factory _PreviewFieldData.file({
    required String label,
    required bool required,
    String value = '',
  }) {
    return _PreviewFieldData._(
      kind: _PreviewFieldKind.file,
      label: label,
      required: required,
      value: value,
    );
  }

  factory _PreviewFieldData.unsupported({
    required String label,
    required bool required,
    required String unavailableMessage,
  }) {
    return _PreviewFieldData._(
      kind: _PreviewFieldKind.unsupported,
      label: label,
      required: required,
      unavailableMessage: unavailableMessage,
    );
  }

  final _PreviewFieldKind kind;
  final String label;
  final bool required;
  final String value;
  final List<DticFormOption> options;
  final String unavailableMessage;
}

const _largeSystemOptions = [
  DticFormOption(value: 'sei', label: 'SEI'),
  DticFormOption(value: 'proa', label: 'PROA'),
  DticFormOption(value: 'gce', label: 'GCE'),
  DticFormOption(value: 'expediente', label: 'Expediente Administrativo'),
  DticFormOption(value: 'email', label: 'Email institucional'),
  DticFormOption(value: 'rede', label: 'Rede e compartilhamentos'),
  DticFormOption(value: 'vpn', label: 'VPN'),
  DticFormOption(value: 'telefonia', label: 'Telefonia'),
  DticFormOption(value: 'assinador', label: 'Assinador digital'),
  DticFormOption(value: 'portal', label: 'Portal interno'),
  DticFormOption(value: 'bi', label: 'BI institucional'),
  DticFormOption(value: 'impressao', label: 'Servidor de impressao'),
];
