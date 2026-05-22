import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sis_mobile_flutter/services/glpi_client_support.dart';

void main() {
  group('GlpiClientSupport user-facing errors', () {
    test('maps GLPI invalid login to clean human message', () {
      final failure = GlpiClientSupport.mapAuthenticationFailure(
        Exception('HTTP 401'),
        statusCode: 401,
        body: '["ERROR_GLPI_LOGIN","Nome de usuário ou senha inválidos"]',
      );

      expect(
        failure.userMessage,
        'Falha na autenticacao: Nome de usuário ou senha inválidos',
      );
      expect(failure.userMessage, isNot(contains('Exception:')));
      expect(failure.userMessage, isNot(contains('Ã')));
      expect(failure.detail, contains('AUTH_INVALID_CREDENTIALS'));
    });

    test(
      'classifies right-missing 403 as permission denied, not expired session',
      () {
        final exception = GlpiClientSupport.authException(
          http.Response(
            '["ERROR_RIGHT_MISSING","Você não tem permissão para executar essa ação."]',
            403,
          ),
        );

        expect(exception.toString(), contains('GLPI_PERMISSION_DENIED'));
        expect(
          exception.toString(),
          isNot(contains('SESSION_INVALID_OR_EXPIRED')),
        );
        expect(
          GlpiClientSupport.isPermissionDeniedException(exception),
          isTrue,
        );
        expect(GlpiClientSupport.isSessionInvalidException(exception), isFalse);
      },
    );
    test('generic auth failure never exposes raw technical detail to UI', () {
      final failure = GlpiClientSupport.mapAuthenticationFailure(
        Exception('ÃƒÆ’bad raw transport detail'),
      );

      expect(
        failure.userMessage,
        'Falha ao autenticar. Verifique os dados informados e tente novamente.',
      );
      expect(failure.userMessage, isNot(contains('Exception')));
      expect(failure.userMessage, isNot(contains('Ã')));
    });
  });
}
