import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widgets/ui/sis_loading_state.dart';
import 'screens/dtic_catalog_screen.dart';
import 'screens/dtic_login_screen.dart';
import 'services/dtic_glpi_client.dart';
import 'state/dtic_app_state.dart';

class DticMobileApp extends StatelessWidget {
  const DticMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DticAppState(DticGlpiClient())..restoreSession(),
      child: Consumer<DticAppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'DTIC Mobile',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.build(),
            home: state.isRestoringSession
                ? const _DticStartupScreen()
                : state.isAuthenticated
                ? const DticCatalogScreen()
                : const DticLoginScreen(),
          );
        },
      ),
    );
  }
}

class _DticStartupScreen extends StatelessWidget {
  const _DticStartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SisLoadingState(
          title: 'Validando sessao DTIC',
          message: 'Restaurando acesso do usuario logado.',
        ),
      ),
    );
  }
}
