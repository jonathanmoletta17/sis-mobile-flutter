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
};

final List<MapEntry<String, String>> workbenchDetailRows = [
  const MapEntry('ID do Chamado', '8090'),
  const MapEntry('Solicitante', 'jonathan-moletta'),
  const MapEntry('Tecnico Responsavel', 'Equipe Predial 02'),
  const MapEntry('Localizacao', 'Predio Principal > 2o Andar > Corredor Norte'),
  const MapEntry('Telefone', '(51) 99999-1234'),
  const MapEntry('Urgencia', 'Alta'),
  const MapEntry('Impacto', 'Medio'),
  const MapEntry('Prioridade', 'Alta'),
  const MapEntry('Criado em', '11/04/2026 08:02'),
  const MapEntry('Ultima Atualizacao', '11/04/2026 08:47'),
  const MapEntry(
    'Resumo do Formulario',
    'Solicitacao aberta pela equipe administrativa.\n'
        '- Necessidade de atendimento antes da agenda de reunioes.\n'
        '- Risco de escurecimento parcial do corredor.\n'
        '- Validar se ha material em estoque antes do deslocamento.',
  ),
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
