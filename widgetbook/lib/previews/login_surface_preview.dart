import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';
import 'package:sis_mobile_flutter/widgets/ui/glpi_login_surface.dart';

import '../workbench_surface.dart';

enum LoginSurfaceVariant { idle, loading, validation, failure }

class LoginSurfacePreview extends StatelessWidget {
  final LoginSurfaceVariant variant;

  const LoginSurfacePreview({super.key, required this.variant});

  bool get _showValidation => variant == LoginSurfaceVariant.validation;
  bool get _showFailure => variant == LoginSurfaceVariant.failure;
  bool get _showLoading => variant == LoginSurfaceVariant.loading;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: GlpiLoginSurface(
        badge: 'GLPI SIS',
        title: 'Acesse o atendimento operacional',
        description:
            'Entre com sua conta GLPI para consultar chamados, interagir com conversas e abrir novas solicitacoes.',
        footer: 'Autenticacao segura via GLPI SIS',
        brandMark: Image.asset(
          'packages/sis_mobile_flutter/assets/images/logo.png',
          height: 108,
          fit: BoxFit.contain,
          semanticLabel: 'SIS',
        ),
        children: [
          TextFormField(
            initialValue: _showValidation || _showLoading || _showFailure
                ? 'jonathan.moletta'
                : '',
            decoration: InputDecoration(
              labelText: 'Usuario GLPI',
              prefixIcon: const Icon(Icons.person_outline),
              errorText: _showValidation
                  ? 'O nome de usuario e obrigatorio'
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: _showLoading || _showFailure ? 'secret' : '',
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              errorText: _showValidation ? 'A senha e obrigatoria' : null,
            ),
          ),
          if (_showFailure) ...[
            const SizedBox(height: AppSpacing.md),
            const GlpiLoginInlineNotice(
              message:
                  'Falha na autenticacao. Verifique usuario, senha e conectividade com o GLPI.',
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {},
            child: _showLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Entrar'),
          ),
        ],
      ),
    );
  }
}
