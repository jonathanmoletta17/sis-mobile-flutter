import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';

class ServiceCategory {
  final String name;
  final IconData icon;
  final Color color;
  final int categoryId;
  final List<String> locations;
  final List<String> typeOptions;
  final List<String> urgencyOptions;
  final bool includeNomePessoa;
  final bool includeUrgencia;
  final bool includeLocalizacao;
  final bool includeAnexo;
  final String? extraFieldLabel;
  final List<String> extraFieldOptions;
  final List<String> aliases;

  const ServiceCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.categoryId,
    required this.locations,
    required this.typeOptions,
    this.urgencyOptions = const ['3 - Media (Padrao)', '1 - Baixa', '5 - Alta'],
    this.includeNomePessoa = true,
    this.includeUrgencia = true,
    this.includeLocalizacao = true,
    this.includeAnexo = true,
    this.extraFieldLabel,
    this.extraFieldOptions = const [],
    this.aliases = const [],
  });

  bool get hasExtraField =>
      extraFieldLabel != null && extraFieldOptions.isNotEmpty;
}

const List<ServiceCategory> serviceCategories = [
  ServiceCategory(
    name: 'Ar-Condicionado',
    icon: FontAwesomeIcons.snowflake,
    color: AppColors.catalogCritical,
    categoryId: 1,
    locations: [
      'Local (Root 70): Sala/Escritorio',
      'Local (Root 70): Sala de Reuniao',
      'Local (Root 70): Area Tecnica/Servidores',
      'Local (Root 70): Outro',
    ],
    typeOptions: [
      'Manutencao Preventiva Agendada',
      'Aparelho Nao Liga',
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
    locations: [
      'Local (Root 36): Armazem',
      'Local (Root 36): Patio de Carga',
      'Local (Root 36): Estoque',
      'Local (Root 36): Outro',
    ],
    typeOptions: [
      'Transporte de Material Pesado',
      'Solicitacao de Ajudante',
      'Movimentacao de Mobiliario',
      'Outro',
    ],
  ),
  ServiceCategory(
    name: 'Copa',
    icon: FontAwesomeIcons.mugHot,
    color: AppColors.catalogOperational,
    categoryId: 98,
    locations: [
      'Local (Root 27): Cozinha Principal',
      'Local (Root 27): Area de Cafe',
      'Local (Root 27): Refeitorio',
      'Local (Root 27): Outro',
    ],
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
    locations: [
      'Local (Root 70): Painel Principal',
      'Local (Root 70): Area Tecnica',
      'Local (Root 70): Escritorio X',
      'Local (Root 70): Outro',
    ],
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
    locations: [
      'Local (Root 70): Banheiro Social',
      'Local (Root 70): Cozinha Industrial',
      'Local (Root 70): Area de Servico/Lavanderia',
      'Local (Root 70): Outro',
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
    locations: [
      'Local (Root 31): Area Externa Principal',
      'Local (Root 31): Canteiro do Estacionamento',
      'Local (Root 31): Floreira da Recepcao',
      'Local (Root 31): Outro',
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
    locations: [
      'Local (Root 27): Banheiro Social',
      'Local (Root 27): Area de Copa/Cozinha',
      'Local (Root 27): Corredor',
      'Local (Root 27): Outro',
    ],
    typeOptions: [
      'Limpeza de Emergencia',
      'Higienizacao de Sanitario',
      'Limpeza de Janelas',
      'Solicitacao de Material de Limpeza',
    ],
    includeUrgencia: false,
  ),
  ServiceCategory(
    name: 'Marcenaria',
    icon: FontAwesomeIcons.toolbox,
    color: AppColors.catalogCritical,
    categoryId: 50,
    locations: [
      'Local (Root 70): Escritorio/Sala',
      'Local (Root 70): Arquivo Morto/Deposito',
      'Local (Root 70): Cozinha',
      'Local (Root 70): Outro',
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
    locations: [
      'Local (Root 36): Protocolo',
      'Local (Root 36): Sala de Expedicao',
      'Local (Root 36): Recepcao Principal',
      'Local (Root 36): Outro',
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
    locations: [
      'Local (Root 70): Parede Interna',
      'Local (Root 70): Piso/Calcada',
      'Local (Root 70): Alvenaria Externa',
      'Local (Root 70): Outro',
    ],
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
    locations: [
      'Local (Root 70): Corredor do 2o Andar',
      'Local (Root 70): Sala/Escritorio',
      'Local (Root 70): Teto',
      'Local (Root 70): Outro',
    ],
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
    locations: [
      'Local (Root 70): Sede Principal',
      'Local (Root 70): Anexo I',
      'Local (Root 70): Outro',
    ],
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
    locations: [
      'Local (Root 70): Sala de Servidores',
      'Local (Root 70): Ponto de Rede Especifico',
      'Local (Root 70): Escritorio/Sala',
      'Local (Root 70): Outro',
    ],
    typeOptions: [
      'Problema de Conectividade (Cabo)',
      'Solicitacao de Novo Ponto de Rede',
      'Configuracao de Equipamento de Rede',
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
    locations: [
      'Local (Root 70): Janela/Esquadria',
      'Local (Root 70): Porta de Vidro',
      'Local (Root 70): Vitrine/Divisoria',
      'Local (Root 70): Outro',
    ],
    typeOptions: [
      'Vidro Quebrado',
      'Manutencao de Esquadria',
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

int resolveServiceCategoryId(dynamic rawCategory) {
  if (rawCategory is int) return rawCategory;

  final numeric = int.tryParse(rawCategory?.toString() ?? '');
  if (numeric != null) return numeric;

  final service = findServiceCategoryByName(
    extractServiceCategoryLabel(rawCategory),
  );
  return service?.categoryId ?? 1;
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
      .replaceAll('Ã§', 'c');
}
