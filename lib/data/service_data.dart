import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../catalog/governed_service_catalog.dart';

class LocationOption {
  final int id;
  final String label;
  final String fullLabel;
  final int? rootId;
  final int? sourceQuestionId;

  const LocationOption({
    required this.id,
    required this.label,
    String? fullLabel,
    this.rootId,
    this.sourceQuestionId,
  }) : fullLabel = fullLabel ?? label;

  Map<String, dynamic> toPayload() => {
    'id': id,
    'label': label,
    'full_label': fullLabel,
    if (rootId != null) 'root_id': rootId,
    if (sourceQuestionId != null) 'source_question_id': sourceQuestionId,
  };
}

class ServiceCategory {
  final String name;
  final IconData icon;
  final Color color;
  final int categoryId;
  final List<String> locations;
  final int? staticLocationRootId;
  final List<LocationOption> locationOptions;
  final List<String> typeOptions;
  final List<String> urgencyOptions;
  final bool includeNomePessoa;
  final bool includeUrgencia;
  final bool includeLocalizacao;
  final bool includeAnexo;
  final String? extraFieldLabel;
  final List<String> extraFieldOptions;
  final List<String> aliases;
  final String domainLabel;
  final String? assignmentGroupLabel;
  final String uiSchemaSource;
  final String? runtimeFormStatus;
  final List<GovernedServiceRecord> governedRecords;

  const ServiceCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.categoryId,
    required this.locations,
    this.staticLocationRootId,
    this.locationOptions = const [],
    required this.typeOptions,
    this.urgencyOptions = const ['3 - Média (Padrão)', '1 - Baixa', '5 - Alta'],
    this.includeNomePessoa = true,
    this.includeUrgencia = true,
    this.includeLocalizacao = true,
    this.includeAnexo = true,
    this.extraFieldLabel,
    this.extraFieldOptions = const [],
    this.aliases = const [],
    this.domainLabel = 'Catálogo estático',
    this.assignmentGroupLabel,
    this.uiSchemaSource = 'static_bootstrap',
    this.runtimeFormStatus,
    this.governedRecords = const [],
  });

  bool get hasExtraField =>
      extraFieldLabel != null && extraFieldOptions.isNotEmpty;

  List<LocationOption> get effectiveLocationOptions {
    if (locationOptions.isNotEmpty) return locationOptions;
    if (staticLocationRootId != null) {
      return List<LocationOption>.unmodifiable(
        locations.map(
          (location) => LocationOption(
            id: staticLocationRootId!,
            label: _stripLegacyLocationPrefix(location),
            rootId: staticLocationRootId,
          ),
        ),
      );
    }
    final parsed = <LocationOption>[];
    for (final location in locations) {
      final option = _parseLegacyLocationOption(location);
      if (option != null) parsed.add(option);
    }
    return List<LocationOption>.unmodifiable(parsed);
  }

  List<String> get displayLocations {
    final options = effectiveLocationOptions;
    if (options.isNotEmpty) {
      return List<String>.unmodifiable(options.map((option) => option.label));
    }
    return List<String>.unmodifiable(locations.map(_stripLegacyLocationPrefix));
  }

  ServiceCategory copyWith({
    String? name,
    int? categoryId,
    List<String>? locations,
    int? staticLocationRootId,
    List<LocationOption>? locationOptions,
    List<String>? typeOptions,
    List<String>? urgencyOptions,
    bool? includeNomePessoa,
    bool? includeUrgencia,
    bool? includeLocalizacao,
    bool? includeAnexo,
    String? extraFieldLabel,
    List<String>? extraFieldOptions,
    List<String>? aliases,
    String? domainLabel,
    String? assignmentGroupLabel,
    String? uiSchemaSource,
    String? runtimeFormStatus,
    List<GovernedServiceRecord>? governedRecords,
  }) {
    return ServiceCategory(
      name: name ?? this.name,
      icon: icon,
      color: color,
      categoryId: categoryId ?? this.categoryId,
      locations: locations ?? this.locations,
      staticLocationRootId: staticLocationRootId ?? this.staticLocationRootId,
      locationOptions: locationOptions ?? this.locationOptions,
      typeOptions: typeOptions ?? this.typeOptions,
      urgencyOptions: urgencyOptions ?? this.urgencyOptions,
      includeNomePessoa: includeNomePessoa ?? this.includeNomePessoa,
      includeUrgencia: includeUrgencia ?? this.includeUrgencia,
      includeLocalizacao: includeLocalizacao ?? this.includeLocalizacao,
      includeAnexo: includeAnexo ?? this.includeAnexo,
      extraFieldLabel: extraFieldLabel ?? this.extraFieldLabel,
      extraFieldOptions: extraFieldOptions ?? this.extraFieldOptions,
      aliases: aliases ?? this.aliases,
      domainLabel: domainLabel ?? this.domainLabel,
      assignmentGroupLabel: assignmentGroupLabel ?? this.assignmentGroupLabel,
      uiSchemaSource: uiSchemaSource ?? this.uiSchemaSource,
      runtimeFormStatus: runtimeFormStatus ?? this.runtimeFormStatus,
      governedRecords: governedRecords ?? this.governedRecords,
    );
  }
}

LocationOption? _parseLegacyLocationOption(String rawLocation) {
  final raw = rawLocation.trim();
  if (raw.isEmpty) return null;
  final match = RegExp(r'Root\s+(\d+)').firstMatch(raw);
  if (match == null) return null;
  final id = int.tryParse(match.group(1) ?? '');
  if (id == null || id <= 0) return null;
  return LocationOption(
    id: id,
    label: _stripLegacyLocationPrefix(raw),
    fullLabel: raw,
  );
}

String _stripLegacyLocationPrefix(String rawLocation) {
  final raw = rawLocation.trim();
  final stripped = raw.replaceFirst(
    RegExp(r'^Local\s*\(Root\s+\d+\)\s*:\s*'),
    '',
  );
  return stripped.trim().isEmpty ? raw : stripped.trim();
}

const List<ServiceCategory> serviceCategories = [
  ServiceCategory(
    name: 'Ar-Condicionado',
    icon: FontAwesomeIcons.snowflake,
    color: AppColors.catalogCritical,
    categoryId: 1,
    staticLocationRootId: 70,
    locations: [
      'Sala/Escritorio',
      'Sala de Reuniao',
      'Area Tecnica/Servidores',
      'Outro',
    ],
    typeOptions: [
      'Manutenção Preventiva Agendada',
      'Aparelho Não Liga',
      'Vazamento/Gotejamento',
      'Barulho Anormal',
      'Outro',
    ],
    aliases: ['ar condicionado'],
  ),
  ServiceCategory(
    name: 'Carregadores',
    icon: FontAwesomeIcons.peopleCarryBox,
    color: AppColors.catalogOperational,
    categoryId: 55,
    staticLocationRootId: 36,
    locations: ['Armazem', 'Patio de Carga', 'Estoque', 'Outro'],
    typeOptions: [
      'Transporte de Material Pesado',
      'Solicitação de Ajudante',
      'Movimentacao de Mobiliario',
      'Outro',
    ],
  ),
  ServiceCategory(
    name: 'Copa',
    icon: FontAwesomeIcons.mugHot,
    color: AppColors.catalogOperational,
    categoryId: 98,
    staticLocationRootId: 27,
    locations: ['Cozinha Principal', 'Area de Cafe', 'Refeitorio', 'Outro'],
    typeOptions: [
      'Falta de Suprimentos',
      'Problema com Eletrodomestico',
      'Limpeza Insuficiente',
      'Outro',
    ],
    includeUrgencia: false,
  ),
  ServiceCategory(
    name: 'Elevadores',
    icon: FontAwesomeIcons.upDown,
    color: AppColors.catalogCritical,
    categoryId: 17,
    locations: [],
    typeOptions: [
      'Iluminacao',
      'Parado',
      'Velocidade subida/descida',
      'Ventilacao',
      'Outras Atividades',
    ],
    includeLocalizacao: false,
  ),
  ServiceCategory(
    name: 'Eletrica',
    icon: FontAwesomeIcons.bolt,
    color: AppColors.catalogCritical,
    categoryId: 22,
    staticLocationRootId: 70,
    locations: ['Painel Principal', 'Area Tecnica', 'Escritorio X', 'Outro'],
    typeOptions: [
      'Troca de Lampada',
      'Tomada Queimada',
      'Problema em Quadro Eletrico',
      'Curto Circuito',
      'Outro',
    ],
    aliases: ['eletrica'],
  ),
  ServiceCategory(
    name: 'Hidraulica',
    icon: FontAwesomeIcons.faucet,
    color: AppColors.catalogCritical,
    categoryId: 30,
    staticLocationRootId: 70,
    locations: [
      'Banheiro Social',
      'Cozinha Industrial',
      'Área de Serviço/Lavanderia',
      'Outro',
    ],
    typeOptions: [
      'Vazamento',
      'Entupimento',
      'Reparo de Torneira/Registro',
      'Instalacao de Novo Ponto',
      'Outro',
    ],
    aliases: ['hidraulica'],
  ),
  ServiceCategory(
    name: 'Jardinagem',
    icon: FontAwesomeIcons.leaf,
    color: AppColors.catalogOperational,
    categoryId: 37,
    staticLocationRootId: 31,
    locations: [
      'Area Externa Principal',
      'Canteiro do Estacionamento',
      'Floreira da Recepcao',
      'Outro',
    ],
    typeOptions: [
      'Poda de Arvore/Arbusto',
      'Limpeza de Canteiro',
      'Implantacao de Paisagismo',
      'Remocao de Residuos Verdes',
      'Outro',
    ],
    includeUrgencia: false,
  ),
  ServiceCategory(
    name: 'Limpeza',
    icon: FontAwesomeIcons.broom,
    color: AppColors.catalogOperational,
    categoryId: 45,
    staticLocationRootId: 27,
    locations: ['Banheiro Social', 'Area de Copa/Cozinha', 'Corredor', 'Outro'],
    typeOptions: [
      'Limpeza de Emergencia',
      'Higienizacao de Sanitario',
      'Limpeza de Janelas',
      'Solicitação de Material de Limpeza',
    ],
    includeUrgencia: false,
  ),
  ServiceCategory(
    name: 'Marcenaria',
    icon: FontAwesomeIcons.toolbox,
    color: AppColors.catalogCritical,
    categoryId: 50,
    staticLocationRootId: 70,
    locations: [
      'Escritorio/Sala',
      'Arquivo Morto/Deposito',
      'Cozinha',
      'Outro',
    ],
    typeOptions: [
      'Reparo de Movel (Gaveta, Porta)',
      'Instalacao de Prateleiras',
      'Ajuste de Porta/Batente',
      'Fabricacao Sob Medida',
      'Outro',
    ],
  ),
  ServiceCategory(
    name: 'Mensageria',
    icon: FontAwesomeIcons.envelope,
    color: AppColors.catalogOperational,
    categoryId: 128,
    staticLocationRootId: 36,
    locations: [
      'Protocolo',
      'Sala de Expedicao',
      'Recepcao Principal',
      'Outro',
    ],
    typeOptions: [
      'Entrega Interna',
      'Coleta de Malote',
      'Entrega Externa Urgente',
      'Registro/Protocolo',
      'Outro',
    ],
  ),
  ServiceCategory(
    name: 'Pedreiro',
    icon: FontAwesomeIcons.screwdriverWrench,
    color: AppColors.catalogCritical,
    categoryId: 81,
    staticLocationRootId: 70,
    locations: ['Parede Interna', 'Piso/Calcada', 'Alvenaria Externa', 'Outro'],
    typeOptions: [
      'Reparo de Alvenaria (Tijolo/Bloco)',
      'Assentamento de Piso ou Revestimento',
      'Pequenas Obras Civis',
      'Chumbamento/Instalacao de Estrutura',
      'Outro',
    ],
  ),
  ServiceCategory(
    name: 'Pintura',
    icon: FontAwesomeIcons.paintRoller,
    color: AppColors.catalogCritical,
    categoryId: 85,
    staticLocationRootId: 70,
    locations: ['Corredor do 2o Andar', 'Sala/Escritorio', 'Teto', 'Outro'],
    typeOptions: [
      'Pintura de Parede',
      'Reparo de Textura',
      'Pintura de Teto',
      'Aplicacao de Verniz/Tinta Especial',
      'Outro',
    ],
  ),
  ServiceCategory(
    name: 'Projeto',
    icon: FontAwesomeIcons.solidPenToSquare,
    color: AppColors.catalogCritical,
    categoryId: 144,
    staticLocationRootId: 70,
    locations: ['Sede Principal', 'Anexo I', 'Outro'],
    typeOptions: [
      'Projetos DCMPC',
      'Projetos Secretaria Executiva GG',
      'Gestao de Espacos',
      'Outras atividades',
    ],
    includeNomePessoa: false,
    extraFieldLabel: 'Divisao / Departamento',
    extraFieldOptions: [
      'Divisao/Departamento 1',
      'Divisao/Departamento 2',
      'Outro',
    ],
  ),
  ServiceCategory(
    name: 'Tecnico de Redes',
    icon: FontAwesomeIcons.networkWired,
    color: AppColors.catalogCritical,
    categoryId: 88,
    staticLocationRootId: 70,
    locations: [
      'Sala de Servidores',
      'Ponto de Rede Especifico',
      'Escritorio/Sala',
      'Outro',
    ],
    typeOptions: [
      'Problema de Conectividade (Cabo)',
      'Solicitação de Novo Ponto de Rede',
      'Configuração de Equipamento de Rede',
      'Problema com WiFi',
      'Outro',
    ],
    aliases: ['redes', 'rede', 'computadores'],
  ),
  ServiceCategory(
    name: 'Vidracaria',
    icon: FontAwesomeIcons.tableColumns,
    color: AppColors.catalogCritical,
    categoryId: 94,
    staticLocationRootId: 70,
    locations: [
      'Janela/Esquadria',
      'Porta de Vidro',
      'Vitrine/Divisoria',
      'Outro',
    ],
    typeOptions: [
      'Vidro Quebrado',
      'Manutenção de Esquadria',
      'Troca de Borracha/Vedacao',
      'Outro',
    ],
    extraFieldLabel: 'Tipo de Atendimento',
    extraFieldOptions: ['Instalacao', 'Medicao', 'Remocao', 'Troca'],
    aliases: ['vidracaria'],
  ),
];

ServiceCategory? findServiceCategoryByName(String? name) {
  if (name == null || name.trim().isEmpty) return null;
  final normalized = normalizeServiceLabel(name);

  for (final service in serviceCategories) {
    if (normalizeServiceLabel(service.name) == normalized) {
      return service;
    }
    if (service.aliases.any(
      (alias) => normalizeServiceLabel(alias) == normalized,
    )) {
      return service;
    }
  }

  return null;
}

ServiceCategory? findServiceCategoryById(int? categoryId) {
  if (categoryId == null) return null;
  for (final service in serviceCategories) {
    if (service.categoryId == categoryId) {
      return service;
    }
  }
  return null;
}

int? tryResolveServiceCategoryId(dynamic rawCategory) {
  if (rawCategory is int) return rawCategory;

  final numeric = int.tryParse(rawCategory?.toString() ?? '');
  if (numeric != null) return numeric;

  final service = findServiceCategoryByName(
    extractServiceCategoryLabel(rawCategory),
  );
  return service?.categoryId;
}

int resolveServiceCategoryId(dynamic rawCategory) {
  final categoryId = tryResolveServiceCategoryId(rawCategory);
  if (categoryId != null) return categoryId;

  throw ArgumentError.value(
    rawCategory,
    'rawCategory',
    'Categoria SIS nao encontrada no catalogo governado; abortando para evitar fallback silencioso para Ar-Condicionado.',
  );
}

String normalizeServiceCategoryLabel(dynamic rawCategory) {
  final numeric = rawCategory is int
      ? rawCategory
      : int.tryParse(rawCategory?.toString() ?? '');
  if (numeric != null) {
    final byId = findServiceCategoryById(numeric);
    if (byId != null) return byId.name;
  }

  final extracted = extractServiceCategoryLabel(rawCategory);
  return findServiceCategoryByName(extracted)?.name ?? extracted;
}

String extractServiceCategoryLabel(dynamic rawCategory) {
  String? label;

  if (rawCategory is Map) {
    final dynamic fullName = rawCategory['completename'] ?? rawCategory['name'];
    if (fullName is String && fullName.trim().isNotEmpty) {
      label = fullName;
    }
  } else if (rawCategory != null) {
    label = rawCategory.toString();
  }

  if (label == null || label.trim().isEmpty) {
    return 'Geral';
  }

  final decoded = label
      .replaceAll('&amp;', '&')
      .replaceAll('&#62;', '>')
      .replaceAll('&gt;', '>')
      .replaceAll('&lt;', '<')
      .replaceAll('&quot;', '"')
      .trim();

  if (decoded.contains('>')) {
    return decoded.split('>').last.trim();
  }

  return decoded;
}

String normalizeServiceLabel(String value) {
  return value
      .toLowerCase()
      .trim()
      .replaceAll('-', ' ')
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ç', 'c')
      .replaceAll('Ã¡', 'a')
      .replaceAll('Ã ', 'a')
      .replaceAll('Ã¢', 'a')
      .replaceAll('Ã£', 'a')
      .replaceAll('Ã¤', 'a')
      .replaceAll('Ã©', 'e')
      .replaceAll('Ãª', 'e')
      .replaceAll('Ã«', 'e')
      .replaceAll('Ã­', 'i')
      .replaceAll('Ã¯', 'i')
      .replaceAll('Ã³', 'o')
      .replaceAll('Ã´', 'o')
      .replaceAll('Ãµ', 'o')
      .replaceAll('Ã¶', 'o')
      .replaceAll('Ãº', 'u')
      .replaceAll('Ã¼', 'u')
      .replaceAll('Ã§', 'c')
      .replaceAll(RegExp(r'\s+'), ' ');
}

ServiceCategory governedServiceTemplate(
  String name, {
  int categoryId = 0,
  String? domainLabel,
}) {
  final normalized = normalizeServiceLabel('$name ${domainLabel ?? ''}');
  final isConservation = normalized.contains('conservacao');
  final isMaintenance = normalized.contains('manutencao');
  final isProject = normalized.contains('projeto');
  final isMultiple = normalized.contains('multiplas');

  return ServiceCategory(
    name: name,
    icon: isProject
        ? FontAwesomeIcons.solidPenToSquare
        : isMultiple
        ? FontAwesomeIcons.toolbox
        : isConservation
        ? FontAwesomeIcons.broom
        : isMaintenance
        ? FontAwesomeIcons.screwdriverWrench
        : FontAwesomeIcons.tableColumns,
    color: isConservation
        ? AppColors.catalogOperational
        : isMaintenance
        ? AppColors.catalogCritical
        : AppColors.brand,
    categoryId: categoryId,
    locations: const [],
    typeOptions: const [],
    aliases: const [],
    domainLabel: domainLabel ?? 'Catálogo governado',
    uiSchemaSource: 'governed_v2_records',
  );
}
