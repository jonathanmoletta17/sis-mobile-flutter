enum GlpiStatus {
  novo(1, 'Novo'),
  emAtendimento(2, 'Em Atendimento'),
  planejado(3, 'Planejado'),
  pendente(4, 'Pendente'),
  solucionado(5, 'Solucionado'),
  fechado(6, 'Fechado');

  const GlpiStatus(this.code, this.label);

  final int code;
  final String label;
}

class GlpiStatusMapper {
  static const String offlineLabel = 'Pendente (Offline)';

  static const List<GlpiStatus> ordered = [
    GlpiStatus.novo,
    GlpiStatus.emAtendimento,
    GlpiStatus.planejado,
    GlpiStatus.pendente,
    GlpiStatus.solucionado,
    GlpiStatus.fechado,
  ];

  static GlpiStatus? tryParse(dynamic rawStatus) {
    if (rawStatus == null) return null;

    if (rawStatus is GlpiStatus) return rawStatus;
    if (rawStatus is int) return _fromCode(rawStatus);

    final raw = rawStatus.toString().trim();
    if (raw.isEmpty) return null;

    final numeric = int.tryParse(raw);
    if (numeric != null) {
      return _fromCode(numeric);
    }

    final normalized = _normalize(raw);

    if (normalized.contains('novo')) return GlpiStatus.novo;
    if (normalized.contains('em atendimento') ||
        normalized.contains('atribuido') ||
        normalized.contains('atendimento')) {
      return GlpiStatus.emAtendimento;
    }
    if (normalized.contains('planejado')) return GlpiStatus.planejado;
    if (normalized.contains('em andamento')) return GlpiStatus.planejado;
    if (normalized.contains('pendente')) return GlpiStatus.pendente;
    if (normalized.contains('solucionado')) return GlpiStatus.solucionado;
    if (normalized.contains('fechado') ||
        normalized.contains('concluido')) {
      return GlpiStatus.fechado;
    }

    return null;
  }

  static int? code(dynamic rawStatus) => tryParse(rawStatus)?.code;

  static String label(dynamic rawStatus, {String fallback = 'Desconhecido'}) {
    if (isOffline(rawStatus)) return offlineLabel;

    final parsed = tryParse(rawStatus);
    if (parsed != null) return parsed.label;

    final raw = rawStatus?.toString().trim() ?? '';
    return raw.isEmpty ? fallback : raw;
  }

  static bool isOffline(dynamic rawStatus) {
    final value = rawStatus?.toString().toLowerCase() ?? '';
    return value.contains('offline');
  }

  static bool isClosed(dynamic rawStatus) {
    return tryParse(rawStatus) == GlpiStatus.fechado;
  }

  static bool isSolved(dynamic rawStatus) {
    return tryParse(rawStatus) == GlpiStatus.solucionado;
  }

  static bool isOpenForInteraction(dynamic rawStatus) {
    if (isOffline(rawStatus)) return true;

    final status = tryParse(rawStatus);
    if (status == null) return true;

    return status != GlpiStatus.solucionado && status != GlpiStatus.fechado;
  }

  static bool canValidateSolution(dynamic rawStatus) {
    if (isOffline(rawStatus)) return false;

    final status = tryParse(rawStatus);
    if (status == null) return false;

    return status == GlpiStatus.solucionado;
  }

  static GlpiStatus? _fromCode(int code) {
    for (final status in ordered) {
      if (status.code == code) return status;
    }
    return null;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }
}
