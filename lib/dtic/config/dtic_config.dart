import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DticConfig {
  static String get baseUrl {
    final url =
        dotenv.env['DTIC_GLPI_BASE_URL'] ?? dotenv.env['GLPI_BASE_URL'] ?? '';
    if (url.isEmpty) {
      debugPrint(
        'AVISO: DTIC_GLPI_BASE_URL/GLPI_BASE_URL nao esta configurada no .env',
      );
      return url;
    }

    final normalized = url.trim();
    if (_looksLikeSisEndpoint(normalized)) {
      throw Exception(
        'Configuracao invalida: app DTIC apontando para endpoint SIS. '
        'Use DTIC_GLPI_BASE_URL com o Worker DTIC ou /glpi/apirest.php.',
      );
    }

    if (_looksLikeDirectInternalGlpi(normalized)) {
      debugPrint(
        'AVISO: DTIC esta apontando diretamente para o GLPI interno. '
        'Para uso fora do dominio, use o Worker DTIC.',
      );
    }

    return normalized;
  }

  static bool get debugLogging {
    final raw = dotenv.env['GLPI_DEBUG_LOGS'];
    if (raw == null || raw.isEmpty) {
      return kDebugMode;
    }
    final normalized = raw.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static bool get formSubmissionEnabled {
    final raw = dotenv.env['DTIC_ENABLE_FORM_SUBMISSION'];
    if (raw == null || raw.isEmpty) return false;
    final normalized = raw.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static bool get ticketActionsEnabled {
    final raw = dotenv.env['DTIC_ENABLE_TICKET_ACTIONS'];
    if (raw == null || raw.isEmpty) return false;
    final normalized = raw.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static const Duration requestTimeout = Duration(seconds: 30);

  static bool _looksLikeSisEndpoint(String url) {
    final lower = url.toLowerCase();
    return lower.contains('sis-glpi') ||
        lower.contains('/sis/apirest.php') ||
        lower.contains('cau.ppiratini.intra.rs.gov.br/sis');
  }

  static bool _looksLikeDirectInternalGlpi(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith('http://cau.ppiratini.intra.rs.gov.br/glpi') ||
        lower.startsWith('https://cau.ppiratini.intra.rs.gov.br/glpi');
  }
}
