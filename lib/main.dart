import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'catalog/service_catalog_provider.dart';
import 'screens/login_screen.dart';
import 'screens/service_catalog_screen.dart';
import 'services/glpi_client.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env');
  await dotenv.load(fileName: envFile);
  await initializeServiceCatalogRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState(GlpiClient())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  AppState? _appState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newAppState = Provider.of<AppState>(context, listen: false);
    if (_appState != newAppState) {
      _appState?.removeListener(_onAppStateChanged);
      _appState = newAppState;
      _appState!.addListener(_onAppStateChanged);
    }
  }

  void _onAppStateChanged() {
    if (_appState != null && !_appState!.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      });
    }
  }

  @override
  void dispose() {
    _appState?.removeListener(_onAppStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'SIS Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: appState.isAuthenticated
          ? const ServiceCatalogScreen()
          : const LoginScreen(),
    );
  }
}
