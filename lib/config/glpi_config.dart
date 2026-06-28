import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GlpiConfig {
  static const String _checklistSubmissionDefine = String.fromEnvironment(
    'SIS_ENABLE_CHECKLISTS_SUBMISSION',
  );
  static const String _checklistTicketNamePrefixDefine = String.fromEnvironment(
    'SIS_CHECKLIST_TICKET_NAME_PREFIX',
  );

  /// URL base da API GLPI (com /apirest.php incluído)
  static String get baseUrl {
    final url =
        dotenv.env['SIS_GLPI_BASE_URL'] ?? dotenv.env['GLPI_BASE_URL'] ?? '';
    if (url.isEmpty) {
      debugPrint(
        'AVISO: SIS_GLPI_BASE_URL/GLPI_BASE_URL nao esta configurada no .env',
      );
      return url;
    }

    final normalized = url.trim();
    if (_looksLikeDticEndpoint(normalized)) {
      throw Exception(
        'Configuracao invalida: app SIS apontando para endpoint DTIC. '
        'Use SIS_GLPI_BASE_URL ou GLPI_BASE_URL com /sis/apirest.php.',
      );
    }

    return normalized;
  }

  static const Duration requestTimeout = Duration(seconds: 30);

  /// Habilitar logs detalhados
  static bool get debugLogging {
    final raw = dotenv.env['GLPI_DEBUG_LOGS'];
    if (raw == null || raw.isEmpty) {
      return kDebugMode;
    }

    final normalized = raw.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static bool _looksLikeDticEndpoint(String url) {
    final lower = url.toLowerCase();
    return lower.contains('dtic-glpi') ||
        lower.contains('/glpi/apirest.php') ||
        lower.contains('cau.ppiratini.intra.rs.gov.br/glpi');
  }

  // --- Checklists SIS (FormCreator) ---

  /// Habilita o caminho de submissao FormCreator de checklist no app.
  /// Default desligado; so executa de fato quando o Worker tambem permite
  /// (`ALLOW_FORMCREATOR_SUBMISSION=true` no Worker) e em ambiente autorizado.
  static bool get sisChecklistSubmissionEnabled =>
      _flag('SIS_ENABLE_CHECKLISTS_SUBMISSION') ||
      _isTruthy(_checklistSubmissionDefine);

  /// Prefixo opcional para rodadas mutaveis de validacao. Em producao fica
  /// vazio; em teste controlado pode ser `[TESTE-AUTOMATIZADO SIS]`.
  static String get sisChecklistTicketNamePrefix {
    final raw =
        _env('SIS_CHECKLIST_TICKET_NAME_PREFIX') ??
        _checklistTicketNamePrefixDefine;
    return raw.trim();
  }

  static String? _env(String key) {
    if (!dotenv.isInitialized) return null;
    return dotenv.maybeGet(key);
  }

  static bool _flag(String key) {
    final raw = _env(key);
    if (raw == null) return false;
    return _isTruthy(raw);
  }

  static bool _isTruthy(String raw) {
    final normalized = raw.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}
