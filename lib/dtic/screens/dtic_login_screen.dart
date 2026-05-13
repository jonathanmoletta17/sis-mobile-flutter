import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_spacing.dart';
import '../../widgets/ui/glpi_login_surface.dart';
import '../state/dtic_app_state.dart';

class DticLoginScreen extends StatefulWidget {
  const DticLoginScreen({super.key});

  @override
  State<DticLoginScreen> createState() => _DticLoginScreenState();
}

class _DticLoginScreenState extends State<DticLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<DticAppState>();
    await state.authenticate(
      _usernameController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DticAppState>();

    return Scaffold(
      body: GlpiLoginSurface(
        badge: 'GLPI DTIC',
        title: 'DTIC Mobile',
        description:
            'Acesse o atendimento DTIC com seu usuario de rede e senha do GLPI.',
        footer: 'Autenticacao segura via GLPI DTIC',
        brandMark: const GlpiLoginBrandIcon(icon: Icons.verified_user_outlined),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Usuario de rede',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o usuario.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Mostrar senha'
                          : 'Ocultar senha',
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a senha.';
                    }
                    return null;
                  },
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  GlpiLoginInlineNotice(message: state.errorMessage!),
                ],
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: state.isBusy ? null : _submit,
                  icon: state.isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(state.isBusy ? 'Entrando...' : 'Entrar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
