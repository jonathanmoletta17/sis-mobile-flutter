import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dtic/dtic_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env');
  await dotenv.load(fileName: envFile);
  runApp(const DticMobileApp());
}
