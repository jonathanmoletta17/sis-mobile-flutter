import '../../models/glpi_status.dart';
import '../utils/dtic_text.dart';

class DticTicketSummary {
  const DticTicketSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.openedAt,
    required this.updatedAt,
    required this.category,
    required this.requester,
  });

  final String id;
  final String title;
  final String status;
  final String openedAt;
  final String updatedAt;
  final String category;
  final String requester;

  String get statusLabel => GlpiStatusMapper.label(status);

  factory DticTicketSummary.fromSearchRow(Map<String, dynamic> row) {
    final data = row['data'] is Map
        ? Map<String, dynamic>.from(row['data'] as Map)
        : row;
    return DticTicketSummary(
      id: _readAny(data, const ['2', 'id', 'ID']),
      title: _readAny(data, const ['1', 'name', 'Titulo'], fallback: 'Chamado'),
      status: _readAny(data, const ['12', 'status'], fallback: 'Status'),
      openedAt: _readAny(data, const ['15', 'date'], fallback: ''),
      updatedAt: _readAny(data, const ['19', 'date_mod'], fallback: ''),
      requester: _readAny(data, const ['4', 'requester'], fallback: ''),
      category: _readAny(data, const ['7', 'category'], fallback: ''),
    );
  }
}

class DticTicketDetail {
  const DticTicketDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.date,
    required this.dateMod,
    required this.category,
    required this.requester,
  });

  final String id;
  final String title;
  final String content;
  final String status;
  final String date;
  final String dateMod;
  final String category;
  final String requester;

  String get statusLabel => GlpiStatusMapper.label(status);

  factory DticTicketDetail.fromJson(Map<String, dynamic> json) {
    return DticTicketDetail(
      id: _readAny(json, const ['id']),
      title: _readAny(json, const ['name'], fallback: 'Chamado'),
      content: DticText.stripHtml(_readAny(json, const ['content'])),
      status: _readAny(json, const ['status'], fallback: 'Status'),
      date: _readAny(json, const ['date']),
      dateMod: _readAny(json, const ['date_mod']),
      category: _readAny(json, const ['itilcategories_id']),
      requester: _readAny(json, const ['users_id_recipient']),
    );
  }
}

class DticTicketInteraction {
  const DticTicketInteraction({
    required this.id,
    required this.kind,
    required this.content,
    required this.date,
    required this.author,
  });

  final String id;
  final String kind;
  final String content;
  final String date;
  final String author;

  factory DticTicketInteraction.followup(Map<String, dynamic> json) {
    return DticTicketInteraction(
      id: _readAny(json, const ['id']),
      kind: 'Mensagem',
      content: DticText.stripHtml(_readAny(json, const ['content'])),
      date: _readAny(json, const ['date_creation', 'date']),
      author: _readAny(json, const ['users_id'], fallback: ''),
    );
  }

  factory DticTicketInteraction.solution(Map<String, dynamic> json) {
    return DticTicketInteraction(
      id: _readAny(json, const ['id']),
      kind: 'Solucao',
      content: DticText.stripHtml(_readAny(json, const ['content'])),
      date: _readAny(json, const ['date_creation', 'date']),
      author: _readAny(json, const ['users_id'], fallback: ''),
    );
  }
}

class DticTicketDocument {
  const DticTicketDocument({
    required this.id,
    required this.name,
    required this.mime,
    required this.downloadPath,
    required this.contextKind,
    required this.contextId,
    required this.date,
  });

  final String id;
  final String name;
  final String mime;
  final String downloadPath;
  final String contextKind;
  final String contextId;
  final String date;

  String get contextLabel {
    return switch (contextKind) {
      'followup' => 'Anexo de mensagem',
      'solution' => 'Anexo de solucao',
      _ => 'Anexo do chamado',
    };
  }

  factory DticTicketDocument.fromJson(Map<String, dynamic> json) {
    return DticTicketDocument(
      id: _readAny(json, const ['id', 'documents_id']),
      name: _readAny(json, const ['filename', 'name'], fallback: 'Anexo'),
      mime: _readAny(json, const ['mime'], fallback: ''),
      downloadPath: _readAny(json, const ['download_path']),
      contextKind: _readAny(json, const ['context_kind'], fallback: 'ticket'),
      contextId: _readAny(json, const ['context_id', 'items_id']),
      date: _readAny(json, const ['date_creation', 'date_mod']),
    );
  }
}

String _readAny(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = DticText.cleanPlainText(value);
    if (text.isNotEmpty) return text;
  }
  return fallback;
}
