import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../catalog/governed_entity_resolver.dart';
import '../catalog/governed_service_catalog.dart';
import '../catalog/governed_submission_contract.dart';
import '../data/service_data.dart';
import '../models/glpi_user_ref.dart';
import '../services/glpi_ticket_support.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/anexar_arquivo_widget.dart';
import '../widgets/custom_dropdown_field.dart';
import '../utils/attachment_opening_policy.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/searchable_select_field.dart';
import '../widgets/ui/sis_page_scaffold.dart';
import '../widgets/ui/sis_section_header.dart';

// NOTA (2026-06-14): MVP FormCreator support - categoria + localização apenas.
// Outras perguntas (texto, checkbox, data, multi-select, etc.) são ignoradas.
// Se FormCreator começar a exigir tipos adicionais, isso é "próxima iteração".
// For now: category dropdown + location dropdown apenas. Escopo pragmático para TODAY.
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
  final List<GovernedServiceRecord> governedRecords;
  final Widget Function(BuildContext, Function(String?))? extraFieldsBuilder;

  const FormTemplate({
    super.key,
    required this.serviceName,
    required this.localizacaoOptions,
    this.locationOptions = const [],
    required this.tipoServicoOptions,
    this.urgenciaOptions = const ['Média (padrão)', 'Baixa', 'Alta'],
    this.includeNomePessoa = true,
    this.includeUrgencia = true,
    this.includeLocalizacao = true,
    this.includeAnexo = true,
    this.domainLabel = 'Catálogo estático',
    this.assignmentGroupLabel,
    this.uiSchemaSource = 'static_bootstrap',
    this.runtimeFormStatus,
    this.governedRecords = const [],
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

  GlpiUserRef? _beneficiaryUser;
  int? _beneficiaryEntityId;
  bool _loadingBeneficiaryEntity = false;
  String? _beneficiaryEntityError;

  String? _atendimentoPara;
  String? _localizacao;
  String? _urgencia;
  String? _tipoDetalhamento;
  String? _subServico;
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
      if (option.label == selected ||
          option.fullLabel == selected ||
          option.displayLabel == selected) {
        return option.toPayload();
      }
    }

    return selected;
  }

  List<GovernedServiceRecord> _candidateGovernedRecords(AppState appState) {
    if (widget.governedRecords.isEmpty) return const [];
    final audience = _requestedAudienceKey();
    final profile = _normalizeGoverned(appState.activeProfile ?? 'Solicitante');
    return widget.governedRecords
        .where((record) {
          if (record.audience != audience) return false;
          return record.profileVisibility.any(
            (visibleProfile) =>
                _normalizeGoverned(visibleProfile.name) == profile,
          );
        })
        .toList(growable: false);
  }

  String _requestedAudienceKey() {
    return _atendimentoPara == 'Para outra Pessoa'
        ? 'para_terceiro'
        : 'para_mim';
  }

  bool _hasThirdPartyRecords(AppState appState) {
    return GovernedSubmissionResolver.hasThirdPartyOption(
      records: widget.governedRecords,
      profileName: appState.activeProfile ?? 'Solicitante',
    );
  }

  GovernedTicketAudience _effectiveSubmissionAudience() {
    return _requestedAudienceKey() == 'para_terceiro'
        ? GovernedTicketAudience.paraTerceiro
        : GovernedTicketAudience.paraMim;
  }

  /// Sub-serviços do card agregado (UX fiel ao GLPI): CONSERVAÇÃO/MANUTENÇÃO/
  /// Multiplas Demandas têm um alvo por sub-serviço, selecionado aqui.
  List<String> _subServiceOptions(AppState appState) {
    final candidates = _candidateGovernedRecords(appState);
    if (!candidates.any((record) => record.isAggregateForm)) return const [];
    final subs = <String>{};
    for (final record in candidates) {
      final sub = record.subService?.trim() ?? '';
      if (sub.isNotEmpty) subs.add(sub);
    }
    final list = subs.toList()..sort();
    return list.length > 1 ? list : const [];
  }

  GovernedServiceRecord? _selectGovernedRecord(AppState appState) {
    var candidates = _candidateGovernedRecords(appState);
    final sub = _subServico?.trim() ?? '';
    if (sub.isNotEmpty) {
      candidates = candidates
          .where(
            (record) =>
                _normalizeGoverned(record.subService ?? '') ==
                _normalizeGoverned(sub),
          )
          .toList(growable: false);
    }

    if (candidates.isEmpty) return null;
    final sorted = List<GovernedServiceRecord>.of(candidates)
      ..sort((a, b) {
        final formCompare = a.formId.compareTo(b.formId);
        if (formCompare != 0) return formCompare;
        return a.targetTicketId.compareTo(b.targetTicketId);
      });
    return sorted.first;
  }

  int? _selectedCategoryIdForRecords(List<GovernedServiceRecord> records) {
    final selected = _tipoDetalhamento?.trim();
    if (selected == null || selected.isEmpty) return null;
    for (final record in records) {
      final question = record.categoryQuestion;
      if (question == null) continue;
      for (final option in question.options) {
        if (_normalizeGoverned(option.label ?? '') ==
                _normalizeGoverned(selected) ||
            _normalizeGoverned(option.fullLabel ?? '') ==
                _normalizeGoverned(selected)) {
          return option.id;
        }
      }
    }
    return null;
  }

  int? _selectedLocationId() {
    final payload = _selectedLocationPayload();
    if (payload is Map) {
      final raw =
          payload['id'] ?? payload['location_id'] ?? payload['locations_id'];
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '');
    }
    if (payload is LocationOption) return payload.id;
    if (payload is int) return payload;
    return null;
  }

  void _clearBeneficiarySelection() {
    _nomePessoaController.clear();
    _beneficiaryUser = null;
    _beneficiaryEntityId = null;
    _beneficiaryEntityError = null;
    _loadingBeneficiaryEntity = false;
  }

  Future<void> _onBeneficiarySelected(GlpiUserRef? user) async {
    setState(() {
      _beneficiaryUser = user;
      _beneficiaryEntityId = user?.defaultEntityId;
      _beneficiaryEntityError = null;
      _loadingBeneficiaryEntity = false;
    });

    if (user == null) return;

    final appState = Provider.of<AppState>(context, listen: false);
    await _ensureBeneficiaryEntity(appState);
  }

  Future<int?> _ensureBeneficiaryEntity(AppState appState) async {
    final user = _beneficiaryUser;
    if (user == null) return null;
    if (_beneficiaryEntityId != null && _beneficiaryEntityId! > 0) {
      return _beneficiaryEntityId;
    }

    setState(() {
      _loadingBeneficiaryEntity = true;
      _beneficiaryEntityError = null;
    });

    try {
      final hydrated = await appState.fetchGlpiUserById(user.id);
      final entityId = hydrated?.defaultEntityId;
      if (!mounted || _beneficiaryUser?.id != user.id) return entityId;
      setState(() {
        _beneficiaryEntityId = entityId;
        _loadingBeneficiaryEntity = false;
        _beneficiaryEntityError = entityId == null || entityId <= 0
            ? 'Não foi possível identificar a unidade da pessoa selecionada.'
            : null;
      });
      return entityId;
    } catch (e) {
      if (!mounted || _beneficiaryUser?.id != user.id) return null;
      setState(() {
        _loadingBeneficiaryEntity = false;
        _beneficiaryEntityError =
            'Não foi possível carregar os dados da pessoa selecionada.';
      });
      return null;
    }
  }

  List<Map<String, dynamic>> _governedActorMaps(GovernedServiceRecord? record) {
    if (record == null || record.actors.isEmpty) return const [];
    return record.actors
        .map(
          (actor) => {
            'role': actor.role,
            'type': actor.type,
            if (actor.value != null) 'value': actor.value,
          },
        )
        .toList(growable: false);
  }

  String _formatActorRules(List<GovernedActor> actors) {
    if (actors.isEmpty) return '(nenhum ator no catálogo)';
    return actors
        .map(
          (actor) =>
              '- ${actor.role}/${actor.type}'
              '${actor.value == null ? '' : '=${actor.value}'}',
        )
        .join('\n');
  }

  String _formatActorFields(Map<String, dynamic> fields) {
    if (fields.isEmpty) return '(nenhum campo de ator derivado)';
    return fields.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  String _normalizeGoverned(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ');
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
    final resolved = AttachmentOpeningPolicy.resolveMimeType(
      filename: filename,
    );
    return resolved == 'application/octet-stream' ? null : resolved;
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

      if (!kIsWeb &&
          bytes == null &&
          file.path != null &&
          file.path!.isNotEmpty) {
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
      final hasThirdPartyOption = _hasThirdPartyRecords(appState);
      final isThirdParty =
          _atendimentoPara == 'Para outra Pessoa' && hasThirdPartyOption;
      if (isThirdParty && _beneficiaryUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Busque e selecione a pessoa antes de enviar.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      if (isThirdParty) {
        final beneficiaryEntityId = await _ensureBeneficiaryEntity(appState);
        if (!mounted) return;
        if (beneficiaryEntityId == null || beneficiaryEntityId <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _beneficiaryEntityError ??
                    'Não foi possível carregar os dados da pessoa selecionada.',
              ),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }
      }

      final governedLocationId = _selectedLocationId();
      GovernedSubmissionContract? governedContract;
      if (widget.governedRecords.isNotEmpty) {
        final selectedAudience = _effectiveSubmissionAudience();
        final pendingSubOptions = _subServiceOptions(appState);
        if (pendingSubOptions.isNotEmpty &&
            (_subServico == null || _subServico!.trim().isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Selecione o serviço desejado em "Qual serviço?" antes de enviar.',
              ),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }
        final preliminaryRecord = _selectGovernedRecord(appState);
        final candidateRecords = preliminaryRecord != null
            ? <GovernedServiceRecord>[preliminaryRecord]
            : _candidateGovernedRecords(appState);
        final governedCategoryId = candidateRecords.isEmpty
            ? null
            : _selectedCategoryIdForRecords(candidateRecords);

        if (preliminaryRecord?.categoryQuestion?.required == true &&
            governedCategoryId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione um tipo válido antes de enviar.'),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }

        if (preliminaryRecord?.locationQuestion?.required == true &&
            governedLocationId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Selecione uma localização válida antes de enviar.',
              ),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }

        final resolution = GovernedSubmissionResolver.resolve(
          GovernedSubmissionInput(
            records: widget.governedRecords,
            profileName: appState.activeProfile ?? 'Solicitante',
            audience: selectedAudience,
            selectedCategoryId: governedCategoryId,
            selectedLocationId: governedLocationId,
            selectedSubService: _subServico,
            entityContext: GovernedEntityContext(
              selectedTicketEntityId: appState.selectedTicketEntityId,
              activeEntityId: appState.activeEntityId,
              beneficiaryEntityId: _beneficiaryEntityId,
            ),
          ),
        );
        if (!resolution.ok || resolution.contract == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resolution.blocker ??
                    'Não foi possível concluir o envio. Revise os campos e tente novamente.',
              ),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }
        governedContract = resolution.contract;
      }

      final governedRecord = governedContract?.record;
      final governedCategoryId = governedContract?.categoryId;
      final governedEntityId = governedContract?.entityId;
      final governedActors = _governedActorMaps(governedRecord);

      final dados = {
        'serviceName': widget.serviceName,
        'atendimentoPara': _atendimentoPara ?? 'Para mim',
        'nomePessoa':
            _atendimentoPara == 'Para outra Pessoa' && hasThirdPartyOption
            ? _nomePessoaController.text
            : null,
        'beneficiaryUserId': _beneficiaryUser?.id,
        'beneficiaryUserName': _beneficiaryUser?.label,
        'beneficiaryEntityId': _beneficiaryEntityId,
        'loggedUserId': appState.loggedUserId,
        'localizacao': _selectedLocationPayload(),
        'telefone': _telefoneController.text,
        'urgencia': widget.includeUrgencia
            ? (_urgencia ?? 'Média (padrão)')
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
        'attachmentPathsList': _anexoPaths,
        'CampoExtra': widget.extraFieldsBuilder != null
            ? _extraDropdownValue
            : null,
        if (governedRecord != null) ...{
          'governedCatalogRecordId': governedRecord.catalogRecordId,
          'governedServiceId': governedRecord.serviceId,
          'governedFormId': governedRecord.formId,
          'governedTargetTicketId': governedRecord.targetTicketId,
          'governedAudience': governedRecord.audience,
          'governedEntityMode': governedRecord.destinationEntityMode,
          'governedEntityCode': governedRecord.destinationEntityCode,
          'governedEntityValue': governedRecord.destinationEntityValue,
          'governedEntityId': governedEntityId,
          'entities_id': governedEntityId,
          'governedCategoryId': governedCategoryId,
          'governedLocationId': governedLocationId,
          'governedContract': governedContract,
          'governedRecord': governedRecord,
          'governedActors': governedActors,
          'governedReadbackExpectation': governedContract?.readbackExpectation,
        },
      };

      // LAB PREVIEW (read-only): quando SIS_LAB_PREVIEW=true, mostra a entidade
      // resolvida e NÃO cria o chamado. Em produção (flag ausente) nada muda.
      final labPreview =
          (dotenv.maybeGet('SIS_LAB_PREVIEW') ?? '').toLowerCase() == 'true';
      if (labPreview) {
        final actorFields = GlpiTicketSupport.buildGovernedActorFields(dados);
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('LAB · Resolução read-only (sem criar chamado)'),
            content: SingleChildScrollView(
              child: Text(
                'Perfil ativo: ${appState.activeProfile ?? '(?)'}\n'
                'Entidade ativa (sessão): ${appState.activeEntityId ?? '(?)'}'
                ' — ${appState.activeEntityName ?? ''}\n'
                'Serviço: ${widget.serviceName}\n'
                'Sub-serviço: ${_subServico ?? '(n/a)'}\n'
                'Atendimento: ${_atendimentoPara ?? 'Para mim'}\n'
                'Beneficiário: '
                '${_beneficiaryUser == null ? '(n/a)' : '${_beneficiaryUser!.id} · ${_beneficiaryUser!.label}'}\n'
                'Entidade do beneficiário: ${_beneficiaryEntityId ?? '(n/a)'}\n'
                '────────────\n'
                'Form: ${governedRecord?.formId} · '
                'Alvo: ${governedRecord?.targetTicketId}\n'
                'Modo entidade: ${governedRecord?.destinationEntityMode} '
                '(code ${governedRecord?.destinationEntityCode})\n'
                'destination_entity_value: '
                '${governedRecord?.destinationEntityValue}\n'
                '➜ ENTIDADE RESOLVIDA: ${governedEntityId ?? '(bloqueado)'}\n'
                'Categoria id: ${governedCategoryId ?? '(nenhuma)'}\n'
                'Localização id: ${governedLocationId ?? '(nenhuma)'}\n'
                'Grupo esperado: '
                '${governedRecord?.expectedAssignmentGroup?.label ?? '(?)'}\n'
                '────────────\n'
                'Atores catalogados:\n'
                '${_formatActorRules(governedRecord?.actors ?? const [])}\n'
                'Campos GLPI derivados:\n'
                '${_formatActorFields(actorFields)}',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
        return;
      }

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
          content: Text('Revise os campos destacados antes de enviar.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final hasThirdPartyOption = _hasThirdPartyRecords(appState);
    final atendimentoItems = hasThirdPartyOption
        ? const ['Para mim', 'Para outra Pessoa']
        : const ['Para mim'];
    final subOptions = _subServiceOptions(appState);
    final hasSubSelected = (_subServico?.trim().isNotEmpty ?? false);
    final subRecord = hasSubSelected ? _selectGovernedRecord(appState) : null;
    // Em cards agregados, as opções de Tipo vêm do alvo do sub-serviço
    // escolhido; sem sub escolhido, lista vazia (usuário escolhe o serviço
    // primeiro). Em forms por-serviço, mantém as opções do catálogo mesclado.
    final tipoItems = subOptions.isEmpty
        ? widget.tipoServicoOptions
        : (subRecord?.categoryQuestion?.options
                  .map(
                    (option) => (option.label?.trim().isNotEmpty == true
                        ? option.label!.trim()
                        : option.fullLabel?.trim() ?? ''),
                  )
                  .where((label) => label.isNotEmpty)
                  .toList(growable: false) ??
              const <String>[]);
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
                subtitle: 'Dados do solicitante',
              ),
              const SizedBox(height: AppSpacing.md),
              CustomDropdownField(
                label: 'Para quem é este atendimento?',
                items: atendimentoItems,
                isRequired: true,
                initialValue: _atendimentoPara,
                onChanged: (newValue) {
                  setState(() {
                    _atendimentoPara = newValue;
                    if (newValue != 'Para outra Pessoa') {
                      _clearBeneficiarySelection();
                    }
                  });
                },
              ),
              if (_atendimentoPara == 'Para outra Pessoa' &&
                  hasThirdPartyOption)
                _GlpiUserSearchField(
                  label: 'Para qual pessoa?',
                  controller: _nomePessoaController,
                  isRequired: true,
                  selectedUser: _beneficiaryUser,
                  onSearch: (query) => appState.searchGlpiUsers(query),
                  onSelected: _onBeneficiarySelected,
                ),
              if (_atendimentoPara == 'Para outra Pessoa' &&
                  hasThirdPartyOption &&
                  (_beneficiaryUser != null ||
                      _loadingBeneficiaryEntity ||
                      _beneficiaryEntityError != null))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    _loadingBeneficiaryEntity
                        ? 'Carregando dados da pessoa selecionada...'
                        : _beneficiaryEntityError ??
                              'Pessoa selecionada. O chamado será aberto em nome dela.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _beneficiaryEntityError == null
                          ? AppColors.textMuted
                          : AppColors.danger,
                    ),
                  ),
                ),
              if (widget.includeLocalizacao)
                SearchableSelectField(
                  label: 'Localização',
                  items: widget.localizacaoOptions,
                  isRequired: true,
                  initialValue: _localizacao,
                  hintText: 'Buscar localização',
                  searchLabel: 'Buscar localização',
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
                subtitle: 'Detalhe o atendimento',
              ),
              const SizedBox(height: AppSpacing.md),
              if (subOptions.isNotEmpty)
                CustomDropdownField(
                  label: 'Qual serviço?',
                  items: subOptions,
                  isRequired: true,
                  initialValue: _subServico,
                  onChanged: (newValue) {
                    setState(() {
                      _subServico = newValue;
                      _tipoDetalhamento = null;
                    });
                  },
                ),
              CustomDropdownField(
                label: 'Tipo de serviço',
                items: tipoItems,
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
                child: const Text('Enviar solicitação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlpiUserSearchField extends StatefulWidget {
  const _GlpiUserSearchField({
    required this.label,
    required this.controller,
    required this.onSearch,
    required this.onSelected,
    this.selectedUser,
    this.isRequired = false,
  });

  final String label;
  final TextEditingController controller;
  final Future<List<GlpiUserRef>> Function(String query) onSearch;
  final ValueChanged<GlpiUserRef?> onSelected;
  final GlpiUserRef? selectedUser;
  final bool isRequired;

  @override
  State<_GlpiUserSearchField> createState() => _GlpiUserSearchFieldState();
}

class _GlpiUserSearchFieldState extends State<_GlpiUserSearchField> {
  Timer? _debounce;
  List<GlpiUserRef> _suggestions = const [];
  bool _loading = false;
  String? _error;
  int _searchGeneration = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    final selected = widget.selectedUser;
    if (selected != null && value.trim() == selected.label) {
      return;
    }

    widget.onSelected(null);
    _debounce?.cancel();

    final query = value.trim();
    if (query.length < 3) {
      setState(() {
        _suggestions = const [];
        _loading = false;
        _error = null;
      });
      return;
    }

    final generation = ++_searchGeneration;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        _loading = true;
        _error = null;
      });

      try {
        final users = await widget.onSearch(query);
        if (!mounted || generation != _searchGeneration) return;
        setState(() {
          _suggestions = users;
          _loading = false;
          _error = users.isEmpty ? 'Nenhum usuário encontrado.' : null;
        });
      } catch (e) {
        if (!mounted || generation != _searchGeneration) return;
        setState(() {
          _suggestions = const [];
          _loading = false;
          _error = 'Não foi possível buscar pessoas. Verifique a conexão.';
        });
      }
    });
  }

  void _selectUser(GlpiUserRef user) {
    _debounce?.cancel();
    setState(() {
      _suggestions = const [];
      _loading = false;
      _error = null;
    });
    widget.controller.text = user.label;
    widget.onSelected(user);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final labelText = widget.isRequired ? '${widget.label} *' : widget.label;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.textStrong),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: 'Digite ao menos 3 caracteres para buscar no GLPI',
              suffixIcon: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : widget.controller.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Limpar',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onSelected(null);
                        setState(() {
                          _suggestions = const [];
                          _error = null;
                        });
                      },
                    )
                  : null,
            ),
            validator: widget.isRequired
                ? (_) => widget.selectedUser == null
                      ? 'Selecione um usuário da lista'
                      : null
                : null,
            onChanged: _onChanged,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                _error!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
              ),
            ),
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(user.displayName),
                    subtitle:
                        (user.login != null &&
                            user.login!.trim().isNotEmpty &&
                            user.login != user.displayName)
                        ? Text('Login: ${user.login!}')
                        : null,
                    onTap: () => _selectUser(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
