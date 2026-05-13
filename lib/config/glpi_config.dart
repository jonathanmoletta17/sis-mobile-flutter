import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GlpiConfig {
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

  /// Endpoint de autenticação
  static String get initSessionEndpoint => '$baseUrl/initSession';

  /// Endpoint para encerrar sessão
  static String get killSessionEndpoint => '$baseUrl/killSession';

  /// Endpoint de categorias ITIL
  static String get itilCategoryEndpoint => '$baseUrl/ITILCategory';

  /// Endpoint de tickets
  static String get ticketEndpoint => '$baseUrl/Ticket';

  static bool _looksLikeDticEndpoint(String url) {
    final lower = url.toLowerCase();
    return lower.contains('dtic-glpi') ||
        lower.contains('/glpi/apirest.php') ||
        lower.contains('cau.ppiratini.intra.rs.gov.br/glpi');
  }
}
