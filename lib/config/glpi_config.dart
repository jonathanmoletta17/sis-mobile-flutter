import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GlpiConfig {
  /// URL base da API GLPI (com /apirest.php incluído)
  static String get baseUrl {
    final url = dotenv.env['GLPI_BASE_URL'] ?? '';
    if (url.isEmpty) {
      debugPrint('AVISO: GLPI_BASE_URL nao esta configurada no .env');
    }
    return url;
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
}
