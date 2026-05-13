import 'package:sis_mobile_flutter/data/service_data.dart';

import 'package:sis_mobile_flutter/models/ticket_message.dart';

final List<Map<String, dynamic>> workbenchTickets = [
  {
    'id': '8090',
    'name': 'Troca de luminaria no corredor norte',
    'serviceName': 'Eletrica',
    'status': GlpiTicketStatus.novoCode,
    'lastUpdateLabel': 'Atualizado ha 12 min',
    'isUnread': true,
    'pendingSync': false,
  },
  {
    'id': '7943',
    'name': 'Verificar tomada energizada na sala de reuniao',
    'serviceName': 'Eletrica',
    'status': GlpiTicketStatus.emAtendimentoCode,
    'lastUpdateLabel': 'Nova atividade ha 34 min',
    'isUnread': true,
    'pendingSync': false,
  },
  {
    'id': '8122',
    'name': 'Inspecao preventiva do ar-condicionado do gabinete',
    'serviceName': 'Ar-Condicionado',
    'status': GlpiTicketStatus.pendenteCode,
    'lastUpdateLabel': 'Aguardando retorno ha 2 h',
    'isUnread': false,
    'pendingSync': false,
  },
  {
    'id': 'OFFLINE-2',
    'name': 'Ajuste de fechadura no almoxarifado',
    'serviceName': 'Marcenaria',
    'status': 'offline',
    'lastUpdateLabel': 'Pendente de sincronizacao',
    'isUnread': false,
    'pendingSync': true,
  },
  {
    'id': '8110',
    'name': 'Limpeza emergencial apos manutencao',
    'serviceName': 'Limpeza',
    'status': GlpiTicketStatus.solucionadoCode,
    'lastUpdateLabel': 'Solucao enviada ha 1 dia',
    'isUnread': false,
    'pendingSync': false,
  },
];

final Map<String, dynamic> workbenchDetailTicket = {
  'id': '8090',
  'assunto': 'Troca de luminaria no corredor norte',
  'name': 'Troca de luminaria no corredor norte',
  'serviceName': 'Eletrica',
  'status': GlpiTicketStatus.emAtendimentoCode,
  'categoria_completa': 'Predial > Eletrica > Iluminacao',
  'descricao':
      'Luminaria do corredor norte oscilando desde o inicio do expediente. '
      'Equipe precisa liberar o espaco antes das 15h.',
  'content': '''
Solicitacao aberta pela equipe administrativa.

-- FORMULARIO DO APP
--------------------------------
Servico: Eletrica
Atendimento para: Para mim
Telefone: (51) 99999-1234
Localizacao: Predio Principal > 2o Andar > Corredor Norte
Urgencia: 4
Tipo: Manutencao
Anexo: 6df4a4cc-768b-43de-95c6-6fe5f6f33a91.jpg
''',
};

final List<MapEntry<String, String>> workbenchDetailRows = [
  const MapEntry('Servico Solicitado', 'Eletrica'),
  const MapEntry('Solicitante', 'jonathan-moletta'),
  const MapEntry('Tecnico Responsavel', 'Equipe Predial 02'),
  const MapEntry('Criado em', '11/04/2026 08:02'),
  const MapEntry('Localizacao', 'Predio Principal > 2o Andar > Corredor Norte'),
  const MapEntry('Telefone', '(51) 99999-1234'),
  MapEntry(
    'Resumo do Atendimento',
    workbenchDetailTicket['content'].toString(),
  ),
];

final List<MapEntry<String, String>> workbenchMetadataRows = [
  const MapEntry('ID do Chamado', '8090'),
  const MapEntry('Assunto', 'Troca de luminaria no corredor norte'),
  const MapEntry('Categoria', 'Predial > Eletrica > Iluminacao'),
  const MapEntry('Urgencia', 'Alta'),
  const MapEntry('Impacto', 'Medio'),
  const MapEntry('Prioridade', 'Alta'),
  const MapEntry('Ultima Atualizacao', '11/04/2026 08:47'),
];

final ServiceCategory workbenchCriticalService = serviceCategories.firstWhere(
  (service) => service.name == 'Eletrica',
);

final ServiceCategory workbenchOperationalService = serviceCategories
    .firstWhere((service) => service.name == 'Carregadores');

final ServiceCategory workbenchFormService = serviceCategories.firstWhere(
  (service) => service.name == 'Vidracaria',
);

class GlpiTicketStatus {
  static const int novoCode = 1;
  static const int emAtendimentoCode = 2;
  static const int planejadoCode = 3;
  static const int pendenteCode = 4;
  static const int solucionadoCode = 5;
  static const int fechadoCode = 6;
}

final List<TicketMessage> workbenchConversationMessages = [
  TicketMessage(
    id: 'm-1',
    ticketId: '8090',
    content:
        'A luminaria voltou a oscilar no inicio da tarde. Precisamos estabilizar antes da reuniao das 15h.',
    sender: 'Jonathan Moletta',
    createdAt: DateTime(2026, 4, 11, 13, 12),
    isPrivate: false,
    senderType: 'user',
  ),
  TicketMessage(
    id: 'm-2',
    ticketId: '8090',
    content:
        'Equipe deslocada para o 2o andar. Vamos validar reator, lampada e conexao no circuito.',
    sender: 'Equipe Predial 02',
    createdAt: DateTime(2026, 4, 11, 13, 28),
    isPrivate: false,
    senderType: 'tech',
  ),
  TicketMessage(
    id: 'doc-3',
    ticketId: '8090',
    content: 'laudo-iluminacao-corredor-norte.pdf',
    sender: 'Equipe Predial 02',
    createdAt: DateTime(2026, 4, 11, 13, 33),
    isPrivate: false,
    senderType: 'tech',
    type: 'attachment',
    mimeType: 'application/pdf',
    documentUrl: 'https://example.invalid/laudo.pdf',
  ),
  TicketMessage(
    id: 'm-4',
    ticketId: '8090',
    content:
        'Conseguem confirmar se a ala sera liberada por completo ou apenas o trecho proximo ao gabinete?',
    sender: 'Jonathan Moletta',
    createdAt: DateTime(2026, 4, 11, 13, 41),
    isPrivate: false,
    senderType: 'user',
  ),
];

final List<TicketMessage> workbenchPendingSolutionMessages = [
  ...workbenchConversationMessages,
  TicketMessage(
    id: 'solution-1',
    ticketId: '8090',
    content:
        'Substituimos o conjunto de lampada e reator, revisamos a fixacao e validamos o circuito energizado. Ambiente liberado.',
    sender: 'Equipe Predial 02',
    createdAt: DateTime(2026, 4, 11, 14, 02),
    isPrivate: false,
    senderType: 'tech',
    type: 'solution',
    solutionStatus: 2,
  ),
];

final List<TicketMessage> workbenchClosedSolutionMessages = [
  ...workbenchConversationMessages,
  TicketMessage(
    id: 'solution-closed-1',
    ticketId: '8090',
    content:
        'Registro historico de solucao mantido no chamado apos encerramento.',
    sender: 'Equipe Predial 02',
    createdAt: DateTime(2026, 4, 11, 14, 18),
    isPrivate: false,
    senderType: 'tech',
    type: 'solution',
    solutionStatus: 4,
  ),
];
