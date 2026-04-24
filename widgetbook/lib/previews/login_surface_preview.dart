import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_radius.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';

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
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.brandDark, AppColors.brand, AppColors.background],
            stops: [0, 0.36, 0.36],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -30,
              child: _DecorativeOrb(
                size: 180,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              top: 120,
              left: -40,
              child: _DecorativeOrb(
                size: 120,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          'GLPI SIS',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.brandDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: 96,
                        height: 96,
                        margin: const EdgeInsets.symmetric(horizontal: 96),
                        decoration: BoxDecoration(
                          color: AppColors.brandSoft,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          size: 52,
                          color: AppColors.brandDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Acesse o atendimento operacional',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Entre com sua conta GLPI para consultar chamados, interagir com conversas e abrir novas solicitacoes.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.danger,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Falha na autenticacao. Verifique usuario, senha e conectividade com o GLPI.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
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
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Autenticacao segura via GLPI SIS',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
