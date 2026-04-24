// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sis_mobile_flutter/main.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';

void main() {
  testWidgets('App initializes MyApp with AppState provider', (
    WidgetTester tester,
  ) async {
    // Mock SharedPreferences antes de instanciar AppState
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AppState(GlpiClient())),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MyApp(),
        ),
      ),
    );

    // Verify that the app loaded without crashing
    expect(find.byType(MyApp), findsOneWidget);
  });
}
