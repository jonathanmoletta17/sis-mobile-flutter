import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_radius.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';
import 'package:sis_mobile_flutter/widgets/anexar_arquivo_widget.dart';
import 'package:sis_mobile_flutter/widgets/custom_dropdown_field.dart';
import 'package:sis_mobile_flutter/widgets/custom_text_field.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_page_scaffold.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_section_header.dart';

import '../workbench_surface.dart';
import 'workbench_fixtures.dart';

enum FormSurfaceVariant {
  pristine,
  seeded,
  validationError,
  submitting,
  submitted,
  offlineFallback,
}

class FormSurfacePreview extends StatefulWidget {
  final FormSurfaceVariant variant;

  const FormSurfacePreview({
    super.key,
    this.variant = FormSurfaceVariant.pristine,
  });

  @override
  State<FormSurfacePreview> createState() => _FormSurfacePreviewState();
}

class _FormSurfacePreviewState extends State<FormSurfacePreview> {
  final _nomePessoaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _assuntoController = TextEditingController();
  final _descricaoController = TextEditingController();

  String? _atendimentoPara;
  String? _localizacao;
  String? _urgencia;
  String? _tipo;
  String? _extraField;
  int _attachmentsCount = 0;

  bool get _isSeededVariant =>
      widget.variant == FormSurfaceVariant.seeded ||
      widget.variant == FormSurfaceVariant.submitting ||
      widget.variant == FormSurfaceVariant.submitted ||
      widget.variant == FormSurfaceVariant.offlineFallback;

  bool get _showValidation =>
      widget.variant == FormSurfaceVariant.validationError;

  bool get _isSubmitting => widget.variant == FormSurfaceVariant.submitting;

  @override
  void initState() {
    super.initState();
    if (_isSeededVariant) {
      _applySeededValues();
    }
  }

  void _applySeededValues() {
    _atendimentoPara = 'Para outra Pessoa';
    _localizacao = workbenchFormService.locations.first;
    _urgencia = workbenchFormService.urgencyOptions.last;
    _tipo = workbenchFormService.typeOptions.first;
    _extraField = workbenchFormService.extraFieldOptions.first;
    _attachmentsCount = 2;
    _nomePessoaController.text = 'Gabinete de projetos';
    _telefoneController.text = '(51) 3333-4444';
    _assuntoController.text = 'Vistoria em divisoria de vidro';
    _descricaoController.text =
        'Solicitacao de vistoria para identificar risco de trinca na divisoria '
        'da sala de reunioes. Avaliar medicao, troca e prazo de atendimento.';
  }

  @override
  void dispose() {
    _nomePessoaController.dispose();
    _telefoneController.dispose();
    _assuntoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _handleFilesSelected(List<dynamic> files) {
    setState(() {
      _attachmentsCount = files.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Solicitar: ${workbenchFormService.name}',
        subtitle: 'Preview do formulario-base com campos reais do produto',
        body: Form(
          autovalidateMode:
              _showValidation ? AutovalidateMode.always : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.variant == FormSurfaceVariant.submitted)
                  const _FormFeedbackBanner(
                    tone: _FormFeedbackTone.success,
                    title: 'Solicitacao pronta para envio online',
                    message:
                        'O preview explicita o retorno de sucesso que hoje aparece apenas por SnackBar no runtime.',
                  ),
                if (widget.variant == FormSurfaceVariant.offlineFallback)
                  const _FormFeedbackBanner(
                    tone: _FormFeedbackTone.warning,
                    title: 'Solicitacao salva localmente',
                    message:
                        'Sem conectividade com o GLPI. O chamado foi preservado offline e aguardara sincronizacao.',
                  ),
                const SisSectionHeader(
                  title: 'Dados gerais',
                  subtitle:
                      'Contexto do atendimento, pessoa atendida e localizacao operacional.',
                ),
                const SizedBox(height: AppSpacing.md),
                CustomDropdownField(
                  label: 'Este atendimento e para quem?',
                  items: const ['Para mim', 'Para outra Pessoa'],
                  isRequired: true,
                  initialValue: _atendimentoPara,
                  onChanged: (newValue) {
                    setState(() {
                      _atendimentoPara = newValue;
                    });
                  },
                ),
                if (_atendimentoPara == 'Para outra Pessoa')
                  CustomTextField(
                    label: 'Qual o nome desta pessoa?',
                    controller: _nomePessoaController,
                    isRequired: true,
                  ),
                CustomDropdownField(
                  label: 'Localizacao',
                  items: workbenchFormService.locations,
                  isRequired: true,
                  initialValue: _localizacao,
                  onChanged: (newValue) {
                    setState(() {
                      _localizacao = newValue;
                    });
                  },
                ),
                CustomTextField(
                  label: 'Telefone de Contato',
                  controller: _telefoneController,
                  isRequired: true,
                  keyboardType: TextInputType.phone,
                ),
                CustomDropdownField(
                  label: 'Urgencia',
                  items: workbenchFormService.urgencyOptions,
                  initialValue: _urgencia,
                  onChanged: (newValue) {
                    setState(() {
                      _urgencia = newValue;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const SisSectionHeader(
                  title: 'Detalhamento',
                  subtitle:
                      'Tipo de atendimento, assunto, descricao e contexto complementar.',
                ),
                const SizedBox(height: AppSpacing.md),
                CustomDropdownField(
                  label: 'Tipo',
                  items: workbenchFormService.typeOptions,
                  isRequired: true,
                  initialValue: _tipo,
                  onChanged: (newValue) {
                    setState(() {
                      _tipo = newValue;
                    });
                  },
                ),
                CustomTextField(
                  label: 'Assunto',
                  controller: _assuntoController,
                  isRequired: true,
                ),
                CustomTextField(
                  label: 'Descricao',
                  helperText: '(Indicar o local e o ocorrido)',
                  controller: _descricaoController,
                  isRequired: true,
                  maxLines: 5,
                ),
                if (workbenchFormService.hasExtraField)
                  CustomDropdownField(
                    label: workbenchFormService.extraFieldLabel!,
                    items: workbenchFormService.extraFieldOptions,
                    isRequired: true,
                    initialValue: _extraField,
                    onChanged: (newValue) {
                      setState(() {
                        _extraField = newValue;
                      });
                    },
                  ),
                AnexarArquivoWidget(onFilesSelected: _handleFilesSelected),
                if (_attachmentsCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      'Anexos selecionados no preview: $_attachmentsCount',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () {},
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('ENVIAR SOLICITACAO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _FormFeedbackTone { success, warning }

class _FormFeedbackBanner extends StatelessWidget {
  final _FormFeedbackTone tone;
  final String title;
  final String message;

  const _FormFeedbackBanner({
    required this.tone,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = tone == _FormFeedbackTone.success;
    final color = isSuccess ? AppColors.success : AppColors.warning;
    final background =
        isSuccess ? AppColors.successSoft : AppColors.warningSoft;
    final icon = isSuccess ? Icons.check_circle_outline : Icons.cloud_off_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textStrong,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
