import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/service_data.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/anexar_arquivo_widget.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/ui/sis_page_scaffold.dart';
import '../widgets/ui/sis_section_header.dart';

class FormTemplate extends StatefulWidget {
  final String serviceName;
  final List<String> localizacaoOptions;
  final List<LocationOption> locationOptions;
  final List<String> tipoServicoOptions;
  final List<String> urgenciaOptions;
  final bool includeNomePessoa;
  final bool includeUrgencia;
  final bool includeLocalizacao;
  final bool includeAnexo;
  final String domainLabel;
  final String? assignmentGroupLabel;
  final String uiSchemaSource;
  final String? runtimeFormStatus;
  final Widget Function(BuildContext, Function(String?))? extraFieldsBuilder;

  const FormTemplate({
    super.key,
    required this.serviceName,
    required this.localizacaoOptions,
    this.locationOptions = const [],
    required this.tipoServicoOptions,
    this.urgenciaOptions = const [
      '3 - Média (Padrão)',
      '1 - Baixa',
      '5 - Alta',
    ],
    this.includeNomePessoa = true,
    this.includeUrgencia = true,
    this.includeLocalizacao = true,
    this.includeAnexo = true,
    this.domainLabel = 'Catálogo estático',
    this.assignmentGroupLabel,
    this.uiSchemaSource = 'static_bootstrap',
    this.runtimeFormStatus,
    this.extraFieldsBuilder,
  });

  @override
  State<FormTemplate> createState() => _FormTemplateState();
}

class _FormTemplateState extends State<FormTemplate> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomePessoaController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _assuntoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  String? _atendimentoPara;
  String? _localizacao;
  String? _urgencia;
  String? _tipoDetalhamento;
  String? _extraDropdownValue;

  final List<String> _anexoPaths = [];
  final List<String> _anexoNames = [];
  final List<Uint8List> _anexoBytesList = [];
  final List<String?> _anexoMimeTypes = [];

  dynamic _selectedLocationPayload() {
    if (!widget.includeLocalizacao) return 'Não Aplicável';
    final selected = _localizacao;
    if (selected == null || selected.trim().isEmpty) return 'Não Informado';

    for (final option in widget.locationOptions) {
      if (option.label == selected || option.fullLabel == selected) {
        return option.toPayload();
      }
    }

    return selected;
  }

  @override
  void dispose() {
    _nomePessoaController.dispose();
    _telefoneController.dispose();
    _assuntoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  String? _guessMimeType(String? filename) {
    if (filename == null || filename.trim().isEmpty) return null;
    final lower = filename.toLowerCase();

    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';

    return null;
  }

  Future<void> _onAnexosSelected(List<PlatformFile> files) async {
    if (files.isEmpty) {
      if (!mounted) return;
      setState(() {
        _anexoPaths.clear();
        _anexoNames.clear();
        _anexoBytesList.clear();
        _anexoMimeTypes.clear();
      });
      return;
    }

    final List<String> newPaths = [];
    final List<String> newNames = [];
    final List<Uint8List> newBytes = [];
    final List<String?> newMimes = [];

    for (final file in files) {
      Uint8List? bytes = file.bytes;

      if (bytes == null && file.path != null && file.path!.isNotEmpty) {
        try {
          bytes = await File(file.path!).readAsBytes();
        } catch (e) {
          debugPrint('Falha ao ler bytes do anexo (${file.name}): $e');
        }
      }

      if (bytes == null || bytes.isEmpty) continue;

      newPaths.add(file.path ?? '');
      newNames.add(file.name);
      newBytes.add(bytes);
      newMimes.add(_guessMimeType(file.name));
    }

    if (!mounted) return;
    setState(() {
      _anexoPaths
        ..clear()
        ..addAll(newPaths);
      _anexoNames
        ..clear()
        ..addAll(newNames);
      _anexoBytesList
        ..clear()
        ..addAll(newBytes);
      _anexoMimeTypes
        ..clear()
        ..addAll(newMimes);
    });
  }

  Future<void> _enviarFormulario() async {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);

      final dados = {
        'serviceName': widget.serviceName,
        'atendimentoPara': _atendimentoPara ?? 'Para mim',
        'nomePessoa':
            _atendimentoPara == 'Para outra Pessoa' && widget.includeNomePessoa
            ? _nomePessoaController.text
            : null,
        'localizacao': _selectedLocationPayload(),
        'telefone': _telefoneController.text,
        'urgencia': widget.includeUrgencia
            ? (_urgencia ?? '3 - Média (Padrão)')
            : null,
        'tipo': _tipoDetalhamento ?? '',
        'assunto': _assuntoController.text,
        'descricao': _descricaoController.text,
        'anexoPath': _anexoPaths.isNotEmpty ? _anexoPaths.first : null,
        'anexoName': _anexoNames.isNotEmpty ? _anexoNames.first : null,
        'attachmentBytes': _anexoBytesList.isNotEmpty
            ? _anexoBytesList.first
            : null,
        'attachmentName': _anexoNames.isNotEmpty ? _anexoNames.first : null,
        'attachmentMime': _anexoMimeTypes.isNotEmpty
            ? _anexoMimeTypes.first
            : null,
        'attachmentBytesList': _anexoBytesList,
        'attachmentNameList': _anexoNames,
        'attachmentMimeList': _anexoMimeTypes,
        'CampoExtra': widget.extraFieldsBuilder != null
            ? _extraDropdownValue
            : null,
      };

      final String message = await appState.submitTicket(dados);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('sucesso')
              ? AppColors.success
              : AppColors.warning,
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija os erros no formulario.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SisPageScaffold(
      title: 'Solicitar: ${widget.serviceName}',
      subtitle: 'Preencha os dados do atendimento antes do envio',
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SisSectionHeader(
                title: 'Dados Gerais',
                subtitle:
                    'Informações de contexto e identificação do solicitante.',
              ),
              const SizedBox(height: AppSpacing.md),
              Consumer<AppState>(
                builder: (context, appState, _) => _GovernedFormContextBanner(
                  domainLabel: widget.domainLabel,
                  assignmentGroupLabel: widget.assignmentGroupLabel,
                  uiSchemaSource: widget.uiSchemaSource,
                  runtimeFormStatus: widget.runtimeFormStatus,
                  username: appState.loggedUsername,
                  activeProfile: appState.activeProfile,
                  activeEntityName: appState.activeEntityName,
                  selectedTicketEntityName: appState.selectedTicketEntityName,
                ),
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
              if (_atendimentoPara == 'Para outra Pessoa' &&
                  widget.includeNomePessoa)
                CustomTextField(
                  label: 'Qual o nome desta pessoa? (glpiselect)',
                  controller: _nomePessoaController,
                  isRequired: true,
                  onChanged: (value) {},
                ),
              if (widget.includeLocalizacao)
                CustomDropdownField(
                  label: 'Localização',
                  items: widget.localizacaoOptions,
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
              if (widget.includeUrgencia)
                CustomDropdownField(
                  label: 'Urgência',
                  items: widget.urgenciaOptions,
                  initialValue: _urgencia ?? widget.urgenciaOptions.first,
                  onChanged: (newValue) => _urgencia = newValue,
                  isRequired: false,
                ),
              const SizedBox(height: AppSpacing.md),
              const SisSectionHeader(
                title: 'Detalhamento',
                subtitle:
                    'Descreva o tipo do serviço, assunto e contexto da solicitação.',
              ),
              const SizedBox(height: AppSpacing.md),
              CustomDropdownField(
                label: 'Tipo',
                items: widget.tipoServicoOptions,
                isRequired: true,
                initialValue: _tipoDetalhamento,
                onChanged: (newValue) => _tipoDetalhamento = newValue,
              ),
              CustomTextField(
                label: 'Assunto',
                controller: _assuntoController,
                isRequired: true,
              ),
              CustomTextField(
                label: 'Descrição',
                controller: _descricaoController,
                helperText: '(Indicar o local e o ocorrido)',
                isRequired: true,
                maxLines: 5,
              ),
              if (widget.extraFieldsBuilder != null)
                widget.extraFieldsBuilder!(context, (newValue) {
                  _extraDropdownValue = newValue;
                }),
              if (widget.includeAnexo)
                AnexarArquivoWidget(onFilesSelected: _onAnexosSelected),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _enviarFormulario,
                child: const Text('ENVIAR SOLICITACAO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GovernedFormContextBanner extends StatelessWidget {
  final String domainLabel;
  final String? assignmentGroupLabel;
  final String uiSchemaSource;
  final String? runtimeFormStatus;
  final String? username;
  final String? activeProfile;
  final String? activeEntityName;
  final String? selectedTicketEntityName;

  const _GovernedFormContextBanner({
    required this.domainLabel,
    required this.assignmentGroupLabel,
    required this.uiSchemaSource,
    required this.runtimeFormStatus,
    required this.username,
    required this.activeProfile,
    required this.activeEntityName,
    required this.selectedTicketEntityName,
  });

  String? get _schemaLabel {
    if (uiSchemaSource == 'formcreator_runtime_metadata') {
      return 'Campos vindos do FormCreator';
    }
    return null;
  }

  bool get _showDomainLabel =>
      domainLabel.trim().isNotEmpty &&
      domainLabel.trim().toLowerCase() != 'catálogo estático' &&
      domainLabel.trim().toLowerCase() != 'catalogo estatico';

  @override
  Widget build(BuildContext context) {
    final schemaLabel = _schemaLabel;
    final rows = <String>[
      if (_showDomainLabel) 'Domínio: $domainLabel',
      if (assignmentGroupLabel != null) 'Fila prevista: $assignmentGroupLabel',
      if (activeProfile != null) 'Perfil ativo: $activeProfile',
      if (activeEntityName != null) 'Entidade ativa: $activeEntityName',
      if (selectedTicketEntityName != null)
        'Entidade do ticket: $selectedTicketEntityName',
      if (schemaLabel != null) schemaLabel,
      if (runtimeFormStatus != null) 'FormCreator: $runtimeFormStatus',
      if (username != null) 'Logado como: $username',
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: rows.map((row) {
          return Text(
            row,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          );
        }).toList(),
      ),
    );
  }
}
