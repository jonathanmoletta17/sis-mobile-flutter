import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../services/glpi_client_support.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/ui/glpi_login_surface.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _didAttemptDebugAutoLogin = false;

  static const String _debugUser = String.fromEnvironment('SIS_E2E_USER');
  static const String _debugPassword = String.fromEnvironment(
    'SIS_E2E_PASSWORD',
  );

  @override
  void initState() {
    super.initState();
    _maybeRunDebugAutoLogin();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      final success = await appState.authenticate(
        _userController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha na autenticação. Verifique usuário e senha.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      final message = e is GlpiAuthFailure
          ? e.userMessage
          : 'Erro ao autenticar. Verifique os dados informados e tente novamente.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.danger),
      );
    }
  }

  void _maybeRunDebugAutoLogin() {
    if (!kDebugMode || _didAttemptDebugAutoLogin) return;
    if (_debugUser.isEmpty || _debugPassword.isEmpty) return;

    _didAttemptDebugAutoLogin = true;
    _userController.text = _debugUser;
    _passwordController.text = _debugPassword;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleLogin();
    });
  }

  bool get _labPreviewEnabled =>
      (dotenv.maybeGet('SIS_LAB_PREVIEW') ?? '').toLowerCase() == 'true';

  void _activateLabProfile({
    required String username,
    required String profile,
    required int activeEntityId,
    required String activeEntityName,
    int? selectedTicketEntityId,
    String? selectedTicketEntityName,
  }) {
    Provider.of<AppState>(context, listen: false).activateLabPreviewSession(
      username: username,
      profile: profile,
      activeEntityId: activeEntityId,
      activeEntityName: activeEntityName,
      selectedTicketEntityId: selectedTicketEntityId,
      selectedTicketEntityName: selectedTicketEntityName,
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlpiLoginSurface(
        badge: 'GLPI SIS',
        title: 'Acesse o atendimento operacional',
        description:
            'Entre com sua conta GLPI para consultar chamados, interagir com conversas e abrir novas solicitações.',
        footer: 'Autenticação segura via GLPI SIS',
        brandMark: Image.asset(
          'assets/images/logo.png',
          height: 108,
          fit: BoxFit.contain,
          semanticLabel: 'SIS',
          cacheWidth: 324,
          cacheHeight: 236,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O nome de usuário é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _handleLogin();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A senha é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
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
                if (_labPreviewEnabled) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'LAB preview: simular perfil sem criar chamado',
                    style: Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () => _activateLabProfile(
                      username: 'lab-solicitante',
                      profile: 'Solicitante',
                      activeEntityId: 28,
                      activeEntityName:
                          'Origem > PIRATINI > CASA CIVIL > Secretaria-Executiva > Subchefia Administrativa > Departamento de Tecnologia e Informação',
                    ),
                    child: const Text('LAB · Solicitante DTIC'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  OutlinedButton(
                    onPressed: () => _activateLabProfile(
                      username: 'lab-manutencao',
                      profile: 'Manutenção e Conservação',
                      activeEntityId: 1,
                      activeEntityName: 'Origem > PIRATINI',
                      selectedTicketEntityId: 1,
                      selectedTicketEntityName: 'Origem > PIRATINI',
                    ),
                    child: const Text('LAB · Manutenção e Conservação'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  OutlinedButton(
                    onPressed: () => _activateLabProfile(
                      username: 'lab-gg-conservacao',
                      profile: 'Solicitante-GG-Conservação',
                      activeEntityId: 58,
                      activeEntityName: 'Origem > PIRATINI > GG Conservação',
                      selectedTicketEntityId: 58,
                      selectedTicketEntityName:
                          'Origem > PIRATINI > GG Conservação',
                    ),
                    child: const Text('LAB · Solicitante-GG-Conservação'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
