import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/service_catalog_screen.dart';
import 'services/glpi_client.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState(GlpiClient())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'SIS Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: appState.isAuthenticated
          ? const ServiceCatalogScreen()
          : const LoginScreen(),
    );
  }
}
